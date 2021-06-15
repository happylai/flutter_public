import 'package:fish_redux/fish_redux.dart';
import 'package:zs_bluetooth_printer/template/print_template_list.dart';

//TODO replace with your own action
enum PrintConfigAction {
  action,
  onTapPrintChoose,
  onTapPrintListItem,
  updateCurrentPrintTemplate,
  changePrinterName,
  onBack,
}

class PrintConfigActionCreator {
  static Action onAction() {
    return const Action(PrintConfigAction.action);
  }

  static Action onBack() {
    return const Action(PrintConfigAction.onBack);
  }

  static Action onTapPrintChoose() {
    return Action(PrintConfigAction.onTapPrintChoose);
  }
  static Action onTapPrintListItem(PrintTemplateList temp) {
    return Action(PrintConfigAction.onTapPrintListItem, payload: temp);
  }

  static Action updateCurrentPrintTemplate(PrintTemplateList temp) {
    return Action(PrintConfigAction.updateCurrentPrintTemplate, payload: temp);
  }

  static Action changePrinterName(String string) {
    return Action(PrintConfigAction.changePrinterName, payload: string);
  }
}
