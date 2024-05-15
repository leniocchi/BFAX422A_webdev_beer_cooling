import 'package:flutter/material.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  _HomePageState();

  String _userInput = "";
  String _aiAnswer = "";

  ChatApi? _api;

  void _setAiAnswer(Message message) {
    setState(() {
      _aiAnswer = message.message ?? "<no message received>";
    });
  }

  void _setUserInput(String input) {
    _userInput = input;
  }

  void _askAI() async {
    var message = Message(
      timestamp: DateTime.now().toUtc(),
      author: MessageAuthorEnum.user,
      message: _userInput,
    );

    var response = await _api!.chat(message);

    _setAiAnswer(response!);
  }

  @override
  Widget build(BuildContext context) {
    _api = Provider.of<ChatApi>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          TextField(
            key: const Key('UserInputTextField'),
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Enter text here',
            ),
            onChanged: (String value) {
              _setUserInput(value);
            },
          ),
          Expanded(
            child: Text(
              _aiAnswer,
              key: const Key('AiAnswerText'),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Ask AI',
        onPressed: _askAI,
        child: const Icon(Icons.send),
      ),
    );
  }
}