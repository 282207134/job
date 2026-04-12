# スケジュール管理アプリ（日 / 中 / EN）

> Flutter・Firebase で開発された日程管理アプリ。共有カレンダー、連絡先・DM、通話、プッシュ通知などに対応。

---

## 📱 アプリ概要

Flutter と Firebase を用いたアプリです。**カレンダー**、**Todo**、**共有カレンダー**、**連絡先・友だち申請・1 対 1 チャット**、**LiveKit による音声・ビデオ通話**、**プッシュ通知**などを備え、**iOS / Android / Web** で利用できます。

---

## 🌐 Web で試す

- **本番 URL（Firebase Hosting）**：<https://job-test-b3034.web.app>  
- 下記 QR からブラウザで開くこともできます。

![QRコード](https://github.com/282207134/job/assets/83965106/f1d11518-69c0-4eea-bb70-700d2877eb26)

> **補足**：Web は `flutter build web` の成果物を Hosting にデプロイします。ルートの `.env` はビルド時にアセットに同梱されます（`.env` は Git に含めない）。CI など `.env` が無い環境では `--dart-define=LIVEKIT_URL=...` 等で LiveKit を注入してください（下記「開発・デプロイ」参照）。

---

## 📅 カレンダー画面

月間・週間ビューでスケジュールを一覧表示できるメイン画面です。登録されたイベントをカレンダー上に分かりやすく表示します。

![カレンダー画面](https://github.com/user-attachments/assets/c67eacd9-2732-4c56-8bdd-7a7ff1f0e007)

---

## ➕ カレンダーイベントの作成

タイトル・日時・場所・メモなどの詳細情報を入力してイベントを作成できます。直感的なフォームで素早く予定を登録できます。

![イベント作成画面1](https://github.com/user-attachments/assets/87df1072-6cd9-4580-a02e-456e28b50f77)

![イベント作成画面2](https://github.com/user-attachments/assets/289cddb8-bdd0-4d79-98d8-1c644feb9e6a)

---

## 🔍 イベント検索機能

キーワードやフィルター条件を使ってイベントを素早く検索・絞り込みできます。大量の予定の中から目的のイベントを簡単に見つけることができます。

![イベント検索画面](https://github.com/user-attachments/assets/0e0fb69b-e500-4231-a3b0-721b916685bf)

---

## 🎌 日本・中国の祝日表示機能

日本と中国の祝日をカレンダー上に自動表示する機能です。両国の祝日をまとめて確認でき、国際的なスケジュール管理に便利です。

![祝日表示画面](https://github.com/user-attachments/assets/a72a2e86-750f-499d-a111-9fb71012382b)

---

## 👥 共有カレンダーの作成・友達招待

共有カレンダーを作成し、友達を招待して一緒に編集・管理できます。グループでの予定調整や共同プロジェクトの管理に最適です。

![共有カレンダー画面](https://github.com/user-attachments/assets/bd8b8d23-6b26-4fd6-9fa2-4691a0b05658)

---

## ✅ Todo（タスク管理）機能

タスクを作成・管理できる Todo 機能を搭載しています。完了・未完了の管理や優先度設定など、日々のタスクを効率よく整理できます。

![Todo画面](https://github.com/user-attachments/assets/e030e1f9-9114-435f-8a66-7fe6d32f7d86)

---

## 🤝 友達追加・カレンダー共有

友達を追加してカレンダーを共有できます。共有されたカレンダーはリアルタイムで同期され、いつでも最新の情報を確認できます。

![友達追加画面](https://github.com/user-attachments/assets/71147d8d-155b-4a0b-ba5d-08966c2a3da9)

![カレンダー共有画面](https://github.com/user-attachments/assets/fb29db3e-12f5-4b26-ab51-c0e78c400336)

---

## 💬 連絡先・友だち申請・1 対 1 チャット

- 下部ナビの **連絡先**：**届いた申請 / 送った申請（承認待ち）** と **友だち一覧**。  
- **友だち追加**：右上の「+」から相手の**登録メール**を入力。自分自身・存在しないユーザーは追加不可。  
- **データ**：Firestore `friend_links`（`pending` / `active`）。双方から申請が重なると相互承認で `active` になります。  
- **DM**：友だちとの 1 対 1 チャット（テキスト・画像など）。`directChats/{pairId}/messages` に保存。  
- **友だち削除**：各行の **⋮** メニューから削除。友だち関係に加え、**会話・通話シグナル**を削除し、**自分の UID 配下**のチャット用 Storage 画像もベストエフォートで削除（相手側の Storage は別途）。

---

## 📞 音声・ビデオ通話（LiveKit）

- 友だちとの **LiveKit** 音声 / ビデオ通話。着信時はグローバル UI・着信音（モバイル）に対応。  
- ルートの **`.env`**（リポジトリに含めない）またはビルド時 **`--dart-define`** で `LIVEKIT_URL` / `LIVEKIT_API_KEY` / `LIVEKIT_API_SECRET` を設定。  
- **セキュリティ**：`LIVEKIT_API_SECRET` を Web / クライアントに埋め込むのは開発・検証向け。本番は **Cloud Functions 等でトークンのみ発行**することを推奨。

---

## 🔔 プッシュ通知（Androidに向け、ios未実装）

- **FCM**：`users/{uid}.fcm_token` に保存し、Functions からデータメッセージ送信。  
- **ローカル通知**：`flutter_local_notifications`（Android はチャンネル・短い着信 / メッセージ音など）。  
- **OneSignal（任意）**：`.env` の `ONESIGNAL_APP_ID`。REST API Key は **Cloud Functions の環境変数**に設定（コミットしない）。設定時は OneSignal を優先し、届かない場合は FCM にフォールバック。  
- **Cloud Functions（`functions/`）**：`friend_links` 申請、DM、**着信 `call_signals`**、カレンダー招待などで相手に通知。`firebase deploy --only functions`。  
- **Web**：プッシュ周りはモバイル中心。Web は **Firestore のリアルタイム購読**が主。

---

## 🔒 ソフトウェアロック

アプリへのアクセスをパスコードや生体認証で保護するセキュリティ機能です。プライバシーを守り、他人にカレンダーを見られないようにします。

![ソフトウェアロック画面](https://github.com/user-attachments/assets/fb42a2fe-55ca-49bf-8b38-b8438be9cdf3)

---

## ⚙️ 設定画面

アプリ全体の設定を管理する画面です。通知、テーマ、**言語（日 / 中 / EN）**、アカウント情報など、カスタマイズが可能です。

![設定画面](https://github.com/user-attachments/assets/cb405e0d-5e90-46cf-b3cb-d6f5f6c32657)

---

## 🔐 ログイン・新規登録

メール / パスワード（Firebase Authentication）。一般的な認証エラーは **日 / 中 / EN のわかりやすい文言**にマッピングし、生の Firebase 英語エラーをそのまま出しません。

---

## 🛠 技術スタック

| 項目 | 内容 |
|------|------|
| フロントエンド | Flutter |
| バックエンド | Firebase（Auth、Firestore、Storage、**Cloud Functions**、**Hosting**） |
| リアルタイム通信 | LiveKit（`livekit_client`） |
| プッシュ | FCM、`flutter_local_notifications`、任意で **OneSignal** |
| 対応プラットフォーム | iOS / Android / Web |

---

## 🧰 開発・デプロイ（要約）

| 手順 | 内容 |
|------|------|
| 依存関係 | ルートで `flutter pub get`；`functions/` で `npm install` |
| シークレット | `.env.example` を `.env` にコピーして記入（リポジトリに `.env` を入れない） |
| Web ビルド | `flutter build web --release`（出力が `build_temp/web` の場合は `firebase.json` の `hosting.public`（例: `build/web`）へコピー） |
| Hosting | `firebase deploy --only hosting` |
| Functions | `firebase deploy --only functions`（OneSignal は環境変数で設定） |

---

## 📌 主な機能一覧

- カレンダー表示（月間・週間ビュー）
- イベントの作成・編集・削除
- イベント検索・フィルタリング
- 日本・中国の祝日自動表示
- 共有カレンダーの作成と友達招待
- Todo タスク管理
- 友達追加・申請・削除（会話データの削除を含む）
- 1 対 1 チャット（テキスト・画像など）
- LiveKit 音声・ビデオ通話・着信
- FCM + ローカル通知、任意の OneSignal、Functions によるプッシュ
- ログイン / 登録エラーのローカライズ
- ソフトウェアロック（セキュリティ）
- 日 / 中 / EN UI
- Firebase Hosting による Web 配信
