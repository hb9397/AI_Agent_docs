#!/bin/bash
# 프로젝트 룰 검사 스크립트 (범용 — 언어 무관)
# 사용: bash scan.sh [대상 디렉토리]

TARGET="${1:-.}"
CODE="--include=*.java --include=*.kt --include=*.ts --include=*.tsx --include=*.js --include=*.jsx --include=*.py --include=*.go --include=*.rs"

echo "=== 프로젝트 룰 검사 스캔 ==="
echo "대상: $TARGET"
echo ""

# 변경 파일 목록
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "## 변경 파일 목록"
  CHANGED=$(git diff --name-only HEAD 2>/dev/null; git diff --name-only --staged 2>/dev/null)
  if [ -z "$CHANGED" ]; then
    echo "(변경 파일 없음 — 전체 스캔)"
  else
    echo "$CHANGED" | sort -u
  fi
  echo ""
fi

# --- 1. 에러 처리 ---
echo "## 1. 에러 처리"
echo ""

echo "### 빈 catch/except 블록"
grep -rn $CODE "catch.*{}" "$TARGET" 2>/dev/null
grep -rn --include="*.py" "except.*:\s*$" "$TARGET" 2>/dev/null
grep -rn $CODE "catch\s*{" "$TARGET" 2>/dev/null | head -20
echo "(위 결과 중 빈 블록 확인 필요)"
echo ""

echo "### 에러 무시 주석 (// ignore, # noqa 등)"
grep -rn $CODE -i "// *ignore\|# *ignore\|# *noqa" "$TARGET" 2>/dev/null || echo "(없음)"
echo ""

# --- 2. 타임아웃 ---
echo "## 2. 외부 호출 (타임아웃 확인 필요)"
echo ""
grep -rn $CODE "fetch(\|axios\.\|requests\.\|HttpClient\|http\.Get\|http\.Post" "$TARGET" 2>/dev/null | head -20 || echo "(없음)"
echo ""

# --- 3. 민감 정보 ---
echo "## 3. 민감 정보"
echo ""

echo "### 하드코딩된 비밀번호/키/토큰"
grep -rn $CODE -iE "(password|apikey|api_key|secret|token)\s*[:=]\s*[\"']" "$TARGET" 2>/dev/null | grep -iv "test\|mock\|example\|placeholder\|TODO\|env\." | head -20 || echo "(없음)"
echo ""

echo "### .env / 설정 파일 변경"
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git diff --name-only --staged 2>/dev/null | grep -iE "\.env|credential|secret|application\.yml|application\.properties" || echo "(없음)"
fi
echo ""

# --- 4. TODO ---
echo "## 4. TODO 주석"
echo ""

echo "### 모든 TODO/FIXME/HACK"
grep -rn $CODE "TODO\|FIXME\|HACK\|XXX" "$TARGET" 2>/dev/null | head -20 || echo "(없음)"
echo ""

echo "### 기한 없는 TODO"
grep -rn $CODE "TODO" "$TARGET" 2>/dev/null | grep -v "TODO(@\|TODO(\|#[0-9]" | head -20 || echo "(없음)"
echo ""

# --- 5. 테스트 ---
echo "## 5. 테스트 존재 여부"
echo ""

echo "### 변경된 비즈니스 로직 파일"
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git diff --name-only HEAD 2>/dev/null | grep -ivE "test|spec|mock|fixture|\.env|\.md|\.json|\.yml|\.yaml" | head -20 || echo "(없음)"
fi
echo ""

echo "### 테스트 파일 목록"
find "$TARGET" \( -name "*Test.*" -o -name "*Spec.*" -o -name "*.test.*" -o -name "*.spec.*" -o -name "test_*" \) -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null | head -20 || echo "(없음)"
echo ""

echo "=== 스캔 완료 ==="
