# 第三方组件声明

## 1. taibu 计算引擎

- 文件：`scripts/taibu.mjs`、`scripts/vendor/taibu-core.bundle.mjs`
- 来源：taibu-divination skill 随包分发
- **授权状态：待确认。** 该 bundle 未随附许可证文件；相关 npm 包 `taibu-mcp` 与公网端点 `https://mcp.mingai.fun/mcp` 指向第三方服务。公开发布前必须取得权利人授权或确认许可证条款。

## 2. 神煞口径（deep-reading/bazi/shensha-table.md）

- 来源：jinchenma94/bazi-skill（https://github.com/jinchenma94/bazi-skill）
- 许可证：MIT License，Copyright (c) 2025 jinchenma94
- 说明：移植时做过更正，详见该文件头部注释。按 MIT 条款保留原版权声明。

MIT License 全文：

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## 3. 其余内容

`deep-reading/bazi/`、`deep-reading/ziwei/`、`deep-reading/qimen/` 其余文档与 `references/`、`interpretation/` 来自本整合包所基于的四个原始 skill，未含已知第三方代码。
