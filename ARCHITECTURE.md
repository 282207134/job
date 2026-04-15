# KantanKanri 项目架构文档

## 📋 项目概述

**项目名称**: KantanKanri (简单管理)  
**版本**: 1.0.0+1  
**技术栈**: Flutter + Firebase  
**开发语言**: Dart (>=3.3.4 <4.0.0)  
**应用类型**: 日程管理与团队协作应用

### 核心功能
- 📅 **共享日历** - 多用户协作的日历系统,支持中日节日自动导入
- 🎥 **LiveKit 音视频通话** - 实时语音/视频通信
- 💬 **好友即时通讯** - 基于 Firestore 的私信系统,支持文本和图片
- 🔐 **应用锁** - 密码保护,自动锁定机制
- 🌍 **多语言支持** - 中文、日文、英文三语言切换
- 🔔 **推送通知** - FCM + OneSignal 双通道推送
- 👥 **好友管理系统** - 好友申请、接受、拒绝流程

---

## 🏗️ 整体架构

```
┌─────────────────────────────────────────────────┐
│                  Presentation Layer              │
│  (UI Components: Screens, Pages, Widgets)       │
├─────────────────────────────────────────────────┤
│              Business Logic Layer                │
│  (Controllers, Providers, Methods)              │
├─────────────────────────────────────────────────┤
│                 Service Layer                    │
│  (Firebase Services, Media, Push, etc.)         │
├─────────────────────────────────────────────────┤
│              Data & Config Layer                 │
│  (Firebase, SharedPreferences, .env)            │
└─────────────────────────────────────────────────┘
```

---

## 📁 目录结构

```
lib/
├── main.dart                          # 应用入口,初始化 Firebase/Provider/推送服务
├── firebase_options.dart              # Firebase 多平台配置(自动生成)
│
├── app/                               # 应用核心模块
│   ├── app_routes.dart                # 路由配置管理
│   └── home_page.dart                 # 登录后主界面(底部导航+抽屉)
│
├── config/                            # 配置文件
│   └── livekit_config.dart            # LiveKit 音视频服务器配置
│
├── controllers/                       # 业务控制器
│   ├── login_controller.dart          # 登录逻辑控制
│   └── signup_controller.dart         # 注册逻辑控制
│
├── methods/                           # 通用方法
│   └── common_methods.dart            # UI 辅助方法(对话框、提示等)
│
├── providers/                         # 状态管理(Provider 模式)
│   ├── app_language_provider.dart     # 多语言状态管理(zh/ja/en)
│   ├── app_lock_provider.dart         # 应用锁状态管理
│   └── userProvider.dart              # 用户信息状态管理
│
├── screens/                           # 主要界面
│   ├── login_screen.dart              # 登录界面
│   ├── signup_screen.dart             # 注册界面
│   ├── profile_screen.dart            # 个人资料界面
│   ├── edit_profile_screen.dart       # 编辑资料界面
│   ├── dashboard_screen.dart          # 仪表板界面
│   ├── contacts_screen.dart           # 联系人列表界面
│   ├── add_friend_screen.dart         # 添加好友界面
│   ├── chat_screen.dart               # 私聊界面
│   ├── direct_voice_call_page.dart    # 语音通话界面
│   ├── direct_video_call_page.dart    # 视频通话界面
│   └── app_lock_gate_screen.dart      # 应用锁门禁界面
│
├── pages/                             # 功能页面
│   ├── jobPage/                       # 工作管理页面
│   │   ├── job_page.dart              # 工作列表页
│   │   ├── staff_page.dart            # 员工管理页
│   │   └── calendarView/              # 日历视图(排除在注释范围外)
│   └── ...                            # 其他功能页面
│
├── services/                          # 服务层(核心业务逻辑)
│   ├── push_notification_service.dart # 推送通知服务(FCM + 本地通知)
│   ├── messaging_service.dart         # 消息服务(好友关系+私聊)
│   ├── chat_media_service.dart        # 聊天媒体服务(图片上传/删除)
│   ├── profile_media_service.dart     # 个人资料媒体服务(头像上传)
│   ├── holiday_service.dart           # 假期服务(中日节日 API)
│   ├── direct_call_signal_service.dart # 直拨呼叫信号服务
│   ├── shared_calendar_service.dart   # 共享日历服务
│   ├── onesignal_push_service.dart    # OneSignal 推送服务
│   └── push_payload_router.dart       # 推送载荷路由器
│
├── widgets/                           # 自定义组件
│   └── global_incoming_call_host.dart # 全局来电显示组件(可最小化)
│
├── utils/                             # 工具类
│   ├── firebase_auth_messages.dart    # Firebase 认证错误消息映射
│   └── livekit_token_generator.dart   # LiveKit JWT 令牌生成器
│
└── splashScreen/                      # 启动屏幕
    ├── splash_screen.dart             # 闪屏页面
    └── OnBoardingPageState.dart       # 引导页(便利性/安全性/可用性)
```

---

## 🔑 核心模块详解

### 1. 应用启动流程 (`main.dart`)

```dart
main() 
  ↓
WidgetsFlutterBinding.ensureInitialized()  // 初始化 Flutter 绑定
  ↓
dotenv.load()                              // 加载环境变量(.env)
  ↓
Firebase.initializeApp()                   // 初始化 Firebase
  ↓
PushNotificationService.initialize()       // 初始化推送服务(非 Web)
  ↓
OneSignalPushService.initialize()          // 初始化 OneSignal
  ↓
runApp(MultiProvider(...))                 // 注入 Provider,启动应用
  ↓
MyApp.build()                              // 构建根组件
  ↓
StreamBuilder<User?>                       // 监听认证状态
  ├─ 已登录 → HomePage (主页)
  └─ 未登录 → SplashScreen → OnBoardingPage → LoginScreen
```

**关键设计**:
- 使用 `GlobalKey<NavigatorState>` 实现从全局来电组件 push 路由
- `WidgetsBindingObserver` 监听应用生命周期,恢复时同步 FCM Token
- `Listener` 包装记录用户活动,用于应用锁自动锁定计时

---

### 2. 状态管理 (Provider 模式)

#### AppLanguageProvider - 多语言管理
```dart
- locale: Locale                     // 当前语言环境
- tr(String key): String             // 翻译方法
- supportedLocales: [zh, ja, en]    // 支持的语言列表
```

#### AppLockProvider - 应用锁管理
```dart
- enabled: bool                      // 是否启用应用锁
- unlocked: bool                     // 是否已解锁
- password: String                   // 锁密码(加密存储)
- idleMinutes: int                   // 自动锁定空闲时间
- recordActivity()                   // 记录用户活动
- shouldRequireUnlock: bool          // 是否需要解锁
```

#### UserProvider - 用户信息管理
```dart
- currentUser: User?                 // 当前用户对象
- userData: Map<String, dynamic>?   // 用户扩展数据
```

---

### 3. 认证系统

#### 登录流程 (`login_controller.dart`)
```dart
LoginController.login()
  ↓
FirebaseAuth.signInWithEmailAndPassword()
  ↓
PushNotificationService.syncTokenNow()  // 同步 FCM Token
  ↓
Navigator.pushAndRemoveUntil(HomePage)  // 跳转到主页,清除历史
  ↓
捕获 FirebaseAuthException → 显示错误消息
```

#### 注册流程 (`signup_controller.dart`)
```dart
SignupController.signup()
  ↓
FirebaseAuth.createUserWithEmailAndPassword()
  ↓
Firestore.users.doc(uid).set(userData)  // 创建用户文档
  ↓
Navigator.pushReplacement(LoginScreen)  // 跳转到登录页
```

**错误处理**: `firebase_auth_messages.dart` 将 Firebase 错误代码映射为用户友好的密钥

---

### 4. 推送通知系统

#### 双通道推送架构
```
┌──────────────────────────────────────┐
│         Push Notification            │
├──────────────┬───────────────────────┤
│   FCM        │   OneSignal           │
│  (Firebase)  │   (第三方服务)         │
├──────────────┴───────────────────────┤
│  flutter_local_notifications         │
│  (本地通知展示)                       │
└──────────────────────────────────────┘
```

#### 核心组件

**PushNotificationService** (`push_notification_service.dart`)
- `initialize()` - 初始化 FCM、请求权限、设置监听器
- `syncTokenNow()` - 立即同步 FCM Token 到 Firestore
- `onAppResumed()` - 应用恢复时同步 Token
- `_showForegroundNotification()` - 显示前台通知
- `firebaseMessagingBackgroundHandler()` - 后台消息处理(@pragma 标记)

**通知通道** (Android):
- `kantankanri_msg_sfx` - 消息通知(message.wav)
- `kantankanri_call_sfx` - 来电通知(notify.wav)

**PushPayloadRouter** (`push_payload_router.dart`)
- 解析推送载荷,路由到对应页面(聊天/通话/日历)

---

### 5. 好友与消息系统

#### Firestore 数据结构
```
friend_links/{pairId}
  ├─ uids: [uid1, uid2]        // 排序后的用户 ID 列表
  ├─ status: pending|active     // 好友状态
  ├─ requested_by: uid          // 申请人 ID
  └─ names: {uid1: name1, ...}  // 用户名称映射

directChats/{pairId}
  ├─ participants: [uid1, uid2]
  ├─ updated_at: Timestamp
  └─ messages/{msgId}
      ├─ text: String           // 文本内容
      ├─ kind: image            // 消息类型
      ├─ image_url: String      // 图片 URL
      ├─ sender_id: String
      ├─ sender_name: String
      └─ timestamp: Timestamp
```

#### 好友申请流程 (`messaging_service.dart`)
```dart
sendFriendRequest(targetUid, targetName, myName)
  ↓
检查是否已存在 friend_links 文档
  ├─ status == 'active' → 已是好友
  ├─ status == 'pending' && by == me → 已发送申请
  └─ status == 'pending' && by != me → 对方已申请,直接变为 active
  ↓
创建新文档 (status: pending)
```

#### 消息发送流程
```dart
sendDirectMessage(pairDocId, senderName, senderId, text?, imageUrl?)
  ↓
Batch Write:
  ├─ 更新 directChats/{pairId} (updated_at)
  └─ 创建 messages/{msgId}
      ├─ 文本消息: {text, sender_id, ...}
      └─ 图片消息: {kind: 'image', image_url, text?, ...}
```

---

### 6. 媒体文件管理

#### Firebase Storage 路径规范
```
users/{uid}/avatars/{timestamp}.{ext}          // 用户头像
directChats/{pairId}/{senderUid}/images/{timestamp}.{ext}  // 聊天图片
```

#### ChatMediaService (`chat_media_service.dart`)
- `uploadChatImage()` - 上传聊天图片,返回下载 URL
- `tryDeleteMyChatFilesForPair()` - 删除自己上传的文件(递归删除)
- `messageForStorageError()` - 将 Storage 错误转为用户友好消息

#### ProfileMediaService (`profile_media_service.dart`)
- `uploadAvatar()` - 上传用户头像

**安全规则**: Storage Rules 限制用户只能访问自己的文件夹

---

### 7. 音视频通话 (LiveKit)

#### 架构
```
┌──────────┐         ┌──────────────┐         ┌──────────┐
│ Client A │ ←RTC→   │ LiveKit Server│ ←RTC→   │ Client B │
└──────────┘         └──────────────┘         └──────────┘
     ↑                                            ↑
JWT Token                                    JWT Token
(Client-side generated)                     (Client-side generated)
```

#### 呼叫信令流程 (`direct_call_signal_service.dart`)
```
Caller                          Callee
  |                               |
  |-- create call_signal -------->| (Firestore)
  |   (status: pending)           |
  |                               |
  |<-- GlobalIncomingCallHost ----| (监听 incoming)
  |   显示来电 UI                  |
  |                               |
  |<-- accept/reject -------------| (更新 status)
  |                               |
  |-- 打开通话页面 --------------->| (DirectVoice/VideoCallPage)
  |   (加入 LiveKit Room)         |   (加入同一 Room)
  |                               |
  |<====== RTC 媒体流 ===========>|
```

#### LivekitTokenGenerator (`livekit_token_generator.dart`)
- 客户端生成 JWT 令牌(生产环境建议改为服务器端生成)
- 包含: room_name, participant_identity, video permissions
- 有效期: 6 小时

---

### 8. 共享日历系统

#### HolidayService (`holiday_service.dart`)
- **节日 API**: https://date.nager.at/api/v3/PublicHolidays/{year}/{countryCode}
- **支持国家**: 日本 (JP)、中国 (CN)
- **自动导入**: 切换月份时自动补齐所选国家的该年节日到 Firestore

#### Firestore 事件结构
```
events/{eventId}
  ├─ title: String
  ├─ description: String
  ├─ date: Timestamp
  ├─ endDate: Timestamp
  ├─ startTime: String?
  ├─ endTime: String?
  ├─ color: int (ARGB)
  ├─ source: 'holiday_api' | 'user'
  └─ country_code: 'JP' | 'CN'
```

---

### 9. 应用锁系统

#### AppLockProvider 工作流程
```dart
启用应用锁:
  enableWithPassword(password)
    ↓
  加密存储密码 (SharedPreferences)
    ↓
  设置 enabled = true, unlocked = true

用户活动追踪:
  recordActivity()
    ↓
  重置空闲计时器 (_idleTimer)
    ↓
  如果超过 idleMinutes → unlocked = false

解锁验证:
  unlock(password)
    ↓
  验证密码
    ↓
  unlocked = true, 重启空闲计时器
```

#### AppLockGateScreen
- 全屏覆盖在应用上方
- 密码输入界面
- 阻止未授权访问

---

## 🔄 数据流图

### 用户登录到主页
```
User Input
  ↓
LoginScreen (UI)
  ↓
LoginController (Business Logic)
  ↓
FirebaseAuth (Authentication)
  ↓
Firestore (User Data)
  ↓
PushNotificationService (Sync Token)
  ↓
HomePage (Navigation)
  ↓
Consumer<AppLanguageProvider, AppLockProvider> (State)
```

### 发送好友申请
```
AddFriendScreen (UI)
  ↓
MessagingService.sendFriendRequest()
  ↓
Firestore.friend_links.set()
  ↓
Cloud Functions (Trigger)
  ↓
FCM Push Notification
  ↓
Recipient's Device
  ↓
PushPayloadRouter (Route to Contacts)
```

### 发起视频通话
```
ChatScreen → Call Button
  ↓
DirectCallSignalService.createIncomingSignal()
  ↓
Firestore.call_signals.set(status: pending)
  ↓
Callee's GlobalIncomingCallHost (Listen)
  ↓
显示来电 UI (接听/拒绝)
  ↓
Accept → DirectVideoCallPage
  ↓
LivekitTokenGenerator.generateToken()
  ↓
加入 LiveKit Room
  ↓
RTC 媒体流传输
```

---

## 🛠️ 关键技术栈

### 核心框架
- **Flutter** - 跨平台 UI 框架
- **Dart** - 编程语言 (>=3.3.4)

### Firebase 服务
- **firebase_core** - Firebase 核心
- **firebase_auth** - 用户认证
- **cloud_firestore** - NoSQL 数据库
- **firebase_storage** - 文件存储
- **firebase_messaging** - 推送通知 (FCM)

### 状态管理
- **provider** - 响应式状态管理

### 实时通信
- **livekit_client** - 音视频通话 SDK
- **crypto** - JWT 令牌生成

### 推送通知
- **flutter_local_notifications** - 本地通知
- **onesignal_flutter** - OneSignal 推送

### UI 组件
- **introduction_screen** - 引导页
- **another_flutter_splash_screen** - 闪屏动画
- **rflutter_alert** - 弹窗组件
- **flutter_colorpicker** - 颜色选择器

### 媒体处理
- **image_picker** - 图片选择
- **camera** - 相机访问
- **flutter_image_compress** - 图片压缩
- **image_cropper** - 图片裁剪
- **audioplayers** - 音频播放

### 数据存储
- **shared_preferences** - 本地键值存储
- **sqflite** - SQLite 数据库
- **flutter_dotenv** - 环境变量管理

### 其他
- **google_maps_flutter** - 地图集成
- **geolocator** - 地理定位
- **excel** - Excel 文件操作
- **http** - HTTP 请求
- **intl** - 国际化支持

---

## 🔒 安全设计

### 1. Firebase Security Rules
```javascript
// Firestore Rules
match /users/{userId} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}

match /friend_links/{pairId} {
  allow read, write: if request.auth != null && 
    resource.data.uids.hasAny([request.auth.uid]);
}

match /directChats/{pairId}/messages/{msgId} {
  allow read, write: if request.auth != null;
}

// Storage Rules
match /users/{uid}/avatars/{fileName} {
  allow read, write: if request.auth != null && request.auth.uid == uid;
}

match /directChats/{pairId}/{senderUid}/images/{fileName} {
  allow read, write: if request.auth != null && request.auth.uid == senderUid;
}
```

### 2. 应用锁
- 密码加密存储在 SharedPreferences
- 空闲超时自动锁定
- 后台切换到前台时检查锁状态

### 3. 数据隐私
- 好友关系双向确认机制
- 聊天图片仅上传者可见(Storage Rules 限制)
- 删除好友时清理聊天记录和媒体文件

---

## 🌐 多语言支持

### 支持语言
- 🇨🇳 中文 (zh)
- 🇯🇵 日文 (ja)
- 🇬🇧 英文 (en)

### 实现方式
```dart
AppLanguageProvider.tr(key)
  ↓
根据当前 locale 查找翻译
  ↓
Map<String, Map<String, String>> translations = {
  'zh': {'welcome': '欢迎'},
  'ja': {'welcome': 'ようこそ'},
  'en': {'welcome': 'Welcome'},
}
```

---

## 📱 平台支持

- ✅ **Android** - 完整支持
- ✅ **iOS** - 完整支持
- ⚠️ **Web** - 部分功能受限(推送通知不可用)
- ❌ **Desktop** - 未测试

---

## 🚀 部署配置

### 环境变量 (`.env`)
```env
LIVEKIT_URL=wss://your-livekit-server.com
LIVEKIT_API_KEY=your_api_key
LIVEKIT_API_SECRET=your_api_secret
```

### Firebase 配置
- `firebase_options.dart` - 自动生成的多平台配置
- 包含 Android、iOS、Web 的 Firebase 项目信息

### OneSignal 配置
- 需在 OneSignal 控制台创建应用
- 配置 Android/iOS 推送证书

---

## 🧪 测试策略

### 单元测试
- Controllers 业务逻辑测试
- Services 核心功能测试
- Utils 工具函数测试

### Widget 测试
- Screens UI 组件测试
- Widgets 自定义组件测试

### 集成测试
- 登录/注册流程
- 好友申请流程
- 消息发送接收
- 音视频通话

---

## 📊 性能优化

### 1. Firestore 查询优化
- 使用复合索引避免多次查询
- 限制查询结果数量 (`.limit()`)
- 使用 Stream 而非 Future 实现实时更新

### 2. 图片优化
- 上传前压缩 (`flutter_image_compress`)
- 使用缩略图预览
- 懒加载聊天图片

### 3. 状态管理优化
- Provider 细粒度更新
- 避免不必要的 rebuild
- 使用 `Consumer` 而非 `context.watch`

### 4. 推送通知
- 后台消息轻量处理
- 本地通知缓存
- Token 去重同步

---

## 🔮 未来扩展方向

### 短期规划
- [ ] 群组聊天功能
- [ ] 消息已读回执
- [ ] 文件传输(文档/PDF)
- [ ] 语音消息
- [ ] 表情包支持

### 中期规划
- [ ] 会议预约系统
- [ ] 任务分配与跟踪
- [ ] 团队看板
- [ ] 数据统计报表
- [ ] 离线模式优化

### 长期规划
- [ ] AI 智能助手
- [ ] 语音识别转录
- [ ] 视频会议录制
- [ ] 多租户支持
- [ ] 企业级权限管理

---

## 📚 相关文档

- [Firebase 官方文档](https://firebase.google.com/docs)
- [Flutter 官方文档](https://flutter.dev/docs)
- [LiveKit 文档](https://docs.livekit.io/)
- [Provider 包文档](https://pub.dev/packages/provider)

---

## 👥 开发团队

**项目维护者**: [您的名字]  
**最后更新**: 2026-04-15  
**文档版本**: 1.0.0

---

*本文档由 AI 助手根据代码分析自动生成,如有疑问请联系开发团队。*
