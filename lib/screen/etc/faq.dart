import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ohmo/screen/etc/inquire.dart';
import 'package:url_launcher/url_launcher.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final List<Map<String, String>> faqData = [
    {
      'question': '서비스는 무료인가요?',
      'answer':
          '네, 현재 모든 기본 기능은 무료로 제공됩니다. 향후 프리미엄 기능이 추가될 수 있으며, 이 경우 사전에 공지해 드리겠습니다.',
    },
    {
      'question': '노션(Notion) 연동은 어떻게 하나요?',
      'answer':
          "마이페이지에서 'Notion 연결 및 업데이트' 버튼을 클릭하신 후, 노션 계정으로 로그인하여 권한을 승인해주세요. 연동 후 자동으로 데이터가 동기화됩니다.",
    },
    {
      'question': '노션 연동 시 어떤 데이터가 공유되나요?',
      'answer':
          '투두리스트, 루틴, 일기 등 사용자가 작성한 콘텐츠가 노션 템플릿으로 동기화됩니다. 개인정보는 공유되지 않으며, 언제든지 연동을 해제할 수 있습니다.',
    },
    {
      'question': '그룹 일정 관리는 어떻게 사용하나요?',
      'answer':
          '새 그룹을 생성하고 다른 사용자에게 초대장을 보낼 수 있습니다. 그룹 멤버들은 공유된 일정을 함께 관리하고 편집할 수 있습니다.',
    },
    {
      'question': '작성한 일기는 다른 사람이 볼 수 있나요?',
      'answer':
          '아니요. 일기는 기본적으로 비공개이며 본인만 볼 수 있습니다. 다만, 노션 연동 시 노션에서의 공개 설정은 사용자가 직접 관리해야 합니다.',
    },
    {
      'question': '루틴은 어떻게 설정하나요?',
      'answer':
          '루틴 메뉴에서 반복할 작업을 추가하고, 반복 요일과 종료 날짜를 설정할 수 있습니다. 설정된 루틴은 자동으로 해당 날짜에 표시됩니다.',
    },
    {
      'question': '데이터를 백업할 수 있나요?',
      'answer': '네, 노션 연동 기능을 통해 제공해드리는 템플릿에 자동으로 백업이 가능합니다.',
    },
    {
      'question': '여러 기기에서 동시에 사용할 수 있나요?',
      'answer':
          '네, 같은 계정으로 로그인하면 모든 기기에서 동일한 데이터를 확인하고 편집할 수 있습니다. 실시간으로 동기화됩니다.',
    },
    {
      'question': '그룹에서 나가려면 어떻게 하나요?',
      'answer':
          "그룹 설정에서 '나가기' 버튼을 클릭하시면 됩니다. 나간 후에는 해당 그룹의 일정을 더 이상 볼 수 없으며, 다시 초대를 받아야 재가입할 수 있습니다.",
    },
    {
      'question': '계정을 삭제하면 데이터는 어떻게 되나요?',
      'answer':
          '계정 삭제 시 모든 개인 데이터(투두리스트, 루틴, 일기 등)가 즉시 삭제됩니다. 단, 그룹에 공유했던 일정은 그룹에 남아있을 수 있습니다. 삭제된 데이터는 복구할 수 없으니 신중히 결정해 주세요.',
    },
    {
      'question': '알림 설정은 어떻게 하나요?',
      'answer':
          '설정 메뉴에서 알림 기능을 켜고, 원하는 시간에 알림을 받도록 설정할 수 있습니다. 투두리스트, 루틴, 그룹 일정 각각에 대해 별도로 설정 가능합니다.',
    },
    {
      'question': '오프라인에서도 사용할 수 있나요?',
      'answer':
          '일부 기능은 오프라인에서도 사용 가능하며, 온라인 연결 시 자동으로 동기화됩니다. 다만 노션 연동과 그룹 일정 실시간 업데이트는 인터넷 연결이 필요합니다.',
    },
    {
      'question': '문제가 발생했을 때 어디에 문의하나요?',
      'answer':
          "기타 메뉴의 '문의하기'를 통해 문의하실 수 있습니다. 이메일로도 ohmo.help@gmail.com으로 연락 주시면 빠르게 답변드리겠습니다.",
    },
    {
      'question': '비밀번호를 잊어버렸어요.',
      'answer': "로그인 화면에서 '비밀번호 재설정'를 클릭하시면 가입 시 등록한 이메일로 비밀번호 재설정 링크가 전송됩니다.",
    },
  ];

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
          '자주 묻는 질문 (FAQ)                                                                       ',
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
              children:
                  faqData.asMap().entries.map((entry) {
                    int index = entry.key;
                    var data = entry.value;
                    return FaqItemWidget(
                      question: data['question']!,
                      answer: data['answer']!,
                      isLast: index == faqData.length - 1,
                    );
                  }).toList(),
            ),
            _buildBaseCard(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '원하는 답변을 찾지 못하셨나요?',
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'PretendardRegular',
                          color: Color(0xFF0A0A0A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '추가 문의사항이 있으시면 문의하기를 통해 연락해 주세요.',
                        style: const TextStyle(
                          fontSize: 13,
                          fontFamily: 'PretendardRegular',
                          color: Color(0xFF4A5565),
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _launchURL('https://tally.so/r/vGYyMX'),
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
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Widget _buildBaseCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
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

class FaqItemWidget extends StatefulWidget {
  final String question;
  final String answer;
  final bool isLast;

  const FaqItemWidget({
    super.key,
    required this.question,
    required this.answer,
    this.isLast = false,
  });

  @override
  State<FaqItemWidget> createState() => _FaqItemWidgetState();
}

class _FaqItemWidgetState extends State<FaqItemWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            onExpansionChanged: (expanded) {
              setState(() {
                _isExpanded = expanded;
              });
            },
            trailing: SvgPicture.asset(
              _isExpanded
                  ? 'android/assets/images/open.svg'
                  : 'android/assets/images/close.svg',
              width: _isExpanded ? 20 : 10,
              height: _isExpanded ? 20 : 10,
            ),
            tilePadding: const EdgeInsets.symmetric(horizontal: 20),
            childrenPadding: const EdgeInsets.only(bottom: 10),
            title: Text(
              widget.question,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'PretendardRegular',
                color: Color(0xFF0A0A0A),
              ),
            ),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 6,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.answer,
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'PretendardRegular',
                      color: Color(0xFF3A5565),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!widget.isLast)
          Divider(
            height: 1,
            color:
                _isExpanded ? const Color(0xFF4A5565) : const Color(0xFF000000),
          ),
      ],
    );
  }
}
