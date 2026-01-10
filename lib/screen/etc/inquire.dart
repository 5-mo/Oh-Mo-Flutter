import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ohmo/screen/home_screen.dart';

class InquireScreen extends StatefulWidget {
  const InquireScreen({super.key});

  @override
  State<InquireScreen> createState() => _InquireScreenState();
}

class _InquireScreenState extends State<InquireScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  String? selectedType;
  final List<String> inquiryTypes = [
    '계정 및 로그인',
    '노션 연동',
    '그룹 일정 관리',
    '버그 신고',
    '기능 제안',
    '결제 및 환불',
    '기타',
  ];

  void _validateAndSubmit() {
    if (emailController.text.isNotEmpty &&
        selectedType != null &&
        titleController.text.isNotEmpty &&
        contentController.text.isNotEmpty) {
      _confirmationPopup();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('모든 필수 항목(*)을 입력해주세요.')));
    }
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
          '문의하기                                                                       ',
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
                _buildEmailInputSection(),
                const SizedBox(height: 20),
                _buildTypeSelectSection(),
                const SizedBox(height: 20),
                _buildTitleInputSection(),
                const SizedBox(height: 20),
                _buildContentInputSection(),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _validateAndSubmit,
                  child: Container(
                    width: double.infinity,
                    height: 37,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        '문의하기',
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
                      '다른 방법으로 문의하기',
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'PretendardRegular',
                        color: Color(0xFF0A0A0A),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '이메일',
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'PretendardRegular',
                        color: Color(0xFF0A0A0A),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'support@example.com',
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'PretendardRegular',
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '운영 시간',
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'PretendardRegular',
                        color: Color(0xFF0A0A0A),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '평일 09:00 - 18:00 (주말 및 공휴일 제외)',
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'PretendardRegular',
                        color: Color(0xFF4A5565),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '평균 응답 시간',
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'PretendardRegular',
                        color: Color(0xFF0A0A0A),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '영업일 기준 1-2일 이내',
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'PretendardRegular',
                        color: Color(0xFF4A5565),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            _buildNoticeBox(),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "이메일 주소",
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
            border: Border.all(color: const Color(0xFFE5E7EB), width: 0.6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: emailController,
            decoration: InputDecoration(
              hintText: 'example@gmail.com',
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

  Widget _buildTypeSelectSection() {
    final double dropdownWidth = MediaQuery.of(context).size.width - 80;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "문의 유형",
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
                    padding: const EdgeInsets.symmetric(horizontal: 114),
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
                text: "제목",
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
            border: Border.all(color: const Color(0xFFE5E7EB), width: 0.6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: titleController,
            decoration: InputDecoration(
              hintText: '문의 제목을 입력해주세요',
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
                text: "문의 내용",
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
              hintText: '문의 내용을 자세히 작성해주세요',
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

  Widget _buildNoticeBox() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFDBEAFE),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF93C5FD)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '문의 전 FAQ를 확인하시면 빠른 답변을 얻으실 수 있습니다. 버그 신고 시에는 발생 상황을 상세히 설명해주시면 더욱 신속하게 해결해드릴 수 있습니다.',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'PretendardRegular',
              color: Color(0xFF1E40AF),
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
                "문의가 접수되었습니다",
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'PretendardBold',
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20),
              Text(
                "이메일로 문의에 대한 답변을\n드리겠습니다. 감사합니다.",
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
