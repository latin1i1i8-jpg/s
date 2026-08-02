# 🚀 자비스 모드 — 완벽한 설정 가이드

## 📋 폴더 구조

이미 모든 파일이 준비돼 있습니다.

```
JarvisMode/
├─ README.md                          프로젝트 전체 설명
├─ QUICK_START.md                     빠른 시작 (5분)
├─ SETUP.md                           이 파일
├─ github_setup.sh                    GitHub 자동 업로드 (선택)
├─ .gitignore                         Git 무시 목록
├─ build.gradle.kts                   루트 빌드 설정
├─ settings.gradle.kts
├─ gradle.properties
├─ gradle/wrapper/gradle-wrapper.properties
├─ app/
│  ├─ build.gradle.kts
│  ├─ proguard-rules.pro
│  ├─ src/main/
│  │  ├─ AndroidManifest.xml
│  │  ├─ java/com/jarvis/assistant/    (30개 Kotlin 파일)
│  │  └─ res/                          (아이콘, 테마)
│  └─ build/                           빌드 산출물 (첫 실행 후 생성)
└─ .github/workflows/build-apk.yml    GitHub Actions (자동 빌드)
```

**지금 바로** `/경로/to/JarvisMode` 폴더를 다운받으면 완성된 프로젝트입니다.

---

## 🎯 가장 빠른 방법 (GitHub + 자동 빌드)

### 1단계: GitHub 저장소 만들기 (1분)

https://github.com/new 에서:
- **Repository name**: `JarvisMode`
- **Public** 선택 (또는 Private, 무관)
- **Add a README.md**: 체크 **해제**
- **Create repository**
- 페이지에서 HTTPS 주소 복사 (예: `https://github.com/username/JarvisMode.git`)

### 2단계: 이 폴더를 GitHub에 올리기

```bash
# 방법 A: 스크립트 사용 (Mac/Linux)
cd /다운로드한/JarvisMode
bash github_setup.sh https://github.com/username/JarvisMode.git
```

또는 **수동으로** (Windows 포함):
```bash
cd /다운로드한/JarvisMode
git init
git add .
git commit -m "초기 커밋"
git branch -M main
git remote add origin https://github.com/username/JarvisMode.git
git push -u origin main
```

### 3단계: GitHub Actions가 자동 빌드 (2~3분)

1. GitHub 저장소 방문
2. **Actions** 탭 → 빌드 실행 중 표시 보임
3. 빌드 완료 후 **Artifacts** 섹션에서 `jarvis-debug-apk.zip` 다운로드
4. 압축 해제 → `app-debug.apk`

### 4단계: 폰에 설치

```bash
adb install -r app-debug.apk
```

또는:
- 폰 설정 → 불명의 출처에서 설치 허용
- APK 파일 직접 실행

---

## 💻 로컬 빌드 (안드로이드 스튜디오 없이)

### Mac/Linux
```bash
cd /다운로드한/JarvisMode
gradle wrapper --gradle-version 8.9   # 최초 1회만
./gradlew assembleDebug
# 결과: app/build/outputs/apk/debug/app-debug.apk
```

### Windows
```cmd
cd C:\다운로드한\JarvisMode
gradle wrapper --gradle-version 8.9
gradlew assembleDebug
```

> 요구사항: Java 17 이상
>
> 버전 확인: `java -version`
>
> 없으면: https://www.oracle.com/java/technologies/downloads/#java17

---

## 🎨 안드로이드 스튜디오 (추천)

1. **File** → **Open** → 이 폴더 선택
2. **Sync** 완료 대기 (5~10초)
3. **Run** (또는 ⌘+R / Ctrl+R)

스튜디오가 Gradle Wrapper를 자동으로 내려받고 에뮬레이터나 연결된 폰에 설치합니다.

---

## 🔑 첫 실행 (키 등록)

앱이 설치되면 다음 화면이 순서대로 나옵니다.

### 1️⃣ 키 등록 화면
- **"AI Studio 에서 키 발급받기"** 버튼 클릭
- 브라우저에서 Google AI Studio 열림
- **+ Create API Key** 클릭
- **Create API Key in new project** → API Key 복사
- 앱으로 돌아와 붙여넣기

### 2️⃣ 키 검증
- **"키 확인하고 시작"** 버튼
- Gemini 한 번 호출로 살아있는 키인지 확인 (2초)
- ✅ 통과 → 제어판으로

### 3️⃣ 권한 설정
```
✓ 런타임 권한 요청     → 터치로 모두 허용
✓ 알림 접근 허용       → 설정 열기 → 자비스 모드 켜기
✓ 배터리 최적화 예외   → 설정 열기 → 자비스 모드 추가
```

### 4️⃣ 가동
- **가동** 버튼 터치
- 상단에 "자비스 가동 중" 알림 표시 → 이어폰으로 브리핑 시작

> 💡 **핵심**: API Key 없으면 서비스가 아예 뜨지 않습니다.
>         키를 등록하지 않으면 화면도 제어판으로 넘어가지 않습니다.

---

## ⚠️ 주의사항

### 갤럭시 핏3 심박
표준 BLE Heart Rate Service(0x180D)는 서드파티 앱에 닫혀 있을 수 있습니다.

**해결:**
- Health Connect(Google) 설치 → `androidx.health:health-connect` 판 만들기
- `HeartRateSource` 인터페이스만 구현하면 엔진은 손댈 필요 없음

### API Key 보안
- 빌드에 키가 없으므로 APK 디컴파일로는 노출 안 됨 ✅
- 기기가 **루팅**돼 있으면 SharedPreferences는 읽힐 수 있음
- 배포용 앱은 Google Cloud 콘솔에서 앱 제한 걸기

### 배터리
- 삼성 기기는 배터리 최적화 예외를 걸지 않으면 몇 분 뒤 서비스가 죽음
- 위치 권한은 "항상 허용"으로 설정하면 화면 꺼진 상태에서도 계속 추적

---

## 🔧 코드 수정

### 어조 / 농담 변경
`app/src/main/java/com/jarvis/assistant/gemini/PromptBuilder.kt` 의
`SYSTEM_INSTRUCTION` 수정

### 건강 임계값 조정
`app/src/main/java/com/jarvis/assistant/core/Constants.kt` 수정
```kotlin
const val HR_STRESS_MIN = 110      // 정지 중 스트레스 시작 심박
const val HR_OVERLOAD_MIN = 170    // 이동 중 과부하 시작 심박
```

### 평시 농담 끄기 또는 주기 변경
앱 화면 → 설정 → **평시 훈수 켜기** 토글

### Gemini 모델 교체
`Constants.kt` 수정
```kotlin
const val GEMINI_MODEL = "gemini-2.5-flash"   // 다른 모델로 변경
```

---

## 🎬 완전 흐름 요약

```
1. 이 폴더 다운로드
   ↓
2. GitHub에 올리기 (또는 로컬 빌드)
   ↓
3. APK 설치
   ↓
4. 앱 실행 → API Key 등록 → 검증
   ↓
5. 권한 설정 (런타임 + 알림 접근 + 배터리)
   ↓
6. 가동 버튼 → 비서 시작 🎉
```

**소요 시간**: 약 15분

---

## ❓ FAQ

**Q. API Key 를 몰라요**
A. https://aistudio.google.com/apikey 에서 무료 발급. 신용카드 불필요.

**Q. 앱이 자꾸 꺼져요**
A. 배터리 최적화 예외를 걸어주세요. (설정 가이드는 위 참고)

**Q. GitHub Actions 탭이 없어요**
A. Settings → Actions → General → Allow all actions 체크

**Q. 내 폰이 Android 10 미만이에요**
A. minSdk = 26 (Android 8.0) 이므로 대부분 호환. 다만 일부 기능(알림 채널)은 동작 안 할 수 있음.

**Q. 다른 사람에게 APK 줄 수 있나요**
A. 네. APK에 API Key가 없으므로 안전합니다. 받은 사람이 자기 Key를 등록해서 쓰면 됨.

---

구글 AI Studio 바로 가기: https://aistudio.google.com/apikey

