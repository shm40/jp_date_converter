import 'package:jp_date_converter/jp_date_converter.dart';

void main() {
  final date = DateTime(1989, 1, 8);
  final wrk = srkToWrk(date);
  print(wrk);
}
