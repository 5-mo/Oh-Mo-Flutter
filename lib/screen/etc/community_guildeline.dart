import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CommunityGuildelineScreen extends StatefulWidget {
  const CommunityGuildelineScreen({super.key});

  @override
  State<CommunityGuildelineScreen> createState() => _CommunityGuidelineScreenState();
}

class _CommunityGuidelineScreenState extends State<CommunityGuildelineScreen> {
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
          '커뮤니티 가이드라인                                                                        ',
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
                  '우리 서비스는 사용자 여러분이 안전하고 긍정적인 환경에서 일정을 관리하고 소통할 수 있도록 최선을 다하고 있습니다. 이 가이드라인은 모든 사용자가 존중받고 편안하게 서비스를 이용할 수 있도록 만들어졌습니다.\n',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'PretendardRegular',
                    color: Color(0xFF4A5565),
                  ),
                ),
                _buildTermsSection(
                  title: '1. 존중과 배려',
                  content:
                  '그룹 일정 관리 기능을 사용할 때는 다른 사용자를 존중하고 배려해 주세요.\n\n'
                      '   • 다른 사용자에게 예의 바르고 친절하게 대해주세요\n\n'
                      '   • 개인의 프라이버시를 존중하고 허가 없이 개인정보를\n   공유하지 마세요\n\n'
                      '   • 건설적이고 긍정적인 소통을 지향해주세요\n\n'
                      '   • 다양한 의견과 관점을 존중해주세요'
                ),
                Text(
                  '2. 금지되는 행위\n',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'PretendardRegular',
                    color: Color(0xFF0A0A0A),
                  ),
                ),
                Text(
                  '다음과 같은 행위는 엄격히 금지됩니다:\n',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'PretendardBold',
                    color: Color(0xFF4A5565),
                  ),
                ),
                Text(
                  '   • 괴롭힘, 협박, 모욕적인 언행\n',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'PretendardRegular',
                    color: Color(0xFF4A5565),
                  ),
                ),
                Text(
                  '   • 혐오 발언 및 차별적인 표현\n',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'PretendardRegular',
                    color: Color(0xFF4A5565),
                  ),
                ),
                Text(
                  '   • 폭력적, 선정적, 불법적인 콘텐츠 공유\n',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'PretendardRegular',
                    color: Color(0xFF4A5565),
                  ),
                ),
                Text(
                  '   • 스팸, 광고, 사기 행위\n',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'PretendardRegular',
                    color: Color(0xFF4A5565),
                  ),
                ),
                Text(
                  '   • 타인의 계정 도용이나 사칭\n',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'PretendardRegular',
                    color: Color(0xFF4A5565),
                  ),
                ),
                Text(
                  '   • 저작권 침해 또는 지적 재산권 위반\n',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'PretendardRegular',
                    color: Color(0xFF4A5565),
                  ),
                ),
                Text(
                  '   • 시스템 악용이나 서비스 방해 행위\n',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'PretendardRegular',
                    color: Color(0xFF4A5565),
                  ),
                ),
                Text(
                  '   • 미성년자에게 부적절한 콘텐츠 노출\n',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'PretendardRegular',
                    color: Color(0xFF4A5565),
                  ),
                ),
                _buildTermsSection(
                  title: '3. 그룹 일정 관리 이용 시 주의사항',
                  content:
                      '  • 그룹을 생성할 때는 명확하고 적절한 그룹명을 사용해\n  주세요\n\n'
                      '  • 그룹 멤버를 초대할 때는 상대방의 동의를 구해주세요\n\n'
                          '  • 공유되는 일정과 메모는 모든 그룹 멤버가 볼 수 있다\n  는 점을 유념해주세요\n\n'
                          '  • 그룹 내에서 분쟁이 발생할 경우 상호 존중하며 대화\n  로 해결해주세요\n\n'
                      '  • 원치 않는 그룹에서는 언제든지 탈퇴할 수 있습니다',
                ),
                _buildTermsSection(
                  title: '4. 콘텐츠 가이드라인',
                  content:
                  '일기, 메모, 그룹 일정 등 모든 콘텐츠 작성 시:\n\n'
                      '  • 정확하고 진실한 정보를 공유해주세요\n\n'
                      '  • 타인의 저작물을 사용할 때는 출처를 명확히 밝혀주세\n  요\n\n'
                      '  • 개인정보나 민감한 정보는 신중하게 다뤄주세요\n\n'
                      '  • 불법 활동을 조장하거나 관련된 콘텐츠를 게시하지 마\n  세요'
                ),
                _buildTermsSection(
                  title: '5. 노션 연동 이용 시 유의사항',
                  content:
                      '  • 노션에 공유되는 정보의 범위를 확인하고 관리해주세\n  요\n\n'
                          '  • 노션 계정의 보안을 철저히 관리해주세요\n\n'
                      '  • 공개 노션 페이지에 민감한 개인정보를 포함하지 마세\n  요',
                ),
                _buildTermsSection(
                  title: '6. 신고 및 제재',
                  content:
                  '가이드라인을 위반하는 행위를 발견하시면:\n\n'
                      "  • 서비스 내 '신고하기' 기능을 이용해 주세요\n\n"
                      '  • 신고는 익명으로 처리되며, 신고자의 정보는 보호됩\n  니다\n\n'
                      '  • 모든 신고는 신중하게 검토되어 적절한 조치가 취해집\n  니다\n\n'
                      '가이드라인 위반 시 다음과 같은 제재가 있을 수 있습니다:\n\n'
                      '  • 경고\n\n'
                      '  • 일시적 서비스 이용 제한\n\n'
                      '  • 특정 기능 이용 제한\n\n'
                      '  • 계정 정지\n\n'
                      '  • 영구 이용 정지\n\n'
                      '  • 법적 조치 (중대한 위반의 경우)'
                ),
                _buildTermsSection(
                    title: '7. 책임 소재',
                    content:
                        '  • 사용자가 서비스에 게시하거나 공유하는 모든 콘텐츠\n  에 대한 책임은 해당 사용자에게 있습니다\n\n'
                            '  • 그룹 내에서 발생하는 분쟁은 당사자 간 해결을 원칙\n  으로 합니다\n\n'
                        '  • 회사는 사용자 간 분쟁 해결을 중재할 수 있으나 법적\n  책임을 지지 않습니다'
                ),
                _buildTermsSection(
                    title: '8. 안전한 서비스 이용을 위한 팁',
                    content:
                        '  • 강력한 비밀번호를 설정하고 정기적으로 변경하세요\n\n'
                        '  • 의심스러운 링크나 파일은 클릭하지 마세요\n\n'
                            '  • 개인정보는 필요한 경우에만 최소한으로 공유하세요\n\n'
                            '  • 알지 못하는 사람의 그룹 초대는 신중하게 수락하세요\n\n'
                        '  • 이상한 활동이나 보안 위협을 발견하면 즉시 신고해주\n  세요'
                ),
                _buildTermsSection(
                  title: '9. 가이드라인 업데이트',
                  content:
                      '  • 이 가이드라인은 필요에 따라 업데이트될 수 있습니다\n\n'
                          '  • 중요한 변경사항이 있을 경우 서비스 내 공지를 통해\n  알려드립니다\n\n'
                          '  • 정기적으로 가이드라인을 확인하여 최신 정책을 숙지\n  해 주세요'
                ),
                _buildTermsSection(
                    title: '10. 문의',
                    content:
                    "커뮤니티 가이드라인에 대한 질문이나 제안사항이 있으시면 '문의하기'를 통해 연락해 주세요.\n\n"
                    "여러분의 적극적인 참여와 협조로 더 나은 커뮤니티를 만들어갈 수 있습니다. 감사합니다!"
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
