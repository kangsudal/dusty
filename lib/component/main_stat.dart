import 'package:flutter/material.dart';

class MainStat extends StatelessWidget {
  const MainStat({
    Key? key,
    required this.category,
    required this.imgPath,
    required this.level,
    required this.stat,
    required this.width,
  }) : super(key: key);

  final String category; //미세먼지/ 초미세먼지
  final String imgPath; //아이콘 위치(경로)
  final String level; //오염 정도
  final String stat; //오염수치
  final double width; //너비

  @override
  Widget build(BuildContext context) {
    final ts = TextStyle(color: Colors.black,);
    return SizedBox(
      width: width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(category,style: ts,),
          const SizedBox(height: 8,),
          Image.asset(imgPath,width: 50,),
          const SizedBox(height: 8,),
          Text(level,style: ts,),
          Text(stat,style: ts,),
        ],
      ),
    );
  }
}
