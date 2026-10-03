# divination-suite 命理占术整合套件

将四个独立 skill（skill-bazi、skill-ziwei-doushu、skill-qimen-dunjia、taibu-divination）整合为单一可发布应用的产物。

## 架构

- **唯一计算引擎**：taibu 引擎（Node.js 18+，零外部依赖，`scripts/vendor/taibu-core.bundle.mjs` 随包分发），覆盖 11 类 15 个排盘工具。
- **解读层**：
  - `interpretation/` — 各体系基础解读框架（来自 taibu）。
  - `deep-reading/` — 深度解读专题资料，按体系分目录：
    - `bazi/`：神煞表（与引擎同口径）、天干地支术语、长提示词对照模板（来自 skill-bazi）。
    - `ziwei/`：排盘规则、星曜、四化、格局（来自 skill-ziwei-doushu）。
    - `qimen/`：访谈模板、mainline-cn-v2 规则集、格局、用神、盘例（来自 skill-qimen-dunjia）。
- **原三个 Python skill 的脚本未纳入本包**：其排盘功能已由 taibu 引擎覆盖，避免双引擎口径分裂。Python 源码（含单元测试）保留在原始 zip 中，如需交叉验证可单独取出。

## 依赖

| 项 | 要求 |
| --- | --- |
| 运行时 | Node.js 18+（唯一硬依赖） |
| Python | 不需要 |
| 网络 | CLI 不需要（完全本地计算）。网页版 `app.html` 首次打开需下载引擎：磁盘 11 MB，gzip 传输约 2.8 MB，之后由浏览器缓存 |

## 使用

见 `SKILL.md`。快速验证：

```bash
node scripts/taibu.mjs list
node scripts/taibu.mjs schema qimen
echo '{"gender":"male","birthYear":1990,"birthMonth":5,"birthDay":20,"birthHour":8}' | node scripts/taibu.mjs call bazi -
```

## 目录结构

```
divination-suite/
├── SKILL.md              # 统一入口：路由、引擎用法、工具表、解读规范
├── README.md             # 本文件
├── LICENSE               # 本包原创部分：MIT
├── DISCLAIMER.md         # 免责声明（发布时须随附）
├── THIRD_PARTY_NOTICES.md# 第三方组件声明（含引擎内嵌库）
├── scripts/
│   ├── taibu.mjs         # CLI 入口
│   └── vendor/taibu-core.bundle.mjs  # 计算引擎（11MB，本地运行）
├── references/           # 15 个工具的参数文档
├── interpretation/       # 各体系基础解读指引
└── deep-reading/         # 八字/紫微/奇门深度解读专题资料
```

### 仓库维护工具（不随包分发）

| 文件 | 用途 |
| --- | --- |
| `deploy.sh` | 静态站点部署（GitHub Pages / Netlify），发布前跑第三方署名预检 |
| `app.html` `index.html` | 在线排盘页与落地页，由 GitHub Pages 直接托管 |
| `scripts/rebuild-zip.py` | 重建 `divination-suite.zip`，见下 |

改动 zip 内的任何文件（`README.md`、`THIRD_PARTY_NOTICES.md`、`SKILL.md`、`DISCLAIMER.md`、`references/`、`interpretation/`、`deep-reading/`、`scripts/`）之后，需要重跑一次打包：

```bash
python scripts/rebuild-zip.py
```

否则分发出的包会**静默停留在旧内容**。该脚本保证条目集合与顺序不变、内容以 git blob 为准（工作区 CRLF 不会带进包里），并在写入前自检条目集合。`app.html`、`index.html`、`deploy.sh` 不在包内，改它们无需重跑。

发布前可只校验不重建：

```bash
python scripts/rebuild-zip.py --check   # 与仓库一致退 0，过期则列出条目并退 1
```

`deploy.sh` 的预检会自动调用它，因此包过期时部署会被拦下。

## 发布前待办（重要）

1. ~~**taibu-core 授权确认（阻断项）**~~ —— **已解决（2026-10-03）。** 结论：`taibu-core@3.5.0` 是 **MIT 许可**，上游 [hhszzzz/taibu](https://github.com/hhszzzz/taibu)。此前判为"无随包许可证声明"是因为本地 bundle 由 esbuild 打包，只保留带 `/*!` 标记的 legal comment，而该库源码未使用该标记，**许可证声明在打包环节被丢弃**——属文件头缺失，非授权缺失。已下载 npm tarball 核对：`package.json` 声明 `"license": "MIT"`，内含 `package/LICENSE`（MIT 全文 + `SPDX-License-Identifier: MIT`，`Copyright (c) 2026 hhszzzz`）。MIT 允许 use / copy / modify / merge / publish / distribute / sublicense / sell，唯一义务是**随副本保留版权与许可声明**，已在 `THIRD_PARTY_NOTICES.md` 第 1 节登记。`deploy.sh` 的阻断检查相应改为核对署名声明是否随包（见下）。
   - 另经核查：`scripts/taibu.mjs` 无任何外部 URL；bundle 内对 `mcp.mingai.fun` / `mingai` 的引用数为 0；`app.html` 仅从自有副本（相对路径、自有 Pages、本仓库的 jsDelivr 镜像）加载引擎。**当前代码不含对外服务依赖，不向外发送任何数据。** 原描述中"`taibu-mcp` 与 `mcp.mingai.fun` 指向第三方服务"指的是 taibu 项目额外提供的 MCP 服务端形态，本包未使用。
2. **口径核对（建议）**：原 Python skill 与 taibu 引擎在神煞查法、奇门定局、紫微流派上可能存在细节差异。`deep-reading/` 资料按各自口径编写，深度解读与引擎输出冲突时，以引擎输出为准并核对资料适用范围。建议用原 Python 脚本对 3-5 个样例做一次输出比对。
3. **平台合规**：占卜类应用在国内应用市场/小程序平台属受限类目，需按"传统文化/娱乐"定位申报，随附 `DISCLAIMER.md`，并遵守目标平台的具体审核要求。

## 已验证与未验证部分

- 已验证（Node v24.14.0，2026-10-03）：`list` 输出 15 个工具、与 `SKILL.md` 工具总表逐一对应；`call bazi`（1990-05-20 08:00 男）返回完整四柱、十神、藏干、神煞与干支关系，输出非空。
- 已验证：本包内嵌的第三方许可证清单与 bundle 尾部 esbuild license 信息、源码标记一致（见 `THIRD_PARTY_NOTICES.md`）。
- 已验证（2026-10-03）：taibu-core 授权状态为 MIT，核对自 npm 包 `taibu-core@3.5.0` 的 `package.json` 与 `LICENSE`（见待办第 1 条）。
- 未验证：引擎与原 Python 脚本的输出一致性（见待办第 2 条）。
