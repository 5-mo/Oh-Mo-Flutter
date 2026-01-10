import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class FinalLeaveScreen extends StatefulWidget {
  const FinalLeaveScreen({super.key});

  @override
  State<FinalLeaveScreen> createState() => _FinalLeaveScreenState();
}

class _FinalLeaveScreenState extends State<FinalLeaveScreen> {
  final TextEditingController confirmationController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final FocusNode _confirmationFocusNode = FocusNode();

  bool isReadyToLeave = false;
  String? selectedType;
  final List<String> inquiryTypes = [
    '서비스가 유용하지 않음',
    '개인정보 보호 우려',
    '사용이 어려움',
    '다른 서비스 이용',
    '버그나 오류가 많음',
    '기타',
  ];

  @override
  void initState() {
    super.initState();
    confirmationController.addListener(() {
      setState(() {
        isReadyToLeave = confirmationController.text == '탈퇴하겠습니다';
      });
    });
    _confirmationFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    confirmationController.dispose();
    contentController.dispose();
    _confirmationFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            'android/assets/images/left.svg',
            width: 21,
            height: 21,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: const Text(
          '회원 탈퇴                                                                   ',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'PretendardRegular',
            fontSize: 14,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildBaseCard(
              children: [
                _buildTypeSelectSection(),
                const SizedBox(height: 20),
                _buildContentInputSection(),
                const SizedBox(height: 20),
                _buildConfirmationInputSection(),
                const SizedBox(height: 9),
                Text(
                  '위 문구를 정확히 입력해야 탈퇴가 가능합니다.',
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'PretendardRegular',
                    color: Color(0xFFDC2626),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '위 내용을 모두 확인하였으며, 탈퇴 후 데이터 복구가 불가능함을 이해했습니다.',
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'PretendardRegular',
                    color: Color(0xFF4A5565),
                  ),
                ),
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: isReadyToLeave ? () {} : null,
                  child: Container(
                    width: double.infinity,
                    height: 45,
                    decoration: BoxDecoration(
                      color:
                          isReadyToLeave
                              ? const Color(0xFFDC2626)
                              : const Color(0xFFDC2626).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        '탈퇴하기',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'PretendardRegular',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                height: 45,
                decoration: BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Color(0xFFE5E7EB)),
                ),
                child: Center(
                  child: Text(
                    '이전으로',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'PretendardRegular',
                      color: Color(0xFF0A0A0A),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelectSection() {
    final double dropdownWidth = MediaQuery.of(context).size.width - 80;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "탈퇴 사유 (선택사항)",
                style: TextStyle(
                  color: Color(0xFF0A0A0A),
                  fontFamily: 'PretendardRegular',
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        DropdownMenu<String>(
          width: dropdownWidth,
          hintText: '선택해주세요',
          enableSearch: false,
          requestFocusOnTap: false,
          trailingIcon: SvgPicture.asset('android/assets/images/dropdown.svg'),
          selectedTrailingIcon: SvgPicture.asset(
            'android/assets/images/dropdown.svg',
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            constraints: const BoxConstraints(maxHeight: 41),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
                width: 0.6,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
                width: 0.6,
              ),
            ),
            hintStyle: TextStyle(
              color: const Color(0xFF303030),
              fontSize: 16,
              fontFamily: 'PretendardRegular',
            ),
          ),
          menuStyle: MenuStyle(
            backgroundColor: WidgetStateProperty.all(Colors.white),
            elevation: WidgetStateProperty.all(0),
            alignment: const Alignment(-1, 1.4),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: const BorderSide(color: Color(0xFFE5E7EB), width: 0.5),
              ),
            ),
          ),
          dropdownMenuEntries:
              inquiryTypes.map((String type) {
                return DropdownMenuEntry<String>(
                  value: type,
                  label: type,
                  style: MenuItemButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 90),
                    foregroundColor: const Color(0xFF0A0A0A),
                  ),
                );
              }).toList(),

          onSelected: (String? newValue) {
            setState(() {
              selectedType = newValue;
            });
          },
        ),
      ],
    );
  }

  Widget _buildContentInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "개선사항 의견 (선택사항)",
                style: TextStyle(
                  color: Color(0xFF0A0A0A),
                  fontFamily: 'PretendardRegular',
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          height: 101,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 0.6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: TextField(
            controller: contentController,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              hintText: '불편했던 점이나 개선이 필요한 부분을 알려주시면 더 나은 서비스를 만드는 데 도움이 됩니다.',
              hintMaxLines: 2,
              hintStyle: TextStyle(
                color: Color(0xFF0A0A0A).withOpacity(0.5),
                fontSize: 14,
                fontFamily: 'PretendardRegular',
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.only(bottom: 6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmationInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "확인 문구 입력",
                style: TextStyle(
                  color: Color(0xFF0A0A0A),
                  fontFamily: 'PretendardRegular',
                  fontSize: 13,
                ),
              ),
              TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Color(0xFF0A0A0A),
                  fontFamily: 'PretendardRegular',
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          height: 41,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color:
                  _confirmationFocusNode.hasFocus
                      ? const Color(0xFFDC2626)
                      : const Color(0xFFE5E7EB),
              width: _confirmationFocusNode.hasFocus ? 2.0 : 0.6,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: TextField(
            focusNode: _confirmationFocusNode,
            controller: confirmationController,
            decoration: InputDecoration(
              hintText: "'탈퇴하겠습니다'를 입력해주세요",
              hintStyle: TextStyle(
                color: Color(0xFF0A0A0A).withOpacity(0.5),
                fontSize: 14,
                fontFamily: 'PretendardRegular',
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.only(bottom: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBaseCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 3),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
