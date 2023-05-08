import 'dart:convert';

class WrkType {
  /// 明治
  static const meiji = 1;

  /// 大正
  static const taisho = 2;

  /// 昭和
  static const showa = 3;

  /// 平成
  static const heisei = 4;

  /// 令和
  static const reiwa = 5;

  static String wrkName(int wrkType) {
    switch (wrkType) {
      case 1:
        return '明治';
      case 2:
        return '大正';
      case 3:
        return '昭和';
      case 4:
        return '平成';
      case 5:
        return '令和';
      default:
        throw Exception('不正な`wrkType`です');
    }
  }
}

class WrkDate {
  final int wrkType;
  final String wrkName;
  final DateTime date;

  const WrkDate(this.wrkType, this.wrkName, this.date);

  @override
  String toString() {
    return jsonEncode({
      'wrkType': wrkType,
      'wrkName': wrkName,
      'date': '${date.year}年${date.month}月${date.day}日',
    });
  }
}

/// 西暦表記の日付を和暦表記に変換し、`WrkDate`クラスを返却
///
/// 明治以降のみの過去に対応
WrkDate srkToWrk(DateTime? dateTime) {
  if (dateTime == null) {
    throw Exception('`date`には日付を設定してください');
  }

  final inputDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
  final inputYear = inputDate.year;
  final inputMonth = inputDate.month;
  final inputDay = inputDate.day;

  // 各元号の始まりと終わり
  final meijiStartDate = DateTime(1868, 1, 25);
  final meijiEndDate = DateTime(1912, 7, 29);
  final taishoStartDate = meijiEndDate.add(Duration(days: 1));
  final taishoEndDate = DateTime(1926, 12, 24);
  final showaStartDate = taishoEndDate.add(Duration(days: 1));
  final showaEndDate = DateTime(1989, 1, 7);
  final heiseiStartDate = showaEndDate.add(Duration(days: 1));
  final heiseiEndDate = DateTime(2019, 4, 30);
  final reiwaStartDate = heiseiEndDate.add(Duration(days: 1));

  if (inputDate.isBefore(meijiStartDate)) {
    throw Exception('$meijiStartDate以降の日付を設定してください。');
  }

  if (inputDate.isAfter(DateTime.now().today)) {
    throw Exception('`date`には未来の日付を設定することはできません');
  }

  // 明治
  if (inputDate.isBetween(meijiStartDate, meijiEndDate)) {
    final wrkType = WrkType.meiji;
    return WrkDate(
      wrkType,
      WrkType.wrkName(wrkType),
      DateTime(inputYear - meijiStartDate.year + 1, inputMonth, inputDay),
    );
  }

  // 大正
  if (inputDate.isBetween(taishoStartDate, taishoEndDate)) {
    final wrkType = WrkType.taisho;
    return WrkDate(
      wrkType,
      WrkType.wrkName(wrkType),
      DateTime(inputYear - taishoStartDate.year + 1, inputMonth, inputDay),
    );
  }

  // 昭和
  if (inputDate.isBetween(showaStartDate, showaEndDate)) {
    final wrkType = WrkType.showa;
    return WrkDate(
      wrkType,
      WrkType.wrkName(wrkType),
      DateTime(inputYear - showaStartDate.year + 1, inputMonth, inputDay),
    );
  }

  // 平成
  if (inputDate.isBetween(heiseiStartDate, heiseiEndDate)) {
    final wrkType = WrkType.heisei;
    return WrkDate(
      wrkType,
      WrkType.wrkName(wrkType),
      DateTime(inputYear - heiseiStartDate.year + 1, inputMonth, inputDay),
    );
  }

  // 令和
  final wrkType = WrkType.reiwa;
  return WrkDate(
    wrkType,
    WrkType.wrkName(wrkType),
    DateTime(inputYear - reiwaStartDate.year + 1, inputMonth, inputDay),
  );
}

/// 和暦日付を西暦に変換
String wrkToSrk(WrkDate wrkDate) {
  final int startYear;
  switch (wrkDate.wrkType) {
    case WrkType.meiji:
      startYear = 1868;
      break;
    case WrkType.taisho:
      startYear = 1912;
      break;
    case WrkType.showa:
      startYear = 1926;
      break;
    case WrkType.heisei:
      startYear = 1989;
      break;
    case WrkType.reiwa:
      startYear = 2019;
      break;
    default:
      throw Exception('`wrkType`には1~5の整数を指定してください。');
  }
  final int srkYear = wrkDate.date.year + startYear - 1;
  return '$srkYear年${wrkDate.date.month}月${wrkDate.date.day}日';
}

extension DateTimeExt on DateTime {
  bool isBetween(DateTime start, DateTime end) {
    final dateStr = toString();
    final startStr = start.toString();
    final endStr = end.toString();

    // A.compareTo(B)から、AがBよりも[過去、同日、未来]か判定する
    // 過去: -1
    // 同日: 0
    // 未来: 1
    return dateStr.compareTo(startStr) >= 0 && dateStr.compareTo(endStr) <= 0;
  }

  DateTime get today => DateTime(year, month, day);
}
