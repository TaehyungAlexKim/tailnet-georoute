# tailnet-georoute

**EN:** Resilient, load-balanced, **selective** geo-egress over [Tailscale](https://tailscale.com). Route just one service's traffic through **two self-hosted routers in another country**, balanced round-robin with automatic failover — using hardware you already own, with no monthly subscription.

**KO:** [Tailscale](https://tailscale.com) 위에서 **회복력 있는·로드밸런싱된·선택적** 지역 송출(egress). 특정 서비스 트래픽만 **다른 나라에 둔 자가 라우터 2대**로, 라운드로빈 + 자동 페일오버로 내보냅니다. 이미 가진 하드웨어로, 월 구독료 없이.

> **Worked example / 예제:** watching Korean live-streaming (Chzzk / 치지직) from abroad. But the pattern is generic — any geo-pinned service, multi-region testing, or redundant egress.
> 해외에서 한국 라이브 스트리밍(치지직) 보기를 예시로 씁니다. 패턴 자체는 범용입니다 — 지역 고정 서비스, 멀티리전 테스트, 이중 egress 등.

---

## Why / 왜 이게 쓸만한가

**EN**
- **Residential IP that doesn't get blocked.** A small router at a friend/relative's home gives you a *residential* exit IP. Streaming services increasingly block commercial VPN datacenter IPs — they rarely block residential ones.
- **Resilience from two nodes.** Two routers on **different ISPs/cities** are used simultaneously (round-robin). If one line hiccups, traffic fails over to the other in seconds — the stream stays up.
- **Selective, not all-or-nothing.** Unlike a Tailscale exit node (whole device through one country), only the target service is routed. Everything else stays direct and fast.
- **No subscription.** Reuses Tailscale (free tier) + cheap routers you own.

**KO**
- **안 막히는 거주지(residential) IP.** 지인·가족 집에 둔 소형 라우터는 *실거주* IP를 줍니다. 스트리밍 서비스는 상용 VPN의 데이터센터 IP를 점점 차단하지만, 거주지 IP는 거의 안 막습니다.
- **두 노드의 회복력.** **다른 ISP/도시**의 라우터 2대를 동시에(라운드로빈) 사용. 한 회선이 흔들리면 수 초 내 다른 쪽으로 페일오버 — 영상이 안 끊깁니다.
- **전부가 아니라 선택적.** Tailscale exit node(전체 트래픽이 한 나라로)와 달리, 대상 서비스만 라우팅. 나머지는 직결로 빠르게.
- **구독료 0원.** Tailscale 무료 티어 + 보유 중인 저가 라우터 재활용.

### vs. alternatives / 대안 비교
| | This pattern / 이 방식 | Commercial VPN / 상용 VPN | Single exit node / 단일 exit node |
|---|---|---|---|
| Exit IP type / IP 종류 | Residential / 거주지 ✅ | Datacenter / 데이터센터 ❌ | depends / 노드 나름 |
| Two lines at once / 두 회선 동시 | ✅ round-robin + failover | ❌ | ❌ one at a time |
| Selective routing / 선택 라우팅 | ✅ per-domain | partial / 부분 | ❌ whole device |
| Recurring cost / 반복 비용 | none / 없음 | $$/mo | none |
| Setup effort / 설치 난이도 | medium / 중 | low / 하 | low–medium |

---

## Architecture / 구성도

```
        KOREA / 한국 (egress)                    ABROAD / 해외 (you)
  ┌───────────────────────────┐          ┌──────────────────────────────┐
  │  Router A  (Seoul / 서울)  │── tailnet ──┐                              │
  │  gost SOCKS5  ISP A        │           │                              │
  └───────────────────────────┘           ▼                              │
                                  ┌──────────────────┐   selective PAC    │
  ┌───────────────────────────┐  │  Load Balancer   │──────► [Browser]   │
  │  Router B  (Busan / 부산)  │──│  gost round-robin│  only target domains│
  │  gost SOCKS5  ISP B        │── │  + failover      │  (rest = DIRECT)   │
  └───────────────────────────┘  └──────────────────┘     [Phone/TV]      │
        (different ISP/city)        listens on tailnet IP                  │
  └──────────── encrypted Tailscale tunnels ────────────┘                 │
```

**EN:** Two routers in Korea each run a SOCKS5 proxy, reachable only over the encrypted Tailscale network. A central always-on host runs a load balancer that round-robins between them. Clients use a PAC file so only the target service's domains go through the balancer.

**KO:** 한국의 라우터 2대가 각각 SOCKS5 프록시를 돌리고, 암호화된 Tailscale 망으로만 접근됩니다. 항상 켜진 중앙 호스트가 둘 사이를 라운드로빈하는 밸런서를 돌리고, 클라이언트는 PAC로 대상 서비스 도메인만 밸런서로 보냅니다.

---

## Requirements / 준비물
- **2× small routers/SBCs** in the target country (different ISPs/cities ideally). Tested on **GL.iNet GL-MT2500** (OpenWrt, aarch64). Any OpenWrt/Linux box works. / 대상 국가의 소형 라우터·SBC 2대(가급적 다른 ISP/도시). **GL-MT2500**(OpenWrt aarch64)에서 검증.
- **Tailscale** on all nodes (the two routers, the balancer host, and your client devices). / 모든 노드에 Tailscale.
- **An always-on host** for the balancer with Docker (a NAS, mini-PC, etc.). / 밸런서용 상시 가동 호스트(Docker).
- A Chromium browser + **Proxy SwitchyOmega (ZeroOmega)** for the client. / 클라이언트용 크로미움 브라우저 + ZeroOmega.

---

## Setup / 설치

### 1. Egress routers (×2) / 송출 라우터 (2대)
**EN:** SSH into each router and run the script with that router's Tailscale IP. It installs a static `gost` SOCKS5 proxy and a boot service bound to the tailnet IP.
**KO:** 각 라우터에 SSH 접속 후, 그 라우터의 Tailscale IP로 스크립트 실행. 정적 `gost` SOCKS5 + tailnet IP 바인딩 부팅 서비스를 설치합니다.

```sh
# on router A (e.g. Seoul) / 라우터 A (예: 서울)
./scripts/setup-brume.sh 100.x.x.A 1080
# on router B (e.g. Busan) / 라우터 B (예: 부산)
./scripts/setup-brume.sh 100.x.x.B 1080
```
Find each Tailscale IP with `tailscale status`. / Tailscale IP는 `tailscale status`로 확인.

### 2. Load balancer / 로드밸런서
```sh
cp balancer/docker-compose.yml.example balancer/docker-compose.yml
# edit: replace <NODE_A_TSIP> / <NODE_B_TSIP>, pick MODE A or B networking
docker compose -f balancer/docker-compose.yml up -d
```
**EN:** Two networking modes are documented in the file — **Mode A** if the Docker host itself is on Tailscale (most common), **Mode B** if Tailscale runs inside a container (share its netns).
**KO:** 파일에 두 네트워크 모드가 있습니다 — 호스트가 Tailscale 멤버면 **모드 A**(가장 흔함), Tailscale이 컨테이너로 돌면 **모드 B**(netns 공유).

### 3. Tailscale ACL (only if your balancer node is **tagged**) / 밸런서 노드가 **태그**됐을 때만
**EN:** If the balancer's Tailscale node uses a tag (e.g. `tag:docker`), the default ACL may block it from the routers — symptom: `tailscale ping` works but TCP/ICMP is dropped. Add an accept rule in the admin console:
**KO:** 밸런서 노드가 태그(`tag:docker` 등)를 쓰면 기본 ACL이 라우터 접근을 막을 수 있습니다 — 증상: `tailscale ping`은 되는데 TCP/ICMP는 손실. 관리 콘솔에서 허용 규칙 추가:
```json
{ "action": "accept", "src": ["tag:docker"], "dst": ["100.x.x.A:1080", "100.x.x.B:1080"] }
```

### 4. Client PAC / 클라이언트 PAC
**EN:** Install **Proxy SwitchyOmega 3 (ZeroOmega)** → New profile → **PAC Profile** → paste `client/proxy.pac.example` (with `<BALANCER_IP>` filled in) → Apply → select the profile. Keep Tailscale **on** with exit node **None**.
**KO:** **ZeroOmega** 설치 → New profile → **PAC Profile** → `client/proxy.pac.example`(<BALANCER_IP> 채워서) 붙여넣기 → Apply → 프로필 선택. Tailscale은 **켜고** exit node는 **None** 유지.

---

## Verify / 검증
```sh
# from a client / 클라이언트에서: the two egress IPs should alternate (round-robin)
for i in 1 2 3 4; do curl -fsS --socks5-hostname <BALANCER_IP>:1080 https://api.ipify.org; echo; done
```
**EN:** Alternating IPs = both nodes in use. Check the balancer logs (`docker logs gost-lb`) while using the service to confirm the right domains are routed and load is split.
**KO:** IP가 번갈아 나오면 두 노드 동시 사용 중. 서비스 사용 중 밸런서 로그(`docker logs gost-lb`)에서 도메인 라우팅·부하 분산을 확인하세요.

---

## Troubleshooting / 트러블슈팅
- **`Connection refused` right after start / 시작 직후 거부:** race — gost not bound yet. Wait for its `... on <ip>:1080` log. / gost 바인딩 전 race. 로그 뜬 뒤 재시도.
- **`none node available` / `i/o timeout` at balancer / 밸런서에서:** Tailscale ACL blocking a tagged node — see step 3. `tailscale ping` works but TCP doesn't = ACL. / 태그 노드 ACL 차단(3단계).
- **Client times out / 클라이언트 타임아웃:** client's Tailscale is off, or exit node is set. Turn on, exit node = None. / Tailscale 꺼짐 또는 exit node 설정됨. 켜고 None.
- **Video blocked but page loads / 페이지는 뜨는데 영상 차단:** a video CDN domain is missing from the PAC. Find it via F12 → Network and add it. / 영상 CDN 도메인 누락. Network 탭에서 찾아 PAC에 추가.
- **gost gone after router firmware update / 펌웨어 업데이트 후 gost 사라짐:** GL.iNet sysupgrade can wipe `/usr/bin/gost`. Re-run `setup-brume.sh`. / 재실행.

---

## ⚠️ Disclaimer / 면책
**EN:** This is a networking pattern for routing **your own** traffic over infrastructure **you control**. Bypassing geographic restrictions may violate a service's Terms of Service and content-licensing terms. You are responsible for complying with all applicable laws and ToS in your jurisdiction. Provided **as-is**, for educational purposes, with no warranty and no support commitment.

**KO:** 이 프로젝트는 **본인 소유** 인프라로 **본인** 트래픽을 라우팅하는 네트워크 패턴입니다. 지역 제한 우회는 해당 서비스의 이용약관·콘텐츠 라이선스에 위배될 수 있습니다. 관련 법률·약관 준수 책임은 사용자에게 있습니다. 교육 목적의 **있는 그대로(as-is)** 제공이며, 어떤 보증·지원도 약속하지 않습니다.

## License / 라이선스
MIT — see [LICENSE](LICENSE).
