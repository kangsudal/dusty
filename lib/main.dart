import 'package:dusty/model/stat_model.dart';
import 'package:dusty/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future main() async{
  await dotenv.load(fileName:'.env');

  await Hive.initFlutter();
  Hive.registerAdapter<StatModel>(StatModelAdapter());//<연결해줄 모델>(코드제너레이션을 통해 생성된 아답터)를 통해 하이브에서 데이터를 불러오거나 저장한다.
  Hive.registerAdapter<ItemCode>(ItemCodeAdapter());
  for(ItemCode itemCode in ItemCode.values){
    await Hive.openBox<StatModel>(itemCode.name);
  }

  runApp(
    MaterialApp(
      theme: ThemeData(fontFamily: 'Sunflower'),
      home: HomeScreen(),
    ),
  );
}
