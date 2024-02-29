import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_instagram_clone/models/message.dart';
import 'package:my_instagram_clone/models/user.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.otherUser});
  final MyUser otherUser;
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  // these are the uids of this chat and they will be sorted
  late List uids;

  @override
  void initState() {
    super.initState();
    uids = List.from([MyUser.currentUser!.uid, widget.otherUser.uid]);
    uids.sort();
  }

  void scrollToEnd() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 100), curve: Curves.bounceIn);
  }

  @override
  void dispose() {
    super.dispose();
    _messageController.dispose();
  }

  void sendMessage() async {
    if (_messageController.text != '') {
      await Message.sendAMessage(MyUser.currentUser!.uid, widget.otherUser.uid,
          _messageController.text, uids);
      _messageController.text = '';

      scrollToEnd();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.otherUser.profilePicUrl),
              radius: 20,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              widget.otherUser.username,
              style: const TextStyle(fontWeight: FontWeight.bold),
            )
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.videocam,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.flag,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.info_outline,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  hintText: 'Message...',
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 5),
                  ),
                ),
              ),
            ),
            IconButton(
                onPressed: sendMessage, icon: const Icon(Icons.arrow_upward))
          ],
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('messages')
            .doc('${uids[0]}${uids[1]}')
            .collection('messages')
            .orderBy('timestamp')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                QueryDocumentSnapshot<Map<String, dynamic>> doc =
                    snapshot.data!.docs[index];
                return message(doc['sender'] == MyUser.currentUser!.uid,
                    snapshot.data!.docs[index]['text']);
              },
            ),
          );
        },
      ),
    );
  }

  Widget message(bool isMe, String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: isMe
                  ? const Color.fromARGB(255, 51, 14, 139)
                  : const Color.fromARGB(83, 111, 117, 114)),
          child: Text(text),
        ),
      ),
    );
  }
}
