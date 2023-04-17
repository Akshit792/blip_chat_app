import 'package:logger/logger.dart';

class LogPrint {
  static info({required String infoMsg}) {
    Logger().i(infoMsg);
  }

  static warning({required String warningMsg}) {
    Logger().w(warningMsg);
  }

  static error({required String errorMsg}) {
    Logger().i(errorMsg);
  }
}
