import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'final_leave.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
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
          '회원 탈퇴                                                                    ',
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '삭제되는 정보',
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'PretendardRegular',
                        color: Color(0xFF0A0A0A),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          '• ',
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'PretendardRegular',
                            color: Color(0xFFDC2626),
                          ),
                        ),
                        Text(
                          '계정 정보 (이메일, 비밀번호, 프로필 등)',
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'PretendardRegular',
                            color: Color(0xFF4A5565),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Text(
                          '• ',
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'PretendardRegular',
                            color: Color(0xFFDC2626),
                          ),
                        ),
                        Text(
                          '작성한 모든 투두리스트 및 루틴',
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'PretendardRegular',
                            color: Color(0xFF4A5565),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Text(
                          '• ',
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'PretendardRegular',
                            color: Color(0xFFDC2626),
                          ),
                        ),
                        Text(
                          '작성한 모든 일기',
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'PretendardRegular',
                            color: Color(0xFF4A5565),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Text(
                          '• ',
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'PretendardRegular',
                            color: Color(0xFFDC2626),
                          ),
                        ),
                        Text(
                          '그룹 일정 관리 참여 내역',
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'PretendardRegular',
                            color: Color(0xFF4A5565),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Text(
                          '• ',
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'PretendardRegular',
                            color: Color(0xFFDC2626),
                          ),
                        ),
                        Text(
                          '노션 연동 정보',
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
              ],
            ),
            const SizedBox(height: 3),
            _buildBaseCard(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '유지되는 정보',
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'PretendardRegular',
                        color: Color(0xFF0A0A0A),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          '• ',
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'PretendardRegular',
                            color: Color(0xFF0A0A0A),
                          ),
                        ),
                        Text(
                          '법령에 따라 보관이 필요한 정보 (거래 기록 등)',
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'PretendardRegular',
                            color: Color(0xFF4A5565),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Text(
                          '• ',
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'PretendardRegular',
                            color: Color(0xFF0A0A0A),
                          ),
                        ),
                        Text(
                          '그룹에 공유했던 일정 (그룹 내에서는 유지됨)',
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
              ],
            ),
            const SizedBox(height: 3),
            _buildBaseCard(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '탈퇴 대신 고려해보세요',
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'PretendardRegular',
                        color: Color(0xFF0A0A0A),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '✓ ',
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'PretendardRegular',
                            color: Color(0xFF2563EB),
                          ),
                        ),
                        Text(
                          '일시적으로 서비스를 사용하지 않으실 거라면 로그아웃\n만 하셔도 됩니다',
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'PretendardRegular',
                            color: Color(0xFF4A5565),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '✓ ',
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'PretendardRegular',
                            color: Color(0xFF2563EB),
                          ),
                        ),
                        Text(
                          '개인정보가 걱정되신다면 프로필 정보를 수정하실 수 있\n습니다',
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'PretendardRegular',
                            color: Color(0xFF4A5565),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '✓ ',
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'PretendardRegular',
                            color: Color(0xFF2563EB),
                          ),
                        ),
                        Text(
                          '불편하신 기능이 있다면 문의하기를 통해 알려주세요',
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
              ],
            ),
            const SizedBox(height: 3),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FinalLeaveScreen(),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                padding: EdgeInsets.symmetric(vertical: 13, horizontal: 20),
                height: 45,
                decoration: BoxDecoration(
                  color: Color(0xFFDC2626),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    '계속 진행하기',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'PretendardRegular',
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 3),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                padding: EdgeInsets.symmetric(vertical: 13, horizontal: 20),
                height: 45,
                decoration: BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Color(0xFFE5E7EB)),
                ),
                child: Center(
                  child: Text(
                    '취소',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'PretendardRegular',
                      color: Color(0xFF0A0A0A),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildNoticeBox() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: EdgeInsets.symmetric(vertical: 13, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '⚠️ ',
                style: TextStyle(fontSize: 22, color: Color(0xFFDC2626)),
              ),
              Text(
                '회원 탈퇴 시 주의사항',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'PretendardRegular',
                  color: Color(0xFFDC2626),
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            '        탈퇴 후에는 계정 및 데이터를 복구할 수 없습니다.',
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'PretendardRegular',
              color: Color(0xFF991B1B),
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
}
