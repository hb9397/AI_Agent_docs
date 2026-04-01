---
name: reroll-buddy
description: Claude Code의 /buddy 펫(companion)을 초기화하여 다시 뽑을 수 있게 합니다. "/reroll-buddy", "buddy 다시 뽑기", "펫 초기화", "companion 리셋", "buddy 리롤", "다른 펫 뽑고 싶어" 요청 시 사용합니다. /buddy로 뽑은 펫이 마음에 들지 않을 때 사용하세요.
---

# Reroll Buddy

Claude Code의 `/buddy` 펫(companion) 데이터를 초기화하여 다시 뽑을 수 있게 하는 스킬.

## 동작 원리

`/buddy`로 뽑은 펫 정보는 `~/.claude.json` 파일의 `companion` 키에 저장된다:

```json
{
  "companion": {
    "name": "Lumen",
    "personality": "...",
    "hatchedAt": 1775013234301
  }
}
```

이 키를 제거하면 `/buddy`를 다시 실행하여 새 펫을 뽑을 수 있다.

## 실행 절차

1. `~/.claude.json` 파일을 읽는다
2. `companion` 키가 있으면 현재 펫 정보를 사용자에게 보여준다
3. `companion` 키가 없으면 "이미 초기화되어 있다"고 알려주고 종료한다
4. 사용자에게 확인을 받은 뒤 `companion` 키를 제거하고 저장한다
5. `/buddy`를 다시 실행하라고 안내한다

### 구현 방법

```bash
python3 -c "
import json, os
path = os.path.expanduser('~/.claude.json')
with open(path, 'r') as f:
    data = json.load(f)
if 'companion' not in data:
    print('companion 키가 없습니다. 이미 초기화된 상태입니다.')
else:
    print(json.dumps(data['companion'], indent=2, ensure_ascii=False))
"
```

제거:
```bash
python3 -c "
import json, os
path = os.path.expanduser('~/.claude.json')
with open(path, 'r') as f:
    data = json.load(f)
del data['companion']
with open(path, 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
print('companion 제거 완료')
"
```

## 주의사항

- `~/.claude.json`은 Claude Code의 핵심 설정 파일이므로 `companion` 키만 정확히 제거해야 한다
- 제거 전 반드시 현재 펫 정보를 보여주고 사용자 확인을 받는다
- `/buddy`는 만우절(4월 1일) 이벤트 기능이므로 시기에 따라 다시 뽑기가 불가능할 수 있다