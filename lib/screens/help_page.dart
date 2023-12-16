import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class HelpPage extends StatelessWidget {
  final TextEditingController messageController = TextEditingController();

  void _sendEmail() async {
    // Set up the SMTP server configuration
    final smtpServer = gmail('vitalcarex@gmail.com', 'vital7care7x@');

    // Create our email message
    final message = Message()
      ..from = Address('sarmadsabir6@gmail.com', 'Sarmad')
      ..recipients.add('sarmadsabir7@gmail.com')
      ..subject = 'Help Request'
      ..text = messageController.text;

    try {
      // Send the email
      final sendReport = await send(message, smtpServer);

      print('Message sent: ' + sendReport.toString());
    } catch (error) {
      print('Error occurred: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.help_outline,
                size: 100.0,
                color: Color.fromARGB(255, 38, 59, 135),
              ),
              SizedBox(height: 30),
              Text(
                'Please mention your problem:',
                style: TextStyle(fontSize: 18, fontFamily: 'Nexa'),
              ),
              SizedBox(height: 10),
              Container(
                width: 300,
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: const Color.fromARGB(255, 6, 69, 120)),
                ),
                child: TextFormField(
                  controller: messageController,
                  maxLines: 5,
                  style: TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Type your message here',
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _sendEmail,
                child: Text(
                  'Send',
                  style: TextStyle(fontFamily: 'Nexa'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
