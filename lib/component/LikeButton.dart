import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lapor_book/model/laporan.dart';

class LikeButton extends StatefulWidget {
  final Laporan _laporan;
  final void Function(int newLikeCount)? _refreshLike;
  const LikeButton({
    super.key,
    required Laporan laporan,
    void Function(int newLikeCount)? refreshLike,
  })  : _laporan = laporan,
        _refreshLike = refreshLike;

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  final String collectionName = 'like';

  bool isLoading = false;

  bool liked = false;
  late String idUser;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void checkLikedLaporan() async {
    debugPrint("checking like status");
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection(collectionName)
          .where('laporan', isEqualTo: widget._laporan.docId)
          .where('akun', isEqualTo: idUser)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        debugPrint("laporan sudah kamu like");
        setState(() {
          liked = true;
        });
      }
    } catch (e) {
      print(e);
    }
    // mendapatkan daftar like

    // cari like yang userId dan loperanId nya sesuai
    // jika ditemukan like yang sesuai ubah liked => true
  }

  Future<int> countingLike() async {
    debugPrint("counting like");
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection(collectionName)
          .where('idLaporan', isEqualTo: widget._laporan.docId)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      debugPrint("$e");
      rethrow;
    }
  }

  void like() async {
    setState(() {
      isLoading = true;
    });
    debugPrint(widget._laporan.judul);
    // tambahkan like

    try {
      CollectionReference likesCollection =
          _firestore.collection(collectionName);
      Timestamp timestamp = Timestamp.fromDate(DateTime.now());

      await likesCollection.doc().set({
        'akun': idUser,
        'laporan': widget._laporan.docId,
        'tanggal': timestamp,
      }).catchError((e) {
        throw e;
      });

      // hilangkan tombol like
      setState(() {
        liked = true;
      });

      int likes = await countingLike();

      widget._refreshLike?.call(likes);
    } catch (e) {
      final snackbar = SnackBar(content: Text(e.toString()));
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    FirebaseAuth auth = FirebaseAuth.instance;
    idUser = auth.currentUser!.uid;
    checkLikedLaporan();
  }

  @override
  Widget build(BuildContext context) {
    return liked
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ElevatedButton(
              onPressed: () {
                if (!isLoading) {
                  debugPrint("Like dipanggil");
                  like();
                }
              },
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                padding: EdgeInsets.all(16),
                primary: Colors.white,
                onPrimary: Colors.red[200],
              ),
              child: Icon(
                Icons.favorite,
                color: Colors.red[200],
                size: 32,
              ),
            ),
          );
  }
}
