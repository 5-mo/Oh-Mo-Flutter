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
    final colors = ColorType.values
        .where((c) => c != ColorType.uncategorizedBlack)
        .toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(32, 32, 32, 32),
      height: MediaQuery.of(context).size.height * 0.52,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 3,
                mainAxisSpacing: 3,
                childAspectRatio: 1,
              ),
              itemCount: colors.length,
              itemBuilder: (context, index) {
                final colorType = colors[index];
                final color = ColorManager.getColor(colorType);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      tempSelectedColor = colorType;
                    });
                  },
                  child: Center(
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
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 5),
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
