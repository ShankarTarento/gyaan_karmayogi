import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatMessage extends StatelessWidget {
  // static const route = AppUrl.dashboardProfilePage;
  final chatMessage;
  final bool isLoading;

  ChatMessage(this.chatMessage, {this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
        tween: Tween<double>(
          begin: 0.0,
          end: 1,
        ),
        duration: const Duration(milliseconds: 200),
        builder: (context, value, _) {
          return Transform.scale(
            alignment: Alignment.centerRight,
            scale: value,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width - 24),
                  child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, top: 8, bottom: 8),
                          child: isLoading
                              ? SizedBox(
                                  child: Center(
                                      child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  )),
                                  height: 16,
                                  width: 16,
                                )
                              : Text(chatMessage,
                                  textAlign: TextAlign.end,
                                  style: GoogleFonts.lato(
                                    color: Colors.white,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w400,
                                  )),
                        ),
                      ),
                    ],
                  ),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(0, 116, 182, 1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                    // border: Border.all(color: Color.fromRGBO(0, 116, 182, 1)),
                  )),
            ),
          );
        });
  }
}
