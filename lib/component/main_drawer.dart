import 'package:dusty/const/colors.dart';
import 'package:dusty/const/regions.dart';
import 'package:flutter/material.dart';

typedef OnRegionTap = void Function(String region);

class MainDrawer extends StatelessWidget {
  final OnRegionTap onRegionTap;
  final String selectedRegion;
  final Color darkColor;
  final Color lightColor;
  const MainDrawer({
    required this.onRegionTap,
    required this.selectedRegion,
    required this.darkColor,
    required this.lightColor,
    Key? key,
  }) : super(key: key);

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
          ...regions
              .map((region) => ListTile(
                    tileColor: Colors.white,
                    selectedTileColor: lightColor,
                    selectedColor: Colors.black, //선택됐을때 글자색
                    selected: region == selectedRegion,
                    title: Text(region),
                    onTap: () {
                      onRegionTap(region);
                    },
                  ))
              .toList(),
        ],
      ),
    );
  }
}
