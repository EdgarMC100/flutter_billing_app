import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/printer_repository.dart';
import 'printer_event.dart';
import 'printer_state.dart';

/// Stable codes emitted as [PrinterState.errorMessage] so the presentation
/// layer (which has a `BuildContext`) can resolve them to a localized
/// string. The bloc has no `BuildContext`, so it cannot call
/// `AppLocalizations` directly. Raw exception text (via `e.toString()`)
/// bypasses this and is shown untranslated, same as elsewhere in the app.
abstract class PrinterMessageCode {
  static const noPairedDevices = 'printer_no_paired_devices';
  static const noDeviceConnectable = 'printer_no_device_connectable';
  static const connectionFailed = 'printer_connection_failed';
}

class PrinterBloc extends Bloc<PrinterEvent, PrinterState> {
  final PrinterRepository repository;

  // A connect() attempt can block for several seconds (OS-level socket
  // timeout) when the printer/Bluetooth radio is unreachable. Guards against
  // a slow attempt overlapping with the next periodic tick.
  bool _connectionCheckInFlight = false;

  PrinterBloc({required this.repository}) : super(const PrinterState()) {
    on<InitPrinterEvent>(_onInit);
    on<RefreshPrinterEvent>(_onRefresh);
    on<CheckConnectionEvent>(_onCheckConnection);
    on<ScanPrintersEvent>(_onScan);
    on<ConnectPrinterEvent>(_onConnect);
    on<DisconnectPrinterEvent>(_onDisconnect);
    on<TestPrintEvent>(_onTestPrint);
  }

  Future<void> _onInit(
      InitPrinterEvent event, Emitter<PrinterState> emit) async {
    final mac = repository.getSavedPrinterMac();
    final name = repository.getSavedPrinterName();
    if (mac == null) {
      emit(state.copyWith(
        status: PrinterStatus.initial,
        connectedMac: null,
        connectedName: null,
      ));
      return;
    }

    // A saved MAC only means the printer was reachable last time we
    // connected to it — verify it's actually live now (e.g. still powered
    // on) rather than trusting the persisted value forever.
    final live = await repository.checkLiveConnection();
    emit(state.copyWith(
      status: live ? PrinterStatus.connected : PrinterStatus.disconnected,
      connectedMac: mac,
      connectedName: name,
    ));
  }

  Future<void> _onCheckConnection(
      CheckConnectionEvent event, Emitter<PrinterState> emit) async {
    // Don't clobber an in-flight scan/connect/print with a stale result.
    const busyStates = {
      PrinterStatus.scanning,
      PrinterStatus.connecting,
      PrinterStatus.testPrinting,
    };
    final mac = state.connectedMac;
    if (mac == null ||
        busyStates.contains(state.status) ||
        _connectionCheckInFlight) {
      return;
    }

    _connectionCheckInFlight = true;
    try {
      if (state.status == PrinterStatus.connected) {
        final live = await repository.checkLiveConnection();
        if (!live) {
          emit(state.copyWith(status: PrinterStatus.disconnected));
        }
        return;
      }

      // Currently disconnected: a plain status check can't recover the
      // connection once the underlying socket has died, so silently retry
      // connecting to the saved MAC. This is what picks it back up when the
      // printer is powered back on, or the phone's Bluetooth radio is
      // re-enabled, without the user needing to tap Refresh.
      final reconnected = await repository.connect(mac);
      if (reconnected) {
        emit(state.copyWith(status: PrinterStatus.connected, clearError: true));
      }
    } finally {
      _connectionCheckInFlight = false;
    }
  }

  Future<void> _onRefresh(
      RefreshPrinterEvent event, Emitter<PrinterState> emit) async {
    emit(state.copyWith(status: PrinterStatus.scanning, clearError: true));
    try {
      final devices = await repository.scanDevices();
      if (devices.isEmpty) {
        emit(state.copyWith(
          status: PrinterStatus.scanFailure,
          errorMessage: PrinterMessageCode.noPairedDevices,
          devices: [],
        ));
        return;
      }

      bool connected = false;
      for (var device in devices) {
        final success = await repository.connect(device.macAdress);
        if (success) {
          await repository.savePrinterData(device.macAdress, device.name);
          emit(state.copyWith(
            status: PrinterStatus.connected,
            connectedMac: device.macAdress,
            connectedName: device.name,
            devices: devices,
            clearError: true,
          ));
          connected = true;
          break;
        }
      }

      if (!connected) {
        emit(state.copyWith(
          status: PrinterStatus.scanFailure,
          errorMessage: PrinterMessageCode.noDeviceConnectable,
          devices: devices,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: PrinterStatus.scanFailure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onScan(
      ScanPrintersEvent event, Emitter<PrinterState> emit) async {
    emit(state.copyWith(status: PrinterStatus.scanning, clearError: true));
    try {
      final devices = await repository.scanDevices();
      emit(state.copyWith(
        status: PrinterStatus.scanSuccess,
        devices: devices,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PrinterStatus.scanFailure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onConnect(
      ConnectPrinterEvent event, Emitter<PrinterState> emit) async {
    emit(state.copyWith(status: PrinterStatus.connecting, clearError: true));
    final success = await repository.connect(event.mac);
    if (success) {
      await repository.savePrinterData(event.mac, event.name);
      emit(state.copyWith(
        status: PrinterStatus.connected,
        connectedMac: event.mac,
        connectedName: event.name,
      ));
    } else {
      emit(state.copyWith(
        status: PrinterStatus.connectionFailure,
        errorMessage: PrinterMessageCode.connectionFailed,
      ));
    }
  }

  Future<void> _onDisconnect(
      DisconnectPrinterEvent event, Emitter<PrinterState> emit) async {
    await repository.disconnect();
    await repository.clearPrinterData();
    emit(PrinterState(
      status: PrinterStatus.disconnected,
      devices: state.devices,
    ));
  }

  Future<void> _onTestPrint(
      TestPrintEvent event, Emitter<PrinterState> emit) async {
    emit(state.copyWith(status: PrinterStatus.testPrinting));
    await repository.testPrint(event.shopName);
    emit(state.copyWith(status: PrinterStatus.scanSuccess));
  }
}
