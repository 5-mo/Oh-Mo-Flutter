# 🗓️ OhMo (오모) - 나만의 방식대로 조합하는 커스텀 스케줄러

> **"계획형(J)부터 즉흥형(P)까지, 모두를 위한 일정 관리"**
> **GDGoC GDGoC Final Stride 인기상** 수상작

OhMo는 정해진 형식에 나를 맞추는 것이 아니라, 사용자의 성향과 라이프스타일에 따라 **루틴, 투두(To-do), 일기(Day-log)를 자유롭게 조합**하여 사용하는 미니멀 커스텀 스케줄러입니다.

---

## ✨ Key Features

### 1. 나만의 스케줄 조합 (Category Customizing)
* **P형을 위한 미니멀리즘**: 불필요한 카테고리는 밀어서 아예 보이지 않게 지워버릴 수 있습니다. (필요 시 복구 가능)
* **J형을 위한 풀옵션**: 루틴, 투두, 질문, 일기 등 모든 섹션을 활성화하여 꼼꼼한 기록이 가능합니다.

### 2. 하이브리드 달력 (Calendar Views)
* **유연한 보기 전환**: 한 달/일주일 보기를 자유롭게 전환하며 일정을 파악합니다.
* **직관적인 관리**: 색상별 카테고리 구분과 간편한 일정 등록 기능을 제공합니다.

### 3. 성장을 기록하는 데이로그 (Day-Log)
* **기분 & 달성률 시각화**: 이모지로 하루 기분을 기록하고, 주간 루틴/투두 달성률을 프로그레스 바로 확인합니다.
* **데일리 Q&A**: "오늘의 소비는?" 같은 질문에 답하며 일상의 사소한 기록들을 남깁니다.

### 4. 함께하는 즐거움 (Group Sharing)
* **공유 달력 & 공지**: 멤버를 초대하여 그룹 공지, 루틴, 투두를 실시간으로 공유합니다.
* **멤버 인터랙션**: 완료 상태를 캐릭터로 확인하고, @멤버 언급 기능을 통해 효율적으로 소통합니다.

### 5. 강력한 위젯 지원 (Widget & Continuity)
* **홈 화면 위젯**: 캘린더, 루틴, 투두 등 다양한 크기와 조합의 위젯을 제공합니다.
* **잠금화면 위젯**: iOS/Android 잠금화면에서 앱을 켜지 않고도 오늘의 할 일을 바로 확인합니다.

---

## 🛠 Technical Deep Dive

### 1️⃣ 다이내믹 UI 및 상태 관리
* 사용자의 설정(카테고리 활성/비활성)에 따라 UI 레이아웃이 실시간으로 대응하는 **컴포넌트 기반 아키텍처**를 설계했습니다.
* Drift(SQLite)를 활용하여 사용자의 커스텀 설정값을 로컬에 보존하고 앱 진입 시 최적의 로딩 속도를 구현했습니다.

### 2️⃣ 데이터 무결성 및 동기화 (Local-Server Sync)
* 오프라인 환경에서의 기록이 손실되지 않도록 로컬 우선 저장 후, 네트워크 연결 시 **Upsert 로직**을 통해 서버와 데이터를 동기화합니다.
* 임시 로컬 ID와 서버 ID 매핑 테이블을 통해 데이터 중복 및 정합성 문제를 해결했습니다.

### 3️⃣ 크로스 플랫폼 네이티브 연동
* Flutter 단일 코드베이스를 유지하면서도 iOS **WidgetKit**과 Android **App Widgets**을 활용해 플랫폼 특화 기능을 구현했습니다.
* 홈 화면 위젯과 앱 간의 실시간 데이터 공유를 위해 유연한 데이터 파이프라인을 구축했습니다.

---

## ⚙️ Tech Stack
- **Framework**: Flutter (Dart)
- **State Management**: Provider
- **Local Database**: Drift (SQLite)
- **Native Integration**: 
  - Home Widget (iOS/Android 홈 화면 위젯 연동)
  - Flutter Local Notifications (푸시 알림 및 스케줄링)
- **Backend & Auth**: 
  - Firebase (Core, Messaging, Analytics)
  - HTTP (REST API Communication)
- Storage & Security:
  - Flutter Secure Storage: 사용자 인증 토큰 등 민감한 데이터 암호화 저장
  - Shared Preferences: 사용자 앱 설정(J/P 성향, 알림 설정 등) 및 경량 데이터 관리
- **Design Assets**: SVG (flutter_svg), Custom Fonts (Pretendard, RubikSprayPaint)

---

## 👨‍💻 Team
- **이유진**: 프론트엔드 개발 (Flutter)
- **홍재원**: 디자이너
- **임효진**: 백엔드 개발
- **정은지**: AI 개발

---

## 🏆 Achievement
- **GDGoC Solution Challenge**: 앱의 확장성과 안정성을 인정받아 **인기상(Popularity Award)** 수상
- **App Store 정식 런칭**: 실사용자 피드백을 반영한 v1.0.2 업데이트 및 유지보수 진행 중

---
Copyright © 2026 OhMo Team. All rights reserved.
