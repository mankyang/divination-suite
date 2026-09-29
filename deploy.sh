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
      git push -u origin main --force
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
