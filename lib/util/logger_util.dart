import 'package:logger/logger.dart';

class LoggerUtil {
  static final LoggerUtil _instance = LoggerUtil._internal();
  static LoggerUtil get instance => _instance;

  late final Logger _logger;

  LoggerUtil._internal() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 5,
        lineLength: 80,
        colors: true,
        printEmojis: true,
      ),
    );
  }

  void d(dynamic message) => _logger.d(message);
  void i(dynamic message) => _logger.i(message);
  void w(dynamic message) => _logger.w(message);
  void e(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
}
