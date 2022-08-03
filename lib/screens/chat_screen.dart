import 'package:corporate_chat/screens/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:corporate_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;
late User loggedInUser;

class ChatScreen extends StatefulWidget {
  static const String id = 'Chat';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  late String messageText;

  void getCurrentUser() {
    final currentUser = _auth.currentUser;
    try {
      if (currentUser != null) {
        loggedInUser = currentUser;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20.0),
            bottomRight: Radius.circular(20.0),
          ),
        ),
        foregroundColor: kDarkPurple,
        centerTitle: true,
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.close,
                color: kDarkPurple,
              ),
              onPressed: () {
                _auth.signOut();
                Navigator.pushNamed(context, WelcomeScreen.id);
              }),
        ],
        title: Text(
          'CORPORATE CHAT',
          style: TextStyle(color: kDarkPurple),
        ),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 4,
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: const BoxDecoration(
                          color: Color(0xFFF3EFF5),
                          border: Border(
                              left:
                                  BorderSide(color: kDarkPurple, width: 0.2))),
                      child: FloatingActionButton(
                        backgroundColor: Colors.white.withOpacity(0),
                        elevation: 0,
                        onPressed: () {
                          messageTextController.clear();
                          _firestore.collection('messages').add({
                            'text': messageText,
                            'sender': loggedInUser.email,
                            'timestamp': FieldValue.serverTimestamp(),
                          });
                        },
                        child: const Text(
                          'Send',
                          style: kSendButtonTextStyle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream:
            _firestore.collection('messages').orderBy('timestamp').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Expanded(
              child: Center(
                child: CircularProgressIndicator(
                  backgroundColor: kDarkPurple,
                ),
              ),
            );
          }
          final messages = snapshot.data!.docs;
          List<MessageBubble> messageBubbles = [];
          for (var message in messages) {
            final currentUser = loggedInUser.email;
            final messageText = message.get('text');
            final messageSender = message.get('sender');
            final messageTime = message.get('timestamp');

            final messageBubble = MessageBubble(
              sender: messageSender,
              text: messageText,
              time: messageTime != null
                  ? messageTime.toDate().toString()
                  : 'Time not available',
              isMe: currentUser == messageSender,
            );
            messageBubbles.add(messageBubble);
          }
          return Expanded(
              child: ListView(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                  children: messageBubbles));
        });
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble(
      {super.key,
      required this.sender,
      required this.text,
      required this.time,
      required this.isMe});

  final String sender;
  final String text;
  final String time;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 3.0),
            child: Text(
              sender,
              style: TextStyle(color: kDarkPurple, fontSize: 12.0),
            ),
          ),
          Material(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isMe ? 30.0 : 0),
                  topRight: Radius.circular(isMe ? 0 : 30.0),
                  bottomLeft: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0)),
              elevation: 5.0,
              color: isMe ? kLightPurple : kSoftBlue,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                child: Text(
                  '$text',
                  style: TextStyle(color: Colors.white, fontSize: 15.0),
                ),
              )),
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Text(
              time.substring(0, 16),
              style: TextStyle(
                color: kDarkPurple,
                fontSize: 12.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
