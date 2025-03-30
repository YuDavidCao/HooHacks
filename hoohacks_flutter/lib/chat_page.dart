import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:hoohacks/global_bottom_navigation_bar.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final model = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: "AIzaSyAF18tAKW1rtT171MRTSKi5mpL0t5zP_-M",
  );

  final TextEditingController chatTextFieldController = TextEditingController();

  final List<Messages> messages = [];

  void onChatSend() async {
    setState(() {
      messages.add(
        Messages(
          text: chatTextFieldController.text,
          fromUser: true,
          time: DateTime.now(),
        ),
      );
    });
    final content = [
      Content.text(
        "This app is meant for students to improve their productivity and mental health, so make sure to give educational content. Here's the user's prompt: ${chatTextFieldController.text}",
      ),
    ];
    final response = await model.generateContent(content);
    setState(() {
      messages.add(
        Messages(
          text: response.text ?? "Error: No response",
          fromUser: false,
          time: DateTime.now(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Find Your Interest"), centerTitle: true),
      body: Stack(
        children: [
          if (messages.isEmpty)
            const Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Welcome User!",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(),
              ],
            ),
          if (messages.isNotEmpty)
            ListView(
              children: [
                for (var message in messages)
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment:
                          message.fromUser
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.only(
                                topLeft:
                                    message.fromUser
                                        ? const Radius.circular(0)
                                        : const Radius.circular(20),
                                topRight:
                                    message.fromUser
                                        ? const Radius.circular(20)
                                        : const Radius.circular(0),
                                bottomLeft: const Radius.circular(20),
                                bottomRight: const Radius.circular(20),
                              ),
                            ),
                            margin:
                                message.fromUser
                                    ? const EdgeInsets.only(right: 50)
                                    : const EdgeInsets.only(left: 50),
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                            child: Column(
                              crossAxisAlignment:
                                  message.fromUser
                                      ? CrossAxisAlignment.start
                                      : CrossAxisAlignment.end,
                              children: [
                                Text(
                                  (message.fromUser) ? "You" : "AI",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(message.text.trim(), maxLines: 10),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 80),
              ],
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                onSubmitted: (String text) {
                  onChatSend();
                  chatTextFieldController.clear();
                },
                controller: chatTextFieldController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: "What activity are you looking for?",
                  suffixIcon: IconButton(
                    onPressed: () {
                      onChatSend();
                      chatTextFieldController.clear();
                    },
                    icon: const Icon(Icons.send),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const GlobalBottomNavigationBar(
        pageName: "ChatPage",
      ),
    );
  }
}

class Messages {
  final String text;
  final bool fromUser;
  final DateTime time;

  Messages({required this.text, required this.fromUser, required this.time});
}
