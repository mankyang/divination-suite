#!/usr/bin/env bash
# divination-suite 静态托管一键部署脚本
# 部署源: 本脚本所在目录 (index.html + divination-suite.zip)
#
# 用法:
#   ./deploy.sh github            # 部署到 GitHub Pages（需先: gh auth login）
#   ./deploy.sh github 自定义域名  # 同上, 并写入 CNAME 绑定自定义域名
#   ./deploy.sh netlify           # 部署到 Netlify（需 NETLIFY_AUTH_TOKEN 或允许浏览器登录）
#   ./deploy.sh netlify 自定义域名 # 同上, 输出域名绑定指引
#
# 前置安装（二选一即可）:
#   GitHub 路线: winget install GitHub.cli  然后  gh auth login
#   Netlify 路线: npm install -g netlify-cli  然后  netlify login（或设置 NETLIFY_AUTH_TOKEN）
set -euo pipefail
cd "$(dirname "$0")"

TARGET="${1:-}"
DOMAIN="${2:-}"

[ -f index.html ] || { echo "错误: 未找到 index.html"; exit 1; }
[ -f divination-suite.zip ] || { echo "错误: 未找到 divination-suite.zip"; exit 1; }

# ---- 发布前检查：zip 新鲜度 + 第三方署名声明 ----
# taibu-core@3.5.0 为 MIT 许可（依据见 THIRD_PARTY_NOTICES.md 第 1 节 / README 待办第 1 条），
# 允许分发；MIT 的唯一义务是「随软件副本保留版权与许可声明」。因此这里核对的是
# 署名声明有没有跟着一起发出去，而不是等一个并不存在的授权确认。
#
# 两层检查，缺一不可：
#   1. zip 内容必须与仓库一致。过期的包会带着旧声明发出去，而下面的关键词检查查的是
#      磁盘上的文件、不是包里的那份，单靠它拦不住——曾出现包里写着「授权待确认，
#      不得公开发布」而仓库里早已改成 MIT 的情况。
#   2. 声明文件本身要覆盖 taibu-core 及其内嵌库，且确实在包内（条目标题检查独立于
#      第 1 层：若 THIRD_PARTY_NOTICES.md 整个从条目表里被删掉，第 1 层是发现不了的）。
NOTICES=THIRD_PARTY_NOTICES.md
ERRORS=0
note_err() { echo "  ✗ $1"; ERRORS=$((ERRORS + 1)); }

echo "发布前检查…"

# --- 1. zip 是否与仓库一致 ---
PY=""
for c in python3 python; do
  if command -v "$c" >/dev/null 2>&1; then PY="$c"; break; fi
done
if [ -z "$PY" ]; then
  echo "  ! 未找到 python，跳过 zip 新鲜度检查——包内容可能已过期"
elif [ -f scripts/rebuild-zip.py ]; then
  if ! out="$("$PY" scripts/rebuild-zip.py --check 2>&1)"; then
    note_err "divination-suite.zip 与仓库不一致："
    printf '%s\n' "$out" | sed 's/^/      /'
  fi
else
  note_err "缺少 scripts/rebuild-zip.py，无法校验 zip 是否与仓库一致"
fi

# --- 2. 第三方署名声明 ---
if [ ! -f "$NOTICES" ]; then
  note_err "缺少 $NOTICES"
else
  # 引擎本体及其版权署名 + 内嵌五个第三方库 + MIT 正文，缺一不可
  for token in "taibu-core" "hhszzzz" "MIT License" "iztro" "moment" \
               "circular-natal-horoscope-js" "pinyin"; do
    grep -q -- "$token" "$NOTICES" || note_err "$NOTICES 未声明：$token"
  done
fi
# 分发的实体是 zip，声明必须也在里面。unzip 缺失时跳过（不阻断）。
if command -v unzip >/dev/null 2>&1; then
  # 刻意不用管道：grep -q 命中即退出会给 unzip 发 SIGPIPE，pipefail 下会误判为失败
  zip_listing="$(unzip -l divination-suite.zip 2>/dev/null || true)"
  case "$zip_listing" in
    *"$NOTICES"*) ;;
    *) note_err "divination-suite.zip 内未包含 $NOTICES" ;;
  esac
fi

if [ "$ERRORS" -gt 0 ]; then
  cat <<'EOF'

⚠️  发布中止：发布前检查未通过

  包已过期：重跑 python scripts/rebuild-zip.py
  署名不全：taibu-core 为 MIT 许可，允许分发，但要求随副本保留版权与许可声明，
            依据见 README「发布前待办」第 1 条与 THIRD_PARTY_NOTICES.md。
EOF
  exit 1
fi
echo "  检查通过"

# 自定义域名: 写 CNAME（GitHub Pages 约定文件）
if [ -n "$DOMAIN" ]; then printf '%s\n' "$DOMAIN" > CNAME; else rm -f CNAME; fi

case "$TARGET" in
  github)
    command -v gh >/dev/null 2>&1 || { echo "错误: 未安装 gh CLI。运行: winget install GitHub.cli"; exit 1; }
    gh auth status >/dev/null 2>&1 || { echo "错误: gh 未登录。运行: gh auth login"; exit 1; }

    git init -q 2>/dev/null || true
    git symbolic-ref HEAD refs/heads/main 2>/dev/null || true
    git add -A
    git commit -qm "deploy: divination-suite static site" 2>/dev/null || true

    USER_LOGIN=$(gh api user -q .login)
    if ! git remote get-url origin >/dev/null 2>&1; then
      gh repo create divination-suite --public --source . --push
    else
      # 不用 --force：历史分叉时宁可让 push 失败，由人工确认后再处理
      git push -u origin main
    fi

    # 启用 Pages（已启用则忽略报错）
    gh api -X POST "repos/$USER_LOGIN/divination-suite/pages" \
        -f "source[branch]=main" -f "source[path]=/" >/dev/null 2>&1 || true

    echo ""
    echo "=============================================="
    echo " 部署完成"
    echo " 站点地址: https://$USER_LOGIN.github.io/divination-suite/"
    echo " (首次启用 Pages 约需 1-2 分钟生效)"
    if [ -n "$DOMAIN" ]; then
      echo " 自定义域名: $DOMAIN (已写入 CNAME)"
      echo " 请到 DNS 服务商添加 CNAME 记录: $DOMAIN -> $USER_LOGIN.github.io"
      echo " 并在仓库 Settings -> Pages -> Custom domain 填入 $DOMAIN"
    fi
    echo "=============================================="
    ;;

  netlify)
    export NETLIFY_SITE_NAME="${NETLIFY_SITE_NAME:-divination-suite}"
    if [ -n "${NETLIFY_AUTH_TOKEN:-}" ]; then
      npx -y netlify-cli@latest deploy --prod --dir . --auth "$NETLIFY_AUTH_TOKEN"
    else
      echo "未检测到 NETLIFY_AUTH_TOKEN，将走浏览器登录流程..."
      npx -y netlify-cli@latest deploy --prod --dir .
    fi
    if [ -n "$DOMAIN" ]; then
      echo ""
      echo "域名绑定: 在 Netlify 控制台 Domain management 添加 $DOMAIN,"
      echo "并在 DNS 服务商添加 CNAME 记录指向部署输出的 *.netlify.app 地址。"
    fi
    ;;

  *)
    echo "用法: ./deploy.sh github|netlify [自定义域名]"
    exit 1
    ;;
esac
