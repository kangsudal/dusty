/*
공통적으로 사용될만한 함수들 모아놓기
 */
import 'package:dusty/const/status_level.dart';
import 'package:dusty/model/stat_model.dart';
import 'package:dusty/model/status_model.dart';

class DataUtils {
  static getTimeFromDateTime({required DateTime dateTime}) {
    return '${dateTime.year}-${dateTime.month}-${dateTime.day} ${getTimeFormat(dateTime.hour)}:${getTimeFormat(dateTime.minute)}';
  }

  static String getTimeFormat(int number) {
    return number.toString().padLeft(2, '0'); //길이가 2이하면 0으로 채운다
  }

  static String getUnitFromItemCode({required ItemCode itemCode}) {
    switch (itemCode) {
      case ItemCode.PM10:
        return 'μg/m3';

      case ItemCode.PM25:
        return 'μg/m3';

      default:
        return 'ppm';
    }
  }

  static String itemCodeKrString({
    required ItemCode itemCode,
  }) {
    switch (itemCode) {
      case ItemCode.PM10:
        return '미세먼지';

      case ItemCode.PM25:
        return '초미세먼지';

      case ItemCode.NO2:
        return '이산화질소';

      case ItemCode.O3:
        return '오존';

      case ItemCode.CO:
        return '일산화탄소';

      case ItemCode.SO2:
        return '아황산가스';
    }
  }

  static StatusModel getStatusFromItemCodeAndValue(
      {required double value, required ItemCode itemCode}) {
    return statusLevel.where((status) {
      if (itemCode == ItemCode.PM10) {
        return status.minFineDust < value;
      } else if (itemCode == ItemCode.PM25) {
        return status.minUltraFineDust < value;
      } else if (itemCode == ItemCode.CO) {
        return status.minCO < value;
      } else if (itemCode == ItemCode.O3) {
        return status.minO3 < value;
      } else if (itemCode == ItemCode.NO2) {
        return status.minNO2 < value;
      } else if (itemCode == ItemCode.SO2) {
        return status.minSO2 < value;
      } else{
        throw Exception('알 수 없는 ItemCode 입니다.');
      }
    }).last;
  }
}
