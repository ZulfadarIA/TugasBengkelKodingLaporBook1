import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lapor_book/component/styles.dart';
import 'package:flutter_lapor_book/component/vars.dart';
import 'package:flutter_lapor_book/model/akun.dart';
import 'package:flutter_lapor_book/model/laporan.dart';
import 'package:intl/intl.dart';

class ListItem extends StatefulWidget {
  final Akun akun;
  final Laporan laporan;
  final bool isLaporanku;
  const ListItem(
      {super.key,
      required this.akun,
      required this.laporan,
      required this.isLaporanku});

  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  int like = 0;

  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  void delete() async {
    try {
      CollectionReference laporanCollection = _db.collection('laporan');

      if (widget.laporan.gambar != '') {
        await _storage.refFromURL(widget.laporan.gambar!).delete();
      }

      await laporanCollection.doc(widget.laporan.docId).delete();
    } catch (e) {
      print(e);
    }
  }

  void countingLike(String laporanId) async {
    debugPrint("count like");
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _db
          .collection("like")
          .where('laporan', isEqualTo: laporanId)
          .get();

      setState(() {
        like = querySnapshot.docs.length;
      });
    } catch (e) {
      debugPrint("$e");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(width: 2),
          borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/detail', arguments: {
            'akun': widget.akun,
            'laporan': widget.laporan,
          });
        },
        onLongPress: () {
          if (widget.isLaporanku)
            showDialog(
                context: context,
                builder: (BuildContext buildContext) {
                  return AlertDialog(
                    title: Text('Hapus ${widget.laporan.judul}?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(buildContext);
                        },
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          delete();
                          Navigator.pop(buildContext);
                        },
                        child: Text('Hapus'),
                      ),
                    ],
                  );
                });
        },
        child: Column(
          children: [
            widget.laporan.gambar != ''
                ? Image.network(
                    widget.laporan.gambar!,
                    width: 130,
                    height: 130,
                  )
                : Image.asset(
                    'assets/default.jpg',
                    width: 130,
                    height: 130,
                  ),
            Container(
              width: double.infinity,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                border: Border.symmetric(horizontal: BorderSide(width: 2)),
              ),
              child: Text(
                widget.laporan.judul,
                style: headerStyle(level: 4),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                        color: widget.laporan.status == 'Posted'
                            ? warnaStatus[0]
                            : widget.laporan.status == 'Process'
                                ? warnaStatus[1]
                                : warnaStatus[2],
                        border: Border(
                          right: BorderSide(width: 2),
                        ),
                        borderRadius:
                            BorderRadius.only(bottomLeft: Radius.circular(8))),
                    child: Text(
                      widget.laporan.status,
                      style: headerStyle(level: 5, dark: false),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: const Border.symmetric(
                            vertical: BorderSide(width: 1))),
                    alignment: Alignment.center,
                    child: Text(
                      '$like Like',
                      style: headerStyle(
                        level: 5,
                        dark: true,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius:
                            BorderRadius.only(bottomRight: Radius.circular(8))),
                    child: Text(
                      DateFormat('dd/MM/yyyy').format(widget.laporan.tanggal),
                      style: headerStyle(level: 6, dark: false),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
