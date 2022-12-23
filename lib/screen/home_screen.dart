import 'package:dio/dio.dart';
import 'package:dusty/container/category_card.dart';
import 'package:dusty/container/hourly_card.dart';
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
import 'package:hive_flutter/hive_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String region = regions[0];
  bool isExpanded = true;
  ScrollController scrollController = ScrollController();

  Future<void> fetchData() async {
    final now = DateTime.now();
    final fetchTime = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
    );

    final box = Hive.box<StatModel>(ItemCode.PM10.name);
    final recent = box.values.last as StatModel;
    //최근데이터시간과 동일하다면 밑에 코드들을 실행할 필요가 없다.

    if (fetchTime.isAtSameMomentAs(recent.dateTime)) {
      //isSameMomentAs:시간 비교
      print('이미 최신데이터가 있습니다.');
      return;
    }

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
      final allKeys = box.keys.toList();
      if (allKeys.length > 24) {
        //모든 데이터의 개수가 24개 이상일때
        //처음~24개까지 데이터만 남기고 지워준다
        final deleteKeys = allKeys.sublist(0, allKeys.length - 24);
        //제일 과거 데이터부터~최근24개빼고 담는다

        box.deleteAll(deleteKeys);
      }
    }
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
    fetchData();
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box>(
      valueListenable: Hive.box<StatModel>(ItemCode.PM10.name).listenable(),
      builder: (context, box, widget) {
        if (box.values.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }
        final StatModel recentStat =
            box.values.toList().last as StatModel; //박스에서 가장 최근(시간대) 데이터
        //미세먼지 최근 데이터의 현재 상태
        final status = DataUtils.getStatusFromItemCodeAndValue(
          value: recentStat.getLevelFromRegion(region), //지역 데이터
          itemCode: ItemCode.PM10,
        );
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
                  stat: recentStat,
                  status: status,
                  dateTime: recentStat.dateTime,
                  isExpanded: isExpanded,
                ),
                SliverToBoxAdapter(
                  //Sliver가 아닌 위젯을 넣을 수 있게해준다
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CategoryCard(
                        region: region,
                        darkColor: status.darkColor,
                        lightColor: status.lightColor,
                      ), //종류별 통계
                      SizedBox(height: 16),
                      ...ItemCode.values.map((itemCode) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: HourlyCard(
                            darkColor: status.darkColor,
                            lightColor: status.lightColor,
                            itemCode: itemCode,
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
