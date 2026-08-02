# 빠른 시작 가이드

이 폴더의 모든 파일을 그대로 GitHub 저장소에 올리면, GitHub Actions가 자동으로 APK를 빌드해 줍니다.

## 1단계: GitHub에 올리기

### A. 이미 GitHub 계정이 있으신 경우
```bash
# 1) 아래 링크에서 새 저장소 만들기
#    https://github.com/new
#    Repository name: JarvisMode (자유롭게 설정)
#    Add a README.md: 체크 해제
#    Create

# 2) 이 폴더를 저장소에 올리기
cd /경로/to/JarvisMode
git init
git add .
git commit -m "초기 커밋"
git branch -M main
git remote add origin https://github.com/YOU/JarvisMode.git
git push -u origin main
```

### B. GitHub 계정이 없으신 경우
[https://github.com/signup](https://github.com/signup) 에서 1분 안에 만들 수 있습니다.

## 2단계: 자동 빌드 기다리기

GitHub에 푸시하면:
1. `.github/workflows/build-apk.yml` 이 자동으로 실행됨
2. Ubuntu 러너에서 APK 빌드 (2~3분 소요)
3. Actions 탭 → 최신 워크플로 클릭 → **Artifacts** 섹션에서 `jarvis-debug-apk.zip` 다운로드

## 3단계: 폰에 설치

```bash
unzip jarvis-debug-apk.zip
adb install -r app-debug.apk
```

또는 폰 설정 → 불명의 출처에서 설치 허용 → APK 파일 직접 실행

---

## 로컬에서 빌드하고 싶으신 경우

### 안드로이드 스튜디오
1. 이 폴더를 안드로이드 스튜디오에서 열기
2. Gradle Sync 완료 대기
3. **Run** (또는 ⌘+R)

### 명령줄 (Mac/Linux)
```bash
cd /경로/to/JarvisMode
gradle wrapper --gradle-version 8.9     # 최초 1회만
./gradlew assembleDebug
# → app/build/outputs/apk/debug/app-debug.apk
```

### 명령줄 (Windows)
```cmd
cd C:\경로\to\JarvisMode
gradle wrapper --gradle-version 8.9
gradlew assembleDebug
```

---

## 빌드 후 실행

앱이 설치되면:
1. **자비스 모드** 실행
2. 키 등록 화면 → Google AI Studio 버튼 클릭
3. API Key 발급 (무료, 1분) → 붙여넣기
4. **키 확인하고 시작** → (Gemini 한 번 호출로 검증)
5. 제어판 → 권한 요청 → 알림 접근 허용 → 배터리 최적화 예외
6. **가동** 버튼

> ⚠️ **API Key 없으면 서비스가 안 뜹니다**
> 이게 정상입니다. 키 등록을 마쳐야 "자비스 모드"가 가동됩니다.

---

## 문제 해결

| 증상 | 해결 |
|------|------|
| GitHub Actions 탭이 안 보임 | Settings → Actions → General → Allow all actions |
| APK 빌드 실패 | Actions 로그 보기 (빌드 실패 이유가 나옴) |
| 앱 설치 안 됨 | `adb uninstall com.jarvis.assistant` 후 재설치 |
| 앱 실행 후 검은 화면 | 폰 재시작 후 다시 실행 |

