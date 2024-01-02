import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lapor_book/component/styles.dart';
import 'package:flutter_lapor_book/model/akun.dart';
import 'package:flutter_lapor_book/pages/AllLaporan.dart';
import 'package:flutter_lapor_book/pages/MyLaporan.dart';
import 'package:flutter_lapor_book/pages/ProfilePage.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardFull();
  }
}

class DashboardFull extends StatefulWidget {
  const DashboardFull({super.key});

  @override
  State<StatefulWidget> createState() => _DashboardFull();
}

class _DashboardFull extends State<DashboardFull> {
  int _selectedIndex = 0;
  List<Widget> pages = [];

  void _onItemTrappeed(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Akun akun = Akun(
    email: '',
    nama: '',
    noHP: '',
    role: '',
    uid: '',
    docId: '',
  );

  void getAkun() async {
    setState(() {
      _isLoading = true;
    });

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('akun')
          .where('uid', isEqualTo: _auth.currentUser!.uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var userData = querySnapshot.docs.first.data() as Map<String, dynamic>;

        setState(() {
          akun = Akun(
            email: userData['email'],
            nama: userData['nama'],
            noHP: userData['noHP'],
            role: userData['role'],
            uid: userData['uid'],
            docId: userData['docId'],
          );
        });
      }
    } catch (e) {
      final snackbar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _isLoading = false;

  void initState() {
    super.initState();
    getAkun();
  }

  @override
  Widget build(BuildContext context) {
    pages = <Widget>[
      AllLaporan(akun: akun),
      MyLaporan(akun: akun),
      Profile(akun: akun),
    ];
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        child: Icon(Icons.add, size: 35),
        onPressed: () {
          Navigator.pushNamed(context, "/add", arguments: {
            'akun': akun,
          });
        },
      ),
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text('Lapor Book', style: headerStyle(level: 2)),
        centerTitle: true,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: primaryColor,
        currentIndex: _selectedIndex,
        onTap: _onItemTrappeed,
        selectedItemColor: Colors.white,
        selectedFontSize: 16,
        unselectedItemColor: Colors.grey[800],
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Semua',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            label: 'Laporan Saya',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            label: 'Profile',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : pages.elementAt(_selectedIndex),
    );
  }
}
