// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
hexstringTocolor(String hexcolor){
  hexcolor=hexcolor.toUpperCase().replaceAll("#", "");
  if(hexcolor.length==6){
    hexcolor="FF"+hexcolor;
  }
  return Color(int.parse(hexcolor,radix: 16));
}