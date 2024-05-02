import 'package:flutter/material.dart';

import '../../util/faderoute.dart';
import '../screens/_screens/chat_bot.dart';

class Chatbotbtn extends StatefulWidget {
  final String loggedInStatus;

  const Chatbotbtn({Key key, this.loggedInStatus}) : super(key: key);
  @override
  ChatbotbtnState createState() => ChatbotbtnState();
}

class ChatbotbtnState extends State<Chatbotbtn> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 150.0),
        child: FloatingActionButton(
            backgroundColor: Colors.transparent,
            elevation: 0,
            onPressed: () {},
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(20), right: Radius.zero)),
            child: Transform.scale(
                scale: 1.8,
                child: IconButton(
                  icon: Image.asset('assets/img/KS_banner.png'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      FadeRoute(
                        page: ChatBot(
                          loggedInStatus: widget.loggedInStatus,
                        ),
                      ),
                    );
                  },
                ))),
      ),
    );
  }
}
