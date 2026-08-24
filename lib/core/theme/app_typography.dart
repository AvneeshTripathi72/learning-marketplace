import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  // H1 (Chapter Title): Lexend 700, 24sp
  static TextStyle h1(Color color) => GoogleFonts.lexend(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: color,
      );

  // H2 (Section Title): Lexend 600, 20sp
  static TextStyle h2(Color color) => GoogleFonts.lexend(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: color,
      );

  // Body: Literata 400, 16sp
  static TextStyle body(Color color, {double fontSize = 16}) => GoogleFonts.literata(
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: color,
      );

  // Caption: Inter 400, 12sp
  static TextStyle caption(Color color) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: color,
      );

  // Button Text: Inter 500, 14sp
  static TextStyle button(Color color) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color,
      );
}
