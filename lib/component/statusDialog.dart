import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lapor_book/component/styles.dart';
import 'package:flutter_lapor_book/model/laporan.dart';

class StatusDialog extends StatefulWidget {
  final Laporan laporan;

  const StatusDialog({super.key, required this.laporan});

  @override
  State<StatusDialog> createState() => _StatusDialogState();
}

class _StatusDialogState extends State<StatusDialog> {
  late String status;
  final _firestore = FirebaseFirestore.instance;

  void updateStatus() async {
    CollectionReference laporanCollection = _firestore.collection('laporan');
    try {
      await laporanCollection.doc(widget.laporan.docId).update({
        'status': status,
      });
      Navigator.pushNamed(context, '/dashboard');
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    status = widget.laporan.status;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: primaryColor,
      content: Container(
        height: 320,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Text(
              widget.laporan.judul,
              style: headerStyle(level: 3),
            ),
            SizedBox(
              height: 15,
            ),
            RadioListTile(
                title: Text('Posted'),
                value: 'Posted',
                groupValue: status,
                onChanged: (value) {
                  setState(() {
                    status = value!;
                  });
                }),
            RadioListTile(
                title: Text('Process'),
                value: 'Process',
                groupValue: status,
                onChanged: (value) {
                  setState(() {
                    status = value!;
                  });
                }),
            RadioListTile(
                title: Text('Done'),
                value: 'Done',
                groupValue: status,
                onChanged: (value) {
                  setState(() {
                    status = value!;
                  });
                }),
            SizedBox(
              height: 15,
            ),
            ElevatedButton(
              onPressed: () {
                updateStatus();
              },
              child: Text('Ubah Status'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
