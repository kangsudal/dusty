import 'package:dusty/const/colors.dart';
import 'package:flutter/material.dart';

import 'main_stat.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      //Horizontal viewport was given unbounded height. Card의 전체 크기를 제한해줘야한다.
      height: 160,
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        color: lightColor,
        child: LayoutBuilder(builder: (context, constraints) {
          return Column(
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
              Expanded(
                //Column안에 스크롤되는 위젯들을 넣을땐 Expanded로 감싸줘야 Horizontal viewport was given unbounded height을 피할 수 있다.
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: PageScrollPhysics(), //다음페이지로 스크롤
                  children: List.generate(
                    20,
                    (index) => MainStat(
                      width: constraints.maxWidth /
                          3, //LayoutBuilde로 감싼 Column의 1/3 너비
                      category: '미세먼지$index',
                      imgPath: 'asset/img/best.png',
                      level: '최고',
                      stat: '0μg/m3',
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
