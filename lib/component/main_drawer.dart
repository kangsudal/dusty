import 'package:dusty/const/colors.dart';
import 'package:flutter/material.dart';

const regions = [
  '서울',
  '경기',
  '대구',
  '충남',
  '인천',
  '대전',
  '경북',
  '세종',
  '광주',
  '전북',
  '강원',
  '울산',
  '전남',
  '부산',
  '제주',
  '충북',
  '강남',
];

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: darkColor,
      child: ListView(
        children: [
          DrawerHeader(
            child: Text(
              '지역선택',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
          ...regions.map((region) =>ListTile(
            tileColor: Colors.white,
            selectedTileColor: lightColor,
            selectedColor: Colors.black,//선택됐을때 글자색
            selected: false,
            title: Text(region),
            onTap: (){},
          ) ).toList(),
        ],
      ),
    );
  }
}
