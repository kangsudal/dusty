/*
CategoryCard의 각 아이템들에
StatModel(아이콘 이미지, 최고)와 StatusModel(region이 주어졌을때의 수치)가
모두 필요해서 만드는 클래스
 */
import 'package:dusty/model/stat_model.dart';
import 'package:dusty/model/status_model.dart';

class StatAndStatusModel {
  final ItemCode itemCode;//미세먼지, 초미세먼지 글자를 만들기 위해
  final StatusModel status;
  final StatModel stat;

  StatAndStatusModel({
    required this.itemCode,
    required this.status,
    required this.stat,
  });
}
