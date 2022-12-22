import 'package:dusty/component/card_title.dart';
import 'package:dusty/component/main_card.dart';
import 'package:dusty/const/colors.dart';
import 'package:dusty/model/stat_and_status_model.dart';
import 'package:dusty/model/stat_model.dart';
import 'package:dusty/utils/data_utils.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../component/main_stat.dart';

class CategoryCard extends StatelessWidget {
  final String region;
  final Color darkColor;
  final Color lightColor;

  const CategoryCard({
    Key? key,
    required this.region,
    required this.darkColor,
    required this.lightColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      //Horizontal viewport was given unbounded height. Card의 전체 크기를 제한해줘야한다.
      height: 160,
      child: MainCard(
        backgroundColor: lightColor,
        child: LayoutBuilder(builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CardTitle(
                title: '종류별 통계',
                backgroundColor: darkColor,
              ),
              Expanded(
                //Column안에 스크롤되는 위젯들을 넣을땐 Expanded로 감싸줘야 Horizontal viewport was given unbounded height을 피할 수 있다.
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: PageScrollPhysics(), //다음페이지로 스크롤
                  children: ItemCode.values
                      .map(
                        (ItemCode itemCode) => ValueListenableBuilder<Box>(
                            valueListenable:
                                Hive.box<StatModel>(itemCode.name).listenable(),//직접적으로 listening하고있는 box가 업데이트했을때 관련 위젯만 부분적으로 렌더링한다
                            builder: (context, box, _) {
                              final stat = box.values.last as StatModel;
                              final status =
                                  DataUtils.getStatusFromItemCodeAndValue(
                                      value: stat.getLevelFromRegion(region),
                                      itemCode: itemCode);
                              return MainStat(
                                category: DataUtils.getItemCodeKrString(
                                    itemCode: itemCode), //미세먼지, 초미세먼지, 아황산가스
                                imgPath: status.imagePath,
                                level: status.label, //최고
                                stat:
                                    '${stat.getLevelFromRegion(region)} ${DataUtils.getUnitFromItemCode(itemCode: itemCode)}',
                                //'0μg/m3'
                                width: constraints.maxWidth /
                                    3, ////LayoutBuilde로 감싼 Column의 1/3 너비
                              );
                            }),
                      )
                      .toList(),
                  /*
                  List.generate(
                    20,
                    (index) => MainStat(
                      width: constraints.maxWidth /
                          3, //LayoutBuilde로 감싼 Column의 1/3 너비
                      category: '미세먼지$index',
                      imgPath: 'asset/img/best.png',
                      level: '최고',
                      stat: '0μg/m3',
                    ),
                  ),*/
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
