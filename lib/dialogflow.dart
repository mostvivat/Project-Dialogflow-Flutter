import 'package:bubble/bubble.dart';
import 'package:dialogflow_flutter/googleAuth.dart';
import 'package:flutter/material.dart';
import 'package:dialogflow_flutter/dialogflowFlutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class Chatbot extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _ChatbotState createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue,
        primarySwatch: Colors.blue,
      ),
      home: ChatBotScreen(),
    );
  }
}

class ChatBotScreen extends StatefulWidget {
  @override
  _ChatBotScreenState createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final messageInsert = TextEditingController();
  List<Map> messsages = [];
  void response(query) async {
    AuthGoogle authGoogle =
        //Change the file name to your json file downloaded from dialogflow
        await AuthGoogle(fileJson: "assets/dialog_flow_auth.json").build();
    DialogFlow dialogflow = DialogFlow(authGoogle: authGoogle, language: "en");
    AIResponse aiResponse = await dialogflow.detectIntent(query);
    // Check if user input matches the specific string
    for (var message in aiResponse.getListMessage()!) {
      if (message.containsKey("payload")) {
        var payload = message["payload"]["richContent"][0];
        for (var content in payload) {
          if (content["type"] == "cards") {
            setState(() {
              messsages.insert(0, {
                "data": 0,
                "message": "",
                "cards": content["options"],
              });
            });
          } else if (content["type"] == "chips") {
            setState(() {
              messsages.insert(
                  0, {"data": 0, "message": "", "chips": content["options"]});
            });
          }
        }
      } else {
        setState(() {
          messsages.insert(
              0, {"data": 0, "message": message["text"]["text"][0].toString()});
        });
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
  
  void showInitialChips() {
    final List<dynamic> initialChips = [
      {"text": "คุยแก้เหงา"},
      {"text": "กินไรดี"},
      {"text": "ไปเที่ยวไหนดี"},
      {"text": "แนะนำเพลงหน่อย"}
    ];

    setState(() {
      messsages.insert(0, {
        "data": 0,
        "message": "สวัสดี",
        "chips": initialChips,
      });
    });
  }
  
  @override
  void initState() {
    super.initState();
    setState(() {
      messsages
          .insert(0, {"data": 0, "message": "สวัสดีมีอะใย"});
    });
    showInitialChips();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BuddyBot',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Color.fromARGB(255, 255, 255, 255),
            )),
        centerTitle: true,
         backgroundColor: const Color.fromARGB(255, 130, 219, 241),
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(top: 15, bottom: 10),
            child: Text(
              "Today, ${DateFormat("Hm").format(DateTime.now())}",
              style: const TextStyle(fontSize: 15),
            ),
          ),
          Flexible(
            child: ListView.builder(
                reverse: true,
                itemCount: messsages.length,
                itemBuilder: (context, index) => chat(
                    messsages[index]["message"].toString(),
                    messsages[index]["data"],
                    messsages[index]["chips"],
                    messsages[index]["cards"])),
          ),
          const SizedBox(
            height: 20,
          ),
          //sending section
          Container(
            decoration: const BoxDecoration(boxShadow: []),
            margin: const EdgeInsets.only(top: 15),
            child: ListTile(
              tileColor: Color.fromARGB(255, 160, 226, 245),
              title: Container(
                height: 35,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(17)),
                  color: Color.fromARGB(255, 207, 232, 243),
                ),
                padding: const EdgeInsets.only(left: 15),
                child: TextFormField(
                  controller: messageInsert,
                  decoration: InputDecoration(
                    hintText: "Type Your Message",
                    hintStyle: TextStyle(
                      color: Colors.black.withOpacity(0.5),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                  ),
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                  onChanged: (value) {},
                ),
              ),
              trailing: GestureDetector(
                onTap: () {
                  if (messageInsert.text.isEmpty) {
                    print("empty message");
                  } else {
                    setState(() {
                      messsages.insert(
                        0,
                        {"data": 1, "message": messageInsert.text},
                      );
                    });
                    response(messageInsert.text);
                    messageInsert.clear();
                  }
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                },
                child: const Icon(
                  Icons.send,
                  color: Color.fromARGB(255, 241, 0, 0),
                  size: 26,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget chat(
  String message, int data, List<dynamic>? chips, List<dynamic>? cards) {
  return Container(
    padding: const EdgeInsets.only(left: 20, right: 20),
    child: Row(
      mainAxisAlignment: data == 1 ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        data == 0
            ? const SizedBox(
                height: 40,
                width: 40,
                child: CircleAvatar(
                  backgroundImage: AssetImage("assets/robot.jpg"),
                ),
              )
            : Container(),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: cards != null
              ? Wrap(
                  direction: Axis.vertical,
                  runSpacing: 4.0,
                  spacing: 8.0,
                  children: cards.map(
                    (card) => InkWell(
                      onTap: () {
                        if (card.containsKey('link')) {
                          _launchUrl(card['link']); // Launch the URL if available
                        }
                      },
                      child: Column(
                        children: [
                          Image.network(
                            card['image'],
                            height: 100,
                            width: 100,
                          ),
                          const SizedBox(height: 5),
                          Text(card['title']),
                          const SizedBox(height: 5),
                          Text(
                            card['subtitle'],
                            style: const TextStyle(fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                  ).toList(),
                )
              : chips != null
                  ? Wrap(
                      direction: Axis.vertical,
                      runSpacing: 4.0,
                      spacing: 8.0,
                      children: chips.map(
                        (chip) => ActionChip(
                          backgroundColor:
                              const Color.fromRGBO(186, 255, 206, 1),
                          label: Text(chip['text'],
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 7, 7, 7))),
                          onPressed: () {
                            if (chip.containsKey('link')) {
                              _launchUrl(chip['link']);
                            } else {
                              setState(() {
                                messsages.insert(0,
                                    {"data": 1, "message": chip['text']});
                              });
                              response(chip['text']);
                            }
                          },
                        ),
                      ).toList(),
                    )
                  : Bubble(
                      radius: const Radius.circular(15.0),
                      color: data == 0
                          ? const Color.fromRGBO(156, 247, 235, 1)
                          : const Color.fromARGB(255, 248, 208, 155),
                      elevation: 0.0,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const SizedBox(
                              width: 10.0,
                            ),
                            Flexible(
                              child: Container(
                                constraints:
                                    const BoxConstraints(maxWidth: 200),
                                child: Text(
                                  message,
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 12, 12, 12)),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
        ),
        data == 1
            ? const SizedBox(
                height: 40,
                width: 40,
                child: CircleAvatar(
                  backgroundImage: AssetImage("assets/default.jpg"),
                ),
              )
            : Container(),
      ],
    ),
  );
}

}

