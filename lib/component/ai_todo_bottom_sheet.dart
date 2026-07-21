import 'package:flutter/material.dart';
import 'package:ohmo/services/group_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt_pkg;

class AITodoBottomSheet extends StatefulWidget {
  final stt_pkg.SpeechToText speechToText;
  final bool isAvailable;
  final int groupId;

  const AITodoBottomSheet({
    super.key,
    required this.speechToText,
    required this.isAvailable,
    required this.groupId,
  });

  @override
  State<AITodoBottomSheet> createState() => _AITodoBottomSheetState();
}

class _AITodoBottomSheetState extends State<AITodoBottomSheet> {
  String _recognizedText = '';
  bool _isListening = false;
  bool _isProcessing = false;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startListening();
    });
  }

  @override
  void dispose() {
    widget.speechToText.stop();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startListening() async {
    if (!widget.isAvailable) return;
    setState(() => _isListening = true);

    await widget.speechToText.listen(
      onResult: (result) {
        setState(() {
          _recognizedText = result.recognizedWords;
        });
        if (result.finalResult && result.recognizedWords.isNotEmpty) {
          _callAiApi(result.recognizedWords);
        }
      },
      localeId: 'ko_KR',
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
    );
  }

  Future<void> _callAiApi(String text) async {
    setState(() => _isProcessing = true);

    final result = await GroupService().registerGroupAiTodo(
      groupId: widget.groupId,
      text: text,
    );

    if (!mounted) return;

    if (result != null) {
      final content = result['content'] ?? text;
      setState(() {
        _controller.text = content;
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
        _isProcessing = false;
      });
    } else {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('AI 등록이 실패했습니다.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(59)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 55,
                height: 4,
                decoration: BoxDecoration(
                  color: Color(0xFF9F9F9F),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                ClipOval(
                  child: Image.asset(
                    'android/assets/images/ohmo_icon.png',
                    width: 60,
                    height: 60,
                  ),
                ),
                const SizedBox(width: 7),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'PretendardSemiBold',
                      color: Color(0xFF2B2B2B),
                    ),
                    children: [
                      TextSpan(text: '어떤 '),
                      TextSpan(
                        text: 'To-do',
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'RubikSprayPaint',
                        ),
                      ),
                      TextSpan(text: '를 추가할까요?'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child:
                  _recognizedText.isEmpty
                      ? const Text(
                        '오모에게 오늘 자료조사 해달라고 해줘',
                        style: TextStyle(
                          fontFamily: 'PretendardSemiBold',
                          fontSize: 20,
                          color: Color(0xFF9D9D9D),
                        ),
                      )
                      : ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.white,
                              Colors.white,
                              Colors.transparent,
                            ],
                            stops: [0.0, 0.3, 0.65, 1.0],
                          ).createShader(bounds);
                        },
                        blendMode: BlendMode.dstIn,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 150),
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Text(
                              _recognizedText,
                              style: const TextStyle(
                                fontFamily: 'PretendardSemiBold',
                                fontSize: 20,
                                color: Color(0xFF2B2B2B),
                              ),
                            ),
                          ),
                        ),
                      ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(27),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 10, bottom: 6),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    final text = _controller.text.trim();
                    if (text.isNotEmpty) {
                      Navigator.pop(context, text);
                    }
                  },
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        '완료',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'PretendardSemiBold',
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
