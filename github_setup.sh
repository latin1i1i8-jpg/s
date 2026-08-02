#!/bin/bash

# GitHub에 올리는 자동화 스크립트
# 사용: bash github_setup.sh <저장소URL>

REPO_URL="${1}"

if [ -z "$REPO_URL" ]; then
    echo "❌ 사용 방법: bash github_setup.sh <GitHub저장소URL>"
    echo ""
    echo "예시:"
    echo "  bash github_setup.sh https://github.com/username/JarvisMode.git"
    echo ""
    echo "GitHub에서 새 저장소 만드는 법:"
    echo "  1. https://github.com/new 방문"
    echo "  2. Repository name: JarvisMode"
    echo "  3. Add a README.md: 체크 해제"
    echo "  4. Create → HTTPS 주소 복사"
    exit 1
fi

echo "🚀 GitHub 저장소에 올리는 중..."
echo "   저장소: $REPO_URL"
echo ""

# 현재 디렉토리를 Git 저장소로 초기화
git init
git add .
git commit -m "초기 커밋: 자비스 모드 완전 프로젝트"

# main 브랜치로 설정 (GitHub 기본값)
git branch -M main

# 원격 저장소 추가
git remote add origin "$REPO_URL"

# main 브랜치로 푸시
git push -u origin main

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ 성공! GitHub에 올려졌습니다."
    echo ""
    echo "다음 단계:"
    echo "  1. $REPO_URL 방문"
    echo "  2. Actions 탭 클릭"
    echo "  3. 첫 번째 빌드가 실행 중이면 기다리기 (2~3분)"
    echo "  4. 빌드 완료 후 Artifacts에서 jarvis-debug-apk.zip 다운로드"
    echo "  5. adb install -r app-debug.apk"
    echo ""
    echo "또는 GitHub에서 직접 다운로드:"
    echo "  https://github.com/username/JarvisMode/actions"
else
    echo ""
    echo "❌ 푸시 실패. 다음을 확인해 주세요:"
    echo "  1. 저장소 URL 이 정확한가?"
    echo "  2. GitHub 계정에 로그인했는가? (git config --global user.email 'xxx')"
    echo "  3. 저장소가 존재하고 비어 있는가?"
    exit 1
fi
