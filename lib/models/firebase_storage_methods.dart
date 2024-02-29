import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:my_instagram_clone/models/user.dart';

class FirebaseStorageMethods {
  static Future<String> uploadFile(Uint8List file, String postId) async {
    Reference ref = FirebaseStorage.instance
        .ref('posts')
        .child(MyUser.currentUser!.uid)
        .child(postId);
    TaskSnapshot snap = await ref.putData(file);
    return await snap.ref.getDownloadURL();
  }
}
