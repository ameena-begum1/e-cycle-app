import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatbotScreen> {
  final TextEditingController _userInput = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: dotenv.env['GEMINI_API_KEY']!);

  final List<Message> _messages = [];
  bool _isTyping = false;
  String? selectedTopic;

  final List<String> topics = [
    "Product Issues",
    "Repair Suggestions",
    "Recycling Options",
    "Selling Price Estimation",
    "Second-hand vs New Product Comparison"
  ];

  @override
  void initState() {
    super.initState();
    _messages.add(Message(isUser: false, message: "Welcome to ई-Assistant! How can I assist you today?"));
  }

  Future<void> sendMessage() async {
    if (_isTyping) return;
    final message = _userInput.text.trim();
    if (message.isEmpty || selectedTopic == null) return;

    setState(() {
      _isTyping = true;
      _messages.add(Message(isUser: true, message: message));
      _userInput.clear();
      _messages.add(Message(isUser: false, message: "..."));
    });

    _scrollToBottom();

    try {
      final response = await model.generateContent([Content.text("User selected topic: $selectedTopic. Now they asked: $message. Reply in context.")]);
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _messages.removeWhere((msg) => msg.message == "...");
        _messages.add(Message(isUser: false, message: response.text ?? "No response"));
        _isTyping = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.removeWhere((msg) => msg.message == "...");
        _messages.add(Message(isUser: false, message: "Error: ${e.toString()}"));
        _isTyping = false;
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void selectTopic(String topic) {
    setState(() {
      selectedTopic = topic;
      _messages.add(Message(isUser: false, message: "You selected **$topic**. Now ask your question."));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
    backgroundColor: Color(0xFF003366),
    iconTheme: IconThemeData(color: Colors.white), // Makes the back button white
    title: const Text(
      "ई-Assistant",
      style: TextStyle(color: Colors.white),
    ),
  ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/images/E-cycle_logo.jpeg',
                width: 500,
              ),
            ),
          ),
      Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return MessageBubble(isUser: message.isUser, message: message.message);
              },
            ),
          ),
          if (selectedTopic == null)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: topics.map((topic) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF003366)),
                  onPressed: () => selectTopic(topic),
                  child: Text(topic, style: TextStyle(color: Colors.white)),
                );
              }).toList(),
            ),
          if (selectedTopic != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _userInput,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Enter Your Message',
                        hintStyle: TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Color.fromARGB(255, 54, 100, 146),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: _isTyping ? Colors.grey : Color(0xFF003366)),
                    onPressed: _isTyping ? null : sendMessage,
                  ),
                ],
              ),
            ),
        ],
      ),
    ],
    ), 
    );
  }
}

class Message {
  final bool isUser;
  final String message;
  Message({required this.isUser, required this.message});
}

class MessageBubble extends StatelessWidget {
  final bool isUser;
  final String message;

  const MessageBubble({super.key, required this.isUser, required this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          decoration: BoxDecoration(
            color: isUser ? Color(0xFF004488) : Color(0xFF002244),
            borderRadius: BorderRadius.circular(15),
          ),
          child: MarkdownBody(
            data: message,
            styleSheet: MarkdownStyleSheet(p: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
