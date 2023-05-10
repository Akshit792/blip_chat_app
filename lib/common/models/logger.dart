import 'package:logger/logger.dart';

class LogPrint {
  static info({required String infoMsg}) {
    Logger().i(infoMsg);
  }

  static warning(
      {required dynamic error,
      required String warningMsg,
      required StackTrace stackTrace}) {
    Logger().w('$warningMsg $error $stackTrace');
  }

  static error(
      {required dynamic error,
      required String errorMsg,
      required StackTrace stackTrace}) {
    Logger().i('$errorMsg $error $stackTrace');
  }
}
