# 日程管理应用（中 / 日 / 英）

> 基于 Flutter 与 Firebase 开发的日程管理应用，含共享日历、好友与私信、通话与推送等。

---

## 📱 应用简介

本应用使用 Flutter 和 Firebase 开发，涵盖**日历**、**待办**、**共享日历**、**联系人 / 好友申请 / 一对一聊天**、**语音与视频通话（LiveKit）**、**推送通知**等功能，并支持 **iOS / Android / Web**。

---

## 🌐 Web 体验

- **线上地址（Firebase Hosting）**：<https://job-test-b3034.web.app>  
- 扫描以下二维码，也可在浏览器中打开 Web 版。

![二维码](https://github.com/282207134/job/assets/83965106/f1d11518-69c0-4eea-bb70-700d2877eb26)

> **说明**：Web 构建产物需执行 `flutter build web` 后部署到 Hosting；根目录 `.env` 在构建时会被打进资源包（`.env` 勿提交仓库）。若无 `.env`，可用 `--dart-define=LIVEKIT_URL=...` 等注入 LiveKit 相关变量（详见下文「开发与部署」）。

---

## 📅 日历界面

主界面以月视图或周视图展示日程列表，已添加的事件将清晰地显示在日历上，方便用户一目了然地掌握全部安排。

![日历界面](https://github.com/user-attachments/assets/c67eacd9-2732-4c56-8bdd-7a7ff1f0e007)

---

## ➕ 创建日历事件

可填写标题、日期时间、地点、备注等详细信息来创建事件。直观的表单设计让您能够快速录入日程。

![创建事件界面1](https://github.com/user-attachments/assets/87df1072-6cd9-4580-a02e-456e28b50f77)

![创建事件界面2](https://github.com/user-attachments/assets/289cddb8-bdd0-4d79-98d8-1c644feb9e6a)

---

## 🔍 查找事件功能

通过关键词或筛选条件，快速搜索并定位特定事件。即使日程繁多，也能轻松找到目标事项。

![查找事件界面](https://github.com/user-attachments/assets/0e0fb69b-e500-4231-a3b0-721b916685bf)

---

## 🎌 显示日本・中国节日功能

自动在日历上显示日本和中国的法定节假日。同时查看两国节日，方便进行国际化日程管理。

![节日显示界面](https://github.com/user-attachments/assets/a72a2e86-750f-499d-a111-9fb71012382b)

---

## 👥 创建可共享的日历并邀请好友一起操作

创建共享日历并邀请好友共同编辑与管理。非常适合团队协作、活动协调及共同项目管理。

![共享日历界面](https://github.com/user-attachments/assets/bd8b8d23-6b26-4fd6-9fa2-4691a0b05658)

---

## ✅ Todo 功能

内置任务管理（Todo）功能，支持创建、管理任务，并进行完成状态追踪及优先级设置，高效整理日常事务。

![Todo界面](https://github.com/user-attachments/assets/e030e1f9-9114-435f-8a66-7fe6d32f7d86)

---

## 🤝 添加好友，共享日历

添加好友后可共享日历。共享的日历实时同步，随时查看最新动态。

<img width="545" height="945" alt="image" src="https://github.com/user-attachments/assets/514b4e0d-d4b6-4173-9e9f-e5d9d5b31f82" />

![共享日历界面2](https://github.com/user-attachments/assets/fb29db3e-12f5-4b26-ab51-c0e78c400336)

---

## 💬 联系人、好友申请与一对一聊天

- **联系人**底部导航进入：查看「收到的申请 / 发出的申请（待通过）」与**好友列表**。  
- **添加好友**：右上角「+」，输入对方**注册邮箱**；不能添加自己或不存在用户。  
- **好友关系**：Firestore `friend_links`（pending / active）；双方同时申请时可自动变为已同意。  
- **私信**：与好友进入一对一聊天（文本、图片等），数据在 `directChats/{pairId}/messages`。  
- **删除好友**：好友行右侧 **⋮** 菜单 → 删除好友；会移除好友关系，并清理与该好友的聊天记录、通话信令及**本账号**在 Storage 中该会话下的聊天图片（对方 bucket 需对方侧或后端另行处理）。

---

## 📞 语音 / 视频通话（LiveKit）

- 与好友发起 **LiveKit** 语音或视频通话；来电时支持全局接听界面与铃声（移动端）。  
- 需在项目根目录配置 **`.env`**（不提交仓库）或构建时使用 **`--dart-define`** 传入：  
  `LIVEKIT_URL`、`LIVEKIT_API_KEY`、`LIVEKIT_API_SECRET`。  
- **安全提示**：将 `LIVEKIT_API_SECRET` 打进 Web/客户端等同于公开密钥；生产环境建议用 **Cloud Functions 等服务端签发 Token**，客户端只拿短期 token。

<img width="543" height="978" alt="image" src="https://github.com/user-attachments/assets/944f40b6-c2eb-43b9-ae3a-1d9e4bfb1c79" />
<img width="543" height="945" alt="image" src="https://github.com/user-attachments/assets/dbc0838e-6c91-4ca3-a41d-30ed5ad35bbf" />
<img width="545" height="950" alt="image" src="https://github.com/user-attachments/assets/75233e6c-38f8-43f4-b3fc-7440b0f50ace" />
---

## 🔔 推送通知（面向 Android、iOS未实装）

- **Firebase Cloud Messaging（FCM）**：令牌写入 `users/{uid}.fcm_token`，供服务端发数据消息。  
- **本地通知**：`flutter_local_notifications`；Android 自定义渠道与短提示音（消息 / 来电）。  
- **OneSignal（可选）**：在 `.env` 配置 `ONESIGNAL_APP_ID`；服务端 REST Key 放在 **Cloud Functions 环境变量**，勿提交仓库。配置后 Functions 优先走 OneSignal，失败再回退 FCM。  
- **Cloud Functions（`functions/`）**：在 Firestore 事件上向对端推送，例如：好友申请、私信、**来电信令**、共享日历邀请等。部署：`firebase deploy --only functions`。  
- **Web**：当前实现中部分推送逻辑对 Web 跳过或行为不同；Web 更依赖应用内 **Firestore 实时监听**。

---

## 🔒 软件锁

通过密码或生物识别（指纹/面容）保护应用访问的安全功能。保护个人隐私，防止他人查看您的日历内容。

![软件锁界面](https://github.com/user-attachments/assets/fb42a2fe-55ca-49bf-8b38-b8438be9cdf3)

---

## ⚙️ 设置界面

统一管理应用全局设置的界面，支持通知提醒、主题外观、**语言切换（中/日/英）**、账户信息等多项个性化配置。

![设置界面](https://github.com/user-attachments/assets/cb405e0d-5e90-46cf-b3cb-d6f5f6c32657)

---

## 🔐 登录与注册

- 邮箱 + 密码注册与登录（Firebase Authentication）。  
- 常见认证错误（如邮箱格式错误、密码错误、用户不存在等）会显示**本地化友好提示**，而非原始 Firebase 英文错误串。

---

## 🛠 技术栈

| 项目 | 内容 |
|------|------|
| 前端框架 | Flutter |
| 后端 / BaaS | Firebase（Auth、Firestore、Storage、**Cloud Functions**、**Hosting**） |
| 实时音视频 | LiveKit（`livekit_client`） |
| 推送 | FCM、`flutter_local_notifications`；可选 **OneSignal** |
| 支持平台 | iOS / Android / Web |

---

## 🧰 开发与部署（摘要）

| 步骤 | 说明 |
|------|------|
| 依赖 | 根目录 `flutter pub get`；Functions 目录 `npm install` |
| 本地密钥 | 复制 `.env.example` 为 `.env`（若仓库提供），填写 OneSignal / LiveKit 等；**勿将 `.env` 提交 Git** |
| Web 构建 | `flutter build web --release`（若工程输出在 `build_temp/web`，需同步到 `firebase.json` 中 `hosting.public` 所指目录，如 `build/web`） |
| Hosting | `firebase deploy --only hosting` |
| Functions | `firebase deploy --only functions`；OneSignal 密钥在 Firebase/Google Cloud 中为 Functions 配置环境变量 |

---

## 📌 主要功能列表

- 日历视图（月视图 / 周视图）
- 事件的创建、编辑与删除
- 事件搜索与筛选
- 自动显示日本・中国节假日
- 创建共享日历并邀请好友
- Todo 任务管理
- 添加好友、好友申请、删除好友（含清理会话数据）
- 一对一聊天（文字 / 图片等）
- LiveKit 语音 / 视频通话与来电处理
- FCM + 本地通知；可选 OneSignal；Cloud Functions 触发推送
- 登录 / 注册错误本地化提示
- 软件锁（安全保护）
- 中 / 日 / 英界面语言
- Firebase Hosting 发布 Web 版
