import 'package:dusty/component/card_title.dart';
import 'package:dusty/component/main_card.dart';
import 'package:dusty/model/stat_model.dart';
import 'package:dusty/model/status_model.dart';
import 'package:dusty/utils/data_utils.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HourlyCard extends StatelessWidget {
  final Color darkColor;
  final Color lightColor;
  final String region;
  final ItemCode itemCode;

  const HourlyCard(
      {required this.darkColor,
      required this.lightColor,
        required this.itemCode,
      required this.region,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box>(
      valueListenable: Hive.box<StatModel>(itemCode.name).listenable(),
      builder: (context, box,_) {
        final stats = box.values;
        return MainCard(
          backgroundColor: lightColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CardTitle(
                title: '시간별 ${DataUtils.getItemCodeKrString(itemCode: itemCode)}',
                backgroundColor: darkColor,
              ),
              Column(
                children: stats.map((stat) => renderRow(stat: stat)).toList(),
              )
            ],
          ),
        );
      }
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
