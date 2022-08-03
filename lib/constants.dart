import 'package:flutter/material.dart';

const kColorizeColors = [
  kDarkPurple,
  kSoftBlue,
  Color(0xFFF85572),
  kLightPurple,
  kExtraLightPurple,
];

const kDarkPurple = Color(0xFF1B0132);
const kExtraLightPurple = Color(0xFFEEDCFF);
const kLightPurple = Color(0xFFA271CC);
const kSoftBlue = Color(0xFF759EF2);

const kSendButtonTextStyle = TextStyle(
  color: kDarkPurple,
  fontWeight: FontWeight.bold,
  fontSize: 18.0,
);

const kMessageTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  hintText: 'Type your message here...',
  hintStyle: TextStyle(color: Color(0xFF5E4E63)),
  border: InputBorder.none,
);

const kMessageContainerDecoration = BoxDecoration(
  border: Border(
    top: BorderSide(color: kDarkPurple, width: 0.5),
  ),
);
