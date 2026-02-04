import 'package:flutter/material.dart';
import 'package:ohmo/const/colors.dart';

class ColorPaletteBottomSheet extends StatefulWidget {
  final void Function(ColorType colorType) onColorSelected;
  final ColorType selectedColorType;

  const ColorPaletteBottomSheet({
    Key? key,
    required this.onColorSelected,
    required this.selectedColorType,
  }) : super(key: key);

  @override
  _ColorPaletteBottomSheetState createState() =>
      _ColorPaletteBottomSheetState();
}

class _ColorPaletteBottomSheetState extends State<ColorPaletteBottomSheet> {
  late ColorType tempSelectedColor;

  @override
  void initState() {
    super.initState();
    tempSelectedColor = widget.selectedColorType;
  }

  @override
  Widget build(BuildContext context) {
    final colors =
        ColorType.values
            .where((c) => c != ColorType.uncategorizedBlack)
            .toList();

    final bool isTablet = MediaQuery.of(context).size.width > 600;

    return Container(
      padding: const EdgeInsets.fromLTRB(50, 30, 50, 32),
      height: MediaQuery.of(context).size.height * (isTablet ? 0.75 : 0.52),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Wrap(
                  alignment: WrapAlignment.start,
                  spacing: isTablet ? 20 : 20,
                  runSpacing: isTablet ? 15 : 30,
                  children:
                      colors.map((colorType) {
                        final color = ColorManager.getColor(colorType);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              tempSelectedColor = colorType;
                            });
                          },
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    colorType == tempSelectedColor
                                        ? Colors.grey
                                        : Colors.white,
                                width: colorType == tempSelectedColor ? 2.5 : 0,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildSaveButton(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Center(
      child: GestureDetector(
        onTap: () {
          widget.onColorSelected(tempSelectedColor);
          Navigator.of(context).pop(tempSelectedColor);
        },
        child: Container(
          width: 334,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Center(
            child: Text(
              '확인',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'PretendardBold',
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
