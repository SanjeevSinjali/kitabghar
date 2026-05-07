import 'package:flutter/material.dart';

class MediaqueryView extends StatelessWidget {
  const MediaqueryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Container'),
      ),
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width * .5,
          height: MediaQuery.of(context).size.height * .5,
          color: Colors.yellow,
        ),
      ),
    );
  }
}