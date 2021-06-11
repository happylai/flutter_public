import 'package:fish_redux/fish_redux.dart';

import 'effect.dart';
import 'reducer.dart';
import 'state.dart';
import 'view.dart';

class PrinterSettingPage
    extends Page<PrinterSettingState, Map<String, dynamic>> {
  PrinterSettingPage()
      : super(
          initState: initState,
          effect: buildEffect(),
          reducer: buildReducer(),
          view: buildView,
          dependencies: Dependencies<PrinterSettingState>(
              adapter: null, slots: <String, Dependent<PrinterSettingState>>{}),
          middleware: <Middleware<PrinterSettingState>>[],
        );
}
