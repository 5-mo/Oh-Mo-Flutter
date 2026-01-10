import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../home_screen.dart';

class BugScreen extends StatefulWidget {
  const BugScreen({super.key});

  @override
  State<BugScreen> createState() => _BugScreenState();
}

class _BugScreenState extends State<BugScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final TextEditingController materialController = TextEditingController();

  String? selectedType;
  final List<String> inquiryTypes = [
    '괴롭힘 및 협박',
    '혐오 발언 및 차별',
    '폭력적 콘텐츠',
    '스팸 및 광고',
    '계정 사칭',
    '저작권 침해',
    '개인정보 노출',
    '부적절한 콘텐츠',
    '기타',
  ];

  void _validateAndSubmit() {
    if (selectedType != null && contentController.text.trim().isNotEmpty) {
      _confirmationPopup();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('필수 항목(신고 유형, 상세 내용)을 입력해주세요.')),
      );
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    materialController.dispose();
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
          '신고하기                                                                       ',
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
            _buildNoticeBox(),
            _buildBaseCard(
              children: [
                _buildTypeSelectSection(),
                const SizedBox(height: 20),
                _buildTitleInputSection(),
                const SizedBox(height: 5),
                Text(
                  '특정 사용자의 행위를 신고하는 경우에만 입력해주세요.',
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'PretendardRegular',
                    color: Color(0xFF6A7282),
                  ),
                ),
                const SizedBox(height: 20),
                _buildContentInputSection(),
                const SizedBox(height: 20),
                _buildMaterialInputSection(),
                const SizedBox(height: 5),
                Text(
                  '증거가 있으면 더 신속하게 처리할 수 있습니다.',
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'PretendardRegular',
                    color: Color(0xFF6A7282),
                  ),
                ),
                const SizedBox(height: 20),
                _buildInformationBox(),
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: _validateAndSubmit,
                  child: Container(
                    width: double.infinity,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Color(0xFFDC2626),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        '신고하기',
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
            _buildBaseCard(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '신고 가능한 사례',
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'PretendardRegular',
                        color: Color(0xFF0A0A0A),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '• 다른 사용자를 괴롭히거나 협박하는 행위',
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'PretendardRegular',
                        color: Color(0xFF4A5565),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '• 인종, 성별, 종교 등에 대한 혐오 발언',
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'PretendardRegular',
                        color: Color(0xFF4A5565),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '• 폭력적이거나 선정적인 콘텐츠',
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'PretendardRegular',
                        color: Color(0xFF4A5565),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '• 스팸, 사기, 무단 광고',
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'PretendardRegular',
                        color: Color(0xFF4A5565),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '• 타인의 개인정보를 무단으로 공유',
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'PretendardRegular',
                        color: Color(0xFF4A5565),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '• 저작권이나 지적재산권 침해',
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'PretendardRegular',
                        color: Color(0xFF4A5565),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '자세한 내용은 커뮤니티 가이드라인을 참고해주세요.',
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'PretendardRegular',
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 50),
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
                text: "신고 유형",
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
            alignment: const Alignment(-1.0, 1.4),
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
                    padding: const EdgeInsets.symmetric(horizontal: 106),
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

  Widget _buildTitleInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "신고 대상 (선택사항)",
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
            border: Border.all(color: const Color(0xFFE5E7EB), width: 0.6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: titleController,
            decoration: InputDecoration(
              hintText: '사용자 이름 또는 이메일',
              hintStyle: TextStyle(
                color: Color(0xFF0A0A0A).withOpacity(0.5),
                fontSize: 14,
                fontFamily: 'PretendardRegular',
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(bottom: 6),
            ),
          ),
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
                text: "상세 내용",
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
          height: 143,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 0.6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: contentController,
            decoration: InputDecoration(
              hintText: '신고 사유와 상황을 구체적으로 설명해주세요',
              hintStyle: TextStyle(
                color: Color(0xFF0A0A0A).withOpacity(0.5),
                fontSize: 14,
                fontFamily: 'PretendardRegular',
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(bottom: 6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMaterialInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "증거 자료 (선택사항)",
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
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 0.6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: TextField(
            controller: materialController,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              hintText: '스크린샷 링크, 날짜/시간 등 증거가 될 수 있는 정보를 입력해주세요',
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

  Widget _buildNoticeBox() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFFBBF24)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.report_problem_rounded,
                color: Color(0xFFD97706),
                size: 16,
              ),
              Text(
                '신고 전 확인사항',
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'PretendardBold',
                  color: Color(0xFF78350F),
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            '신고는 커뮤니티 가이드라인을 위반한 명백한 사례에만 사용해주세요. 개인적인 의견 차이나 단순 분쟁은 신고 사유가 아닙니다.',
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'PretendardRegular',
              color: Color(0xFF78350F),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformationBox() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 4),
          Text(
            '신고는 익명으로 처리되며, 신고자의 정보는 철저히 보호됩니다. 단, 법적 절차가 필요한 경우 관련 기관에 제공될 수 있습니다.',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'PretendardRegular',
              color: Color(0xFF4A5565),
              height: 1.5,
            ),
          ),
        ],
      ),
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

  void _confirmationPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 50, vertical: 40),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "신고가 접수되었습니다",
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'PretendardBold',
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20),
              Text(
                "이메일로 신고에 대한 답변을\n드리겠습니다. 감사합니다.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'PretendardRegular',
                  color: Colors.black,
                ),
              ),

              SizedBox(height: 35),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: Size(277, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false,
                  );
                },
                child: const Text(
                  "홈으로",
                  style: TextStyle(
                    fontFamily: 'PretendardBold',
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
