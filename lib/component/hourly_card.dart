import 'package:dusty/component/card_title.dart';
import 'package:dusty/component/main_card.dart';
import 'package:dusty/model/stat_model.dart';
import 'package:dusty/model/status_model.dart';
import 'package:dusty/utils/data_utils.dart';
import 'package:flutter/material.dart';

class HourlyCard extends StatelessWidget {
  final Color darkColor;
  final Color lightColor;
  final String category;
  final List<StatModel> stats;
  final String region;

  const HourlyCard(
      {required this.darkColor,
      required this.lightColor,
      required this.category,
      required this.stats,
      required this.region,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MainCard(
      backgroundColor: lightColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardTitle(
            title: '시간별 $category',
            backgroundColor: darkColor,
          ),
          Column(
            children: stats.map((stat) => renderRow(stat: stat)).toList(),
          )
        ],
      ),
    );
  }

  Widget renderRow({required StatModel stat}) {
    //statusModel: 좋음, 안좋음
    StatusModel statusModel = DataUtils.getStatusFromItemCodeAndValue(
        value: stat.getLevelFromRegion(region), itemCode: stat.itemCode);
    //getLevelFromRegion(): ex: (서울)의 (아황산가스) 수치값/ 아황산가스인것을 어떻게 아는가? stat에 있는가? ㅇㅇ. stat을 넘겨줄때 Map에서 itemCode를 지정해서 보내준 데이터임
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      child: Row(
        children: [
          Expanded(child: Text('${stat.dateTime.hour}시')),
          Expanded(
            child: Image.asset(
              statusModel.imagePath, //'asset/img/good.png'
              height: 20,
            ),
          ),
          Expanded(
            child: Text(
              statusModel.label, //'좋음',
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
