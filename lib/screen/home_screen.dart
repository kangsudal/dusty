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

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String region = regions[0];

  Future<Map<ItemCode, List<StatModel>>> fetchData() async {
    Map<ItemCode, List<StatModel>> stats = {};
    List<Future<List<StatModel>>> futures = [];
    for (ItemCode itemCode in ItemCode.values) {
      final Future<List<StatModel>> response =
          StatRepository.fetchData(itemCode: itemCode);
      futures.add(response);
    }
    final results = await Future.wait(futures); //모든 future들이 다 끝날때까지 기다린다.

    for (int i = 0; i < results.length; i++) {
      final key = ItemCode.values[i]; //itemCode
      final value = results[i];
      stats.addAll({key: value});
    }
    return stats;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      drawer: MainDrawer(
        selectedRegion: region,
        onRegionTap: (String region) {
          setState(() {
            this.region = region;
          });
          Navigator.of(context).pop();
        },
      ),
      body: FutureBuilder<Map<ItemCode, List<StatModel>>>(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()), //Text('에러가 있습니다.'),
            );
          }
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          Map<ItemCode, List<StatModel>> stats = snapshot.data!;
          StatModel pm10RecentStat = stats[ItemCode.PM10]![0]; //제일 첫번째 시간의 값

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
          return CustomScrollView(
            slivers: [
              MainAppBar(
                region: region,
                stat: pm10RecentStat,
                status: status,
              ),
              SliverToBoxAdapter(
                //Sliver가 아닌 위젯을 넣을 수 있게해준다
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CategoryCard(
                      models: ssModel,
                      region: region,
                    ), //종류별 통계
                    SizedBox(height: 16),
                    HourlyCard(), //시간별 미세먼지
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
