// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, await_only_futures, deprecated_member_use, depend_on_referenced_packages, must_be_immutable, use_key_in_widget_constructors, avoid_print, use_build_context_synchronously, sized_box_for_whitespace

import 'dart:io';
import 'dart:async';
import 'package:async/async.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lapak/service/api_service.dart';
import 'package:lapak/style/color.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateBarang extends StatefulWidget {
  int id;
  CreateBarang({required this.id});

  @override
  State<CreateBarang> createState() => _CreateBarangState();
}

class _CreateBarangState extends State<CreateBarang> {
  File? path;
  bool isLoading = false;
  TextEditingController namaBarang = TextEditingController();
  TextEditingController harga = TextEditingController();
  TextEditingController deskripsi = TextEditingController();
  TextEditingController diskon = TextEditingController();
  File? _image;
  String? selectedValue;
  final picker = ImagePicker();

  Future<void> getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        path = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future createBarang(File imgFile, BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    var stream = http.ByteStream(DelegatingStream.typed(imgFile.openRead()));
    var length = await imgFile.length();
    Uri url = Uri.parse("$baseUrl/barang/create");
    SharedPreferences storage = await SharedPreferences.getInstance();
    final req = http.MultipartRequest("POST", url);
    req.fields["store_id"] = widget.id.toString();
    req.fields["nama_barang"] = namaBarang.text;
    req.fields["harga"] = harga.text;
    req.fields["deskripsi"] = deskripsi.text;
    req.fields["diskon"] = diskon.text.isEmpty ? 0.toString() : diskon.text;
    req.fields["kategori"] = selectedValue.toString();
    req.headers["Authorization"] = "Bearer ${storage.getString("token")}";

    var multipartFile = http.MultipartFile('foto_barang', stream, length,
        filename: basename(imgFile.path));
    req.files.add(multipartFile);
    await req.send().then((result) async {
      http.Response.fromStream(result).then((res) {
        if (res.statusCode == 200) {
          setState(() {
            isLoading = false;
          });
          Navigator.of(context).pop();
          return true;
        } else {
          setState(() {
            isLoading = false;
          });
          print(res.statusCode);
          print(res.body);
          Get.snackbar("Gagal", "terjadi kesalahan, silahkan coba lagi",
              snackPosition: SnackPosition.BOTTOM,
              leftBarIndicatorColor: Colors.red,
              backgroundColor: Colors.red.withOpacity(0.3));
          return false;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(width / 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(context, width),
              SizedBox(
                height: width / 15,
              ),
              _label("Nama barang", width),
              SizedBox(
                height: width / 35,
              ),
              TextField(
                controller: namaBarang,
                style: TextStyle(fontSize: width / 33),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(width / 30),
                      borderSide: BorderSide(color: grayBorder, width: 3)),
                ),
              ),
              SizedBox(
                height: width / 35,
              ),
              _label("Harga", width),
              SizedBox(
                height: width / 35,
              ),
              TextField(
                keyboardType: TextInputType.number,
                controller: harga,
                style: TextStyle(fontSize: width / 33),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(width / 30),
                      borderSide: BorderSide(color: grayBorder, width: 3)),
                ),
              ),
              SizedBox(
                height: width / 35,
              ),
              _label("Deskripsi", width),
              SizedBox(
                height: width / 35,
              ),
              TextField(
                maxLines: 10,
                controller: deskripsi,
                style: TextStyle(fontSize: width / 33),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: width / 40, vertical: width / 40),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(width / 30),
                      borderSide: BorderSide(color: grayBorder, width: 3)),
                ),
              ),
              SizedBox(
                height: width / 35,
              ),
              _label("Diskon", width),
              SizedBox(
                height: width / 35,
              ),
              TextField(
                controller: diskon,
                style: TextStyle(fontSize: width / 33),
                decoration: InputDecoration(
                  hintText: "Opsional",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(width / 30),
                      borderSide: BorderSide(color: grayBorder, width: 3)),
                ),
              ),
              SizedBox(
                height: width / 35,
              ),
              _label("Kategori", width),
              SizedBox(
                height: width / 35,
              ),
              DropdownButton(
                hint: Text("Pilih kategori"),
                value: selectedValue,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedValue = newValue!;
                  });
                },
                items: [
                  "elektronik",
                  "makanan",
                  "fashion",
                  "aksesoris",
                  "buku",
                  "hiburan"
                ].map((value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              Stack(
                children: [
                  InkWell(
                    onTap: () async => await getImage(),
                    child: path == null
                        ? LottieBuilder.asset(
                            "assets/json/63534-image-preloader.json")
                        : Container(
                            margin: EdgeInsets.symmetric(vertical: width / 10),
                            height: width / 1.5,
                            decoration: BoxDecoration(
                                image:
                                    DecorationImage(image: FileImage(path!))),
                          ),
                  ),
                  path == null
                      ? Container()
                      : InkWell(
                          onTap: () {
                            setState(() {
                              path = null;
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(top: width / 20),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: CircleAvatar(
                                minRadius: width / 24,
                                maxRadius: width / 24,
                                backgroundColor: Colors.black.withOpacity(0.3),
                                child: Icon(
                                  Icons.cancel,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                  Container(
                    margin: EdgeInsets.only(top: width / 1.3),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        path == null ? " Masukan foto toko" : "",
                        style: TextStyle(
                            color: grayText,
                            fontFamily: "popinmedium",
                            fontSize: width / 25),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: width / 20,
              ),
              Container(
                width: width,
                child: ElevatedButton(
                    onPressed: () {
                      if (namaBarang.text.isEmpty ||
                          harga.text.isEmpty ||
                          deskripsi.text.isEmpty ||
                          selectedValue!.isEmpty ||
                          _image == null) {
                        Dialogs.materialDialog(
                            context: context,
                            lottieBuilder: LottieBuilder.asset(
                                "assets/json/94900-error.json"),
                            title: "Terjadi kesalahan",
                            titleStyle: TextStyle(
                                fontFamily: "popinsemi",
                                fontSize:
                                    MediaQuery.of(context).size.width / 20),
                            msg: "Semua field harus diisi",
                            msgStyle: TextStyle(
                                color: grayText, fontSize: width / 30),
                            actions: [
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: blueTheme,
                                      padding: EdgeInsets.symmetric(
                                          vertical: width / 67),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              width / 50))),
                                  onPressed: () {
                                    Get.back();
                                  },
                                  child: Text(
                                    "Ok",
                                    style: TextStyle(fontSize: width / 30),
                                  ))
                            ]);
                        return;
                      }
                      createBarang(_image!, context);
                    },
                    style: ElevatedButton.styleFrom(
                        primary: blueTheme,
                        padding: EdgeInsets.symmetric(
                          vertical: width / 55,
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(width / 50))),
                    child: isLoading
                        ? CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text(
                            "Simpan",
                            style: TextStyle(
                                fontSize: width / 20, fontFamily: "popinsemi"),
                          )),
              )
            ],
          ),
        ),
      )),
    );
  }

  Widget _label(String text, width) {
    return Text(
      text,
      style: TextStyle(fontSize: width / 22, fontFamily: "popinmedium"),
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
          "Barang",
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
