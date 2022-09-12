import 'package:intl/intl.dart';

class AppFormats {
  AppFormats._internal();

  static DateFormat formatDate = DateFormat('EEE dd MMM yyyy', 'vi_VN');

  static DateFormat formatTime = DateFormat('HH:mm');
}
