---
name: divination-suite
description: >
  统一命理占术排盘与解读套件，覆盖八字、紫微斗数、奇门遁甲、六爻、梅花易数、大六壬、
  小六壬、太乙、塔罗、西方占星、黄历共 11 类 15 个工具。仅在用户为自己或指定的人明确
  要求排盘、起卦、抽牌、查黄历宜忌，或明确询问八字/紫微/奇门等命盘专属概念时使用。
  不用于公众号文章、星座运势栏目、选题策划等内容创作，也不用于泛泛讨论命理文化。
compatibility: Requires Node.js 18+; all chart calculations run locally via the bundled engine, no other dependencies.
---

# 命理占术整合套件（统一入口）

本套件提供 15 个占术与命理排盘工具，统一由本地计算引擎驱动（`scripts/vendor/taibu-core.bundle.mjs`，随包分发，仅要求 Node.js 18+）。盘面一律由引擎计算；解读分两层：基础解读按 `interpretation/<体系>.md` 的框架输出，深度解读（神煞细论、星曜四化、奇门用神格局等）按需加载 `deep-reading/` 下的专题资料。

排盘只用引擎，不凭记忆手算。干支、卦象、星曜的推算规则繁多，手算既容易出错也无法复现；解读时以引擎输出为唯一事实来源，不确定的细节回到输出中核对。

## 用法

`TB` 指本 skill 的根目录（加载 skill 时会告知）：

```bash
node "$TB/scripts/taibu.mjs" list           # 列出全部工具
node "$TB/scripts/taibu.mjs" schema bazi    # 查看参数说明与调用示例
echo '{"gender":"male","birthYear":1990,"birthMonth":5,"birthDay":20,"birthHour":8}' \
  | node "$TB/scripts/taibu.mjs" call bazi -
```

- 参数为 JSON。含中文内容时走 stdin（`call <tool> -`），避免 shell 转义问题。
- 默认输出规范文本，适合直接作为解读依据；加 `--json` 改为输出结构化数据（`structuredContent`）。
- 出错时返回中文提示（缺哪个参数、允许哪些取值），按提示修正后重试。退出码：0 成功，1 参数或业务错误，2 用法错误。

## 路由：判断体系与深度

### 第 1 步：识别体系

| 用户意图 | 工具 | 深度资料 |
| --- | --- | --- |
| 八字/四柱命盘、十神、大运流年、喜用神 | `bazi`、`bazi_dayun`、`bazi_pillars_resolve` | `deep-reading/bazi/` |
| 紫微斗数、命宫主星、四化、大限、飞星 | `ziwei`、`ziwei_horoscope`、`ziwei_flying_star` | `deep-reading/ziwei/` |
| 奇门遁甲、择时、方位判断、事情成败 | `qimen` | `deep-reading/qimen/` |
| 六爻、梅花、大六壬、小六壬、太乙、塔罗、占星、黄历 | 对应工具 | 仅 `interpretation/` |

完整工具表见下文「工具总表」。调用前先 `schema <tool>`，或读 `references/<tool>.md`（参数表与可复制的示例）。

### 第 2 步：排盘前信息确认

- **命盘类**（八字、紫微、占星）：生辰信息不全时应当询问，而非代为假设。性别（八字大运需要）、公历/农历、出生时间与地点是最低要求。
- **占事类**（奇门、六爻、梅花、大小六壬、太乙）：奇门必须先完成两段式访谈（见下节）；其余体系确认「占什么事 + 起卦方式」即可。
- **学习/理论咨询**：不进入正式排盘，按 `deep-reading/qimen/examples.md` 等资料做讲解。

### 第 3 步：调用引擎 → 分层解读

1. 排盘：调用引擎，拿到盘面文本。
2. 基础解读：读 `interpretation/<体系>.md`，按其专家角色与分析框架组织内容。
3. 深度解读（按需触发）：
   - 用户问神煞、要求逐项细论 → 读 `deep-reading/bazi/shensha-table.md`（与引擎同一神煞口径，用于核对与展开）。
   - 用户问十神/旺衰/格局推演过程 → 读 `deep-reading/bazi/tiangan-dizhi.md`；用户自带长提示词时对照 `deep-reading/bazi/prompt-template.md`。
   - 用户问星曜含义、四化飞化、格局组合 → 读 `deep-reading/ziwei/` 对应文档。
   - 奇门解盘涉及用神选取、格局判断、规则细节 → 读 `deep-reading/qimen/yongshen.md`、`geju.md`、`ruleset-mainline.md`。

## 奇门专属：两段式访谈

奇门正式排盘前必须先访谈，默认规则集固定为 `mainline-cn-v2`（时家转盘、拆补定局、中宫寄坤）。

第一轮核心问题（语言直白）：

1. 你要看什么事？一句话说清。
2. 事情对应的时间是什么？如果就是现在，直接说"现在"。
3. 你人在哪个城市？如果不在中国大陆，请直接说国家/城市。
4. 你最想判断什么？比如能不能成、什么时候动、选哪边、要避开什么。
5. 这件事现在进展到哪一步了？
6. 你要"直接结论"还是"详细讲解"？

第二轮按条件追问：只有日期没时辰 → 补到时辰；农历 → 补问闰月；海外 → 补时区；问题太泛 → 补"最想判断哪个结果"；高风险主题（疾病、法律、投资）→ 提醒寻求专业帮助。

信息收齐（事项、时间、地点时区、判断目标）后才调用 `qimen` 排盘。用户要求其他流派时，先说明默认规则集并确认，不接受则只做理论讨论。

访谈模板见 `deep-reading/qimen/interview.md`。

## 解读通用要求

- 断语必须引用盘面证据（干支、星曜、爻位、格局名与引擎输出逐字一致），不确定的回到输出核对。
- 正文以该体系术师的口吻写给问事人：先结论、后论证。工具调用与核验过程不写入正文，至多在文末一句带过。
- 解释边界：命盘展示的是倾向、结构、课题与机会，不是绝对命定。不用恐吓式、宿命式表述，不说"注定如此""无法改变"。健康、法律、财务问题只做命盘角度的结构提醒，不替代现实专业意见。
- 结论要有依据，体现推演过程；客观平衡，不只说好话也不刻意吓人。
- 分析深度跟随用户要求伸缩：速断类（小六壬、单牌塔罗）短平快，命盘全局类（八字、紫微）分层展开，用户要求逐大限、逐流年时调用运限工具补数据。

## 工具总表

<!-- TOOLS:BEGIN -->
| 工具名 | 名称 | 用途 | 参数文档 | 解读指引 |
| --- | --- | --- | --- | --- |
| `astrology` | 西方占星命盘 | 根据出生信息计算本命盘与流运盘，输出基础坐标、命盘锚点、本命主星与流运触发 | [references/astrology.md](references/astrology.md) | [interpretation/astrology.md](interpretation/astrology.md) |
| `bazi` | 八字命盘 | 根据出生信息计算四柱命盘，输出天干地支、十神、藏干、神煞、关系格局等信息 | [references/bazi.md](references/bazi.md) | [interpretation/bazi.md](interpretation/bazi.md) |
| `bazi_pillars_resolve` | 四柱反推 | 根据年柱、月柱、日柱、时柱反推出生时间候选列表 | [references/bazi_pillars_resolve.md](references/bazi_pillars_resolve.md) | [interpretation/bazi.md](interpretation/bazi.md) |
| `ziwei` | 紫微斗数命盘 | 根据出生信息计算紫微命盘，输出十二宫位、星曜分布、四化、大限等信息 | [references/ziwei.md](references/ziwei.md) | [interpretation/ziwei.md](interpretation/ziwei.md) |
| `ziwei_horoscope` | 紫微斗数运限 | 根据出生信息与目标日期计算大限、小限、流年、流月、流日、流时等运限信息 | [references/ziwei_horoscope.md](references/ziwei_horoscope.md) | [interpretation/ziwei.md](interpretation/ziwei.md) |
| `ziwei_flying_star` | 紫微斗数飞星 | 分析命盘中的四化飞布、自化、落宫与三方四正关系 | [references/ziwei_flying_star.md](references/ziwei_flying_star.md) | [interpretation/ziwei.md](interpretation/ziwei.md) |
| `liuyao` | 六爻排卦 | 根据问题与起卦信息排出六爻盘面，输出卦象、爻位、用神体系、关系判断与时机提示 | [references/liuyao.md](references/liuyao.md) | [interpretation/liuyao.md](interpretation/liuyao.md) |
| `meihua` | 梅花易数起卦 | 根据时间、字占、物数、报数等方式起卦，输出起卦信息、卦盘与体用推演 | [references/meihua.md](references/meihua.md) | [interpretation/meihua.md](interpretation/meihua.md) |
| `tarot` | 塔罗抽牌 | 根据问题与牌阵抽取塔罗牌，输出牌面结果及占卜参考信息 | [references/tarot.md](references/tarot.md) | [interpretation/tarot.md](interpretation/tarot.md) |
| `taiyi` | 太乙九星观测 | 根据问卜时间生成时空底盘、九星阵列与核心关系 | [references/taiyi.md](references/taiyi.md) | [interpretation/taiyi.md](interpretation/taiyi.md) |
| `almanac` | 黄历查询 | 查询指定日期的黄历、宜忌、冲煞、值星、方位与时辰吉凶等信息 | [references/almanac.md](references/almanac.md) | [interpretation/almanac.md](interpretation/almanac.md) |
| `bazi_dayun` | 八字大运 | 根据出生信息计算起运时间、大运列表、小运与流年链路 | [references/bazi_dayun.md](references/bazi_dayun.md) | [interpretation/bazi.md](interpretation/bazi.md) |
| `qimen` | 奇门遁甲排盘 | 根据指定时间排出奇门盘，输出九宫、九星、八门、八神、格局等信息 | [references/qimen.md](references/qimen.md) | [interpretation/qimen.md](interpretation/qimen.md) |
| `daliuren` | 大六壬排盘 | 根据日期时间起课，输出天地盘、四课、三传、神将、课体与时空信息 | [references/daliuren.md](references/daliuren.md) | [interpretation/daliuren.md](interpretation/daliuren.md) |
| `xiaoliuren` | 小六壬占测 | 根据农历月日时辰起课，输出起课信息、推演链与结果信息 | [references/xiaoliuren.md](references/xiaoliuren.md) | [interpretation/xiaoliuren.md](interpretation/xiaoliuren.md) |
<!-- TOOLS:END -->

## 约定

- **历法**：生辰类工具默认公历（`calendarType: "solar"`）；用户给的是农历生日时改传 `"lunar"`，闰月再加 `isLeapMonth: true`。`xiaoliuren` 例外，直接接收农历月、日。
- **时间**：`birthHour` 传 0-23 的钟表小时，早晚子时由引擎处理，不要自行折算时辰。用户未提供的出生信息应当询问，而非代为假设。
- **时区**：默认按北京时间。运行环境的系统时钟可能是 UTC（云端容器常见）。CLI 已把进程时区固定为 `Asia/Shanghai`（可用环境变量 `TAIBU_TZ` 改）；取当前时间一律用 `TZ=Asia/Shanghai date +"%Y-%m-%dT%H:%M:%S"`。`qimen`、`daliuren`、`taiyi` 显式传 `"timezone": "Asia/Shanghai"`。用户明确身处其他时区时，同时改这三处。
- **占当下**：`qimen`、`daliuren`、`liuyao`、`meihua` 的时间起卦需要当前时间时，按上条取北京时间后显式填入参数，不依赖工具的"省略即当前"默认值。
- **日期核实**：用户说「今天/现在」并同时报出农历日期时，先用 `almanac` 核对公农历对应——农历与公历的映射是查历数据，不能凭记忆换算。口述与核实不符时，指出差异并以核实结果起盘。
- **随机性**：`tarot` 可传 `seed` 复现抽牌；`liuyao` 的 `method: "auto"` 每次结果随机，需要复现时改用 `select`（指定卦名）或 `number`（数字起卦）。
- **六爻用神**：`yongShenTargets` 必填，按占问主题选择，可多选：事业官职、官司、疾病忧患取 `官鬼`；财运、男问感情取 `妻财`；文书合同、长辈、房产车辆取 `父母`；子女晚辈、健康平安取 `子孙`；合作竞争、朋友取 `兄弟`。
- **detailLevel**：默认输出已够解读；需要完整盘面时在参数中加 `"detailLevel": "full"`（部分工具另有 `"more"`）。

## 其他接入方式

支持 MCP 的客户端可以不经本 skill，直接使用 npm 包 `taibu-mcp`（stdio）或公网端点 `https://mcp.mingai.fun/mcp`，工具集相同。
