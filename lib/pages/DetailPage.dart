import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lapor_book/component/LikeButton.dart';
import 'package:flutter_lapor_book/component/LikeCount.dart';
import 'package:flutter_lapor_book/component/statusDialog.dart';
import 'package:flutter_lapor_book/component/styles.dart';
import 'package:flutter_lapor_book/component/vars.dart';
import 'package:flutter_lapor_book/model/akun.dart';
import 'package:flutter_lapor_book/model/laporan.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool _isLoading = false;
  int like = 0;

  final _firestore = FirebaseFirestore.instance;

  Future launch(String url) async {
    if (url == '') return;
    if (await launchUrl(Uri.parse(url))) {
      throw Exception('Tidak dapat memanggil $url');
    }
  }

  void countingLike(String idLaporan) async {
    debugPrint("count like");
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('like')
          .where('laporan', isEqualTo: idLaporan)
          .get();

      setState(() {
        like = querySnapshot.docs.length;
      });
    } catch (e) {
      debugPrint('$e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final Akun akun = arguments['akun'];
    final Laporan laporan = arguments['laporan'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          "Detail Laporan",
          style: headerStyle(level: 1, dark: false),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.all(30),
                    child: Column(
                      children: [
                        Text(
                          laporan.judul,
                          style: headerStyle(level: 2),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        laporan.gambar != ''
                            ? Image.network(
                                laporan.gambar!,
                                width: 130,
                                height: 130,
                              )
                            : Image.asset(
                                'assets/default.jpg',
                                width: 130,
                                height: 130,
                              ),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            textStatus(
                                laporan.status,
                                laporan.status == 'Posted'
                                    ? warnaStatus[0]
                                    : laporan.status == 'Process'
                                        ? warnaStatus[1]
                                        : warnaStatus[2],
                                Colors.white),
                            textStatus(
                                laporan.instansi, Colors.white, Colors.black),
                          ],
                        ),
                        // Container(
                        //   margin: EdgeInsets.only(top: 5),
                        //   width: 250,
                        //   child: ElevatedButton.icon(
                        //     onPressed: () {},
                        //     label: Text('Like'),
                        //     icon: Icon(Icons.favorite),
                        //     style: TextButton.styleFrom(
                        //       foregroundColor: Colors.white,
                        //       backgroundColor: Colors.red,
                        //       shape: RoundedRectangleBorder(
                        //           borderRadius: BorderRadius.circular(16)),
                        //     ),
                        //   ),
                        // ),
                        LikeCount(qty: like),
                        LikeButton(laporan: laporan),
                        ListTile(
                          title: Text('Nama Pelapor'),
                          subtitle: Text(laporan.nama),
                          leading: Icon(Icons.person),
                        ),
                        ListTile(
                          title: Text('Tanggal'),
                          subtitle: Text(DateFormat('dd MMMM yyyy')
                              .format(laporan.tanggal)),
                          leading: Icon(Icons.date_range),
                          trailing: IconButton(
                              onPressed: () {
                                launch(laporan.maps);
                              },
                              icon: Icon(Icons.location_on)),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          'Deskripsi',
                          style: headerStyle(level: 2),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(laporan.deskripsi ?? ''),
                        SizedBox(
                          height: 50,
                        ),
                        if (akun.role == 'admin')
                          Container(
                            width: 250,
                            child: ElevatedButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return StatusDialog(
                                        laporan: laporan,
                                      );
                                    });
                              },
                              child: Text('Ubah Status'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: primaryColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                )),
    );
  }

  Container textStatus(String text, var bgColor, var fgColor) {
    return Container(
        alignment: Alignment.center,
        width: 150,
        decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(
              width: 1,
              color: primaryColor,
            ),
            borderRadius: BorderRadius.circular(15)),
        child: Text(
          text,
          style: TextStyle(color: fgColor),
        ));
  }
}
