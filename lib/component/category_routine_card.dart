import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:ohmo/const/colors.dart';
import '../db/drift_database.dart';
import 'color_palette_bottom_sheet.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CategoryRoutineCard extends StatefulWidget {
  final String content;
  final int scheduleId;
  final ColorType colorType;

  final Function(String) onEdit;
  final Widget Function(BuildContext)? deletePopupBuilder;
  final VoidCallback? onDataChanged;

  final bool isColorPickerEnabled;

  const CategoryRoutineCard({
    Key? key,
    required this.content,
    required this.scheduleId,
    required this.colorType,
    required this.onEdit,
    this.deletePopupBuilder,
    this.onDataChanged,
    this.isColorPickerEnabled = true,
  }) : super(key: key);

  @override
  _CategoryRoutineCardState createState() => _CategoryRoutineCardState();
}

class _CategoryRoutineCardState extends State<CategoryRoutineCard> {
  bool _isEditing = false;
  late TextEditingController _controller;
  ColorType _selectedColorType = ColorType.pinkLight;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.content);
    _selectedColorType = widget.colorType;
  }

  @override
  void didUpdateWidget(covariant CategoryRoutineCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content) {
      _controller.text = widget.content;
    }
    if (oldWidget.colorType != widget.colorType) {
      _selectedColorType = widget.colorType;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: 16.0,
      fontFamily: 'PretendardRegular',
      color: Colors.black,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: widget.isColorPickerEnabled
                  ? () => _openColorPicker(context)
                  : null,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ColorManager.getColor(_selectedColorType),
                ),
              ),
            ),

            const SizedBox(width: 15.0),

            Expanded(
              child: _isEditing
                  ? TextField(
                controller: _controller,
                style: textStyle,
                autofocus: true,
                onSubmitted: (value) async {
                  await _saveContent(value);
                },
                onTapOutside: (_) async {
                  await _saveContent(_controller.text);
                },
              )
                  : GestureDetector(
                onTap: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
                child: Text(
                  widget.content,
                  style: textStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            if (widget.deletePopupBuilder != null)
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => widget.deletePopupBuilder!(context),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: SvgPicture.asset(
                    'android/assets/images/routine_alarm.svg',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveContent(String value) async {
    setState(() => _isEditing = false);

    widget.onEdit(value);

    final db = LocalDatabaseSingleton.instance;
    await db.updateRoutine(
      RoutinesCompanion(
        id: Value(widget.scheduleId),
        content: Value(value),
      ),
    );
  }

  void _openColorPicker(BuildContext context) {
    showModalBottomSheet<ColorType>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(59),
          topLeft: Radius.circular(59),
        ),
      ),
      builder: (context) => ColorPaletteBottomSheet(
        selectedColorType: _selectedColorType,
        onColorSelected: (colorType) {
          setState(() {
            _selectedColorType = colorType;
          });
        },
      ),
    ).then((selectedColor) async {
      if (selectedColor != null) {
        try {
          final db = LocalDatabaseSingleton.instance;
          await db.updateCategoryAndChildrenColor(
            categoryId: widget.scheduleId,
            newColor: selectedColor,
          );
          widget.onDataChanged?.call();
        } catch (e) {
          print("카테고리 색상 변경 실패: $e");
          setState(() => _selectedColorType = widget.colorType);
        }
      } else {
        setState(() => _selectedColorType = widget.colorType);
      }
    });
  }
}