import 'package:dio/dio.dart';
import 'package:dusty/model/stat_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StatRepository{
  static Future<List<StatModel>> fetchData({required ItemCode itemCode}) async{
    final response = await Dio().get(
        'http://apis.data.go.kr/B552584/ArpltnStatsSvc/getCtprvnMesureLIst',
        queryParameters: {
          'serviceKey': dotenv.env['serviceKey'],
          'returnType': 'json',
          'numOfRows': 30,
          'pageNo': 1,
          'itemCode': itemCode.name,//'PM10',
          'dataGubun': 'HOUR',
          'searchCondition': 'WEEK',
        });
    //json -> StatModel object
    return response.data['response']['body']['items'].map<StatModel>(
          (item) => StatModel.fromJson(json: item),
    ).toList();
  }
}