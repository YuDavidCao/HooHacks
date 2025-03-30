import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:hoohacks/activity_page.dart';
import 'package:hoohacks/firebase/firebase_firestore.dart';
import 'package:hoohacks/firebase/flask_endpint.dart';
import 'package:hoohacks/global_bottom_navigation_bar.dart';
import 'package:hoohacks/map_page.dart';
import 'package:hoohacks/models/activity_model.dart';

class InterestPage extends StatefulWidget {
  const InterestPage({super.key});

  @override
  State<InterestPage> createState() => _InterestPageState();
}

class _InterestPageState extends State<InterestPage> {
  final model = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: "AIzaSyAF18tAKW1rtT171MRTSKi5mpL0t5zP_-M",
  );

  final TextEditingController interestTextController = TextEditingController();

  final List<Messages> messages = [];

  bool loading = false;

  void onChatSend() async {
    setState(() {
      messages.add(
        Messages(
          text: interestTextController.text,
          fromUser: true,
          time: DateTime.now(),
          response: null,
        ),
      );
      loading = true;
    });
    Map<String, String> response = await getRelaventActivity(
      interestTextController.text,
    );
    setState(() {
      loading = false;
      messages.add(
        Messages(
          text: "",
          fromUser: false,
          time: DateTime.now(),
          response: response,
        ),
      );
    });
    // setState(() {
    //   messages.add(
    //     Messages(
    //       text: interestTextController.text,
    //       fromUser: true,
    //       time: DateTime.now(),
    //     ),
    //   );
    // });
    // final content = [
    //   Content.text(
    //     "This app is meant for students to improve their productivity and mental health, so make sure to give educational content. Here's the user's prompt: ${interestTextController.text}",
    //   ),
    // ];
    // final response = await model.generateContent(content);
    // setState(() {
    //   messages.add(
    //     Messages(
    //       text: response.text ?? "Error: No response",
    //       fromUser: false,
    //       time: DateTime.now(),
    //     ),
    //   );
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Find Your Interest"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          if (messages.isEmpty)
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Welcome ${FirebaseAuth.instance.currentUser!.displayName}",
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
                                  (message.fromUser)
                                      ? "You"
                                      : "Based on your interest",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                (message.fromUser)
                                    ? Text(message.text.trim(), maxLines: 10)
                                    : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        for (var key in message.response!.keys)
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  message.response![key]!,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  IconButton(
                                                    onPressed: () async {
                                                      ActivityModel?
                                                      activityModel =
                                                          await getActivityById(
                                                            key,
                                                          );
                                                      if (activityModel ==
                                                          null) {
                                                        return;
                                                      }
                                                      Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder:
                                                              (
                                                                context,
                                                              ) => MapPage(
                                                                activityModel:
                                                                    activityModel,
                                                              ),
                                                        ),
                                                      );
                                                    },
                                                    icon: const Icon(
                                                      Icons.location_pin,
                                                    ),
                                                  ),
                                                  IconButton(
                                                    onPressed: () async {
                                                      ActivityModel?
                                                      activityModel =
                                                          await getActivityById(
                                                            key,
                                                          );
                                                      if (activityModel ==
                                                          null) {
                                                        return;
                                                      }
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder:
                                                              (
                                                                context,
                                                              ) => ActivityPage(
                                                                activityModel:
                                                                    activityModel,
                                                              ),
                                                        ),
                                                      );
                                                    },
                                                    icon: const Icon(
                                                      Icons.arrow_right,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
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
                  interestTextController.clear();
                },
                controller: interestTextController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: "What activity are you looking for?",
                  suffixIcon: IconButton(
                    onPressed: () {
                      onChatSend();
                      interestTextController.clear();
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
        pageName: "InterestPage",
      ),
    );
  }
}

class Messages {
  final String text;
  final bool fromUser;
  final DateTime time;
  final Map<String, String>? response;

  Messages({
    required this.text,
    required this.fromUser,
    required this.time,
    required this.response,
  });
}
