import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:contact/viewpage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class insertpage extends StatefulWidget {
  const insertpage({Key? key}) : super(key: key);

  @override
  State<insertpage> createState() => _insertpageState();
}

class _insertpageState extends State<insertpage> {
  String path = '';
  final ImagePicker _picker = ImagePicker();
  TextEditingController tname = TextEditingController();
  TextEditingController tcontact = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: SafeArea(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    InkWell(
                      onTap: () async {
                        showDialog(
                            builder: (context) {
                              return SimpleDialog(
                                title: Text("Select Picture"),
                                children: [
                                  ListTile(
                                    onTap: () async {
                                      Navigator.pop(context);
                                      final XFile? photo =
                                          await _picker.pickImage(
                                              source: ImageSource.camera);
                                      if (photo != null) {
                                        path = photo.path;
                                        setState(() {});
                                      }
                                    },
                                    title: Text("Camera"),
                                  ),
                                  ListTile(
                                    onTap: () async {
                                      Navigator.pop(context);
                                      final XFile? photo =
                                          await _picker.pickImage(
                                              source: ImageSource.gallery);
                                      if (photo != null) {
                                        path = photo.path;
                                        setState(() {});
                                      }
                                    },
                                    title: Text("Gallery"),
                                  ),
                                  TextButton(onPressed: () {
                                    Navigator.pop(context);
                                    path='';
                                    setState(() {});
                                  }, child: Text("Remove picture"))
                                ],
                              );
                            },
                            context: context);
                      },
                      child: path.isEmpty
                          ? SizedBox(
                              height: 100,
                              width: 100,
                              child: Image.asset("myimage/user.png"),
                            )
                          : Image.file(
                              File(path),
                              height: 100,
                              width: 100,
                            ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextField(
                      textCapitalization: TextCapitalization.words,
                      keyboardType: TextInputType.name,
                      controller: tname,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.person),
                        label: Text("Name"),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      keyboardType: TextInputType.phone,
                      controller: tcontact,
                      maxLength: 10,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.call),
                        label: Text("Mobile Number"),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: ElevatedButton(
                          onPressed: () async {
                            String name = tname.text;
                            String contact = tcontact.text;
                            DateTime dt = DateTime.now();
                            String imagename =
                                "$name${dt.year}${dt.month}${dt.day}${dt.hour}${dt.minute}${dt.second}";

                            var formData = path.isEmpty
                                ? FormData.fromMap({
                                    'name': name,
                                    'contact': contact,
                                    'imageview': "0"
                                  })
                                : FormData.fromMap({
                                    'name': name,
                                    'contact': contact,
                                    'imageview': "1",
                                    'file': await MultipartFile.fromFile(path,
                                        filename: imagename)
                                  });

                            var response = await Dio().post(
                                'https://learnwithproject.000webhostapp.com/insert/data.php',
                                data: formData);

                            print(response.data);
                            Map m = jsonDecode(response.data);
                            int connection = m['connection'];
                            if (connection == 1) {
                              int result = m['result'];
                              if (result == 1) {
                                Fluttertoast.showToast(
                                    msg: "Contact Saved",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.transparent,
                                    textColor: Colors.black,
                                    fontSize: 16.0);
                                Navigator.pushReplacement(context,
                                    MaterialPageRoute(
                                  builder: (context) {
                                    return viewpage();
                                  },
                                ));
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Contact Not Saved",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.transparent,
                                    textColor: Colors.black,
                                    fontSize: 16.0);
                              }
                            }
                          },
                          child: Text("Save")),
                    )
                  ],
                ),
              ),
            ),
          )),
        ),
        onWillPop: goback);
  }

  Future<bool> goback() {
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (context) {
        return viewpage();
      },
    ));
    return Future.value();
  }
}
