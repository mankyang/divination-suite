# 第三方组件声明

本包（divination-suite）作者原创部分以 MIT 许可证发布，见 [`LICENSE`](LICENSE)。
以下为随包分发、或被打包进引擎 bundle 的第三方组件，各自适用其原许可证。

## 1. taibu 计算引擎（taibu-core@3.5.0）

- 文件：`scripts/taibu.mjs`、`scripts/vendor/taibu-core.bundle.mjs`（11 MB，esbuild 自包含 bundle）
- 来源：taibu-divination skill 随包分发；相关 npm 包 `taibu-mcp` 与公网端点 `https://mcp.mingai.fun/mcp` 指向第三方服务。
- **授权状态：待确认（阻断项）。** 该 bundle 未随附许可证文件。**在取得权利人授权或确认许可证条款之前，不得公开发布。**
- 该 bundle 内部打包了以下第三方库，由 bundle 尾部的 esbuild license 清单与源码标记识别：

| 组件 | 用途 | 许可证 | 版权声明 |
| --- | --- | --- | --- |
| [iztro](https://github.com/SylarLong/iztro) | 紫微斗数排盘 | MIT | Copyright (c) 2023 All Contributors |
| [moment](https://momentjs.com) | 日期时间处理 | MIT | Copyright (c) JS Foundation and other contributors |
| [moment-timezone](https://github.com/moment/moment-timezone) 0.5.26 | 时区数据 | MIT | Copyright (c) JS Foundation and other contributors |
| [circular-natal-horoscope-js](https://github.com/0xStarcat/CircularNatalHoroscopeJS) | 西方占星排盘 | Unlicense（公有领域） | 无需署名 |
| [pinyin](https://github.com/hotoo/pinyin) | 拼音转换 | MIT | Copyright (c) 闲耘™ |

> 说明：iztro 的许可证声明未随 esbuild 的 license 清单一并保留（该库源码中无 `/*!` 注释），
> 此处依据其上游 LICENSE 文件补充声明。moment 上游现署名为 OpenJS Foundation，
> 此处按 bundle 内保留的原始声明记。

## 2. MIT 许可证全文

适用于上表中标注 MIT 的组件，以及第 4 节的神煞表来源。

```
MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

各组件对应的版权声明：

- iztro — `Copyright (c) 2023 All Contributors`
- moment / moment-timezone — `Copyright (c) JS Foundation and other contributors`
- pinyin — `Copyright (c) 闲耘™`
- bazi-skill — `Copyright (c) 2025 jinchenma94`

## 3. Unlicense（公有领域声明）

`circular-natal-horoscope-js` 采用 Unlicense，全文如下：

```
This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or distribute
this software, either in source code form or as a compiled binary, for any
purpose, commercial or non-commercial, and by any means.

In jurisdictions that recognize copyright laws, the author or authors of this
software dedicate any and all copyright interest in the software to the public
domain. We make this dedication for the benefit of the public at large and to
the detriment of our heirs and successors. We intend this dedication to be an
overt act of relinquishment in perpetuity of all present and future rights to
this software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```

## 4. 神煞口径（deep-reading/bazi/shensha-table.md）

- 来源：jinchenma94/bazi-skill（https://github.com/jinchenma94/bazi-skill）
- 许可证：MIT License，Copyright (c) 2025 jinchenma94（全文见第 2 节）
- 说明：移植时做过更正，详见该文件头部注释。按 MIT 条款保留原版权声明。

## 5. 其余内容

`deep-reading/bazi/`、`deep-reading/ziwei/`、`deep-reading/qimen/` 其余文档与
`references/`、`interpretation/` 来自本整合包所基于的四个原始 skill，未含已知第三方代码。
