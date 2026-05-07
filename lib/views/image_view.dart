import 'package:flutter/material.dart';

class ImageView extends StatelessWidget {
  const ImageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amberAccent,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png'),

              const SizedBox(height: 20),

              Image.network(
                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSAwkw4ypTPlzJjNr1i_MbJOd3fyKTNgRe8nw&s',
              ),
            ],
          ),
        ),
      ),
    );
  }
}