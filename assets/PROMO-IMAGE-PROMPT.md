# Promo image prompt / 홍보 이미지 프롬프트

> The generated image itself is **git-ignored** (see `.gitignore`). Only this prompt is tracked.
> 생성된 이미지는 **git에서 제외**됩니다(`.gitignore`). 이 프롬프트만 추적됩니다.
>
> Generate on claude.ai or any image model, then save the result as e.g. `assets/promo.png`.
> claude.ai 등에서 생성 후 `assets/promo.png` 등으로 저장하세요.

---

## Prompt (English — recommended for image models)

```
A clean, modern flat-design isometric tech illustration, 16:9 wide aspect ratio,
on a light background (white to soft blue gradient). Professional infographic
style suitable for a GitHub social preview / blog header. Crisp vector look,
soft long shadows, a cool blue-and-teal palette with one warm accent color.

COMPOSITION — a horizontal network diagram split into a LEFT region and a
RIGHT region, with two glowing dashed "encrypted tunnel" lines crossing the
gap between them (small padlock icons on the tunnels to signal encryption).

LEFT THIRD — labeled "KOREA / 한국". Show TWO separate small wired routers in
TWO different cities, stacked vertically and clearly distinct:
  - Top: a small wired router box with an antenna and an Ethernet cable,
    on a small platform labeled "SEOUL / 서울", with a tiny city-skyline
    silhouette behind it.
  - Bottom: another small wired router box with an Ethernet cable, on a
    platform labeled "BUSAN / 부산", with a tiny coastal/port skyline behind it.
  Each router emits one glowing encrypted tunnel line heading to the right.

RIGHT TWO-THIRDS — labeled "OVERSEAS / 해외". In the middle, a central server/box
node labeled "LOAD BALANCER", receiving BOTH tunnel lines from the two Korean
routers. Show a small circular "round-robin / failover" motif near it (two
curved arrows alternating between the two incoming lines). From the load
balancer, a single clean line connects to the right edge where a LAPTOP showing
a web browser window and a SMARTPHONE sit on a desk surface, representing the
end-user client devices streaming video.

Minimal, legible labels only (KOREA/한국, SEOUL/서울, BUSAN/부산, OVERSEAS/해외,
LOAD BALANCER, round-robin). No paragraphs of text, no watermark, no logos of
real companies. Balanced, uncluttered, polished, presentation-grade.
```

## 프롬프트 (한국어 버전)

```
밝은 배경(흰색~연한 파랑 그라데이션)의 깔끔하고 현대적인 플랫 아이소메트릭
테크 일러스트, 16:9 가로 비율. GitHub 소셜 프리뷰/블로그 헤더에 어울리는
전문 인포그래픽 스타일. 선명한 벡터 느낌, 부드러운 긴 그림자, 차가운
파랑·청록 팔레트에 따뜻한 포인트 컬러 하나.

구성 — 좌측 영역과 우측 영역으로 나뉜 가로형 네트워크 다이어그램. 그 사이를
빛나는 점선 "암호화 터널" 두 줄이 가로지름(터널 위에 작은 자물쇠 아이콘으로
암호화 표현).

좌측 1/3 — "KOREA / 한국" 라벨. 서로 다른 두 도시에 위치한 유선 라우터 2개를
세로로 배치하고 명확히 구분:
  - 위: 안테나와 이더넷 케이블이 달린 소형 유선 라우터, "SEOUL / 서울" 라벨의
    받침대 위, 뒤에 작은 도시 스카이라인 실루엣.
  - 아래: 또 다른 소형 유선 라우터(이더넷 케이블), "BUSAN / 부산" 라벨의
    받침대 위, 뒤에 작은 해안/항구 스카이라인.
  각 라우터에서 빛나는 암호화 터널 한 줄이 오른쪽으로 향함.

우측 2/3 — "OVERSEAS / 해외" 라벨. 가운데에 "LOAD BALANCER"라고 적힌 중앙
서버 노드가 두 한국 라우터의 터널 두 줄을 모두 수신. 근처에 작은 원형
"라운드로빈/페일오버" 모티프(두 입력선 사이를 번갈아 도는 곡선 화살표 2개).
밸런서에서 깔끔한 선 하나가 오른쪽 끝의 책상 위 노트북(웹 브라우저 창)과
스마트폰으로 연결 — 영상 스트리밍 중인 최종 사용자 기기 표현.

라벨은 최소·가독성 위주(KOREA/한국, SEOUL/서울, BUSAN/부산, OVERSEAS/해외,
LOAD BALANCER, round-robin)만. 긴 문장·워터마크·실제 기업 로고 금지.
균형 잡히고 깔끔하며 정돈된 발표용 품질.
```

## Tips / 팁
- 16:9 → good as the repo's GitHub "social preview" (Settings → Social preview).
  / 16:9는 GitHub 소셜 프리뷰(Settings → Social preview)에 적합.
- If text labels render messy, regenerate or ask for "labels as clean sans-serif,
  no gibberish text". / 라벨이 지저분하면 재생성 또는 "깔끔한 산세리프, 의미없는
  글자 금지" 요청.
