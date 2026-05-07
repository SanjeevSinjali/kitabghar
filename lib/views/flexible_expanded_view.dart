import 'package:flutter/material.dart';

class FlexibleExpandedView extends StatelessWidget {
  const FlexibleExpandedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Containers'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              color: Colors.yellow,
              child: const Center(
                child: Text(
                  'Container 1',
                  style: TextStyle(color: Colors.black, fontSize: 50),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              color: Colors.red,
              child: const Center(
                child: Text(
                  'Container 2',
                  style: TextStyle(color: Colors.black, fontSize: 50),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}