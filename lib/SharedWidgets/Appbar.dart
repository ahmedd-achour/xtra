import 'package:flutter/material.dart';

final sharedappbar = AppBar(
  backgroundColor: Colors.transparent,
  elevation: 0,
  centerTitle: true,
  title: Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      SizedBox(
        width: 120,
        child: Image.asset(
          'assets/movmap.png',
          height: 50,
          fit: BoxFit.contain,
        ),
      ),
    ],
  ),
);
