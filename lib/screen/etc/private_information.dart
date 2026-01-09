import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PrivateInformationScreen extends StatefulWidget {
  const PrivateInformationScreen({super.key});

  @override
  State<PrivateInformationScreen> createState() => _PrivateInformationScreenState();
}

class _PrivateInformationScreenState extends State<PrivateInformationScreen> {
  @override
  void initState() {
    super.initState();
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
          '개인정보 처리방침                                                                        ',
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
                Text(
                  '오모(이하 "회사")는 이용자의 개인정보를 중요시하며, "개인정보 보호법" 등 관련 법령상의 개인정보보호 규정을 준수하고 있습니다. 회사는 개인정보처리방침을 통하여 이용자가 제공하는 개인정보가 어떠한 용도와 방식으로 이용되고 있으며, 개인정보보호를 위해 어떠한 조치가 취해지고 있는지 알려드립니다.\n',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'PretendardRegular',
                    color: Color(0xFF4A5565),
                  ),
                ),
                _buildTermsSection(
                  title: '1. 개인정보의 수집 및 이용 목적',
                  content:
                  '회사는 다음의 목적을 위하여 개인정보를 처리합니다. 처리하고 있는 개인정보는 다음의 목적 이외의 용도로는 이용되지 않으며, 이용 목적이 변경되는 경우에는 별도의 동의를 받는 등 필요한 조치를 이행할 예정입니다.\n\n'
                      '   • 회원 가입 및 관리: 회원 가입의사 확인, \n   회원제 서비스 제공에 따른 본인 식별·인증, 회원자격\n   유지·관리\n\n'
                      '   • 서비스 제공: 투두리스트, 루틴, 일기 관리 서비스 \n   제공, 그룹 일정 관리 서비스 제공, 노션 연동 서비스 \n   제공\n\n'
                      '   • 서비스 개선: 신규 서비스 개발 및 맞춤 서비스 제공, \n   통계학적 특성에 따른 서비스 제공',
                ),
                _buildTermsSection(
                  title: '2. 수집하는 개인정보의 항목',
                  content:
                  '회사는 다음의 개인정보 항목을 처리하고 있습니다:',
                ),
                Text(
                  '• 필수항목',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'PretendardBold',
                    color: Color(0xFF4A5565),
                  ),
                ),
                Text(
                  '   - 이메일 주소, 비밀번호, 닉네임\n',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'PretendardRegular',
                    color: Color(0xFF4A5565),
                  ),
                ),
                Text(
                  '• 선택항목',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'PretendardBold',
                    color: Color(0xFF4A5565),
                  ),
                ),
                Text(
                  '   - 프로필 사진, 노션 연동 정보(API 토큰)\n',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'PretendardRegular',
                    color: Color(0xFF4A5565),
                  ),
                ),
                Text(
                  '• 자동 수집 항목',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'PretendardBold',
                    color: Color(0xFF4A5565),
                  ),
                ),
                Text(
                  '   - 서비스 이용 기록, 접속 로그, 쿠키, 접속 IP 정보, \n   기기정보\n',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'PretendardRegular',
                    color: Color(0xFF4A5565),
                  ),
                ),
                _buildTermsSection(
                  title: '3. 개인정보의 보유 및 이용기간',
                  content:
                  '회사는 법령에 따른 개인정보 보유·이용기간 또는 이용자로부터 개인정보를 수집 시에 동의받은 개인정보 보유·이용기간 내에서 개인정보를 처리·보유합니다.\n\n'
                      '  • 회원 정보: 회원 탈퇴 시까지 (단, 관계 법령 위반에 \n  따른 수사·\n  조사 등이 진행 중인 경우에는 해당 수사·조사 종료 시\n  까지)\n\n'
                      '  • 서비스 이용 기록: 서비스 이용 종료 후 5년\n\n'
                      '  • 노션 연동 정보: 연동 해제 시 즉시 삭제',
                ),
                _buildTermsSection(
                  title: '4. 개인정보의 제3자 제공',
                  content:
                  '회사는 원칙적으로 이용자의 개인정보를 제3자에게 제공하지 않습니다. 다만, 다음의 경우에는 예외로 합니다:\n\n'
                      '  • 이용자가 사전에 동의한 경우\n\n'
                      '  • 법령의 규정에 의거하거나, 수사 목적으로 법령에 \n  정해진 절차와 방법에 따라 수사기관의 요구가 있는 \n  경우\n\n'
                      '  • 노션(Notion) 연동: 이용자가 명시적으로 연동을 \n  요청한 경우, 서비스 데이터를 노션 플랫폼으로 전송합\n  니다.',
                ),
                _buildTermsSection(
                  title: '5. 개인정보 처리의 위탁',
                  content:
                  '회사는 서비스 제공을 위하여 필요한 경우 개인정보 처리 업무를 외부 전문업체에 위탁할 수 있습니다. 위탁 시에는 관계 법령에 따라 위탁계약 시 개인정보가 안전하게 관리될 수 있도록 필요한 사항을 규정합니다.\n\n'
                      '  현재 회사는 다음과 같이 개인정보 처리업무를 위탁하\n  고 있습니다:\n\n'
                      '  • 수탁업체: [클라우드 서비스 제공자]\n\n'
                      '  • 위탁업무 내용: 서버 호스팅, 데이터 저장 및 관리',
                ),
                _buildTermsSection(
                  title: '6. 이용자 및 법정대리인의 권리와 그 행사방법',
                  content:
                  '이용자는 언제든지 다음과 같은 개인정보 보호 관련 권리를 행사할 수 있습니다:\n\n'
                      '  • 개인정보 열람 요구\n\n'
                      '  • 오류 등이 있을 경우 정정 요구\n\n'
                      '  • 삭제 요구\n\n'
                  '  • 처리정지 요구\n\n'
                    "  이러한 권리 행사는 서비스 내 '설정' 메뉴 또는 개인정\n  보 보호책임자에게 서면, 전화, 이메일 등을 통하여 하\n  실 수 있으며 회사는 이에 대해 지체 없이 조치하겠습니\n  다.",
                ),
                _buildTermsSection(
                  title: '7. 개인정보의 파기',
                  content:
                  '회사는 개인정보 보유기간의 경과, 처리목적 달성 등 개인정보가 불필요하게 되었을 때에는 지체없이 해당 개인정보를 파기합니다.\n\n'
                      '  • 파기절차: 불필요한 개인정보는 개인정보 보호책임자\n  의 승인 절차를 거쳐 파기합니다.\n\n'
                      '  • 파기방법: 전자적 파일 형태의 정보는 기록을 재생할\n  수 없는 기술적 방법을 사용하여 삭제하며, 종이에 출력\n  된 개인정보는 분쇄기로 분쇄하거나 소각합니다.'
                ),
                _buildTermsSection(
                    title: '8. 개인정보의 안전성 확보조치',
                    content:
                    '회사는 개인정보의 안전성 확보를 위해 다음과 같은 조치를 취하고 있습니다:\n\n'
                        '  • 관리적 조치: 내부관리계획 수립·시행, 정기적 직원 교\n  육\n\n'
                        '  • 기술적 조치: 개인정보처리시스템 등의 접근권한 관\n  리, 접근통제시스템 설치, 개인정보의 암호화, 보안프로\n  그램 설치\n\n'
                    '  • 물리적 조치: 전산실, 자료보관실 등의 접근통제'
                ),
                _buildTermsSection(
                    title: '9. 개인정보 보호책임자',
                    content:
                    '회사는 개인정보 처리에 관한 업무를 총괄해서 책임지고, 개인정보 처리와 관련한 이용자의 불만처리 및 피해구제 등을 위하여 아래와 같이 개인정보 보호책임자를 지정하고 있습니다.\n\n'
                        '  • 개인정보 보호책임자\n\n'
                        '      - 성명: [책임자명]\n\n'
                        '      - 직책: [직책]\n\n'
                        '      - 이메일: privacy@example.com\n\n'
                        '      - 전화번호: 02-xxxx-xxxx',
                ),
                _buildTermsSection(
                  title: '10. 개인정보 처리방침 변경',
                  content:
                  '이 개인정보 처리방침은 시행일로부터 적용되며, 법령 및 방침에 따른 변경내용의 추가, 삭제 및 정정이 있는 경우에는 변경사항의 시행 7일 전부터 공지사항을 통하여 고지할 것입니다.'
                ),
                
                const Divider(height: 1, color: Color(0xFFF3F4F6)),
                SizedBox(height: 10),
                Text(
                  textAlign: TextAlign.start,
                  '시행일자 : 2025년 1월 1일',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'PretendardRegular',
                    color: Color(0xFF6A7282),
                  ),
                ),
                SizedBox(height: 30),
              ],
            ),
            SizedBox(height: 50),
          ],
        ),

      ),
    );
  }

  Widget _buildBaseCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
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

  Widget _buildTermsSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'PretendardRegular',
            color: Color(0xFF0A0A0A),
          ),
        ),
        SizedBox(height: 10),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'PretendardRegular',
            color: Color(0xFF4A5565),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
