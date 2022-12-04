import 'package:dusty/component/card_title.dart';
import 'package:dusty/component/category_card.dart';
import 'package:dusty/component/main_app_bar.dart';
import 'package:dusty/component/main_card.dart';
import 'package:dusty/component/main_drawer.dart';
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
                CategoryCard(),
                SizedBox(height: 16),
                MainCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CardTitle(
                        title: '시간별 미세먼지',
                      ),
                      Column(
                        children: List.generate(24, (index) {
                          final now = DateTime.now();
                          final hour = now.hour;
                          int currentHour = hour - index;
                          if (currentHour < 0) {
                            currentHour += 24;
                          }
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: Row(
                              children: [
                                Expanded(child: Text('$currentHour시')),
                                Expanded(
                                  child: Image.asset(
                                    'asset/img/good.png',
                                    height: 20,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '좋음',
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      )
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
