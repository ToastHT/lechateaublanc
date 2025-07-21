import 'package:flutter/material.dart';

class Message extends StatefulWidget {
  final bool isAdmin;

  Message({required this.isAdmin});

  @override
  _MessageState createState() => _MessageState();
}

class _MessageState extends State<Message> {
  TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> messages = [
    {
      'sender': 'Support',
      'message': 'Hello! How can we help you today?',
      'time': '10:30 AM',
      'isMe': false,
    },
    {
      'sender': 'You',
      'message': 'Hi, I want to ask about my order.',
      'time': '10:32 AM',
      'isMe': true,
    },
    {
      'sender': 'Support',
      'message': 'Sure! What would you like to know about your order?',
      'time': '10:33 AM',
      'isMe': false,
    },
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        messages.add({
          'sender': 'You',
          'message': _messageController.text.trim(),
          'time': '${DateTime.now().hour}:${DateTime.now().minute}',
          'isMe': true,
        });
      });
      _messageController.clear();

      // Auto reply after 2 seconds
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          messages.add({
            'sender': 'Support',
            'message':
                'Thank you for your message. We will get back to you soon!',
            'time': '${DateTime.now().hour}:${DateTime.now().minute}',
            'isMe': false,
          });
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('Messages', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Align(
                  alignment: message['isMe']
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    decoration: BoxDecoration(
                      color: message['isMe'] ? Colors.orange : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message['message'],
                          style: TextStyle(
                            color:
                                message['isMe'] ? Colors.white : Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          message['time'],
                          style: TextStyle(
                            color: message['isMe']
                                ? Colors.white.withOpacity(0.8)
                                : Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  backgroundColor: Colors.orange,
                  child: Icon(Icons.send, color: Colors.white),
                  mini: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
