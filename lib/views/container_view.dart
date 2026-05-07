import 'package:flutter/material.dart';

class ContainerView extends StatelessWidget {
  const ContainerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Container View")),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topRight,
          child: Container(
            width: 200,
            height: 200,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.yellow,
              border: Border.all(
                color: Colors.black,
                width: 2,
              ),
            ),
            child: const Text(
              "Container 1",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}