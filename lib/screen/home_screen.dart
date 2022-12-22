import 'package:dio/dio.dart';
import 'package:dusty/component/category_card.dart';
import 'package:dusty/component/hourly_card.dart';
import 'package:dusty/component/main_app_bar.dart';
import 'package:dusty/component/main_card.dart';
import 'package:dusty/component/main_drawer.dart';
import 'package:dusty/const/colors.dart';
import 'package:dusty/const/regions.dart';
import 'package:dusty/const/status_level.dart';
import 'package:dusty/model/stat_and_status_model.dart';
import 'package:dusty/model/stat_model.dart';
import 'package:dusty/repository/stat_rerpository.dart';
import 'package:dusty/utils/data_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String region = regions[0];
  bool isExpanded = true;
  ScrollController scrollController = ScrollController();

  Future<Map<ItemCode, List<StatModel>>> fetchData() async {
    //List: 시간별, StatModel: 각 지역별 데이터 모아놓은 객체
    // Map<ItemCode, List<StatModel>> stats = {};
    List<Future<List<StatModel>>> futures = [];
    for (ItemCode itemCode in ItemCode.values) {
      final Future<List<StatModel>> response =
          StatRepository.fetchData(itemCode: itemCode);
      futures.add(response);
    }
    final results = await Future.wait(futures); //모든 future들이 다 끝날때까지 기다린다.

    Map<ItemCode, List<StatModel>> statsByItemCode;
    for (int i = 0; i < results.length; i++) {
      final key = ItemCode.values[i]; //ItemCode
      final value = results[i]; //List<StatModel>

      //Hive에 데이터를 저장해준다.
      final box = Hive.box<StatModel>(key.name);
      for (StatModel stat in value) {
        box.put(stat.dateTime.toString(), stat);
      }
    }
    //저장해준 Hive에서 데이터를 꺼내서 리턴해준다
    return ItemCode.values.fold<Map<ItemCode, List<StatModel>>>({},
        (previousMap, itemCode) {
      final box = Hive.box<StatModel>(itemCode.name);
      previousMap.addAll({
        itemCode: box.values.toList(), //{'PM10':List<StatModel>} 초미세먼지의 시간별 StatModel
      });
      return previousMap;
    });
  }

  scrollListener() {
    bool isExpanded = scrollController.offset < (500 - kToolbarHeight);
    //offset: 현재 스크롤 하는 위치를 알 수 있다.
    //SliverAppBar- expandedHeight: 500
    //스크롤한 위치가 앱바 500을 다 덮으면 isExpanded가 false가 된다
    //기본 앱바의 높이만큼 덜덮여도(500보다 작아도) false가 되어야하므로 -kToobarHeight를 해준다
    if (isExpanded != this.isExpanded) {
      setState(() {
        this.isExpanded = isExpanded;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(scrollListener);
    //scrollController가 움직일때(값이 바뀔때) scrollListener를 실행한다
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<ItemCode, List<StatModel>>>(
      future: fetchData(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(snapshot.error.toString()), //Text('에러가 있습니다.'),
            ),
          );
        }
        if (!snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        Map<ItemCode, List<StatModel>> stats = snapshot.data!;
        StatModel pm10RecentStat = stats[ItemCode.PM10]![0]; //제일 첫번째 시간의 값

        //미세먼지 최근 데이터의 현재 상태
        final status = DataUtils.getStatusFromItemCodeAndValue(
          value: pm10RecentStat.seoul,
          itemCode: ItemCode.PM10,
        );

        final ssModel = (stats.keys.map((itemCode) {
          final statModelList = stats[itemCode]!;
          //stats[PM10]은 미세먼지의 List<StatModel>를 가져온다. 0시~12시가지
          final stat = statModelList[0];
          //종류별 통계에 들어갈것은 가장 가까운 시간이니까 제일 첫번째 시간인 0이 들어간다.

          return StatAndStatusModel(
              itemCode: itemCode,
              //status는 가장 첫번째 시간의 값이 어떤상태인지
              status: DataUtils.getStatusFromItemCodeAndValue(
                value: stat.getLevelFromRegion(region),
                //stats[itemCode][0].seoul, itemCode(아황산가스)의 모든 시간 중 첫번째시간[0] 중 region이 seoul인 값
                itemCode: itemCode, //ItemCode.PM10,
              ),
              stat: stat);
        })).toList();

        return Scaffold(
          // backgroundColor: primaryColor,
          drawer: MainDrawer(
            selectedRegion: region,
            onRegionTap: (String region) {
              setState(() {
                this.region = region;
              });
              Navigator.of(context).pop();
            },
            darkColor: status.darkColor,
            lightColor: status.lightColor,
          ),
          body: Container(
            color: status.primaryColor,
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                MainAppBar(
                  region: region,
                  stat: pm10RecentStat,
                  status: status,
                  dateTime: pm10RecentStat.dateTime,
                  isExpanded: isExpanded,
                ),
                SliverToBoxAdapter(
                  //Sliver가 아닌 위젯을 넣을 수 있게해준다
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CategoryCard(
                        models: ssModel,
                        region: region,
                        darkColor: status.darkColor,
                        lightColor: status.lightColor,
                      ), //종류별 통계
                      SizedBox(height: 16),
                      ...stats.keys.map((itemCode) {
                        final stat = stats[itemCode]!;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: HourlyCard(
                            darkColor: status.darkColor,
                            lightColor: status.lightColor,
                            category: DataUtils.getItemCodeKrString(
                              itemCode: itemCode, //ItemCode.PM10,
                            ),
                            stats: stat, //stats[ItemCode.PM10]!,
                            region: region,
                          ),
                        );
                      }).toList(),
                      //시간별 미세먼지
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
