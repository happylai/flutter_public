import 'package:fish_redux/fish_redux.dart';

import 'print_config_action.dart';
import 'print_config_state.dart';

Reducer<PrintConfigState> buildReducer() {
  return asReducer(
    <Object, Reducer<PrintConfigState>>{
      PrintConfigAction.action: _onAction,
      PrintConfigAction.updateCurrentPrintTemplate: _updateCurrentPrintTemplate,
      PrintConfigAction.changePrinterName: _changePrinterName,
    },
  );
}

PrintConfigState _onAction(PrintConfigState state, Action action) {
  final PrintConfigState newState = state.clone();
  return newState;
}

PrintConfigState _updateCurrentPrintTemplate(PrintConfigState state, Action action) {
  final PrintConfigState newState = state.clone();
  newState.currentPrintTemplate = action.payload;
  return newState;
}

PrintConfigState _changePrinterName(PrintConfigState state, Action action) {
  final PrintConfigState newState = state.clone();
  newState.printerName = action.payload;
  return newState;
}
