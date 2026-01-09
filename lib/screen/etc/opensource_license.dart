import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

class OpenSourceLicenseScreen extends StatefulWidget {
  const OpenSourceLicenseScreen({super.key});

  @override
  State<OpenSourceLicenseScreen> createState() =>
      _OpenSourceLicenseScreenState();
}

class _OpenSourceLicenseScreenState extends State<OpenSourceLicenseScreen> {
  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
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
          '오픈소스 라이선스                                                                        ',
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
                const Text(
                  '이 서비스는 다음 오픈소스 소프트웨어를 사용하여 개발되었습니다. 각 라이브러리의 저작권자와 기여분들께 감사드립니다.',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'PretendardRegular',
                    color: Color(0xFF4A5565),
                  ),
                ),
                const SizedBox(height: 30),
                
                _buildLibraryItem(
                  'flutter_local_notifications',
                  '19.4.2',
                  'Local notification plugin for Flutter.',
                  'BSD License',
                  'https://pub.dev/packages/flutter_local_notifications',
                ),
                _buildLibraryItem(
                  'drift',
                  '2.28.1',
                  'Reactive persistence library for Flutter and Dart.',
                  'Apache 2.0',
                  'https://pub.dev/packages/drift',
                ),
                _buildLibraryItem(
                  'shared_preferences',
                  '2.2.2',
                  'Flutter plugin for reading and writing simple key-value pairs.',
                  'BSD License',
                  'https://pub.dev/packages/shared_preferences',
                ),
                _buildLibraryItem(
                  'flutter_svg',
                  '2.0.17',
                  'An SVG rendering and drawing library for Flutter.',
                  'MIT License',
                  'https://pub.dev/packages/flutter_svg',
                ),
                _buildLibraryItem(
                  'timezone',
                  '0.10.1',
                  'Time zone database and calculations for Dart.',
                  'BSD License',
                  'https://pub.dev/packages/timezone',
                ),
                _buildLibraryItem(
                  'intl',
                  '0.18.1',
                  'Internationalization and localization support.',
                  'BSD License',
                  'https://pub.dev/packages/intl',
                ),
                _buildLibraryItem(
                  'provider',
                  '6.0.0',
                  'A wrapper around InheritedWidget for state management.',
                  'MIT License',
                  'https://pub.dev/packages/provider',
                  isLast: true,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Divider(height: 1, color: Color(0xFFF3F4F6)),
                ),

                const SizedBox(height: 10),

                _buildLicenseTextSection(
                  'MIT License',
                  '''
Copyright (c) 2026 OhMo Team\n\nPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.''',
                ),
                const SizedBox(height: 30),
                _buildLicenseTextSection(
                  'BSD License',
                  '''
Copyright (c) 2026 OhMo Team\n\nRedistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES.''',
                ),
                const SizedBox(height: 30),

                _buildInternalNoticeBox(),
              ],
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildLibraryItem(String name,
      String version,
      String desc,
      String license,
      String url, {
        bool isLast = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'PretendardRegular',
                  color: Color(0xFF0A0A0A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  version,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6A7282),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            desc,
            style: const TextStyle(fontSize: 13, color: Color(0xFF4A5565)),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  license,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF1E40AF),
                    fontFamily: 'PretendardRegular',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _launchURL(url),
                child: const Text(
                  '웹사이트 방문',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
          if (!isLast)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(height: 1, color: Color(0xFFF3F4F6)),
            ),
          if (isLast) const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildLicenseTextSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'PretendardRegular',
            color: Color(0xFF0A0A0A),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF415565),
              fontFamily: 'Courier',
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInternalNoticeBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFFBBF24)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '참고:',
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'PretendardBold',
              color: Color(0xFF78350F),
            ),
          ),
          SizedBox(height: 4),
          Text(
            '이 목록은 주요 오픈소스 라이브러리만 포함하고 있습니다. 전체 의존성 목록 및 라이선스 정보는 프로젝트의 pubspec.yaml 파일을 참조하세요.',
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
}
