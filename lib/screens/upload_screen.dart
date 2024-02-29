import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_instagram_clone/models/post.dart';
import 'package:my_instagram_clone/models/user.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  Uint8List? file;
  bool isLoading = false;
  TextEditingController _descriptionController = TextEditingController();

  pickImage(ImageSource source) async {
    Navigator.pop(context);
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(source: source);
    if (file != null) {
      this.file = await file.readAsBytes();
      setState(() {});
    }
  }

  void uploadPost() async {
    setState(() {
      isLoading = true;
    });
    Post post = Post(
        uid: MyUser.currentUser!.uid,
        profilePicUrl: MyUser.currentUser!.profilePicUrl,
        username: MyUser.currentUser!.username,
        pubDate: DateTime.now().toString(),
        description: _descriptionController.text);
    await post.uploadPost(file!);
    MyUser.currentUser!.posts++;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'The post has been shared successfully',
        ),
      ),
    );
    setState(() {
      isLoading = false;
      file = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: file == null
          ? null
          : AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  file = null;
                  setState(() {});
                },
              ),
              actions: [
                TextButton(
                    onPressed: uploadPost,
                    child: const Text(
                      'Post',
                      style: TextStyle(color: Colors.blue, fontSize: 20),
                    ))
              ],
              title: const Text(
                'Post to',
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
            ),
      body: file != null
          ? shareAPost()
          : Center(
              child: IconButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (c) => SimpleDialog(
                              children: [
                                SimpleDialogOption(
                                  onPressed: () {
                                    pickImage(ImageSource.camera);
                                  },
                                  child: const Text(
                                    'From camera',
                                    style: TextStyle(fontSize: 25),
                                  ),
                                ),
                                SimpleDialogOption(
                                  child: const Text('From gallery',
                                      style: TextStyle(fontSize: 25)),
                                  onPressed: () {
                                    pickImage(ImageSource.gallery);
                                  },
                                ),
                              ],
                            ));
                  },
                  icon: const Icon(Icons.upload)),
            ),
    );
  }

  Widget shareAPost() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          if (isLoading) const LinearProgressIndicator(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                backgroundImage:
                    NetworkImage(MyUser.currentUser!.profilePicUrl),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                    hintText: 'Write a caption...',
                  ),
                ),
              ),
              Image.memory(
                file!,
                height: 60,
                width: 60,
              )
            ],
          ),
        ],
      ),
    );
  }
}
