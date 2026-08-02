# 📦 파일 인덱스

전체 41개 파일. 모두 GitHub에 올려도 됩니다.

## 📄 문서 (읽기)
- **README.md** — 전체 프로젝트 설명 ⭐ 먼저 읽기
- **QUICK_START.md** — 5분 안에 끝내기
- **SETUP.md** — 완벽한 설정 가이드
- **INDEX.md** — 이 파일 (파일 구조 설명)

## ⚙️ 빌드 설정 (그대로 둬도 됨)
- `build.gradle.kts` — 루트 Gradle
- `settings.gradle.kts`
- `gradle.properties`
- `gradle/wrapper/gradle-wrapper.properties`
- `app/build.gradle.kts` — 앱 빌드
- `app/proguard-rules.pro`

## 🚀 GitHub 자동화
- `.github/workflows/build-apk.yml` — GitHub Actions (푸시하면 자동 빌드)
- `github_setup.sh` — GitHub 업로드 스크립트 (선택)
- `.gitignore`

## 💻 소스코드 (Kotlin)

### 핵심 (먼저 봐야 할 것)
- `core/JarvisBus.kt` ⭐ — 전역 이벤트 버스
- `engine/BriefingEngine.kt` ⭐ — 우선순위 엔진
- `service/JarvisService.kt` — 포그라운드 서비스

### 센서 수집
- `ble/HeartRateBleManager.kt` — 갤럭시 핏3 심박
- `location/LocationTracker.kt` — GPS 속도/고도
- `engine/HealthMonitor.kt` — 건강 판정 (2순위)

### 트리거 소스 (4순위)
- `phone/CallReceiver.kt` — 1순위 (수신 전화)
- `phone/PhoneStateWatcher.kt` — 1순위 (API 31+)
- `phone/CallerLookup.kt` — 번호 → 이름
- `notification/JarvisNotificationListener.kt` — 3순위 (앱 알림)

### Gemini & TTS
- `gemini/GeminiManager.kt` ⭐ — REST 호출 (키 검증 포함)
- `gemini/PromptBuilder.kt` ⭐ — 시스템 프롬프트 (어조 수정처)
- `tts/TtsManager.kt` — 한국어 발화

### 설정 & 유틸
- `data/AppPrefs.kt` — SharedPreferences (키 저장)
- `util/Permissions.kt` — 권한 체크
- `util/NotificationHelper.kt` — 알림 채널
- `util/HapticBridge.kt` — 진동
- `core/Constants.kt` — 모든 임계값 / UUID / 엔드포인트
- `core/Models.kt` — 데이터 클래스

### UI
- `ui/MainActivity.kt` — 키 등록 + 제어판
- `ui/Theme.kt` — Compose 테마
- `notification/InstalledAppLoader.kt` — 앱 목록 로더
- `JarvisApp.kt` — Application 클래스

## 🎨 리소스 (XML / 이미지)
- `res/drawable/ic_launcher_foreground.xml` — 런처 아이콘 (심박 파형)
- `res/drawable/ic_stat_jarvis.xml` — 상단 알림 아이콘
- `res/mipmap-anydpi-v26/ic_launcher.xml` — 적응형 아이콘
- `res/mipmap-anydpi-v26/ic_launcher_round.xml`
- `res/values/strings.xml` — 앱 이름 / 라벨
- `res/values/themes.xml` — 안드로이드 테마 (Compose가 실제 UI)
- `res/values/colors.xml` — 런처 배경색

## 📱 AndroidManifest.xml
- 권한 선언 (31개)
- 서비스 / 리시버 등록
- 알림 채널

---

## 🎯 손대야 할 곳

### 어조 바꾸기
→ `core/PromptBuilder.kt` 의 `SYSTEM_INSTRUCTION`

### 임계값 조정
→ `core/Constants.kt` 의 `HR_STRESS_MIN` / `HR_OVERLOAD_MIN` 등

### 모델 교체
→ `Constants.kt` 의 `GEMINI_MODEL`

### 심박 소스 교체 (Health Connect 판)
→ `ble/HeartRateBleManager.kt` 를 구현한 다른 클래스를 만들고
→ `service/JarvisService.kt` 에서 `ble` 변수만 바꾸면 됨

---

## 📊 통계
- 소스 파일: 28개 (.kt)
- 리소스: 8개 (.xml 등)
- 설정: 5개 (.gradle.kts, .properties 등)
- 문서: 4개 (.md)
- 총 크기: 약 300 KB (빌드 산출물 제외)

---

## ✅ 체크리스트

- [ ] README.md 읽음
- [ ] SETUP.md 로 설정 진행 중
- [ ] GitHub 저장소 만들었음 (또는 로컬 빌드 준비)
- [ ] APK 빌드 완료
- [ ] 폰에 설치
- [ ] API Key 등록 완료
- [ ] 권한 설정 완료
- [ ] 비서 가동 중 ✨

