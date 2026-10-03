#!/usr/bin/env python3
"""重建 divination-suite.zip —— 仓库维护工具，不随包分发。

用法:
    python scripts/rebuild-zip.py             # 重建；默认按脚本位置推断仓库根
    python scripts/rebuild-zip.py <仓库根>
    python scripts/rebuild-zip.py --check     # 只校验 zip 是否与仓库一致，不落盘

--check 用于发布前把关：逐条目比对 zip 内容与「重算一遍会得到的内容」，
一致退 0，过期则列出不一致的条目并退 1。deploy.sh 的预检会调用它，避免
分发出一个内容停留在旧版本的包。

什么时候需要跑:
    改动 README.md / THIRD_PARTY_NOTICES.md / SKILL.md / DISCLAIMER.md /
    references/ / interpretation/ / deep-reading/ / scripts/ 之后。这些文件都在
    zip 里，不改 zip 的话，分发出的包会静默停留在旧内容——曾出现过 zip 里带着
    「授权待确认，不得公开发布」而仓库里早已改成 MIT 的情况。

不随包的文件（改了也不用重跑，脚本也不会把它们塞进 zip）:
    app.html、index.html、deploy.sh、本脚本自身。

保证的不变量:
  1. 条目集合与顺序 = 原 archive，一个不多一个不少。新增条目是有意决策，
     不在这里偷偷补——早期版本无条件插入 LICENSE，等 LICENSE 真正加入后
     就产生了重复条目。
  2. 内容以 git 为准：已提交且未改动的文件取 `git show HEAD:<name>`，改动过或
     未跟踪的读磁盘并归一化为 LF。这样 archive 跟的是仓库，而不是可能带 CRLF
     的工作区。
  3. 权限位与时间戳沿用原 archive，改写后与旧包逐条可比。
"""
import os
import subprocess
import sys
import zipfile

CHECK = "--check" in sys.argv[1:]
rest = [a for a in sys.argv[1:] if not a.startswith("-")]
USAGE = ("用法: python scripts/rebuild-zip.py [--check] [仓库根]"
         "   （--help 看完整说明）")
if "--help" in sys.argv[1:] or "-h" in sys.argv[1:]:
    print(__doc__)
    sys.exit(0)
bad = [a for a in sys.argv[1:] if a.startswith("-") and a not in ("--check",)]
if bad or len(rest) > 1:
    sys.exit(f"无法识别的参数: {' '.join(bad or rest[1:])}\n{USAGE}")

REPO = (rest[0] if rest
        else os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OLD = os.path.join(REPO, "divination-suite.zip")
NEW = OLD + ".new"

if not os.path.isfile(OLD):
    sys.exit(f"找不到 {OLD}")
if not CHECK and os.path.exists(NEW):
    sys.exit(f"{NEW} 已存在——上次中断的残留，确认后手动删除再跑")

with zipfile.ZipFile(OLD) as z:
    old_names = z.namelist()
    old_attr = {n: z.getinfo(n).external_attr for n in old_names}
    old_date = {n: z.getinfo(n).date_time for n in old_names}
    actual = {n: z.read(n) for n in old_names}

if len(old_names) != len(set(old_names)):
    dupes = sorted({n for n in old_names if old_names.count(n) > 1})
    sys.exit(f"原始 archive 自身就有重复条目，先修好再跑: {dupes}")


def in_head(name):
    return subprocess.run(["git", "cat-file", "-e", f"HEAD:{name}"], cwd=REPO,
                          capture_output=True).returncode == 0


def modified(name):
    # 必须接住 stderr：git 在 autocrlf 下会往这里吐 "LF will be replaced by CRLF"
    # 的告警，漏出去会混进 deploy.sh 的检查输出里
    return subprocess.run(["git", "diff", "--quiet", "HEAD", "--", name],
                          cwd=REPO, capture_output=True).returncode != 0


def content(name):
    if in_head(name) and not modified(name):
        return subprocess.run(["git", "show", f"HEAD:{name}"], cwd=REPO,
                              capture_output=True, check=True).stdout
    with open(os.path.join(REPO, name), "rb") as f:
        return f.read().replace(b"\r\n", b"\n")


expected = {n: content(n) for n in old_names}
stale = [n for n in old_names if expected[n] != actual[n]]

if CHECK:
    if stale:
        print(f"zip 已过期：{len(stale)}/{len(old_names)} 个条目与仓库不一致")
        for n in stale:
            print(f"  - {n}")
        print("修复：python scripts/rebuild-zip.py")
        sys.exit(1)
    print(f"zip 与仓库一致（{len(old_names)} 个条目）")
    sys.exit(0)

try:
    with zipfile.ZipFile(NEW, "w", zipfile.ZIP_DEFLATED, compresslevel=9) as z:
        for n in old_names:
            info = zipfile.ZipInfo(n)
            info.external_attr = old_attr[n]
            info.compress_type = zipfile.ZIP_DEFLATED
            info.date_time = old_date[n]
            z.writestr(info, expected[n])

    # 自检：条目集合与顺序必须与原始 archive 完全一致
    with zipfile.ZipFile(NEW) as z:
        now = z.namelist()
        assert now == old_names, "条目集合或顺序发生变化"
        assert len(now) == len(set(now)), "出现重复条目"
except BaseException:
    if os.path.exists(NEW):
        os.remove(NEW)
    raise

os.replace(NEW, OLD)
print(f"rebuilt: {len(old_names)} entries (unchanged set/order)")
