#!/bin/bash
set -e

#----------------------------------------
# 使い方：
#   1) 実行権限を付与
#       chmod +x script_name.sh
#
#   2) 実行例
#       1] テスト
#          - test.jsonを用意
#              {
#                "repo_url": "git@github.com:<GIT_USER>/<REPOSITORY>.git",
#                "branch": "main"
#              }
#          - コマンドで確認
#             ./sha_getter.sh < test.json
#       2] data "external" {}で呼び出し
#          - ssh-agentを起動
#             eval "$(ssh-agent -s)"
#             ssh-add ~/.ssh/rsa_github
#          - `terraform plan`でdataブロックがパースされるとスクリプトが走る。
#----------------------------------------

# 標準入力から JSON を受け取る
input=$(cat)
repo_url=$(echo "$input" | jq -r '.repo_url')
branch=$(echo "$input" | jq -r '.branch')

# branch が空の場合は HEAD をデフォルトにする
if [ -z "$branch" ] || [ "$branch" = "null" ]; then
  branch="HEAD"
fi

# SSH通信で最新コミットハッシュを取得（awkで最初のカラムを抽出）
commit_hash=$(git ls-remote "$repo_url" "$branch" | awk '{print $1}')

# JSON形式で出力
jq -n --arg commit_hash "$commit_hash" '{"commit_hash": $commit_hash}'
