# OhMo - 개인 & 그룹 일정 관리 앱

> **할일(Todo), 루틴(Routine), 감정 일기(DayLog)를 하나로** — 개인 생산성과 그룹 협업을 동시에 지원하는 Flutter 앱

---

## 주요 기능

| 기능 | 설명 |
|---|---|
| 할일 & 루틴 관리 | 카테고리/색상별 구분, 요일 반복 설정, 알람 |
| 그룹 협업 | 그룹 생성·초대, 멤버 권한 관리, 공지사항 |
| 감정 일기 (DayLog) | 이모지 기반 감정 기록 + 하루 일기 작성 |
| 홈 화면 위젯 | iOS/Android 위젯에서 직접 완료 토글 |
| 오프라인 지원 | 오프라인 중 로컬 저장 → 온라인 복구 시 자동 동기화 |
| 푸시 알림 | FCM 기반 실시간 알림 (그룹 초대, 일정 알람) |

---

## 기술 스택

### Frontend
- **Flutter** (Dart 3.7.0+) — iOS/Android 크로스 플랫폼
- **Provider** — 전역 사용자 상태 관리 (ProfileData)
- **Drift (SQLite ORM)** — 로컬 데이터베이스 (11개 테이블)
- **Flutter Secure Storage** — JWT 토큰 보안 저장
- **Firebase (Core, Messaging, Analytics)** — 푸시 알림 및 사용자 분석
- **Home Widget** — 네이티브 홈 화면 위젯 연동

### Backend (외부 서버)
- REST API 기반 통신
- JWT 인증 (Access Token + Refresh Token)
- FCM 서버 사이드 푸시 알림

---

## 아키텍처

```
┌─────────────────────────────────────────┐
│          UI Layer (Screens)             │
│  HomeScreen / DaylogScreen / GroupScreen│
└────────────────┬────────────────────────┘
                 │
┌────────────────▼────────────────────────┐
│       State Management (Provider)       │
│           ProfileData                   │
└────────────────┬────────────────────────┘
                 │
┌────────────────▼────────────────────────┐
│          Service Layer                  │
│  AuthService / TodoService / ...        │
│  (JWT 자동 갱신 포함)                    │
└──────────┬──────────────────────────────┘
           │
    ┌──────▼──────┐    ┌────────────────┐
    │  Drift DB   │    │  REST API      │
    │  (SQLite)   │    │  (백엔드 서버)  │
    └─────────────┘    └────────────────┘
```

**핵심 설계 결정:**
- **왜 Drift?** — 타입 안전한 쿼리와 오프라인 동기화를 위해 raw SQLite 대신 Drift ORM 선택
- **왜 Provider?** — 전역적으로 필요한 사용자 정보(이메일, 닉네임, 게스트 여부)만 관리하므로 BLoC보다 가벼운 Provider 선택
- **왜 SecureStorage?** — JWT 토큰은 SharedPreferences(평문 저장)가 아닌 FlutterSecureStorage에 저장해 탈취 위험 최소화

---

## 로컬 DB 구조 (Drift)

```
Users / Groups / GroupMembers / Notices
Categories / Routines / Todos
CompletedRoutines / CompletedTodos
DayLogs / DayLogQuestions / Notifications
```

---

## 트러블슈팅 경험

### 1. 오프라인 동기화 - 데이터 유실 방지
**문제**: 네트워크 없는 상태에서 할일/루틴 생성 시 서버에 전달이 안 됨  
**해결**: Drift DB에 `isSynced` 플래그 추가 → `connectivity_plus`로 네트워크 복구 감지 → `SyncService`가 미동기 항목 일괄 전송

### 2. JWT 토큰 만료 처리 - 자동 재발급
**문제**: API 호출 중 토큰이 만료되면 401 에러로 앱이 로그인 화면으로 튕겨나감  
**해결**: `AuthService.authenticatedRequest()`에 401 감지 → Refresh Token으로 자동 재발급 → 원래 요청 재시도 로직 구현

### 3. 홈 위젯 ↔ 앱 양방향 통신
**문제**: 네이티브 위젯에서 Flutter 앱 데이터(할일 완료 여부)를 업데이트해야 함  
**해결**: `MethodChannel`을 통해 위젯 클릭 이벤트를 Flutter로 전달 → Drift DB 업데이트 → 위젯 새로고침

---

## 실행 방법

```bash
# 의존성 설치
flutter pub get

# 코드 생성 (Drift ORM)
dart run build_runner build

# 앱 실행
flutter run
```

---

## 프로젝트 구조

```
lib/
├── main.dart              # 앱 진입점
├── const/
│   ├── app_config.dart    # API URL 등 환경 설정
│   └── colors.dart        # 색상 팔레트
├── screen/                # UI 화면 (17개)
│   ├── login/             # 로그인, 회원가입
│   ├── group/             # 그룹 기능 (5개)
│   └── etc/               # 설정, FAQ 등
├── component/             # 재사용 UI 컴포넌트 (28개)
├── services/              # 비즈니스 로직 + API 통신 (12개)
├── models/                # 데이터 모델
└── db/                    # Drift 로컬 DB
```

---

## 개발자

**이유진** — [lee.yujineee@gmail.com](mailto:lee.yujineee@gmail.com)
