import 'package:dusty/component/main_app_bar.dart';
import 'package:dusty/component/main_drawer.dart';
import 'package:dusty/component/main_stat.dart';
import 'package:dusty/const/colors.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

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
                Card(
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  color: lightColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        child: Text(
                          '종류별 통계',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        decoration: BoxDecoration(
                          color: darkColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        padding: EdgeInsets.all(4),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          MainStat(
                            category: '미세먼지',
                            imgPath: 'asset/img/best.png',
                            level: '최고',
                            stat: '0μg/m3',
                          ),
                          MainStat(
                            category: '미세먼지',
                            imgPath: 'asset/img/best.png',
                            level: '최고',
                            stat: '0μg/m3',
                          ),
                          MainStat(
                            category: '미세먼지',
                            imgPath: 'asset/img/best.png',
                            level: '최고',
                            stat: '0μg/m3',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
