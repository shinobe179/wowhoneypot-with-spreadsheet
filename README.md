# wowhoneypot-with-spreadsheet

- WOWHoneypotのログをGoogleのスプレッドシートへ記録するための諸々が入ったリポジトリです。
- Googleデータポータルを使ってダッシュボードを作ると、ログを可視化できて楽しいです。

# おおまかな仕組み

- WOWHoneypot
  - ハニーポット本体
  - systemdのサービス（WOWHoneypot.service）として管理できる
- honeypot-watcher
  - WOWHoneypotのログ（access_log）を監視して、追加された行をスプレッドシートへ送る
  - systemdのサービス（honeypot-watcher.service）として管理できる

# セットアップ方法

画像付きのより詳しい手順は[こちら](https://shinobe179.hatenablog.com/entry/2022/05/05/013149)をご覧ください。

## 事前準備

- Google Workspacesのアカウント
- GCPのアカウントとプロジェクト
- AWSアカウント

## GCP：APIの有効化

- 「APIとサービス」内の「APIとサービスの有効化」で、Google Sheets APIとGoogle Drive APIを有効化する
- 「APIとサービス」内の「認証情報」でサービスアカウントを作って、キーを発行して保存しておく
  - ロールはなくていい

## Google Workspaces：スプレッドシートの作成

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
```

honeypot-watcher/config.pyを修正する。各値の意味は以下の通り。

- sensor_id
  - センサー（ハニーポット）の識別子。ログに記録される。
- sensor_region
  - センサー（ハニーポット）がある地域。ログに記録される。
- book_name
  - ログを書き込むスプレッドシートのファイル（ブック）名。
- sheet_name
  - ログを書き込むシート名。

以下を実行すると、Makefileに書かれたセットアップ処理が自動で実行される。

```
$ sudo make
```

## 動作確認

以下のコマンドを実行して、スプレッドシートにログが追記されたら成功！

```
$ curl localhost:8080
```
