// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lapak/pages/store/create_store.dart';
import 'package:lapak/style/color.dart';
import 'package:material_dialogs/material_dialogs.dart';

class EmptyStore extends StatelessWidget {
  const EmptyStore({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(width / 25),
          child: Column(
            children: [
              _header(context, width),
              LottieBuilder.asset("assets/json/99778-my-store-animated.json"),
              Text(
                "Kamu belum memiliki toko",
                style: TextStyle(color: grayText, fontSize: width / 26),
              ),
              SizedBox(
                height: width / 30,
              ),
              Container(
                width: width,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: width / 60), backgroundColor: blueTheme,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(width / 40))),
                  onPressed: () {
                    Get.off(CreateStore(), transition: Transition.rightToLeft);
                  },
                  child: Text(
                    "Buat toko",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: width / 20,
                        fontFamily: "popinsemi"),
                  ),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }

  Widget _header(BuildContext context, width) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Iconsax.arrow_left)),
        Text(
          "Toko",
          style: TextStyle(
            fontSize: width / 15,
            fontFamily: "popinsemi",
          ),
        ),
        Text(
          "Chat",
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}
