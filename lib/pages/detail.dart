// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, prefer_typing_uninitialized_variables, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, use_build_context_synchronously, library_prefixes, avoid_print, prefer_final_fields, must_be_immutable

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:lapak/service/api_service.dart';
import 'package:lapak/chat/chat.dart';
import 'package:lapak/pages/checkout/checkout.dart';
import 'package:lapak/pages/store/toko.dart';
import 'package:lapak/style/color.dart';
import 'package:lapak/widget/rupiah_format.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as Io;
import 'package:toast/toast.dart';

class Detail extends StatefulWidget {
  final data;
  var where;
  Detail({required this.data, this.where});
  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  Io.Socket socket = Io.io(baseUrl, <String, dynamic>{
    "transports": ["websocket"],
  });

  int userId = 0;
  void getUserId() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    var token = Jwt.parseJwt(storage.getString("token").toString());
    setState(() {
      userId = token["id"];
    });
  }

  void connectSocket() {
    socket.onConnect((data) => print("connect"));
    socket.onConnectError((data) => print("error $data"));
    socket.onDisconnect((data) => print("disconnect"));
  }

  Future generateCode() async {
    Toast.show("Mohon tunggu sebentar", gravity: Toast.bottom);
    Uri url = Uri.parse("$baseUrl/chat/generate-code/${widget.data.owner}");
    SharedPreferences storage = await SharedPreferences.getInstance();
    headers["Authorization"] = "Bearer ${storage.getString("token")}";
    final res = await http.get(url, headers: headers);
    if (res.statusCode == 200) {
      if (jsonDecode(res.body)["code"]["room_code"] != null) {
        socket.emit("join_room", {
          "room_code": jsonDecode(res.body)["code"]["room_code"],
          "from": userId
        });
        Get.to(
            ChatPage(
                to: widget.data.owner,
                roomCode: jsonDecode(res.body)["code"]["room_code"]),
            transition: Transition.rightToLeft);
      } else {
        socket.emit("join_room", {
          "room_code": jsonDecode(res.body)["code"]["code"],
          "from": userId
        });
        Get.to(
            ChatPage(
                to: widget.data.owner,
                roomCode: jsonDecode(res.body)["code"]["code"]),
            transition: Transition.rightToLeft);
      }
    } else {
      print(res.statusCode);
      print(res.body);
    }
  }

  @override
  void initState() {
    getUserId();
    super.initState();
    connectSocket();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: widget.data.owner != userId
          ? Container(
              padding: EdgeInsets.all(width / 25),
              width: width,
              child: ElevatedButton(
                  onPressed: () {
                    Get.to(
                        Checkout(
                          data: widget.data,
                          where: widget.where,
                        ),
                        transition: Transition.rightToLeft);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: blueTheme,
                      padding: EdgeInsets.symmetric(vertical: width / 80),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(width / 50))),
                  child: Text(
                    "Pesan",
                    style: TextStyle(
                        fontSize: width / 20, fontFamily: "popinsemi"),
                  )),
            )
          : Text(""),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              elevation: 0,
              snap: true,
              backgroundColor: Colors.white,
              floating: true,
              stretch: true,
              leading: Container(
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(width)),
                child: IconButton(
                  icon: Icon(Iconsax.arrow_left),
                  onPressed: () => Get.back(),
                ),
              ),
              expandedHeight: width / 1.1,
              flexibleSpace: FlexibleSpaceBar(
                background: Image.network(
                  widget.data.fotoBarang,
                  fit: BoxFit.cover,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(height / 10),
                child: Transform.translate(
                  offset: Offset(0, 1),
                  child: Container(
                    height: width / 7,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(width / 15),
                            topRight: Radius.circular(width / 15)),
                        color: Colors.white),
                    child: Center(
                      child: Container(
                        width: width / 2,
                        height: width / 80,
                        decoration: BoxDecoration(
                            color: Color(0xffC4C4C4),
                            borderRadius: BorderRadius.circular(width)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate.fixed([
                Container(
                  padding: EdgeInsets.all(width / 25),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              widget.data.namaBarang,
                              style: TextStyle(
                                  fontSize: width / 18,
                                  fontFamily: "popinsemi"),
                            ),
                          ),
                          widget.data.owner != userId
                              ? IconButton(
                                  onPressed: () {
                                    generateCode();
                                  },
                                  icon: Icon(
                                    Iconsax.message,
                                    size: width / 20,
                                  ))
                              : Container(),
                        ],
                      ),
                      SizedBox(
                        height: width / 50,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Iconsax.dollar_circle,
                                    color: grayText,
                                    size: width / 22,
                                  ),
                                  SizedBox(
                                    width: width / 50,
                                  ),
                                  widget.data.diskon == null ||
                                          widget.data.diskon == 0
                                      ? Text(
                                          CurrencyFormat.convertToIdr(
                                              widget.data.harga, 0),
                                          style: TextStyle(
                                              color: grayText,
                                              fontSize: width / 30),
                                        )
                                      : RichText(
                                          text: TextSpan(
                                              style: TextStyle(
                                                  fontFamily: "popin",
                                                  fontSize: width / 33,
                                                  color: grayText),
                                              children: [
                                              TextSpan(
                                                  text: CurrencyFormat
                                                      .convertToIdr(
                                                          widget.data.harga, 0),
                                                  style: TextStyle(
                                                      decoration: TextDecoration
                                                          .lineThrough,
                                                      color: Colors.grey
                                                          .withOpacity(0.6),
                                                      fontSize: width / 40)),
                                              TextSpan(
                                                  text:
                                                      "   ${CurrencyFormat.convertToIdr((0.5 * widget.data.harga) - widget.data.diskon, 0)}")
                                            ]))
                                ],
                              ),
                              SizedBox(
                                height: widget.data.diskon == null ||
                                        widget.data.diskon == 0
                                    ? 0
                                    : width / 60,
                              ),
                              widget.data.diskon == null ||
                                      widget.data.diskon == 0
                                  ? Container()
                                  : _infoBarang(width, "${widget.data.diskon}%",
                                      Iconsax.discount_circle),
                              SizedBox(
                                height: width / 60,
                              ),
                              _infoBarang(
                                  width, widget.data.daerah, Iconsax.location),
                            ],
                          ),
                          InkWell(
                            onTap: () => Get.to(
                                Toko(storeId: widget.data.storeId),
                                transition: Transition.rightToLeft),
                            child: CircleAvatar(
                              maxRadius: width / 25,
                              minRadius: width / 25,
                              backgroundImage:
                                  NetworkImage(widget.data.fotoToko),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: width / 40,
                      ),
                      Text(
                        widget.data.deskripsi,
                        style: TextStyle(fontSize: width / 30),
                      ),
                      SizedBox(
                        height: width / 20,
                      ),
                    ],
                  ),
                )
              ]),
            )
          ],
        ),
      ),
    );
  }

  Widget _infoBarang(width, text, icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: grayText,
          size: width / 22,
        ),
        SizedBox(
          width: width / 50,
        ),
        Text(
          text,
          style: TextStyle(color: grayText, fontSize: width / 30),
        )
      ],
    );
  }
}
