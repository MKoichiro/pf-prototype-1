# pf-prototype-1

## 📋 概要
- プロジェクト名: "pf-portfolio-1"
- アプリケーション名: (未定)
- URL: https://clino-mania.net

このリポジトリは、`Rails API`のバックエンドと`React` フロントエンドを `Docker` イメージを経由して `ECS on Fargate` へデプロイするものです。`CI/CD`や`IaC` を含みます。
※ AWSでインフラ構築までを済ませたプロジェクトです。アプリケーション部分は未作成です。

## 📁 ディレクトリ構成（抜粋）
```bash
/
├── .github/            # GitHub Actions ワークフロー
│   ├── api.cicd.yml   # API（Rails）用 CI/CD
│   └── web.cicd.yml   # Web（React）用 CI/CD
├── api/                # Rails API サービス
│   ├── docker/        # Dockerfile、.dockerignore
│   └── app/           # Rails アプリケーション本体
├── web/                # React フロントエンドサービス
│   ├── docker/        # Dockerfile、.dockerignore
│   ├── nginx/         # 本番環境のNginxサーバー設定
│   └── src/           # ソースコード
├── infra/              # AWS＋Terraform によるインフラ定義
│   ├── aws/task-def/  # ECS タスク定義（JSON）
│   └── terraform/     # Terraform モジュール・環境別設定
└── compose.*.yml       # Docker Compose ファイル（dev／prod）
```

## ⚙️ 利用技術スタック

- **コンテナ**: Docker, Docker Compose
- **バックエンド**: Ruby on Rails API (7.2.x), PostgreSQL
- **フロントエンド**: React (Vite + TypeScript)
- **CI/CD**: GitHub Actions
  1. Docker イメージビルド（compose.prod.yml）
  2. ECR へプッシュ
  3. ECS タスク定義を取得し、イメージ URI を差し替え
  4. ECS サービスをローリングデプロイ
- **インフラ**: AWSで構築、以下のリソース・インスタンスを含みます。
  - VPC
  - Security Group
  - ALB
  - ECR
  - ECS on Fargate
  - RDS, PostgreSQL
  - SSM Parameter Store
  - Secrets Manager
  - CloudMap, Service Connect
  - S3 (ログとtfstateファイル)
- **IaC**: Terraform モジュール化（ECR, S3, Secrets Manager, CloudMap 以外の上記リソース）

### ネットワーク図
![alt text](network.svg)

## 動作確認
※ 意味のあるアプリケーションをデプロイしているわけではないので、疎通確認です。
1. [http(s)://clino-mania.net](https://clino-mania.net) へアクセス
2. Call APIボタンをクリック
3. テストユーザー一覧のJSONが取れる
