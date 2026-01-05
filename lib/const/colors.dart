import 'package:flutter/material.dart';

const LIGHT_GREY_COLOR = Color(0xFFCDCDCD);
const Middle_GREY_COLOR = Color(0xFFA5A5A5);
const DARK_GREY_COLOR = Color(0xFF656464);
const ICON_GREY_COLOR = Color(0xffB9B9B9);

enum ColorType {
  pinkLight,
  peachLight,
  yellowLight,
  paleYellow,
  lightYellowGreen,
  aquaGreen,
  skyBlue,
  realRed,
  paleBlue,
  lavender,
  lightLavender,
  softPink,
  dustyRose,
  mutedPurple,
  oliveYellow,
  mintGreen,
  blueViolet,
  deepPink,
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
  uncategorizedBlack,
}

extension ColorTypeExtension on ColorType {
  static ColorType fromString(String colorString) {
    if (colorString.isEmpty) return ColorType.pinkLight;
    if (colorString.startsWith('#')) {
      if (colorString.toUpperCase() == '#000000') {
        return ColorType.uncategorizedBlack;
      }
      return ColorType.uncategorizedBlack;
    }

    final intValue = int.tryParse(colorString);
    if (intValue != null) {
      if (intValue >= 0 && intValue < ColorType.values.length) {
        return ColorType.values[intValue];
      }
      return ColorType.pinkLight;
    }

    final normalizedInput = colorString.toLowerCase().replaceAll(' ', '');

    try {
      return ColorType.values.firstWhere(
        (e) => e.name.toLowerCase() == normalizedInput,
      );
    } catch (e) {
      if (normalizedInput == 'red') return ColorType.realRed;
      if (normalizedInput == 'blue') return ColorType.darkBlue;
      if (normalizedInput == 'green') return ColorType.forestGreen;
      if (normalizedInput == 'yellow') return ColorType.yellowLight;
      if (normalizedInput == 'orange') return ColorType.peachLight;
      if (normalizedInput == 'purple') return ColorType.magentaPurple;
      if (normalizedInput.contains('gray') ||
          normalizedInput.contains('grey')) {
        return ColorType.uncategorizedBlack;
      }
      if (normalizedInput.contains('black'))
        return ColorType.uncategorizedBlack;

      return ColorType.uncategorizedBlack;
    }
  }
}

class ColorManager {
  static const Map<ColorType, Color> colorMap = {
    ColorType.pinkLight: Color(0xFFFFABAB),
    ColorType.peachLight: Color(0xFFFFC5AB),
    ColorType.yellowLight: Color(0xFFFFE0AB),
    ColorType.paleYellow: Color(0xFFFFF2AB),
    ColorType.lightYellowGreen: Color(0xFF4C89BB),
    ColorType.aquaGreen: Color(0xFFABFFDB),
    ColorType.skyBlue: Color(0xFF7BF7FB),
    ColorType.realRed: Color(0xFFE43500),
    ColorType.paleBlue: Color(0xFFABCFFF),
    ColorType.lavender: Color(0xFFB3ABFF),
    ColorType.lightLavender: Color(0xFFF0ABFF),
    ColorType.softPink: Color(0xFFFFABD6),
    ColorType.dustyRose: Color(0xFFD0878B),
    ColorType.mutedPurple: Color(0xFF766F85),
    ColorType.oliveYellow: Color(0xFFC1BC6C),
    ColorType.mintGreen: Color(0xFF9CF191),
    ColorType.blueViolet: Color(0xFF7076F0),
    ColorType.deepPink: Color(0xFFBF248B),
    ColorType.cherryRed: Color(0xFFC53C6A),
    ColorType.softBlue: Color(0xFFADD3C9),
    ColorType.oliveGreen: Color(0xFF9DAA93),
    ColorType.seaGreen: Color(0xFF61BAAB),
    ColorType.magentaPurple: Color(0xFF842595),
    ColorType.darkRed: Color(0xFF750D0D),
    ColorType.palePink: Color(0xFFFFE2E2),
    ColorType.softPurple: Color(0xFFDCD1E8),
    ColorType.darkBlue: Color(0xFF3C3F73),
    ColorType.goldenYellow: Color(0xFFE1A967),
    ColorType.forestGreen: Color(0xFF48604E),
    ColorType.sandBrown: Color(0xFFD7A88F),
    ColorType.uncategorizedBlack: Color(0xFF000000),
  };

  static Color getColor(ColorType colorType) {
    return colorMap[colorType] ?? Colors.transparent;
  }
}
