import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ServiceScreen extends StatefulWidget {
  const ServiceScreen({super.key});

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
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
          '서비스 이용약관                                                                        ',
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
                _buildTermsSection(
                  title: '제 1조 (목적)',
                  content:
                      '본 약관은 오모 (이하 "회사")이 제공하는 투두리스트, 루틴, 일기 관리 및 그룹 일정 관리 서비스(이하 "서비스")의 이용과 관련하여 회사와 이용자 간의 권리, 의무 및 책임사항, 기타 필요한 사항을 규정함을 목적으로 합니다.',
                ),
                _buildTermsSection(
                  title: '제2조 (정의)',
                  content:
                      '1. "서비스"란 투두리스트, 루틴 관리, 일기 작성, 노션 연동, 그룹 일정 관리 등 회사가 제공하는 모든 서비스를 의미합니다.\n\n'
                      '2. "이용자"란 본 약관에 따라 회사가 제공하는 서비스를 이용하는 회원 및 비회원을 말합니다.\n\n'
                      '3. "회원"이란 서비스에 접속하여 본 약관에 따라 회사와 이용계약을 체결하고 회사가 제공하는 서비스를 이용하는 자를 의미합니다.\n\n'
                      '4. "노션 연동"이란 회원이 본 서비스의 데이터를 노션(Notion) 플랫폼과 동기화하는 기능을 의미합니다.',
                ),
                _buildTermsSection(
                  title: '제3조 (약관의 게시와 개정)',
                  content:
                      '1. 회사는 본 약관의 내용을 이용자가 쉽게 알 수 있도록 서비스 초기 화면 또는 연결화면에 게시합니다.\n\n'
                      '2. 회사는 필요한 경우 관련 법령을 위배하지 않는 범위에서 본 약관을 개정할 수 있습니다.\n\n'
                      '3. 회사가 약관을 개정할 경우에는 적용일자 및 개정사유를 명시하여 현행약관과 함께 서비스의 초기화면에 그 적용일자 7일 이전부터 적용일자 전일까지 공지합니다.\n',
                ),
                _buildTermsSection(
                  title: '제4조 (서비스의 제공 및 변경)',
                  content:
                      '1. 회사는 다음과 같은 서비스를 제공합니다:\n'
                      '- 투두리스트 작성 및 관리\n\n'
                      '- 루틴 설정 및 추적\n\n'
                      '- 일기 작성 및 관리\n\n'
                      '- 노션(Notion) 템플릿 연동\n\n'
                      '- 그룹 일정 공유 및 관리\n\n'
                      '- 기타 회사가 추가 개발하거나 제휴계약 등을 통해 이용자에게 제공하는 일체의 서비스\n\n'
                      '2. 회사는 상당한 이유가 있는 경우 운영상, 기술상의 필요에 따라 제공하고 있는 서비스를 변경할 수 있습니다.\n',
                ),
                _buildTermsSection(
                  title: '제5조 (서비스의 중단)',
                  content:
                      '1. 회사는 컴퓨터 등 정보통신설비의 보수점검, 교체 및 고장, 통신의 두절 등의 사유가 발생한 경우에는 서비스의 제공을 일시적으로 중단할 수 있습니다.\n\n'
                      '2. 회사는 제1항의 사유로 서비스의 제공이 일시적으로 중단됨으로 인하여 이용자 또는 제3자가 입은 손해에 대하여는 배상하지 않습니다. 단, 회사에 고의 또는 중과실이 있는 경우에는 그러하지 아니합니다.\n',
                ),
                _buildTermsSection(
                  title: '제6조 (회원가입)',
                  content:
                      '1. 이용자는 회사가 정한 가입 양식에 따라 회원정보를 기입한 후 본 약관에 동의한다는 의사표시를 함으로써 회원가입을 신청합니다.\n\n'
                      '2. 회사는 제1항과 같이 회원으로 가입할 것을 신청한 이용자 중 다음 각 호에 해당하지 않는 한 회원으로 등록합니다:\n'
                      '- 가입신청자가 본 약관에 의하여 이전에 회원자격을 상실한 적이 있는 경우\n\n'
                      '- 실명이 아니거나 타인의 명의를 이용한 경우\n\n'
                      '- 허위의 정보를 기재하거나, 회사가 제시하는 내용을 기재하지 않은 경우',
                ),
                _buildTermsSection(
                  title: '제7조 (개인정보의 보호)',
                  content:
                      '1. 회사는 이용자의 개인정보 수집 시 서비스 제공을 위하여 필요한 범위에서 최소한의 개인정보를 수집합니다.\n\n'
                      '2. 회사는 개인정보의 보호 및 사용에 대해서는 관련법령 및 회사의 개인정보처리방침이 적용됩니다.\n\n'
                      '3. 회사는 이용자가 노션 연동을 위해 제공한 인증정보를 안전하게 보관하며, 이용자의 동의 없이 제3자에게 제공하지 않습니다.\n',
                ),
                _buildTermsSection(
                  title: '제8조 (이용자의 의무)',
                  content:
                      '1. 이용자는 다음 행위를 하여서는 안 됩니다:\n'
                      '- 신청 또는 변경 시 허위내용의 등록\n\n'
                      '- 타인의 정보 도용\n\n'
                      '- 회사가 게시한 정보의 변경\n\n'
                      '- 회사가 정한 정보 이외의 정보(컴퓨터 프로그램 등) 등의 송신 또는 게시\n\n'
                      '- 회사 및 기타 제3자의 저작권 등 지적재산권에 대한 침해\n\n'
                      '- 회사 및 기타 제3자의 명예를 손상시키거나 업무를 방해하는 행위\n\n'
                      '- 외설 또는 폭력적인 메시지, 화상, 음성, 기타 공서양속에 반하는 정보를 서비스에 공개 또는 게시하는 행위\n',
                ),
                _buildTermsSection(
                  title: '제9조 (노션 연동 서비스)',
                  content:
                      '1. 회사는 이용자의 요청에 따라 본 서비스의 데이터를 노션(Notion) 템플릿과 연동하는 기능을 제공합니다.\n\n'
                      '2. 노션 연동 기능은 노션의 API 정책 변경, 서비스 중단 등의 사유로 예고 없이 변경되거나 중단될 수 있습니다.\n\n'
                      '3. 이용자는 노션 연동을 위해 필요한 권한을 회사에 제공해야 하며, 언제든지 연동을 해제할 수 있습니다.\n',
                ),
                _buildTermsSection(
                  title: '제10조 (그룹 일정 관리)',
                  content:
                      '1. 회원은 그룹을 생성하고 다른 회원을 초대하여 일정을 공유할 수 있습니다.\n\n'
                      '2. 그룹 내에서 발생하는 분쟁이나 문제에 대해서는 회원 간 자율적으로 해결해야 하며, 회사는 이에 대한 책임을 지지 않습니다.\n\n'
                      '3. 회사는 그룹 내에서 부적절한 활동이 발견될 경우 사전 통보 없이 해당 그룹을 삭제하거나 이용을 제한할 수 있습니다.\n',
                ),
                _buildTermsSection(
                  title: '제11조 (면책조항)',
                  content:
                      '1. 회사는 천재지변 또는 이에 준하는 불가항력으로 인하여 서비스를 제공할 수 없는 경우에는 서비스 제공에 관한 책임이 면제됩니다.\n\n'
                      '2. 회사는 이용자의 귀책사유로 인한 서비스 이용의 장애에 대하여는 책임을 지지 않습니다.\n\n'
                      '3. 회사는 이용자가 서비스와 관련하여 게재한 정보, 자료, 사실의 신뢰도, 정확성 등의 내용에 관하여는 책임을 지지 않습니다.\n',
                ),
                _buildTermsSection(
                  title: '제12조 (분쟁해결)',
                  content:
                      '1. 회사는 이용자가 제기하는 정당한 의견이나 불만을 반영하고 그 피해를 보상처리하기 위하여 피해보상처리기구를 설치·운영합니다.\n\n'
                      '2. 회사와 이용자 간에 발생한 전자상거래 분쟁에 관한 소송은 민사소송법상의 관할법원에 제기합니다.',
                ),
                const Divider(height: 1, color: Color(0xFFF3F4F6)),
                SizedBox(height: 10),
                Text(
                  textAlign: TextAlign.start,
                  '시행일자 : 2026년 1월 21일',
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
