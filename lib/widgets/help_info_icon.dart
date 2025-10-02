import 'package:flutter/material.dart';

class HelpInfoIcon extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;

  const HelpInfoIcon({
    super.key,
    required this.title,
    required this.content,
    this.icon = Icons.help_outline,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(title),
              content: Text(content),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
