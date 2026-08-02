# 자비스 모드 — 안드로이드 단일 앱 구조 정리

BLE 심박 + GPS + Gemini + TTS 를 하나의 포그라운드 서비스로 묶은 개인 비서 앱.
서버 없이 앱 안에서 전부 처리한다.

## 1. 파일 구조

```
JarvisMode/
├─ settings.gradle.kts / build.gradle.kts / gradle.properties   루트 빌드 설정
├─ .github/workflows/build-apk.yml   푸시하면 APK 자동 빌드 (스튜디오 없이 뽑을 때)
└─ app/src/main/java/com/jarvis/assistant/
├─ JarvisApp.kt                  앱 진입점 (알림 채널 생성)
├─ core/
│   ├─ Constants.kt              임계값·UUID·엔드포인트 등 모든 매직넘버
│   ├─ Models.kt                 Priority / Trigger / SensorSnapshot / BriefingResult
│   └─ JarvisBus.kt              전역 이벤트 버스 + 상태 StateFlow  ★핵심
├─ data/AppPrefs.kt              설정 저장
├─ ble/HeartRateBleManager.kt    표준 BLE 심박(0x180D) 구독
├─ location/LocationTracker.kt   속도·고도·좌표 + 역지오코딩
├─ gemini/
│   ├─ PromptBuilder.kt          시스템 프롬프트 & 폴백 대본  ★어조 수정은 여기만
│   └─ GeminiManager.kt          REST 호출 + JSON 스키마 강제
├─ tts/TtsManager.kt             한국어 발화, 오디오 포커스, 끊어치기
├─ notification/
│   ├─ JarvisNotificationListener.kt   3순위 소스
│   └─ InstalledAppLoader.kt           설정 화면용 앱 목록
├─ phone/
│   ├─ CallReceiver.kt           1순위 소스 (브로드캐스트)
│   ├─ PhoneStateWatcher.kt      1순위 소스 (API 31+ 정식 경로)
│   └─ CallerLookup.kt           번호 → 연락처 이름
├─ engine/
│   ├─ HealthMonitor.kt          2순위 판정 (로컬 계산)
│   └─ BriefingEngine.kt         우선순위 큐 + 쿨다운 + 선점  ★핵심
├─ service/
│   ├─ JarvisService.kt          포그라운드 서비스 (몸통)
│   └─ BootReceiver.kt           재부팅 자동 실행
├─ util/                         권한 · 알림 · 진동
└─ ui/                           Compose 제어판
```

## 2. 데이터 흐름

```
CallReceiver ─┐
NotifListener ─┼─→ JarvisBus.events ─→ BriefingEngine ─→ GeminiManager ─→ TtsManager
HealthMonitor ─┤                          (우선순위 선택      (JSON 응답)     (이어폰)
Ambient 타이머 ─┘                          + 쿨다운 + 선점)

BLE / GPS ─→ JarvisBus.sensors ─→ (HealthMonitor 판정, 프롬프트 컨텍스트, UI 표시)
```

**리팩토링의 핵심은 `JarvisBus`다.** NotificationListenerService 와 BroadcastReceiver 는
시스템이 마음대로 살리고 죽이기 때문에 포그라운드 서비스와 직접 바인딩하면 코드가 엉킨다.
전역 SharedFlow 하나를 두고 전부 여기로만 흘리면 각 컴포넌트가 서로를 몰라도 된다.

## 3. 우선순위 규칙

| 순위 | 트리거 | 쿨다운 | 특징 |
|---|---|---|---|
| 1 | 수신 전화 | 없음 | 진행 중 발화를 끊고 즉시 말함 |
| 2 | 건강 경고 | 60초 | 로컬 판정 + 히스테리시스, 진동 동반 |
| 3 | 허용 앱 알림 | 8초 | 중복 알림 억제, 40자 요약 |
| 4 | 평시 훈수 | 5분 | 실패 시 조용히 넘어감 |

- 판정은 전부 **로컬**에서 하고 Gemini 는 "문장 만들기"에만 쓴다.
  심박이 흔들릴 때마다 API 를 부르면 무료 쿼터가 몇 분 만에 녹는다.
- 히스테리시스: 임계값 근처에서 왔다갔다 할 때 반복 경고를 막는다.
  경고 발생 후 -10 BPM 아래로 내려와야 다시 울린다.
- 네트워크가 죽어도 1·2순위는 `PromptBuilder.fallbackSpeech()` 로 반드시 소리가 난다.

## 4. 빌드

### A. 안드로이드 스튜디오
프로젝트 폴더를 열고 Sync 한 뒤 Run. 스튜디오가 Gradle Wrapper 를 자동으로 채운다.

### B. 명령줄 한 방
```bash
gradle wrapper --gradle-version 8.9   # 최초 1회 (wrapper jar 생성)
./gradlew assembleDebug
# 결과물: app/build/outputs/apk/debug/app-debug.apk
```

### C. 스튜디오도 JDK도 없을 때
이 프로젝트를 GitHub 저장소에 올리기만 하면 `.github/workflows/build-apk.yml` 이
푸시할 때마다 디버그 APK 를 빌드해 Actions → Artifacts 에 올려준다. 받아서 폰에 설치하면 끝이다.

> 참고: 디버그 APK 는 디버그 키로 서명돼 있어 그대로 설치된다.
> 스토어 배포용 release 빌드를 하려면 별도 키스토어 서명이 필요하다.

## 5. 첫 실행 (API Key 게이트)

**키가 없으면 앱은 아무것도 하지 않는다.** 빌드에 키를 굽지 않으므로 APK 는 누구에게 줘도 안전하다.

1. 앱 실행 → 키 등록 화면이 먼저 뜬다. 이 화면은 건너뛸 수 없다.
2. Google AI Studio 에서 무료 키를 발급받아 붙여넣는다 (화면의 버튼이 바로 열어준다).
3. **"키 확인하고 시작"** → 실제로 Gemini 를 한 번 호출해 살아있는 키인지 검증한다.
   - 통과해야만 제어판으로 넘어간다.
   - 거부되면 `prefs.apiKeyVerified = false` 로 남아 다음 실행 때도 다시 이 화면이다.
4. 제어판에서 권한 요청 → 알림 접근 허용 → 배터리 최적화 예외 → **가동**

키 검증을 통과하지 못하면:
- `JarvisService.onStartCommand` 가 `stopSelf()` 로 즉시 내려간다 (`prefs.hasUsableKey` 검사)
- `BootReceiver` 도 재부팅 자동 실행을 건너뛴다
- 즉 키 없이는 센서도, 알림 수집도, TTS 도 돌지 않는다

키는 `SharedPreferences` 에만 저장되고 앱 밖으로 나가지 않는다.
제어판 → 설정 → **변경** 을 누르면 저장된 키를 지우고 다시 등록 화면으로 돌아간다.

## 6. 알아둘 제약 (중요)

**갤럭시 핏3 심박**
표준 BLE Heart Rate Service(0x180D)는 삼성 웨어러블이 서드파티 앱에 열어주지 않는 경우가 많다.
`HeartRateBleManager` 로 스캔했을 때 잡히지 않으면, 같은 `HeartRateSource` 인터페이스를 구현하는
**Health Connect(androidx.health.connect)** 판을 하나 더 만들어 끼우면 된다.
엔진과 나머지 코드는 `JarvisBus.updateHeartRate()` 만 보므로 손댈 필요가 없다.

**핏3 진동**
서드파티가 핏3 를 직접 진동시키는 공개 API 는 없다. 그래서 과부하 경고 시
IMPORTANCE_HIGH 알림을 띄워 **핏3 의 알림 미러링 진동을 유도**하는 방식을 썼다(`HapticBridge`).
폰 진동은 동시에 나간다.

**API Key 보안**
키를 빌드에 굽지 않고 런타임 입력으로 바꿨기 때문에 APK 디컴파일로는 키가 나오지 않는다.
다만 기기가 루팅돼 있으면 SharedPreferences 는 읽힌다. 여러 사람에게 배포할 계획이면
Google Cloud 콘솔에서 키에 Android 앱 제한(패키지명 + SHA-1)을 걸어두는 편이 낫다.

**발신자 번호**
Android 10 부터 `EXTRA_INCOMING_NUMBER` 는 `READ_CALL_LOG` 가 있어야 채워진다.
없으면 "알 수 없는 번호"로 브리핑한다. 이름을 부르려면 `READ_CONTACTS` 도 필요하다.
(참고: `READ_CALL_LOG` 를 쓰는 앱은 Play 스토어 심사에서 용도 설명을 요구받는다.)

## 7. 손대기 좋은 지점

- **어조/농담 스타일** → `PromptBuilder.SYSTEM_INSTRUCTION` 만 수정
- **임계값** → `Constants.HR_STRESS_MIN` 등
- **말이 너무 많다** → `Priority` enum 의 `cooldownMs` 를 늘리거나 평시 훈수 끄기
- **모델 교체** → `Constants.GEMINI_MODEL`
  (thinking 미지원 모델로 바꾸면 `GeminiManager` 의 `thinkingConfig` 블록 삭제)


---

## 🚀 빠른 시작

파일을 다운받아 GitHub에 올리면 **자동으로 APK가 빌드**됩니다.

👉 **[QUICK_START.md](QUICK_START.md)** 참고

