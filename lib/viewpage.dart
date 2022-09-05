import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:contact/insertpage.dart';
import 'package:contact/updatepage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

class viewpage extends StatefulWidget {
  const viewpage({Key? key}) : super(key: key);

  @override
  State<viewpage> createState() => _viewpageState();
}

class _viewpageState extends State<viewpage> {
  bool status = true;
  List l = [];
  List dummy = [];
  bool search = true;
  int result = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getalldata();
    gonext();
  }

  Future<List> getalldata() async {
    Response response = await Dio()
        .get('https://learnwithproject.000webhostapp.com/insert/viewdata.php');
    print(response.data.toString());
    Map m = jsonDecode(response.data);

    int connection = m['connection'];
    if (connection == 1) {
      result = m['result'];
      if (result == 1) {
        l = m['data'];
      }
    }
    return l;
  }

  gonext() async {
    var status = await Permission.camera.status;
    if (status.isDenied) {
      Map<Permission, PermissionStatus> statuses =
          await [Permission.camera].request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) {
                return insertpage();
              },
            ));
          },
          child: Icon(Icons.add),
        ),
        appBar: search
            ? AppBar(
                title: Text("Contact"),
                actions: [
                  IconButton(
                      onPressed: () {
                        search = false;
                        setState(() {});
                      },
                      icon: Icon(Icons.search))
                ],
              )
            : AppBar(
                title: TextField(
                  onChanged: (value) {
                    dummy = [];
                    if (value.isEmpty) {
                      dummy = l;
                    } else {
                      for (int i = 0; i < l.length; i++) {
                        if (l[i]['name']
                                .toString()
                                .toLowerCase()
                                .contains(value) ||
                            l[i]['contact'].toString().contains(value)) {
                          dummy.add(l[i]);
                        }
                      }
                    }
                    setState(() {});
                  },
                  autofocus: true,
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                      prefix: Icon(Icons.search),
                      suffix: IconButton(
                          onPressed: () {
                            search = true;
                            dummy = [];
                            setState(() {});
                          },
                          icon: Icon(Icons.close))),
                ),
              ),
        body: FutureBuilder(
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                l.sort(
                  (a, b) =>
                      a['name'].toString().compareTo(b['name'].toString()),
                );
                dummy.sort(
                  (a, b) =>
                      a['name'].toString().compareTo(b['name'].toString()),
                );
                return search
                    ? ListView.builder(
                        itemCount: l.length,
                        itemBuilder: (context, index) {
                          Map map = l[index];
                          String imageurl = map['imagename'] == ''
                              ? ""
                              : "https://learnwithproject.000webhostapp.com/insert/${map['imagename']}";
                          return ListTile(
                            onLongPress: () {
                              String serverlocation = map['imagename'];
                              showDialog(
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text("Delete"),
                                    content: Text(
                                        "Are you sure you wan't to delete ${map['name'].toString().toUpperCase()}"),
                                    actions: [
                                      TextButton(
                                          onPressed: () async {
                                            Navigator.pop(context);

                                            String id = map['id'];

                                            var url = Uri.parse(
                                                'https://learnwithproject.000webhostapp.com/insert/delete.php?id=$id');
                                            var response = await http.get(url);
                                            print(
                                                'Response status: ${response.statusCode}');
                                            print(
                                                'Response body: ${response.body}');
                                            if (response.statusCode == 200) {
                                              Fluttertoast.showToast(
                                                  msg: "Contact Delete",
                                                  toastLength:
                                                      Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.BOTTOM,
                                                  timeInSecForIosWeb: 1,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  textColor: Colors.black,
                                                  fontSize: 16.0);
                                            } else {
                                              Fluttertoast.showToast(
                                                  msg: "Contact not Delete",
                                                  toastLength:
                                                      Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.BOTTOM,
                                                  timeInSecForIosWeb: 1,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  textColor: Colors.black,
                                                  fontSize: 16.0);
                                            }
                                            setState(() {});
                                          },
                                          child: Text("Yes")),
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text("No"))
                                    ],
                                  );
                                },
                                context: context,
                              );
                            },
                            onTap: () {
                              Navigator.pushReplacement(context,
                                  MaterialPageRoute(
                                builder: (context) {
                                  return updatepage(map);
                                },
                              ));
                            },
                            leading: imageurl.isEmpty
                                ? Container(
                                    height: 30,
                                    width: 30,
                                    child: Image.asset(
                                      "myimage/user.png",
                                      fit: BoxFit.contain,
                                    ),
                                  )
                                : ClipRRect(
                                    child: Image.network(
                                      imageurl,
                                      height: 30,
                                      width: 30,
                                      fit: BoxFit.fill,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            CircularProgressIndicator(
                                              value: loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!,
                                            ),
                                            Text(
                                              ((loadingProgress.cumulativeBytesLoaded /
                                                              loadingProgress
                                                                  .expectedTotalBytes!) *
                                                          100)
                                                      .toInt()
                                                      .toString() +
                                                  "%",
                                              style: TextStyle(fontSize: 10),
                                            )
                                          ],
                                        );
                                      },
                                    ),
                                    borderRadius: BorderRadius.circular(20)),
                            title: Text("${map['name']}"),
                            subtitle: Text("${map['contact']}"),
                          );
                        },
                      )
                    : ListView.builder(
                        itemCount: dummy.length,
                        itemBuilder: (context, index) {
                          Map map = dummy[index];
                          String imageurl = map['imagename'] == ''
                              ? ""
                              : "https://learnwithproject.000webhostapp.com/insert/${map['imagename']}";
                          return ListTile(
                            onLongPress: () {
                              String serverlocation = map['imagename'];
                              showDialog(
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text("Delete"),
                                    content: Text(
                                        "Are you sure you wan't to delete ${map['name'].toString().toUpperCase()}"),
                                    actions: [
                                      TextButton(
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            var formData = FormData.fromMap({
                                              'id': map['id'],
                                              'serverlocation': serverlocation,
                                            });
                                            var response = await Dio().post(
                                                'https://learnwithproject.000webhostapp.com/insert/delete.php',
                                                data: formData);

                                            print(response.data);
                                            Map m = jsonDecode(response.data);
                                            int connection = m['connection'];

                                            if (connection == 1) {
                                              int result = m['result'];
                                              if (result == 1) {
                                                Fluttertoast.showToast(
                                                    msg: "Contact Deleted",
                                                    toastLength:
                                                        Toast.LENGTH_SHORT,
                                                    gravity:
                                                        ToastGravity.BOTTOM,
                                                    timeInSecForIosWeb: 1,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    textColor: Colors.black,
                                                    fontSize: 16.0);
                                                setState(() {
                                                  getalldata();
                                                });
                                              } else {
                                                Fluttertoast.showToast(
                                                    msg: "Contact Not Delete",
                                                    toastLength:
                                                        Toast.LENGTH_SHORT,
                                                    gravity:
                                                        ToastGravity.BOTTOM,
                                                    timeInSecForIosWeb: 1,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    textColor: Colors.black,
                                                    fontSize: 16.0);
                                              }
                                            }
                                          },
                                          child: Text("Yes")),
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text("No"))
                                    ],
                                  );
                                },
                                context: context,
                              );
                            },
                            onTap: () {
                              Navigator.pushReplacement(context,
                                  MaterialPageRoute(
                                builder: (context) {
                                  return updatepage(map);
                                },
                              ));
                            },
                            leading: imageurl.isEmpty
                                ? Container(
                                    height: 30,
                                    width: 30,
                                    child: Image.asset(
                                      "myimage/user.png",
                                      fit: BoxFit.contain,
                                    ),
                                  )
                                : Image.network(
                                    imageurl,
                                    height: 30,
                                    width: 30,
                                    fit: BoxFit.contain,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          CircularProgressIndicator(
                                            value: loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!,
                                          ),
                                          Text(
                                            ((loadingProgress.cumulativeBytesLoaded /
                                                            loadingProgress
                                                                .expectedTotalBytes!) *
                                                        100)
                                                    .toInt()
                                                    .toString() +
                                                "%",
                                            style: TextStyle(fontSize: 10),
                                          )
                                        ],
                                      );
                                    },
                                  ),
                            title: Text("${map['name']}"),
                            subtitle: Text("${map['contact']}"),
                          );
                        },
                      );
              }
            } else {
              Center(
                child: CircularProgressIndicator(),
              );
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
          future: getalldata(),
        ));
  }
}
