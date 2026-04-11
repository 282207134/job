import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { zh, ja, en }

class AppLanguageProvider extends ChangeNotifier {
  AppLanguageProvider() {
    _load();
  }

  static const _prefsKey = 'app_language';
  AppLanguage _language = AppLanguage.zh;

  AppLanguage get language => _language;

  Locale get locale {
    switch (_language) {
      case AppLanguage.ja:
        return const Locale('ja');
      case AppLanguage.en:
        return const Locale('en');
      case AppLanguage.zh:
        return const Locale('zh');
    }
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) {
      final sys = PlatformDispatcher.instance.locale.languageCode.toLowerCase();
      if (sys == 'ja') {
        _language = AppLanguage.ja;
      } else if (sys == 'zh') {
        _language = AppLanguage.zh;
      } else {
        _language = AppLanguage.en;
      }
      notifyListeners();
      return;
    }
    _language = _fromCode(raw);
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage next) async {
    if (_language == next) return;
    _language = next;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, _codeOf(next));
  }

  String tr(String key) {
    const table = <String, Map<AppLanguage, String>>{
      'title_schedule': {
        AppLanguage.zh: '日程管理',
        AppLanguage.ja: 'スケジュール管理',
        AppLanguage.en: 'Schedule',
      },
      'contacts': {
        AppLanguage.zh: '联系人',
        AppLanguage.ja: '連絡先',
        AppLanguage.en: 'Contacts',
      },
      'calendar': {
        AppLanguage.zh: '日历',
        AppLanguage.ja: 'カレンダー',
        AppLanguage.en: 'Calendar',
      },
      'todo': {
        AppLanguage.zh: '待办',
        AppLanguage.ja: 'Todo',
        AppLanguage.en: 'Todo',
      },
      'profile': {
        AppLanguage.zh: '个人信息',
        AppLanguage.ja: '個人情報',
        AppLanguage.en: 'Profile',
      },
      'holiday_settings': {
        AppLanguage.zh: '节日设置',
        AppLanguage.ja: '祝日設定',
        AppLanguage.en: 'Holiday Settings',
      },
      'shared_calendar': {
        AppLanguage.zh: '共享日历',
        AppLanguage.ja: '共有カレンダー',
        AppLanguage.en: 'Shared Calendar',
      },
      'logout': {
        AppLanguage.zh: '退出登录',
        AppLanguage.ja: 'ログアウト',
        AppLanguage.en: 'Logout',
      },
      'language_settings': {
        AppLanguage.zh: '语言设置',
        AppLanguage.ja: '言語設定',
        AppLanguage.en: 'Language',
      },
      'language_zh': {
        AppLanguage.zh: '中文',
        AppLanguage.ja: '中国語',
        AppLanguage.en: 'Chinese',
      },
      'language_ja': {
        AppLanguage.zh: '日语',
        AppLanguage.ja: '日本語',
        AppLanguage.en: 'Japanese',
      },
      'language_en': {
        AppLanguage.zh: '英语',
        AppLanguage.ja: '英語',
        AppLanguage.en: 'English',
      },
      'not_logged_in': {
        AppLanguage.zh: '未登录',
        AppLanguage.ja: '未ログインです',
        AppLanguage.en: 'Not logged in',
      },
      'unknown_friend': {
        AppLanguage.zh: '无法识别好友',
        AppLanguage.ja: '友だちを識別できません',
        AppLanguage.en: 'Cannot identify friend',
      },
      'no_shared_calendar_created': {
        AppLanguage.zh: '你还没有创建共享日历',
        AppLanguage.ja: '共有カレンダーがまだありません',
        AppLanguage.en: 'No shared calendars created yet',
      },
      'send_to': {
        AppLanguage.zh: '发送给',
        AppLanguage.ja: '送信先',
        AppLanguage.en: 'Send to',
      },
      'select_shared_calendar': {
        AppLanguage.zh: '选择共享日历',
        AppLanguage.ja: '共有カレンダーを選択',
        AppLanguage.en: 'Select shared calendar',
      },
      'cancel': {
        AppLanguage.zh: '取消',
        AppLanguage.ja: 'キャンセル',
        AppLanguage.en: 'Cancel',
      },
      'send': {
        AppLanguage.zh: '发送',
        AppLanguage.ja: '送信',
        AppLanguage.en: 'Send',
      },
      'invite_sent': {
        AppLanguage.zh: '邀请已发送',
        AppLanguage.ja: '招待を送信しました',
        AppLanguage.en: 'Invite sent',
      },
      'send_image': {
        AppLanguage.zh: '发送图片',
        AppLanguage.ja: '画像を送信',
        AppLanguage.en: 'Send Image',
      },
      'send_calendar': {
        AppLanguage.zh: '发送日历',
        AppLanguage.ja: 'カレンダーを送信',
        AppLanguage.en: 'Send Calendar',
      },
      'more': {
        AppLanguage.zh: '更多',
        AppLanguage.ja: 'その他',
        AppLanguage.en: 'More',
      },
      'no_name_available': {
        AppLanguage.zh: '暂无姓名',
        AppLanguage.ja: '名前がありません',
        AppLanguage.en: 'No name available',
      },
      'no_email_available': {
        AppLanguage.zh: '暂无邮箱',
        AppLanguage.ja: 'メールがありません',
        AppLanguage.en: 'No email available',
      },
      'chat_send_failed': {
        AppLanguage.zh: '发送失败',
        AppLanguage.ja: '送信に失敗しました',
        AppLanguage.en: 'Failed to send',
      },
      'photo_access_failed': {
        AppLanguage.zh: '无法访问照片',
        AppLanguage.ja: '写真へのアクセスに失敗しました',
        AppLanguage.en: 'Failed to access photos',
      },
      'image_pick_failed': {
        AppLanguage.zh: '选择图片失败',
        AppLanguage.ja: '画像の選択に失敗しました',
        AppLanguage.en: 'Failed to pick image',
      },
      'image_send_failed': {
        AppLanguage.zh: '发送图片失败',
        AppLanguage.ja: '画像の送信に失敗しました',
        AppLanguage.en: 'Failed to send image',
      },
      'default_shared_calendar_name': {
        AppLanguage.zh: '共享日历',
        AppLanguage.ja: '共有カレンダー',
        AppLanguage.en: 'Shared Calendar',
      },
      'image_display_failed': {
        AppLanguage.zh: '无法显示图片',
        AppLanguage.ja: '画像を表示できません',
        AppLanguage.en: 'Failed to display image',
      },
      'chat_error_prefix': {
        AppLanguage.zh: '错误',
        AppLanguage.ja: 'エラー',
        AppLanguage.en: 'Error',
      },
      'no_messages': {
        AppLanguage.zh: '暂无消息',
        AppLanguage.ja: 'メッセージがありません',
        AppLanguage.en: 'No messages',
      },
      'message_input_hint': {
        AppLanguage.zh: '输入消息…',
        AppLanguage.ja: 'メッセージを入力…',
        AppLanguage.en: 'Type a message…',
      },
      'livekit_not_configured': {
        AppLanguage.zh:
            '未配置 LiveKit：请在项目根目录的 .env 中填写 LIVEKIT_URL、LIVEKIT_API_KEY、LIVEKIT_API_SECRET（也可使用 --dart-define 覆盖）',
        AppLanguage.ja:
            'LiveKit が未設定です。プロジェクト直下の .env に LIVEKIT_URL / LIVEKIT_API_KEY / LIVEKIT_API_SECRET を記入するか、--dart-define で上書きしてください。',
        AppLanguage.en:
            'LiveKit is not configured. Set LIVEKIT_URL, LIVEKIT_API_KEY, LIVEKIT_API_SECRET in the project root `.env`, or pass them via --dart-define.',
      },
      'call_voice_tooltip': {
        AppLanguage.zh: '语音通话',
        AppLanguage.ja: '音声通話',
        AppLanguage.en: 'Voice call',
      },
      'call_video_tooltip': {
        AppLanguage.zh: '视频通话',
        AppLanguage.ja: 'ビデオ通話',
        AppLanguage.en: 'Video call',
      },
      'call_incoming_voice': {
        AppLanguage.zh: '邀请你语音通话',
        AppLanguage.ja: '音声通話の招待',
        AppLanguage.en: 'Incoming voice call',
      },
      'call_incoming_video': {
        AppLanguage.zh: '邀请你视频通话',
        AppLanguage.ja: 'ビデオ通話の招待',
        AppLanguage.en: 'Incoming video call',
      },
      'call_calling_voice': {
        AppLanguage.zh: '正在呼叫（语音）…',
        AppLanguage.ja: '呼び出し中（音声）…',
        AppLanguage.en: 'Calling (voice)…',
      },
      'call_calling_video': {
        AppLanguage.zh: '正在呼叫（视频）…',
        AppLanguage.ja: '呼び出し中（ビデオ）…',
        AppLanguage.en: 'Calling (video)…',
      },
      'call_waiting_peer_answer': {
        AppLanguage.zh: '等待对方接听…',
        AppLanguage.ja: '相手の応答を待っています…',
        AppLanguage.en: 'Waiting for answer…',
      },
      'call_rejected': {
        AppLanguage.zh: '对方已拒绝',
        AppLanguage.ja: '相手が拒否しました',
        AppLanguage.en: 'Call declined',
      },
      'call_failed': {
        AppLanguage.zh: '通话请求失败',
        AppLanguage.ja: '通話リクエストに失敗しました',
        AppLanguage.en: 'Call request failed',
      },
      'call_connecting': {
        AppLanguage.zh: '正在连接…',
        AppLanguage.ja: '接続中…',
        AppLanguage.en: 'Connecting…',
      },
      'call_waiting_peer': {
        AppLanguage.zh: '等待对方加入…',
        AppLanguage.ja: '相手の参加を待っています…',
        AppLanguage.en: 'Waiting for peer…',
      },
      'call_accept': {
        AppLanguage.zh: '接听',
        AppLanguage.ja: '応答',
        AppLanguage.en: 'Accept',
      },
      'call_decline': {
        AppLanguage.zh: '拒绝',
        AppLanguage.ja: '拒否',
        AppLanguage.en: 'Decline',
      },
      'call_incoming_minimize': {
        AppLanguage.zh: '最小化',
        AppLanguage.ja: '最小化',
        AppLanguage.en: 'Minimize',
      },
      'call_incoming_restore': {
        AppLanguage.zh: '展开来电',
        AppLanguage.ja: '着信を展開',
        AppLanguage.en: 'Expand',
      },
      'call_hide_self_preview': {
        AppLanguage.zh: '隐藏自己的画面',
        AppLanguage.ja: '自分の映像を隠す',
        AppLanguage.en: 'Hide self preview',
      },
      'call_show_self_preview': {
        AppLanguage.zh: '显示自己的画面',
        AppLanguage.ja: '自分の映像を表示',
        AppLanguage.en: 'Show self preview',
      },
      'call_voice_mic_on': {
        AppLanguage.zh: '麦克风已开',
        AppLanguage.ja: 'マイクオン',
        AppLanguage.en: 'Mic on',
      },
      'call_voice_mic_off': {
        AppLanguage.zh: '麦克风已关',
        AppLanguage.ja: 'マイクオフ',
        AppLanguage.en: 'Mic off',
      },
      'call_voice_speaker_on': {
        AppLanguage.zh: '扬声器已开',
        AppLanguage.ja: 'スピーカーオン',
        AppLanguage.en: 'Speaker on',
      },
      'call_voice_speaker_off': {
        AppLanguage.zh: '扬声器已关',
        AppLanguage.ja: 'スピーカーオフ',
        AppLanguage.en: 'Speaker off',
      },
      'call_voice_hang_up': {
        AppLanguage.zh: '挂断',
        AppLanguage.ja: '終了',
        AppLanguage.en: 'Hang up',
      },
      'call_voice_minimize_hint': {
        AppLanguage.zh: '当前版本请在通话界面内使用；结束请点挂断',
        AppLanguage.ja: 'この版ではバックグラウンド最小化に未対応です。終了は「終了」から。',
        AppLanguage.en: 'Minimize to background is not available in this build. Use Hang up to end.',
      },
      'call_voice_add_unsupported': {
        AppLanguage.zh: '一对一通话暂不支持邀请更多人',
        AppLanguage.ja: '1対1通話では追加招待に未対応です',
        AppLanguage.en: 'Adding participants is not supported in 1:1 calls',
      },
      'call_retry': {
        AppLanguage.zh: '重试',
        AppLanguage.ja: '再試行',
        AppLanguage.en: 'Retry',
      },
      'contacts_login_required': {
        AppLanguage.zh: '需要先登录',
        AppLanguage.ja: 'ログインが必要です',
        AppLanguage.en: 'Login required',
      },
      'contacts_load_error': {
        AppLanguage.zh: '加载失败',
        AppLanguage.ja: '読み込みエラー',
        AppLanguage.en: 'Load error',
      },
      'contacts_section_requests_friends': {
        AppLanguage.zh: '申请与好友',
        AppLanguage.ja: '申請・友だち',
        AppLanguage.en: 'Requests & Friends',
      },
      'contacts_incoming_requests': {
        AppLanguage.zh: '收到的申请',
        AppLanguage.ja: '受け取った申請',
        AppLanguage.en: 'Incoming requests',
      },
      'contacts_outgoing_pending': {
        AppLanguage.zh: '发送的申请（待通过）',
        AppLanguage.ja: '送った申請（承認待ち）',
        AppLanguage.en: 'Sent requests (pending)',
      },
      'contacts_friends': {
        AppLanguage.zh: '好友',
        AppLanguage.ja: '友だち',
        AppLanguage.en: 'Friends',
      },
      'contacts_empty_friends_hint': {
        AppLanguage.zh: '还没有好友，点击右上角 + 添加。',
        AppLanguage.ja: '友だちがいません。右上の＋から追加できます。',
        AppLanguage.en: 'No friends yet. Add one from + in the top-right.',
      },
      'contacts_preview_unavailable': {
        AppLanguage.zh: '无法读取预览',
        AppLanguage.ja: 'プレビューを読めません',
        AppLanguage.en: 'Cannot load preview',
      },
      'add_friend_email_required': {
        AppLanguage.zh: '请输入邮箱',
        AppLanguage.ja: 'メールを入力してください',
        AppLanguage.en: 'Please enter an email',
      },
      'user_not_found': {
        AppLanguage.zh: '找不到该用户',
        AppLanguage.ja: 'ユーザーが見つかりません',
        AppLanguage.en: 'User not found',
      },
      'user_default': {
        AppLanguage.zh: '用户',
        AppLanguage.ja: 'ユーザー',
        AppLanguage.en: 'User',
      },
      'request_sent': {
        AppLanguage.zh: '已发送',
        AppLanguage.ja: '送信しました',
        AppLanguage.en: 'Sent',
      },
      'add_friend': {
        AppLanguage.zh: '添加好友',
        AppLanguage.ja: '友だちを追加',
        AppLanguage.en: 'Add Friend',
      },
      'enter_registered_email': {
        AppLanguage.zh: '输入对方注册邮箱',
        AppLanguage.ja: '相手の登録メールアドレスを入力',
        AppLanguage.en: 'Enter the other user\'s registered email',
      },
      'email_address': {
        AppLanguage.zh: '邮箱地址',
        AppLanguage.ja: 'メールアドレス',
        AppLanguage.en: 'Email address',
      },
      'send_request': {
        AppLanguage.zh: '发送申请',
        AppLanguage.ja: '申請を送る',
        AppLanguage.en: 'Send request',
      },
      'request_approved': {
        AppLanguage.zh: '已同意',
        AppLanguage.ja: '承認しました',
        AppLanguage.en: 'Approved',
      },
      'approve': {
        AppLanguage.zh: '同意',
        AppLanguage.ja: '承認',
        AppLanguage.en: 'Approve',
      },
      'decline': {
        AppLanguage.zh: '拒绝',
        AppLanguage.ja: '却下',
        AppLanguage.en: 'Decline',
      },
      'pending_approval': {
        AppLanguage.zh: '待通过',
        AppLanguage.ja: '承認待ち',
        AppLanguage.en: 'Pending approval',
      },
      'waiting_for_approval': {
        AppLanguage.zh: '等待对方同意',
        AppLanguage.ja: '相手の承認を待っています',
        AppLanguage.en: 'Waiting for approval',
      },
      'cancel_request': {
        AppLanguage.zh: '取消申请',
        AppLanguage.ja: '取り消し',
        AppLanguage.en: 'Cancel',
      },
      'image': {
        AppLanguage.zh: '图片',
        AppLanguage.ja: '画像',
        AppLanguage.en: 'Image',
      },
      'message': {
        AppLanguage.zh: '消息',
        AppLanguage.ja: 'メッセージ',
        AppLanguage.en: 'Message',
      },
      'my_calendar': {
        AppLanguage.zh: '我的日历',
        AppLanguage.ja: 'マイカレンダー',
        AppLanguage.en: 'My Calendar',
      },
      'my_calendar_rooms': {
        AppLanguage.zh: '我的日历房间',
        AppLanguage.ja: '自分のカレンダールーム',
        AppLanguage.en: 'My Calendar Rooms',
      },
      'incoming_invites': {
        AppLanguage.zh: '收到的邀请',
        AppLanguage.ja: '受け取った招待',
        AppLanguage.en: 'Incoming Invites',
      },
      'no_invites': {
        AppLanguage.zh: '暂无邀请',
        AppLanguage.ja: '招待はありません',
        AppLanguage.en: 'No invites',
      },
      'read_calendar_rooms_failed': {
        AppLanguage.zh: '读取日历房间失败',
        AppLanguage.ja: 'カレンダールームの読み込みに失敗',
        AppLanguage.en: 'Failed to load calendar rooms',
      },
      'read_invites_failed': {
        AppLanguage.zh: '读取邀请失败',
        AppLanguage.ja: '招待の読み込みに失敗',
        AppLanguage.en: 'Failed to load invites',
      },
      'create_shared_calendar': {
        AppLanguage.zh: '创建共享日历',
        AppLanguage.ja: '共有カレンダーを作成',
        AppLanguage.en: 'Create shared calendar',
      },
      'enter_room_name': {
        AppLanguage.zh: '请输入房间名称',
        AppLanguage.ja: 'ルーム名を入力してください',
        AppLanguage.en: 'Enter room name',
      },
      'invite_member': {
        AppLanguage.zh: '邀请成员',
        AppLanguage.ja: 'メンバーを招待',
        AppLanguage.en: 'Invite member',
      },
      'delete_shared_calendar': {
        AppLanguage.zh: '删除共享日历',
        AppLanguage.ja: '共有カレンダーを削除',
        AppLanguage.en: 'Delete shared calendar',
      },
      'leave_shared_calendar': {
        AppLanguage.zh: '退出共享日历',
        AppLanguage.ja: '共有カレンダーを退出',
        AppLanguage.en: 'Leave shared calendar',
      },
      'shared_calendar_notice': {
        AppLanguage.zh: '共享日历提示',
        AppLanguage.ja: '共有カレンダーのお知らせ',
        AppLanguage.en: 'Shared calendar notice',
      },
      'got_it': {
        AppLanguage.zh: '知道了',
        AppLanguage.ja: '了解',
        AppLanguage.en: 'Got it',
      },
      'invite_message': {
        AppLanguage.zh: '邀请你加入',
        AppLanguage.ja: 'あなたを招待しました',
        AppLanguage.en: 'invites you to join',
      },
      'reject': {
        AppLanguage.zh: '拒绝',
        AppLanguage.ja: '拒否',
        AppLanguage.en: 'Reject',
      },
      'join': {
        AppLanguage.zh: '加入',
        AppLanguage.ja: '参加',
        AppLanguage.en: 'Join',
      },
      'change_avatar': {
        AppLanguage.zh: '更换头像',
        AppLanguage.ja: 'アバターを変更',
        AppLanguage.en: 'Change avatar',
      },
      'avatar_updated': {
        AppLanguage.zh: '头像已更新',
        AppLanguage.ja: 'アバターを更新しました',
        AppLanguage.en: 'Avatar updated',
      },
      'avatar_update_failed': {
        AppLanguage.zh: '头像更新失败',
        AppLanguage.ja: 'アバターの更新に失敗しました',
        AppLanguage.en: 'Failed to update avatar',
      },
      'edit_name': {
        AppLanguage.zh: '修改姓名',
        AppLanguage.ja: '名前を変更',
        AppLanguage.en: 'Edit name',
      },
      'profile_info': {
        AppLanguage.zh: '个人信息',
        AppLanguage.ja: '個人情報',
        AppLanguage.en: 'Profile',
      },
      'name_empty': {
        AppLanguage.zh: '姓名不能为空',
        AppLanguage.ja: '名前を入力してください',
        AppLanguage.en: 'Name cannot be empty',
      },
      'name': {
        AppLanguage.zh: '姓名',
        AppLanguage.ja: '名前',
        AppLanguage.en: 'Name',
      },
      'todo_new_task': {
        AppLanguage.zh: '新任务',
        AppLanguage.ja: '新しいタスク',
        AppLanguage.en: 'New task',
      },
      'todo_empty': {
        AppLanguage.zh: '暂无任务',
        AppLanguage.ja: 'タスクがありません',
        AppLanguage.en: 'No tasks',
      },
      'login': {
        AppLanguage.zh: '登录',
        AppLanguage.ja: 'ログイン',
        AppLanguage.en: 'Login',
      },
      'email': {
        AppLanguage.zh: '邮箱',
        AppLanguage.ja: 'メール',
        AppLanguage.en: 'Email',
      },
      'password': {
        AppLanguage.zh: '密码',
        AppLanguage.ja: 'パスワード',
        AppLanguage.en: 'Password',
      },
      'email_required': {
        AppLanguage.zh: '请输入邮箱',
        AppLanguage.ja: 'メールを入力してください',
        AppLanguage.en: 'Email is required',
      },
      'password_required': {
        AppLanguage.zh: '请输入密码',
        AppLanguage.ja: 'パスワードを入力してください',
        AppLanguage.en: 'Password is required',
      },
      'no_account': {
        AppLanguage.zh: '还没有账号',
        AppLanguage.ja: 'アカウントをお持ちでないですか',
        AppLanguage.en: 'No account yet',
      },
      'register_here': {
        AppLanguage.zh: '点这里注册',
        AppLanguage.ja: 'こちらから登録',
        AppLanguage.en: 'Register here',
      },
      'create_account': {
        AppLanguage.zh: '创建账号',
        AppLanguage.ja: 'アカウント作成',
        AppLanguage.en: 'Create account',
      },
      'register_with_email_password': {
        AppLanguage.zh: '使用邮箱和密码注册',
        AppLanguage.ja: 'メールとパスワードで登録してください',
        AppLanguage.en: 'Register with email and password',
      },
      'valid_email_required': {
        AppLanguage.zh: '请输入有效邮箱',
        AppLanguage.ja: '有効なメール形式で入力してください',
        AppLanguage.en: 'Enter a valid email',
      },
      'password_min_6': {
        AppLanguage.zh: '密码至少 6 位',
        AppLanguage.ja: '6文字以上にしてください',
        AppLanguage.en: 'Use at least 6 characters',
      },
      'confirm_password': {
        AppLanguage.zh: '确认密码',
        AppLanguage.ja: '確認用パスワード',
        AppLanguage.en: 'Confirm password',
      },
      'confirm_password_required': {
        AppLanguage.zh: '请输入确认密码',
        AppLanguage.ja: '確認用パスワードを入力してください',
        AppLanguage.en: 'Confirm password is required',
      },
      'password_not_match': {
        AppLanguage.zh: '两次密码不一致',
        AppLanguage.ja: 'パスワードが一致しません',
        AppLanguage.en: 'Passwords do not match',
      },
      'enter_name': {
        AppLanguage.zh: '请输入姓名',
        AppLanguage.ja: 'お名前を入力してください',
        AppLanguage.en: 'Please enter your name',
      },
      'register_user': {
        AppLanguage.zh: '注册',
        AppLanguage.ja: 'ユーザ登録',
        AppLanguage.en: 'Sign up',
      },
      'error': {
        AppLanguage.zh: '错误',
        AppLanguage.ja: 'エラー',
        AppLanguage.en: 'Error',
      },
      'holiday_country_jp': {
        AppLanguage.zh: '日本节日',
        AppLanguage.ja: '日本祝日',
        AppLanguage.en: 'Japan Holidays',
      },
      'holiday_country_cn': {
        AppLanguage.zh: '中国节日',
        AppLanguage.ja: '中国の祝日',
        AppLanguage.en: 'China Holidays',
      },
      'password_hint_6': {
        AppLanguage.zh: '建议至少 6 位',
        AppLanguage.ja: '6文字以上を推奨',
        AppLanguage.en: 'At least 6 characters recommended',
      },
      'confirm_password_hint': {
        AppLanguage.zh: '请再次输入',
        AppLanguage.ja: 'もう一度入力',
        AppLanguage.en: 'Enter again',
      },
      'create_event': {
        AppLanguage.zh: '创建活动',
        AppLanguage.ja: '新規イベント作成',
        AppLanguage.en: 'Create event',
      },
      'update_event': {
        AppLanguage.zh: '更新活动',
        AppLanguage.ja: 'イベント更新',
        AppLanguage.en: 'Update event',
      },
      'failed_to_add_event': {
        AppLanguage.zh: '添加活动失败',
        AppLanguage.ja: 'イベントの追加に失敗しました',
        AppLanguage.en: 'Failed to add event',
      },
      'actor': {
        AppLanguage.zh: '操作者',
        AppLanguage.ja: '操作ユーザー',
        AppLanguage.en: 'Actor',
      },
      'date': {
        AppLanguage.zh: '日期',
        AppLanguage.ja: '日付',
        AppLanguage.en: 'Date',
      },
      'start_time': {
        AppLanguage.zh: '开始时间',
        AppLanguage.ja: '開始時間',
        AppLanguage.en: 'Start time',
      },
      'end_time': {
        AppLanguage.zh: '结束时间',
        AppLanguage.ja: '終了時間',
        AppLanguage.en: 'End time',
      },
      'content': {
        AppLanguage.zh: '内容',
        AppLanguage.ja: '内容',
        AppLanguage.en: 'Content',
      },
      'delete_event': {
        AppLanguage.zh: '删除活动',
        AppLanguage.ja: 'イベント削除',
        AppLanguage.en: 'Delete event',
      },
      'edit_event': {
        AppLanguage.zh: '编辑活动',
        AppLanguage.ja: 'イベント編集',
        AppLanguage.en: 'Edit event',
      },
      'tab_month': {
        AppLanguage.zh: '月',
        AppLanguage.ja: '月',
        AppLanguage.en: 'Month',
      },
      'tab_week': {
        AppLanguage.zh: '周',
        AppLanguage.ja: '週',
        AppLanguage.en: 'Week',
      },
      'tab_day': {
        AppLanguage.zh: '日',
        AppLanguage.ja: '日',
        AppLanguage.en: 'Day',
      },
      'event_title': {
        AppLanguage.zh: '活动标题',
        AppLanguage.ja: 'イベントタイトル',
        AppLanguage.en: 'Event Title',
      },
      'start_date': {
        AppLanguage.zh: '开始日期',
        AppLanguage.ja: '開始日',
        AppLanguage.en: 'Start Date',
      },
      'end_date': {
        AppLanguage.zh: '结束日期',
        AppLanguage.ja: '終了日',
        AppLanguage.en: 'End Date',
      },
      'please_enter_event_title': {
        AppLanguage.zh: '请输入活动标题',
        AppLanguage.ja: 'イベントタイトルを入力してください',
        AppLanguage.en: 'Please enter event title',
      },
      'please_select_start_date': {
        AppLanguage.zh: '请选择开始日期',
        AppLanguage.ja: '開始日を選択してください',
        AppLanguage.en: 'Please select start date',
      },
      'please_select_end_date': {
        AppLanguage.zh: '请选择结束日期',
        AppLanguage.ja: '終了日を選択してください',
        AppLanguage.en: 'Please select end date',
      },
      'end_date_before_start': {
        AppLanguage.zh: '结束日期早于开始日期',
        AppLanguage.ja: '終了日が開始日より前です',
        AppLanguage.en: 'End date occurs before start date',
      },
      'event_description': {
        AppLanguage.zh: '活动描述',
        AppLanguage.ja: 'イベント説明',
        AppLanguage.en: 'Event Description',
      },
      'please_enter_event_description': {
        AppLanguage.zh: '请输入活动描述',
        AppLanguage.ja: 'イベント説明を入力してください',
        AppLanguage.en: 'Please enter event description',
      },
      'event_color': {
        AppLanguage.zh: '活动颜色',
        AppLanguage.ja: 'イベントカラー',
        AppLanguage.en: 'Event Color',
      },
      'add_event': {
        AppLanguage.zh: '创建活动',
        AppLanguage.ja: 'イベント追加',
        AppLanguage.en: 'Add Event',
      },
      'select_event_color': {
        AppLanguage.zh: '选择活动颜色',
        AppLanguage.ja: 'イベントカラーを選択',
        AppLanguage.en: 'Select event color',
      },
      'select': {
        AppLanguage.zh: '选择',
        AppLanguage.ja: '選択',
        AppLanguage.en: 'Select',
      },
      'search_events': {
        AppLanguage.zh: '搜索活动',
        AppLanguage.ja: 'イベントを検索',
        AppLanguage.en: 'Search events',
      },
      'search_event_hint': {
        AppLanguage.zh: '输入标题或描述',
        AppLanguage.ja: 'タイトルまたは説明を入力',
        AppLanguage.en: 'Search by title or description',
      },
      'search_no_results': {
        AppLanguage.zh: '没有匹配的活动',
        AppLanguage.ja: '一致するイベントがありません',
        AppLanguage.en: 'No matching events',
      },
      'search_start_typing': {
        AppLanguage.zh: '输入关键词开始搜索',
        AppLanguage.ja: 'キーワードを入力して検索',
        AppLanguage.en: 'Start typing to search',
      },
      'app_lock': {
        AppLanguage.zh: '程序锁',
        AppLanguage.ja: 'アプリロック',
        AppLanguage.en: 'App Lock',
      },
      'app_lock_enabled': {
        AppLanguage.zh: '启用程序锁',
        AppLanguage.ja: 'アプリロックを有効化',
        AppLanguage.en: 'Enable app lock',
      },
      'app_lock_enabled_success': {
        AppLanguage.zh: '程序锁已启用',
        AppLanguage.ja: 'アプリロックを有効にしました',
        AppLanguage.en: 'App lock enabled',
      },
      'app_lock_disabled': {
        AppLanguage.zh: '程序锁已停用',
        AppLanguage.ja: 'アプリロックは無効です',
        AppLanguage.en: 'App lock disabled',
      },
      'app_lock_status_enabled': {
        AppLanguage.zh: '已启用',
        AppLanguage.ja: '有効',
        AppLanguage.en: 'Enabled',
      },
      'app_lock_status_disabled': {
        AppLanguage.zh: '已停用',
        AppLanguage.ja: '無効',
        AppLanguage.en: 'Disabled',
      },
      'set_lock_password': {
        AppLanguage.zh: '设置程序锁密码',
        AppLanguage.ja: 'ロックパスワードを設定',
        AppLanguage.en: 'Set lock password',
      },
      'change_lock_password': {
        AppLanguage.zh: '修改程序锁密码',
        AppLanguage.ja: 'ロックパスワードを変更',
        AppLanguage.en: 'Change lock password',
      },
      'lock_password_hint': {
        AppLanguage.zh: '输入密码（至少 4 位）',
        AppLanguage.ja: 'パスワードを入力（4文字以上）',
        AppLanguage.en: 'Enter password (at least 4 chars)',
      },
      'confirm_lock_password_hint': {
        AppLanguage.zh: '再次输入密码',
        AppLanguage.ja: 'パスワードを再入力',
        AppLanguage.en: 'Confirm password',
      },
      'lock_password_too_short': {
        AppLanguage.zh: '密码至少 4 位',
        AppLanguage.ja: 'パスワードは4文字以上です',
        AppLanguage.en: 'Password must be at least 4 chars',
      },
      'lock_password_mismatch': {
        AppLanguage.zh: '两次密码不一致',
        AppLanguage.ja: 'パスワードが一致しません',
        AppLanguage.en: 'Passwords do not match',
      },
      'lock_password_updated': {
        AppLanguage.zh: '程序锁密码已更新',
        AppLanguage.ja: 'ロックパスワードを更新しました',
        AppLanguage.en: 'Lock password updated',
      },
      'unlock_app': {
        AppLanguage.zh: '解锁应用',
        AppLanguage.ja: 'アプリをロック解除',
        AppLanguage.en: 'Unlock App',
      },
      'enter_lock_password': {
        AppLanguage.zh: '请输入程序锁密码',
        AppLanguage.ja: 'ロックパスワードを入力してください',
        AppLanguage.en: 'Enter lock password',
      },
      'wrong_lock_password': {
        AppLanguage.zh: '密码错误',
        AppLanguage.ja: 'パスワードが違います',
        AppLanguage.en: 'Incorrect password',
      },
      'save': {
        AppLanguage.zh: '保存',
        AppLanguage.ja: '保存',
        AppLanguage.en: 'Save',
      },
      'auto_lock_timeout': {
        AppLanguage.zh: '自动锁定时间',
        AppLanguage.ja: '自動ロック時間',
        AppLanguage.en: 'Auto-lock timeout',
      },
      'auto_lock_disabled': {
        AppLanguage.zh: '不自动锁定',
        AppLanguage.ja: '自動ロックしない',
        AppLanguage.en: 'Disabled',
      },
      'auto_lock_minutes': {
        AppLanguage.zh: '{n} 分钟无操作后锁定',
        AppLanguage.ja: '{n} 分操作なしでロック',
        AppLanguage.en: 'Lock after {n} minutes idle',
      },
    };
    return table[key]?[_language] ?? key;
  }

  static AppLanguage _fromCode(String code) {
    switch (code) {
      case 'ja':
        return AppLanguage.ja;
      case 'en':
        return AppLanguage.en;
      default:
        return AppLanguage.zh;
    }
  }

  static String _codeOf(AppLanguage language) {
    switch (language) {
      case AppLanguage.ja:
        return 'ja';
      case AppLanguage.en:
        return 'en';
      case AppLanguage.zh:
        return 'zh';
    }
  }
}
