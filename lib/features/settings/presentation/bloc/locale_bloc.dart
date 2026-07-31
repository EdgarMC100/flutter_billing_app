import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/locale_repository.dart';
import 'locale_event.dart';
import 'locale_state.dart';

class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  final LocaleRepository repository;

  LocaleBloc({required this.repository}) : super(const LocaleState()) {
    on<InitLocaleEvent>(_onInit);
    on<ChangeLocaleEvent>(_onChange);
  }

  void _onInit(InitLocaleEvent event, Emitter<LocaleState> emit) {
    final code = repository.getSavedLanguageCode();
    emit(state.copyWith(locale: Locale(code)));
  }

  Future<void> _onChange(
      ChangeLocaleEvent event, Emitter<LocaleState> emit) async {
    await repository.saveLanguageCode(event.languageCode);
    emit(state.copyWith(locale: Locale(event.languageCode)));
  }
}
