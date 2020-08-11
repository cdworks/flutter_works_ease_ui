

import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:flutter/widgets.dart';
import 'package:works_common/works_common.dart';

import '../works_ease_ui.dart';

class EaseUIHelper implements EMMessageListener,WidgetsBindingObserver
{

  static EaseUIHelper _instance;

  AppLifecycleState _lifecycleState;
  DateTime lastPlaySoundDate;
   ChatDelegate _delegate;

   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  factory EaseUIHelper.getInstance() {
    return _instance = _instance ?? EaseUIHelper._internal();
  }

  /// @nodoc private constructor
  EaseUIHelper._internal();

  void init(ChatDelegate delegate,FlutterLocalNotificationsPlugin plugin)
  {
    _delegate = delegate;
    flutterLocalNotificationsPlugin = plugin;
    _lifecycleState = AppLifecycleState.resumed;

    EMClient.getInstance().chatManager().initManager();
    EMClient.getInstance().chatManager().addMessageListener(this);
    WidgetsBinding.instance.addObserver(this);
  }


  ///发送消息本地推送通知
  void sendLocalNotice(List<EMMessage> messages,List noPushGroupIds)
  {

    EMClient.getInstance().getCurrentUser().then((currentUserId)
    {
      for(EMMessage message in messages)
      {
        Map messageExt = message.ext();

        bool isNeedPush = true;

        if(message.chatType != ChatType.Chat)  //群聊没有at或者消息免打扰
            {
          if(noPushGroupIds.contains(message.conversationId))
          {
            if(messageExt == null || !messageExt.containsKey(EaseUIOptions.CHAT_GROUP_MESSAGE_At_LIST))
            {
              isNeedPush = false;
            }
            else
            {
              var atTarget = message.getAttribute(EaseUIOptions.CHAT_GROUP_MESSAGE_At_LIST);
              if(atTarget is String)
              {
                if(atTarget.toLowerCase() != EaseUIOptions.CHAT_GROUP_MESSAGE_At_ALL) //at所有人
                    {
                  isNeedPush = false;
                }
              }
              else if(atTarget is List && currentUserId != null && currentUserId.isNotEmpty)
              {

                if(!atTarget.contains(currentUserId))
                {
                  isNeedPush = false;
                }
              }
              else
              {
                isNeedPush = false;
              }

            }

          }
        }

        print('isNeedPush:$isNeedPush _lifecycleState:$_lifecycleState');
        if(isNeedPush)
        {
          if(_lifecycleState != AppLifecycleState.resumed)
          {
            EMClient.getInstance().pushManager().getPushConfigs().then((configs)
            {

              if(_delegate != null && (configs == null || configs.displayStyle == 1) )  //发送消息内容
                  {

                _delegate.getUserInfo(message.from).then((userInfo)
                {
                  if(userInfo != null)
                  {
                    postNotificationWithMessageWithTitle(userInfo.nickname, message,currentUserId);
                  }
                  else
                  {
                    postNotificationWithMessageWithTitle(null, message,currentUserId);
                  }
                });
              }
              else
              {
                postNotificationWithMessageWithTitle(null, message,currentUserId);
              }

            });

          }
          else if(lastPlaySoundDate == null || DateTime.now().difference(lastPlaySoundDate).inMilliseconds > EaseUIOptions.kDefaultPlaySoundInterval)
          {
            print('lastPlaySoundDate');
            lastPlaySoundDate = DateTime.now();
            if(EaseUIOptions.notificationSoundName == null)
              {
                WorksCommon.playSytemSounds();
              }
            else
              {
                WorksCommon.playSytemSounds(soundId:EaseUIOptions.notificationSoundName);
              }

            WorksCommon.vibrate();

          }
        }
      }
    });
  }

  Future<void> postNotificationWithMessageWithTitle(String title,EMMessage message,String userId)
  async {

    String soundName = EaseUIOptions.notificationSoundName;

    //安卓的通知配置，必填参数是渠道id, 名称, 和描述, 可选填通知的图标，重要度等等。
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails('channel1',
        'channelname1',
        'channeldes',
        sound: soundName == null ? null : RawResourceAndroidNotificationSound(soundName.split('.').first),
        importance: Importance.Default,
        priority: Priority.Default);
    //IOS的通知配置
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails(sound: soundName);
    var platformChannelSpecifics = new NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    String alertContent = "您有一条新消息";
    String alertTitle = '';
    if (title != null && title.isNotEmpty) {
      EMMessageBody messageBody = message.body;
      String messageStr;
      switch (message.type) {
        case EMMessageType.TXT:
          {
            messageStr = (messageBody as EMTextMessageBody).message;
          }
          break;
        case EMMessageType.IMAGE:
          {
            messageStr = '[图片]';
          }
          break;
        case EMMessageType.VIDEO:
          messageStr = '[视频]';
          break;
        case EMMessageType.FILE:
          messageStr = '[文件]';
          break;
        case EMMessageType.VOICE:
          messageStr = '[语音]';
          break;
        case EMMessageType.LOCATION:
          messageStr = '[位置]';
          break;
        default:
          messageStr = '';
          break;
      }

      if (message.chatType == ChatType.Chat) {
        alertTitle = title;
        alertContent = messageStr;
      } else if (message.chatType == ChatType.GroupChat) {
        bool isAtMe = false;
        if (message.ext() != null && message.ext().containsKey(EaseUIOptions.CHAT_GROUP_MESSAGE_At_LIST)) {

          List atList = message.getAttribute(EaseUIOptions.CHAT_GROUP_MESSAGE_At_LIST);

          if(userId != null && userId.isNotEmpty)
            {
              for(int i = 0;i<atList.length;i++)
                {
                  if (atList[i] == userId) {
                    isAtMe = true;
                    break;
                  }
                }
            }

        }
        var group = await EMClient.getInstance().groupManager().getGroup(message.conversationId);
        if (group != null && group.getGroupName() != null && group.getGroupName().isNotEmpty) {
          alertTitle = group.getGroupName();
        }
        alertContent = isAtMe ? '[有人@你]$title: $messageStr' : '$title: $messageStr';
      }
    }

    flutterLocalNotificationsPlugin.show(0, alertTitle, alertContent, platformChannelSpecifics);
  }

  @override
  void onCmdMessageReceived(List<EMMessage> messages) {
    // TODO: implement onCmdMessageReceived

    messages.forEach((element) {
      EMCmdMessageBody body = element.body;
      if(body.action == EaseUIOptions.CMD_REVOKE_ACTION && element.ext() != null)  //消息撤回
      {
        if(element.ext().containsKey('msgId') && element.ext().containsKey("conversationId"))
        {
          EMConversationType conversationType = EMConversationType.Chat;
          if(element.chatType == ChatType.ChatRoom)
            {
              conversationType = EMConversationType.ChatRoom;
            }
          else if(element.chatType == ChatType.GroupChat)
          {
            conversationType = EMConversationType.GroupChat;
          }

          EMClient.getInstance()
              .chatManager()
              .getConversation(element.conversationId, conversationType, true).then((conversation)
          {
             if(conversation != null)
               {
                 String msgId = element.getAttribute('msgId').toString();

                 String nickName = element.ext().containsKey("nickName") ? element.getAttribute("nickName") : element.from;

                 EMMessage message = EMMessage.createTxtSendMessage('"$nickName"撤回了一条消息', element.conversationId);
                 message.msgTime = element.msgTime;
                 message.localTime = element.msgTime;
                 message.status = Status.SUCCESS;
                 message.unread = false;
                 message.setAttribute("work_easeui_recall", true);
                 message.chatType = element.chatType;
                 conversation.removeMessage(
                     msgId).then((_) => conversation.insertMessage(message).then((_) => DartNotificationCenter.post(
                       channel: EaseUIOptions.CHAT_CONVERSATION_REFRESH_EVENT)));
               }
          });
        }
      }
    });

  }

  @override
  void onMessageChanged(EMMessage message) {
    // TODO: implement onMessageChanged

  }

  @override
  void onMessageDelivered(List<EMMessage> messages) {
    // TODO: implement onMessageDelivered
  }

  @override
  void onMessageRead(List<EMMessage> messages) {
    // TODO: implement onMessageRead
  }

  @override
  void onMessageRecalled(List<EMMessage> messages) {
    // TODO: implement onMessageRecalled
  }

  @override
  void onMessageReceived(List<EMMessage> messages) {
    // TODO: implement onMessageReceived
    EMClient.getInstance().pushManager().getNoPushGroups().then((igGroupIds) {
      print('iggrouids:$igGroupIds');
      if(igGroupIds != null) {
        sendLocalNotice(messages, igGroupIds);
      }
    });
  }

  @override
  void didChangeAccessibilityFeatures() {
    // TODO: implement didChangeAccessibilityFeatures
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    _lifecycleState = state;
  }

  @override
  void didChangeLocales(List<Locale> locale) {
    // TODO: implement didChangeLocales
  }

  @override
  void didChangeMetrics() {
    // TODO: implement didChangeMetrics
  }

  @override
  void didChangePlatformBrightness() {
    // TODO: implement didChangePlatformBrightness
  }

  @override
  void didChangeTextScaleFactor() {
    // TODO: implement didChangeTextScaleFactor
  }

  @override
  void didHaveMemoryPressure() {
    // TODO: implement didHaveMemoryPressure
  }

  @override
  Future<bool> didPopRoute() {
    // TODO: implement didPopRoute
    return Future<bool>.value(false);
  }

  @override
  Future<bool> didPushRoute(String route) {
    // TODO: implement didPushRoute
    return Future<bool>.value(false);
  }

}