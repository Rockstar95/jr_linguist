// For Parsing Dynamic Values To Specific Type
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'my_print.dart';

class ParsingHelper {
  static String parseStringMethod(dynamic value, {String defaultValue = ""}) {
    return value?.toString() ?? defaultValue;
  }

  static int parseIntMethod(dynamic value, {int defaultValue = 0}) {
    if(value == null) {
      return defaultValue;
    }
    else if(value is int) {
      return value;
    }
    else if(value is double) {
      return value.toInt();
    }
    else if(value is String) {
      return int.tryParse(value) ?? defaultValue;
    }
    else {
      return defaultValue;
    }
  }

  static double parseDoubleMethod(dynamic value, {double defaultValue = 0}) {
    if(value == null) {
      return defaultValue;
    }
    else if(value is int) {
      return value.toDouble();
    }
    else if(value is double) {
      return value;
    }
    else if(value is String) {
      return double.tryParse(value) ?? defaultValue;
    }
    else {
      return defaultValue;
    }
  }

  static bool parseBoolMethod(dynamic value, {bool defaultValue = false}) {
    if(value == null) {
      return defaultValue;
    }
    else if(value is bool) {
      return value;
    }
    else if(value is String) {
      if(value.toLowerCase() == "true") {
        return true;
      }
      else if(value.toLowerCase() == "false") {
        return false;
      }
      else {
        return defaultValue;
      }
    }
    else {
      return defaultValue;
    }
  }

  static List<T2> parseListMethod<T1, T2>(dynamic value, {List<T2> defaultValue = const []}) {
    if(value == null) {
      return defaultValue;
    }
    else if(value is List<T1>) {
      try {
        List<T2> newList = List.castFrom<T1, T2>(value);
        return newList;
      }
      catch(e) {
        return defaultValue;
      }
    }
    else if(value is List<dynamic>) {
      try {
        List<T2> newList = List.castFrom<dynamic, T2>(value);
        return newList;
      }
      catch(e) {
        return defaultValue;
      }
    }
    else {
      return defaultValue;
    }
  }

  static Map<K2, V2> parseMapMethod<K1, V1, K2, V2>(dynamic value, {Map<K2, V2> defaultValue = const {}}) {
    if(value == null) {
      return defaultValue;
    }
    else if(value is Map) {
      try {
        Map<K1, V1> newMap = Map.castFrom<dynamic, dynamic, K1, V1>(value);
        Map<K2, V2> newMap2 = Map.castFrom<K1, V1, K2, V2>(newMap);
        return newMap2;
      }
      catch(e) {
        return defaultValue;
      }
    }
    else {
      return defaultValue;
    }
  }

  static DateTime? parseDateTimeMethod(dynamic value, {DateTime? defaultValue, String? dateFormat, bool fromMilliseconds = true}) {
    if(value == null) {
      return defaultValue;
    }
    else if(value is Timestamp) {
      return value.toDate();
    }
    else if(value is int) {
      if(fromMilliseconds) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      else {
        return DateTime.fromMicrosecondsSinceEpoch(value);
      }
    }
    else if(value is double) {
      if(fromMilliseconds) {
        return DateTime.fromMillisecondsSinceEpoch(value.toInt());
      }
      else {
        return DateTime.fromMicrosecondsSinceEpoch(value.toInt());
      }
    }
    else if(value is String) {
      if(dateFormat != null) {
        try {
          return DateFormat(dateFormat).parse(value);
        }
        on FormatException catch(e, s) {
          MyPrint.printOnConsole("Format Exception in Parsing Date:$e");
          MyPrint.printOnConsole(s);
        }
        catch(e, s) {
          MyPrint.printOnConsole("Error in Parsing Date:$e");
          MyPrint.printOnConsole(s);
        }
      }
      return DateTime.tryParse(value) ?? defaultValue;
    }
    else {
      return defaultValue;
    }
  }

  static Timestamp? parseTimestampMethod(dynamic value, {Timestamp? defaultValue, String? dateFormat}) {
    DateTime? dateTime = parseDateTimeMethod(value, dateFormat: dateFormat, defaultValue: defaultValue?.toDate());

    if(dateTime == null) {
      return defaultValue;
    }
    else {
      return Timestamp.fromDate(dateTime);
    }
  }
}