import 'package:flutter/material.dart';

const LIGHT_GREY_COLOR=Color(0xFFCDCDCD);
const Middle_GREY_COLOR=Color(0xFFA5A5A5);
const DARK_GREY_COLOR=Color(0xFF656464);

enum ColorType {
  pinkLight,
  peachLight,
  yellowLight,
  paleYellow,
  lightYellowGreen,
  aquaGreen,
  skyBlue,
  lightBlue,
  paleBlue,
  lavender,
  lightLavender,
  softPink,
  dustyRose,
  mutedPurple,
  oliveYellow,
  mintGreen,
  blueViolet,
  deepPurple,
  cherryRed,
  softBlue,
  oliveGreen,
  seaGreen,
  magentaPurple,
  darkRed,
  palePink,
  softPurple,
  darkBlue,
  goldenYellow,
  forestGreen,
  sandBrown,
}

class ColorManager {
  static const Map<ColorType, Color> colorMap = {
    ColorType.pinkLight: Color(0xFFFFABAB),
    ColorType.peachLight: Color(0xFFFFC5AB),
    ColorType.yellowLight: Color(0xFFFFE0AB),
    ColorType.paleYellow: Color(0xFFFFF2AB),
    ColorType.lightYellowGreen: Color(0xFFD1D9E3),
    ColorType.aquaGreen: Color(0xABFFDBAB),
    ColorType.skyBlue: Color(0x7BF7FBFF),
    ColorType.lightBlue: Color(0xABDFFFFF),
    ColorType.paleBlue: Color(0xABCFFFFF),
    ColorType.lavender: Color(0xB3ABFFFF),
    ColorType.lightLavender: Color(0xF0ABFFFF),
    ColorType.softPink: Color(0xFFABDBFF),
    ColorType.dustyRose: Color(0xD0878BFF),
    ColorType.mutedPurple: Color(0x766F85FF),
    ColorType.oliveYellow: Color(0xC1BC6CFF),
    ColorType.mintGreen: Color(0x9CF191FF),
    ColorType.blueViolet: Color(0x7076F0FF),
    ColorType.deepPurple: Color(0x522DA3FF),
    ColorType.cherryRed: Color(0xC53C6AFF),
    ColorType.softBlue: Color(0xADD3C9FF),
    ColorType.oliveGreen: Color(0x9DAA93FF),
    ColorType.seaGreen: Color(0x61BAABFF),
    ColorType.magentaPurple: Color(0x842595FF),
    ColorType.darkRed: Color(0x750D0DFF),
    ColorType.palePink: Color(0xFFE2E2FF),
    ColorType.softPurple: Color(0xDCD1E8FF),
    ColorType.darkBlue: Color(0x3C3F73FF),
    ColorType.goldenYellow: Color(0xE1A967FF),
    ColorType.forestGreen: Color(0x48604EFF),
    ColorType.sandBrown: Color(0xD7A88FFF),
  };

  static Color getColor(ColorType colorType) {
    return colorMap[colorType] ?? Colors.transparent;
  }
}