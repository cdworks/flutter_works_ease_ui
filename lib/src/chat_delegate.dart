

import 'package:im_flutter_sdk/im_flutter_sdk.dart';

class ChatUserModel
{
  final String userId;   //用户Id
  final String nickname;  //昵称
  final String avatarURLPath;  //头像的网络地址
  final String avatarFilePath;  //本地asset名称
  const ChatUserModel(this.userId, this.nickname, this.avatarURLPath, this.avatarFilePath);  //默认头像asset  注意，若头像的网络地址不为空，则不会加载默认头像
}



class EaseChatError
{
  final int code;  //0 成功
  final String message;
  final dynamic object;  //额外信息
  const EaseChatError({this.code = 0 ,this.message = '',this.object});
}


//class ChatGroupModel
//{
//  final String groupId;   //用户Id
//  final String groupName;  //昵称
//
//  ChatGroupModel(this.groupId, this.groupName);  //默认头像asset  注意，若头像的网络地址不为空，则不会加载默认头像
//}

abstract class ChatDelegate
{

  //获取当前用户信息
  ChatUserModel getCurrentUserInfo();

  //获取用户信息
   Future<ChatUserModel> getUserInfo(String userId);

   //获取本地缓存群组
   Future<List<EMGroup>> getLocalGroups();

   //获取本地缓存好友列表
   Future<List<ChatUserModel>> getLocalContacts();

   //获取好友列表
   Future<List<ChatUserModel>> getContacts();

   //添加好友
   Future<EaseChatError> addGroupMember(List<String> invitorList);

   //删除好友
   Future<EaseChatError> removeGroupMember(List<String> memberList);

   //修改群组
   Future<EaseChatError> modifyGroupMember(String groupId,String name);

   //群内禁言
   Future<EaseChatError> muteGroupMember(String groupId,String userId, int muteSeconds);
   Future<EaseChatError> unMuteMember(String groupId,String userId);


   //删除特定时间以前的群消息
   Future<EaseChatError> removeGroupMessageAfterTime(String groupId,String startTime,);

   //根据透传消息获取删除特定时间段的开始时间 返回时间戳,单位毫秒
   int getDeleteMessageBeginTime(EMMessage cmdMessage);

   //删除特定ID的群消息
   Future<EaseChatError> removeGroupMessageWithMessageId(String groupId,String msgId,);

   //根据透传消息获取需要删除的消息ID ,返回id
  String getDeleteMessageId(EMMessage cmdMessage);


}