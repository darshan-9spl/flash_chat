import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final firestore = FirebaseFirestore.instance;
User? loggedInUser;

class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;

  TextEditingController _editMsg = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    print("User======" + loggedInUser!.email.toString());
  }

  @override
  void deactivate() async {
    await _auth.signOut();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // await _auth.signOut();
        Navigator.popUntil(context, ModalRoute.withName(WelcomeScreen.id));
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: null,
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.close),
                onPressed: () async {
                  //Implement logout functionality
                  await _auth.signOut();
                  // Navigator.pop(context);
                  Navigator.popUntil(
                      context, ModalRoute.withName(WelcomeScreen.id));
                  // messagesStreams();
                  // getMessage();
                  // print(_auth.currentUser);
                }),
          ],
          title: Text('⚡️Chat'),
          backgroundColor: Colors.lightBlueAccent,
        ),
        body: SafeArea(
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                MessageStream(),
                Container(
                  decoration: kMessageContainerDecoration,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _editMsg,
                          keyboardType: TextInputType.text,
                          decoration: kMessageTextFieldDecoration,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          //Implement send functionality.
                          try {
                            if (_editMsg.text.isNotEmpty) {
                              firestore.collection('messages').add({
                                'text': _editMsg.text,
                                'sender': loggedInUser!.email
                              });
                              _editMsg.clear();
                            } else {}
                          } on Exception catch (e) {
                            print("Errorrrrr=====$e");
                          }
                        },
                        child: Text(
                          'Send',
                          style: kSendButtonTextStyle,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser!.email);
      }
    } catch (e) {
      print(e);
    }
  }

  void getMessage() async {
    final messages = await firestore.collection('messages').get();
    try {
      for (var message in messages.docs) {
        print("message=====" + message.data().toString());
      }
    } catch (e) {
      print("Error====$e");
    }
  }

  /* void messagesStreams() async {
    await for (var snapshot in firestore.collection('messages').snapshots()) {
      for (var message in snapshot.docs) {
        print("message=====${message.data}");
      }
    }
  }*/
}

class MessageStream extends StatelessWidget {
  const MessageStream({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection('messages').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        } else {
          final messages = snapshot.data!.docs.reversed;
          List<MessageBubble> messageBubbles = [];
          for (var message in messages) {
            Map msg = message.data() as Map<String, dynamic>;
            final messageTxt = msg['text'].toString();
            final messageSender = msg['sender'].toString();
            final currentUser = loggedInUser!.email.toString();

            /*final messageWidget = Text(
                          '$messageTxt from $messageSender',
                          style: TextStyle(fontSize: 50),
                        );*/
            final messageBubble = MessageBubble(
                text: messageTxt,
                sender: messageSender,
                isMe: currentUser == messageSender);
            messageBubbles.add(messageBubble);
          }
          return Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              reverse: true,
              children: messageBubbles,
            ),
          );
        }
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String text;
  final String sender;
  final bool isMe;
  MessageBubble({required this.text, required this.sender, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(fontSize: 12.0, color: Colors.black54),
          ),
          Material(
            // color: Colors.lightBlueAccent,
            color: !isMe ? Colors.white : Colors.lightBlueAccent,
            elevation: 5.0,
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30))
                : BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
                '$text',
                style: TextStyle(
                    fontSize: 15, color: isMe ? Colors.white : Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
