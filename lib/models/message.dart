// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  List uids;
  String sender;
  String receiver;
  String text;

  Message({
    required this.uids,
    required this.sender,
    required this.receiver,
    required this.text,
  });

  static Future<void> sendAMessage(
      String sender, String receiver, String text, List uids) async {
    DocumentReference<Map<String, dynamic>> doc = FirebaseFirestore.instance
        .collection('messages')
        .doc('${uids[0]}${uids[1]}');

    await doc.collection('messages').add({
      'sender': sender,
      'receiver': receiver,
      'text': text,
      'timestamp': DateTime.now().toString()
    });
  }
}

//  static Future<void> sendAMessage(
//       String sender, String receiver, String text, List uids) async {
//     QuerySnapshot<Map<String, dynamic>> snap = await FirebaseFirestore.instance
//         .collection('messages')
//         .where('uids', isEqualTo: uids)
//         .get();

//     if (snap.docs.length == 0) {
//       await FirebaseFirestore.instance
//           .collection('messages')
//           .doc('${uids[0]}${uids[1]}')
//           .set({'uids': '${uids[0]}${uids[1]}'});
//     }

//     await FirebaseFirestore.instance
//         .collection('messages')
//         .doc('${uids[0]}${uids[1]}')
//         .collection('messages')
//         .add({
//       'sender': sender,
//       'receiver': receiver,
//       'text': text,
//       'timestamp': DateTime.now().toString()
//     });
//   }