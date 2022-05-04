# wowhoneypot-with-spreadsheet

- WOWHoneypotのログをGoogleのスプレッドシートへ記録するための諸々が入ったリポジトリです。
- Googleデータポータルを使ってダッシュボードを作ると、ログを可視化できていい楽しいです。

# セットアップ方法

## 事前準備

- Google Workspacesのアカウント
- GCPのアカウントとプロジェクト
- AWSアカウント

## GCP：APIの有効化

- 「APIとサービス」内の「APIとサービスの有効化」で、Google Sheets APIとGoogle Drive APIを有効化する
- 「APIとサービス」内の「認証情報」でサービスアカウントを作って、キーを発行して保存しておく
  - ロールはなくていい

## Google Wordspaces：スプレッドシートの作成

- スプレッドシートを作成する
  - ブック名を「honeypot-log」、シート名を「Sheet1」（デフォルト）にしておくと後で楽（設定変更をしなくてよくなる）
- 1行目の各列に、ヘッダーとして以下を入力しておく
  - `timestamp	source_ip	dest_host	request	status_code	match	payload	user_agent	request_method	request_path	sensor_id	sensor_region`
-  スプレッドシートの共有先として、さっき作ったサービスアカウントを編集者として追加する
  - 発行したキーの中に「client_email」という情報があるので、それを入力すればよい

## AWS

- Lightsailを立てる
  - Amazon Linux 2（OS Only）
- ログインして以下のコマンドを実行する

```
$ sudo yum -y update
$ sudo yum -y install git
$ git clone https://github.com/shinobe179/wowhoneypot-with-spreadsheet.git
$ cd wowhoneypot-with-spreadsheet
$ vim honeypot-watcher/client_secret.json # コメントを消して、GCPで発行したキーをコピペする
$ sudo make
```
## 動作確認

以下のコマンドを実行して、スプレッドシートにログが追記されたら成功！

```
$ curl localhost:8080
```
