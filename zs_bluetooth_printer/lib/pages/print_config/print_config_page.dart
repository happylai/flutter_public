import 'package:fish_redux/fish_redux.dart';

import 'print_config_effect.dart';
import 'print_config_reducer.dart';
import 'print_config_state.dart';
import 'print_config_view.dart';

class PrintConfigPage extends Page<PrintConfigState, Map<String, dynamic>> {
  PrintConfigPage()
      : super(
            initState: initState,
            effect: buildEffect(),
            reducer: buildReducer(),
            view: buildView,
            dependencies: Dependencies<PrintConfigState>(
                adapter: null,
                slots: <String, Dependent<PrintConfigState>>{
                }),
            middleware: <Middleware<PrintConfigState>>[
            ],);

}
