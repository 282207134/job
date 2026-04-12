/**
 * 部署：在项目根目录执行 `firebase deploy --only functions`
 *
 * 推送策略：若配置了 OneSignal（Google Cloud 中为本服务设置环境变量）
 *   ONESIGNAL_APP_ID、ONESIGNAL_REST_API_KEY —— 则优先走 OneSignal REST（MIUI 等更稳）。
 * 否则回退 FCM（users/{uid}.fcm_token）。
 *
 * OneSignal 与客户端约定：OneSignal.login(Firebase uid)，REST 使用 include_aliases.external_id。
 * 文档：https://documentation.onesignal.com/docs/flutter-sdk-setup
 */
const {onDocumentCreated, onDocumentWritten} = require("firebase-functions/v2/firestore");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");

initializeApp();
const db = getFirestore();
const messaging = getMessaging();

function dataStrings(obj) {
  const o = {};
  for (const [k, v] of Object.entries(obj || {})) {
    o[k] = v == null ? "" : String(v);
  }
  return o;
}

async function tokenForUser(uid) {
  const snap = await db.collection("users").doc(uid).get();
  if (!snap.exists) {
    console.log("users doc missing for", uid);
    return null;
  }
  const raw = snap.get("fcm_token");
  const fromData = snap.data()?.fcm_token;
  const t = typeof raw === "string" && raw.length > 0 ? raw :
    typeof fromData === "string" && fromData.length > 0 ? fromData : null;
  return t;
}

async function sendViaOneSignal(uid, title, body, dataFlat) {
  const appId = process.env.ONESIGNAL_APP_ID;
  const apiKey = process.env.ONESIGNAL_REST_API_KEY;
  if (!appId || !apiKey) {
    return false;
  }
  try {
    const res = await fetch("https://api.onesignal.com/notifications", {
      method: "POST",
      headers: {
        "Content-Type": "application/json; charset=utf-8",
        Authorization: `Key ${apiKey}`,
      },
      body: (() => {
        const payload = {
          app_id: appId,
          target_channel: "push",
          include_aliases: {external_id: [uid]},
          headings: {en: title, ja: title, zh: title},
          contents: {en: body, ja: body, zh: body},
          data: dataFlat,
        };
        // 着信は優先度を上げ、短い TTL で古い着信を抑止
        const isCall = dataFlat && dataFlat.type === "incoming_call";
        if (isCall) {
          payload.priority = 10;
          payload.ttl = 120;
          payload.android_channel_id = "kantankanri_call_sfx";
          payload.android_sound = "notify";
          payload.ios_sound = "notify.wav";
        } else {
          payload.android_channel_id = "kantankanri_msg_sfx";
          payload.android_sound = "message";
          payload.ios_sound = "message.wav";
        }
        return JSON.stringify(payload);
      })(),
    });
    const text = await res.text();
    if (!res.ok) {
      console.error("OneSignal HTTP", res.status, text);
      return false;
    }
    console.log("OneSignal ok", uid, text.slice(0, 200));
    return true;
  } catch (e) {
    console.error("OneSignal failed", uid, e.message || e);
    return false;
  }
}

async function sendViaFcm(uid, title, body, payloadData) {
  const token = await tokenForUser(uid);
  if (!token) {
    console.warn("No fcm_token for user", uid);
    return;
  }
  try {
    const mid = await messaging.send({
      token,
      data: payloadData,
      android: {
        priority: "high",
      },
      apns: {
        headers: {
          "apns-priority": "10",
        },
        payload: {
          aps: {
            alert: {
              title,
              body,
            },
            sound: "default",
            "content-available": 1,
          },
        },
      },
    });
    console.log("FCM sent ok", {uid, mid});
  } catch (e) {
    console.error("FCM send failed", uid, e.message || e);
  }
}

async function sendToUser(uid, title, body, data = {}) {
  const payloadData = dataStrings({
    ...data,
    title,
    body,
  });
  const osOk = await sendViaOneSignal(uid, title, body, payloadData);
  if (osOk) {
    return;
  }
  await sendViaFcm(uid, title, body, payloadData);
}

// 新建或再次设为 pending 时通知（仅 onCreate 会漏掉「同 inviteId 重新 set」）
exports.onCalendarInviteNotify = onDocumentWritten(
    "calendar_invites/{inviteId}",
    async (event) => {
      const after = event.data.after?.data();
      if (!after || after.status !== "pending") return;
      const before = event.data.before?.data();
      if (before?.status === "pending") return;
      const toUid = after.to_uid;
      if (!toUid) return;
      const fromName = after.from_name || "Someone";
      const room = after.room_name || "Shared calendar";
      await sendToUser(
          toUid,
          "Calendar invite",
          `${fromName}: ${room}`,
          {
            type: "calendar_invite",
            invite_id: event.params.inviteId,
          },
      );
    },
);

exports.onFriendRequestCreated = onDocumentCreated(
    "friend_links/{pairId}",
    async (event) => {
      const d = event.data?.data();
      if (!d || d.status !== "pending") return;
      const requestedBy = d.requested_by;
      const uids = d.uids;
      if (!Array.isArray(uids) || uids.length < 2) return;
      const target = uids.find((u) => u !== requestedBy);
      if (!target) return;
      const names = d.names || {};
      const fromName = names[requestedBy] || "Someone";
      await sendToUser(
          target,
          "Friend request",
          `${fromName} wants to connect`,
          {
            type: "friend_request",
            pair_id: event.params.pairId,
          },
      );
    },
);

exports.onDirectMessageCreated = onDocumentCreated(
    "directChats/{pairId}/messages/{msgId}",
    async (event) => {
      const d = event.data?.data();
      if (!d) return;
      const sender = d.sender_id;
      if (!sender) return;
      const pairId = event.params.pairId;
      const parts = pairId.split("__");
      if (parts.length !== 2) return;
      let recipient;
      if (parts[0] === sender) recipient = parts[1];
      else if (parts[1] === sender) recipient = parts[0];
      else return;

      const name = d.sender_name || "Message";
      let preview = "";
      if (d.kind === "image") {
        preview = d.text ? `[Image] ${String(d.text).slice(0, 60)}` : "[Image]";
      } else {
        preview = String(d.text || "").slice(0, 100);
      }
      if (!preview) preview = "New message";

      await sendToUser(recipient, name, preview, {
        type: "chat_message",
        pair_id: pairId,
      });
    },
);

exports.onCallSignalCreated = onDocumentCreated(
    "directChats/{pairId}/call_signals/{sigId}",
    async (event) => {
      const d = event.data?.data();
      if (!d || d.status !== "pending") return;
      const toUid = d.to_uid;
      if (!toUid) return;
      const fromName = d.from_name || "Someone";
      const isVideo = d.call_type === "video";
      const kind = isVideo ? "Video" : "Voice";
      await sendToUser(
          toUid,
          `Incoming ${kind} call`,
          `${fromName} is calling…`,
          {
            type: "incoming_call",
            pair_id: event.params.pairId,
            signal_id: event.params.sigId,
            call_type: d.call_type || "voice",
          },
      );
    },
);
