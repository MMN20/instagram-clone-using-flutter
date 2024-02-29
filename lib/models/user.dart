import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class MyUser {
  String uid;
  String email;
  int followers;
  int following;
  String profilePicUrl;
  String bio;
  String username;
  int posts;

  static Future<List<MyUser>> getSearchedUsers(String username) async {
    List<MyUser> users = [];
    QuerySnapshot<Map<String, dynamic>> snap = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: username)
        .get();

    for (var doc in snap.docs) {
      // to get the number of posts for each user
      QuerySnapshot<Map<String, dynamic>> snap2 = await FirebaseFirestore
          .instance
          .collection('posts')
          .where('uid', isEqualTo: doc['uid'])
          .get();

      users.add(
        MyUser(
          uid: doc['uid'],
          email: doc['email'],
          followers: doc['followers'].length,
          following: doc['following'].length,
          profilePicUrl: doc['profilePicUrl'],
          bio: doc['bio'],
          username: doc['username'],
          posts: snap2.size,
        ),
      );
    }
    return users;
  }

  Future<List<MyUser>> getAllMyFollowing() async {
    List<MyUser> users = [];

    DocumentSnapshot<Map<String, dynamic>> doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (doc['following'].length != 0) {
      QuerySnapshot<Map<String, dynamic>> snap = await FirebaseFirestore
          .instance
          .collection('users')
          .where('uid', whereIn: doc['following'])
          .get();

      for (var doc in snap.docs) {
        users.add(MyUser(
            uid: doc['uid'],
            email: doc['email'],
            followers: doc['followers'].length,
            following: doc['following'].length,
            profilePicUrl: doc['profilePicUrl'],
            bio: doc['bio'],
            username: doc['username'],
            posts: 0));
      }
    }
    return users;
  }

  Future<void> followUnfollow(String uid, bool follow) async {
    DocumentReference<Map<String, dynamic>> myDoc =
        FirebaseFirestore.instance.collection('users').doc(this.uid);

    DocumentReference<Map<String, dynamic>> otherDoc =
        FirebaseFirestore.instance.collection('users').doc(uid);

    WriteBatch batch = FirebaseFirestore.instance.batch();
    if (follow) {
      batch.update(
        myDoc,
        {
          'following': FieldValue.arrayRemove([uid])
        },
      );

      batch.update(
        otherDoc,
        {
          'followers': FieldValue.arrayRemove([this.uid])
        },
      );
      currentUser!.following--;
    } else {
      batch.update(
        myDoc,
        {
          'following': FieldValue.arrayUnion([uid])
        },
      );

      batch.update(
        otherDoc,
        {
          'followers': FieldValue.arrayUnion([this.uid])
        },
      );
      currentUser!.following++;
    }
    await batch.commit();
  }

  Future<bool> doIFollow(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(this.uid)
        .get();
    return doc['following'].contains(uid);
  }

  static Future<MyUser?> get getCurrentUser async {
    if (FirebaseAuth.instance.currentUser == null) {
      return null;
    }

    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot<Map<String, dynamic>> snap =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    QuerySnapshot<Map<String, dynamic>> snap2 = await FirebaseFirestore.instance
        .collection('posts')
        .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    print(
        '${snap2.size} n of posts ===========================================');

    return MyUser._fromMap(snap.data()!, snap2.size);
  }

  static MyUser? currentUser;

  static Future<MyUser?> findUserByID(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      QuerySnapshot<Map<String, dynamic>> snap = await FirebaseFirestore
          .instance
          .collection('posts')
          .where('uid', isEqualTo: uid)
          .get();

      return MyUser(
        uid: doc['uid'],
        email: doc['email'],
        followers: doc['followers'].length,
        following: doc['following'].length,
        profilePicUrl: doc['profilePicUrl'],
        bio: doc['bio'],
        username: doc['username'],
        posts: snap.size,
      );
    } catch (e) {
      print(e.toString());
    }

    return null;
  }

  MyUser(
      {required this.uid,
      required this.email,
      required this.followers,
      required this.following,
      required this.profilePicUrl,
      required this.bio,
      required this.username,
      this.posts = 0});

  factory MyUser._fromMap(Map<String, dynamic> map, int nOfPosts) {
    return MyUser(
        uid: map['uid'],
        email: map['email'],
        followers: map['followers'].length,
        following: map['following'].length,
        profilePicUrl: map['profilePicUrl'],
        bio: map['bio'],
        username: map['username'],
        posts: nOfPosts);
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'profilePicUrl': profilePicUrl,
      'bio': bio,
      'followers': followers,
      'following': following,
      'username': username
    };
  }

  static Future<MyUser?> signInUser(String email, String password) async {
    try {
      UserCredential cred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(cred.user!.uid)
          .get();
      QuerySnapshot<Map<String, dynamic>> snap = await FirebaseFirestore
          .instance
          .collection('posts')
          .where('uid', isEqualTo: cred.user!.uid)
          .get();

      return MyUser._fromMap(doc.data()!, snap.size);
    } catch (e) {
      print(e.toString());
    }
    return null;
  }

  static Future<MyUser?> signUpUser(
      {required String email,
      required String password,
      required String username,
      required Uint8List? file,
      required String bio}) async {
    try {
      // saving to firebase auth
      UserCredential cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // saving the profile pic to firebase storage
      Reference ref =
          FirebaseStorage.instance.ref('profilePics').child(cred.user!.uid);
      String profilePicUrl;
      if (file != null) {
        TaskSnapshot snap = await ref.putData(file);
        profilePicUrl = await snap.ref.getDownloadURL();
      } else {
        profilePicUrl =
            'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png';
      }

      // saving to firebaseFirestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set({
        'uid': cred.user!.uid,
        'email': email,
        'profilePicUrl': profilePicUrl,
        'bio': bio,
        'followers': [],
        'following': [],
        'username': username
      });

      return MyUser._fromMap({
        'uid': cred.user!.uid,
        'email': email,
        'profilePicUrl': profilePicUrl,
        'bio': bio,
        'followers': [],
        'following': [],
        'username': username
      }, 0);
    } catch (e) {
      print(e.toString());
    }
    return null;
  }
}
