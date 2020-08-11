
 import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ui相关属性配置

class EaseUIOptions {

   static String _packageName = 'works_ease_ui'; //package name

   static get  packageName => _packageName;  //用于当需要引用本插件中的图片Image.asset中的'package'参数

   ///以下数据若不设置，有默认值

   static int kDefaultPlaySoundInterval = 4000;  //消息两次提示音的默认间隔 毫秒

   ///特别提示 android端忽略文件后缀，所以，如果android是sound.mp3 ios 是sound.caf 那么直接传sound.caf，两端通用
   static String notificationSoundName; //消息提示音，若不设置，默认提示音

   static SystemUiOverlayStyle statusStyle = SystemUiOverlayStyle.light;  //状态栏颜色

   static String msgUserHead;  // 默认用户头像
   static String msgGroupHead;  // 默认群组头像
   static String msgReceiverBgName;  // 文本消息接收方背景  默认白色边框
   static String msgSenderBgName ;  // 文本消息发送方背景  默认绿色边框
   static Color msgReceiverTextColor = const Color(0xFF333333); //文本消息接收方颜色  默认黑色
   static Color msgSenderTextColor = const Color(0xFFFFFFFF); //文本消息发送方颜色   默认白色

   static String msgReceiverVoiceIconName; // 语音消息接收方标志
   static String msgReceiverVoiceAnimateName;   //  语音消息接收方播放中动效


   static String msgSenderVoiceIconName;  //语音发送方标志
   static String msgSenderVoiceAnimateName;    //语音消息发送方播放中动效



   static Color pageDotActiveColor =  Colors.black;   //表情页指示器当前页面颜色 默认黑色
   static Color pageDotNormalColor = const Color(0xFFAAAAAA);    //表情页指示器非当前页面颜色  默认灰色
   static Color sendBtnBackgroundColor = Colors.blue;  //发送按钮背景色  默认 绿色
   static Color sendBtnTitleColor = Colors.white;  //发送按钮字体颜色    默认 白色


   //是否可以转发 注意，若可以转发，则需要访问联系人
   static bool needRetransmit = true;

   //是否可以添加群成员，注意，若可以添加，则需要访问联系人
   //由于环信群组的限制，及时设置可以添加也需要根据不同的群类型决定是否可以，详见http://docs-im.easemob.com/im/ios/basics/group中的加入群组
   static int needAddMember = 1;  //0 不可以，1 群组拥有者或管理员可以添加  2 任何人可以添加

   static bool needRemoveMember = true; //仅限拥有者或管理员

   //添加群成员或删除是否由环信sdk调用，若否，则通过自己的服务器以REST的方式向环信请求,需要在ChatDelegate中实现请求
   ///特别提示，3.x创建群组，添加群成员是需要用户上线才可以添加上，您可以服务端调用rest接口去群组加人 rest接口是服务端调用的，直接进入群 建议设置为否
   static bool addOrRemoveMemberBySDK = true;


   //修改群名称是否由环信sdk调用，若否，则通过自己的服务器以REST的方式向环信请求,需要在ChatDelegate中实现请求
   static bool modifyGroupNameBySdk = true;

   //禁言是否由环信sdk调用，若否，则通过自己的服务器以REST的方式向环信请求,需要在ChatDelegate中实现请求
   static bool muteMemberBySdk = true;

   //删除群中特定的聊天记录（注意，不是自己的，是群内若有人都不能看到删除后的聊天记录）是否由环信sdk调用，若否，则通过自己的服务器以REST的方式向环信请求,需要在ChatDelegate中实现请求
   ///特别提示 ，透传消息需要使用下面定义的透传相关的CMD_ACTION字段
   static bool removeMessageAtTimeBySDK = true;  //删除时间段的所有消息（指定startTime到当前msgId发送时间）
   static bool removeMessageWithIDBySDK = true;  //删除特定id的群消息

   //透传相关
   static const String CMD_CHAT_GROUP_DELETE_BY_START_TIME = 'cmd_delete_group_by_start_time';
   static const String CMD_CHAT_GROUP_DELETE_BY_START_ID = 'cmd_delete_group_by_ID';
   static const String CMD_REVOKE_ACTION = 'cmd_revoke_action'; //消息撤回Action

   //一般常量
   static const String CHAT_GROUP_MESSAGE_At_LIST = 'em_at_list';  //at某些人功能
   static const String CHAT_GROUP_MESSAGE_At_ALL = 'all';    //at所有人

  //通知常量
  static const String CHAT_EXIT_EVENT = 'chat_exit_event';  //聊天界面退出 需要刷新会话等
   static const String CHAT_UNREAD_CHANGED_EVENT = 'chat_unread_changed_event';  //消息未读消息改变
   static const String CHAT_GROUP_NAME_CHANGED_EVENT = 'chat_group_name_changed_event'; //群组名改变

   static const String CHAT_CONVERSATION_CLEAR_EVENT = 'chat_clear_msg_event'; //清空聊天记录改变

   static const String CHAT_CONVERSATION_REFRESH_EVENT = 'chat_conversation_refresh_event';  //需要刷新会话

  //route name(用于跳转）

   static const String CHAT_ROUTE_NAME = 'easeui_chat_route_name';  //聊天界面退出 需要刷新会话等 会话和联系人需要在route中添加

  //


}
