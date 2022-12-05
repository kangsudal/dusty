import 'package:dio/dio.dart';
import 'package:dusty/component/category_card.dart';
import 'package:dusty/component/main_app_bar.dart';
import 'package:dusty/component/main_drawer.dart';
import 'package:dusty/const/colors.dart';
import 'package:dusty/model/stat_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    fetchData();
    super.initState();
  }

  fetchData() async {
    final response = await Dio().get(
        'http://apis.data.go.kr/B552584/ArpltnStatsSvc/getCtprvnMesureLIst',
        queryParameters: {
          'serviceKey': dotenv.env['serviceKey'],
          'returnType': 'json',
          'numOfRows': 30,
          'pageNo': 1,
          'itemCode': 'PM10',
          'dataGubun': 'HOUR',
          'searchCondition': 'WEEK',
        });

    print(
      //json -> StatModel object
      response.data['response']['body']['items'].map(
        (item) => StatModel.fromJson(json: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      drawer: MainDrawer(),
      body: CustomScrollView(
        slivers: [
          MainAppBar(),
          SliverToBoxAdapter(
            //Sliver가 아닌 위젯을 넣을 수 있게해준다
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CategoryCard(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
