

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import '../../works_ease_ui.dart';
import '../itmes/ease_message_model.dart';

import '../chat_widget_util.dart';
import 'message_item_factory.dart';

enum EMErrorCode{
EMErrorGeneral ,                      /*! \~chinese 一般错误 \~english General error */
EMErrorNetworkUnavailable,               /*! \~chinese 网络不可用 \~english Network is unavaliable */
EMErrorDatabaseOperationFailed,          /*! \~chinese 数据库操作失败 \~english Database operation failed */
EMErrorExceedServiceLimit,               /*! \~chinese 超过服务器限制 \~english Exceed service limit */
EMErrorServiceArrearages,                /*! \~chinese 余额不足 \~english Need charge for service */
EMErrorInvalidAppkey ,              /*! \~chinese Appkey无效 \~english App (API) key is invalid */
EMErrorInvalidUsername,                  /*! \~chinese 用户名无效 \~english Username is invalid */
EMErrorInvalidPassword,                  /*! \~chinese 密码无效 \~english Password is invalid */
EMErrorInvalidURL,                       /*! \~chinese URL无效 \~english URL is invalid */
EMErrorInvalidToken,                     /*! \~chinese Token无效 \~english Token is invalid */
EMErrorUserAlreadyLogin ,           /*! \~chinese 用户已登录 \~english User already logged in */
EMErrorUserNotLogin,                     /*! \~chinese 用户未登录 \~english User not logged in */
EMErrorUserAuthenticationFailed,         /*! \~chinese 密码验证失败 \~english Password authentication failed */
EMErrorUserAlreadyExist,                 /*! \~chinese 用户已存在 \~english User already existed */
EMErrorUserNotFound,                     /*! \~chinese 用户不存在 \~english User not found */
EMErrorUserIllegalArgument,              /*! \~chinese 参数不合法 \~english Invalid argument */
EMErrorUserLoginOnAnotherDevice,         /*! \~chinese 当前用户在另一台设备上登录 \~english User has logged in from another device */
EMErrorUserRemoved,                      /*! \~chinese 当前用户从服务器端被删掉 \~english User was removed from server */
EMErrorUserRegisterFailed,               /*! \~chinese 用户注册失败 \~english Registration failed */
EMErrorUpdateApnsConfigsFailed,          /*! \~chinese 更新推送设置失败 \~english Update Apple Push Notification configurations failed */
EMErrorUserPermissionDenied,             /*! \~chinese 用户没有权限做该操作 \~english User has no operation permission */
EMErrorUserBindDeviceTokenFailed,        /*! \~chinese 绑定device token失败  \~english Bind device token failed */
EMErrorUserUnbindDeviceTokenFailed,      /*! \~chinese 解除device token失败 \~english Unbind device token failed */
EMErrorUserBindAnotherDevice,            /*! \~chinese 已经在其他设备上绑定了，不允许自动登录 \~english already bound to other device and auto login is not allowed*/
EMErrorUserLoginTooManyDevices,          /*! \~chinese 登录的设备数达到了上限 \~english User login on too many devices */
EMErrorUserMuted,                        /*! \~chinese 用户在群组或聊天室中被禁言 \~english User is muted in group or chatroom */
EMErrorUserKickedByChangePassword,       /*! \~chinese 用户已经修改了密码 \~english User has changed the password */
EMErrorUserKickedByOtherDevice,          /*! \~chinese 被其他设备踢掉了 \~english User was kicked out from other device */
EMErrorServerNotReachable ,         /*! \~chinese 服务器未连接 \~english Server is not reachable */
EMErrorServerTimeout,                    /*! \~chinese 服务器超时 \~english Server response timeout */
EMErrorServerBusy,                       /*! \~chinese 服务器忙碌 \~english Server is busy */
EMErrorServerUnknownError,               /*! \~chinese 未知服务器错误 \~english Unknown server error */
EMErrorServerGetDNSConfigFailed,         /*! \~chinese 获取DNS设置失败 \~english Get DNS config failed */
EMErrorServerServingForbidden,           /*! \~chinese 服务被禁用 \~english Service is forbidden */
EMErrorFileNotFound ,               /*! \~chinese 文件没有找到 \~english Cannot find the file */
EMErrorFileInvalid,                      /*! \~chinese 文件无效 \~english File is invalid */
EMErrorFileUploadFailed,                 /*! \~chinese 上传文件失败 \~english Upload file failed */
EMErrorFileDownloadFailed,               /*! \~chinese 下载文件失败 \~english Download file failed */
EMErrorFileDeleteFailed,                 /*! \~chinese 删除文件失败 \~english Delete file failed */
EMErrorFileTooLarge,                     /*! \~chinese 文件体积过大 \~english File too large */
EMErrorMessageInvalid ,             /*! \~chinese 消息无效 \~english Message is invalid */
EMErrorMessageIncludeIllegalContent,     /*! \~chinese 消息内容包含不合法信息 \~english Message contains invalid content */
EMErrorMessageTrafficLimit,              /*! \~chinese 单位时间发送消息超过上限 \~english Unit time to send messages over the upper limit */
EMErrorMessageEncryption,                /*! \~chinese 加密错误 \~english Encryption error */
EMErrorMessageRecallTimeLimit,           /*! \~chinese 消息撤回超过时间限制 \~english Unit time to send recall for message over the time limit */
EMErrorMessageExpired,                   /*! \~chinese 消息过期 \~english  The message has expired */
EMErrorGroupInvalidId ,             /*! \~chinese 群组ID无效 \~english Group Id is invalid */
EMErrorGroupAlreadyJoined,               /*! \~chinese 已加入群组 \~english User already joined the group */
EMErrorGroupNotJoined,                   /*! \~chinese 未加入群组 \~english User has not joined the group */
EMErrorGroupPermissionDenied,            /*! \~chinese 没有权限进行该操作 \~english User does not have permission to access the operation */
EMErrorGroupMembersFull,                 /*! \~chinese 群成员个数已达到上限 \~english Group's max member capacity reached */
EMErrorGroupNotExist,                    /*! \~chinese 群组不存在 \~english Group does not exist */
EMErrorGroupSharedFileInvalidId,         /*! \~chinese 共享文件ID无效 \~english Shared file Id is invalid */
EMErrorChatroomInvalidId ,          /*! \~chinese 聊天室ID无效 \~english Chatroom id is invalid */
EMErrorChatroomAlreadyJoined,            /*! \~chinese 已加入聊天室 \~english User already joined the chatroom */
EMErrorChatroomNotJoined,                /*! \~chinese 未加入聊天室 \~english User has not joined the chatroom */
EMErrorChatroomPermissionDenied,         /*! \~chinese 没有权限进行该操作 \~english User does not have operation permission */
EMErrorChatroomMembersFull,              /*! \~chinese 聊天室成员个数达到上限 \~english Chatroom's max member capacity reached */
EMErrorChatroomNotExist,                 /*! \~chinese 聊天室不存在 \~english Chatroom does not exist */
EMErrorCallInvalidId ,              /*! \~chinese 实时通话ID无效 \~english Call id is invalid */
EMErrorCallBusy,                         /*! \~chinese 已经在进行实时通话了 \~english User is busy */
EMErrorCallRemoteOffline,                /*! \~chinese 对方不在线 \~english Callee is offline */
EMErrorCallConnectFailed,                /*! \~chinese 实时通话建立连接失败 \~english Establish connection failure */
EMErrorCallCreateFailed,                 /*! \~chinese 创建实时通话失败 \~english Create a real-time call failed */
EMErrorCallCancel,                       /*! \~chinese 取消实时通话 \~english Cancel a real-time call */
EMErrorCallAlreadyJoined,                /*! \~chinese 已经加入了实时通话 \~english Has joined the real-time call */
EMErrorCallAlreadyPub,                   /*! \~chinese 已经上传了本地数据流 \~english The local data stream has been uploaded */
EMErrorCallAlreadySub,                   /*! \~chinese 已经订阅了该数据流 \~english The data stream has been subscribed */
EMErrorCallNotExist,                     /*! \~chinese 实时通话不存在 \~english The real-time do not exist */
EMErrorCallNoPublish,                    /*! \~chinese 实时通话没有已经上传的数据流 \~english Real-time calls have no data streams that have been uploaded */
EMErrorCallNoSubscribe,                  /*! \~chinese 实时通话没有可以订阅的数据流 \~english Real-time calls have no data streams that can be subscribed */
EMErrorCallNoStream,                     /*! \~chinese 实时通话没有数据流 \~english There is no data stream in the real-time call */
EMErrorCallInvalidTicket,                /*! \~chinese 无效的ticket \~english Invalid ticket */
EMErrorCallTicketExpired,                /*! \~chinese ticket已过期 \~english Ticket has expired */
EMErrorCallSessionExpired,               /*! \~chinese 实时通话已过期 \~english The real-time call has expired */
EMErrorCallInvalidParams ,          /*! \~chinese 无效的会议参数 \~invalid conference params */
EMErrorCallSpeakerFull,                   /*! \~chinese 主播个数已达到上限  */
EMErrorNoType
}

/// @nodoc 消息状态 int 类型数据转 Status
EMErrorCode fromEMErrorCode(int code) {
  if(code < 100)
    {
      return EMErrorCode.values[code-1];
    }
  else if(code < 200)
    {
      return EMErrorCode.values[code-95];
    }
  else if(code < 300)
    {
      return EMErrorCode.values[code-190];
    }
  else if(code < 400)
    {
    return EMErrorCode.values[code-272];
    }
  else if(code < 500)
  {
    return EMErrorCode.values[code-366];
  }
  else if(code < 600)
    {
      return EMErrorCode.values[code-460];
    }
  else if(code < 700)
  {
    return EMErrorCode.values[code-553];
  }
  else if(code < 800)
  {
    return EMErrorCode.values[code-647];
  }
  else if(code < 818)
    {
      return EMErrorCode.values[code-741];
    }
  else if(code == 818)
    {
      return EMErrorCode.EMErrorCallInvalidParams;
    }
  else if(code == 819)
    {
      return EMErrorCode.EMErrorCallSpeakerFull;
    }
  return EMErrorCode.EMErrorNoType;
}

/// @nodoc 消息状态 Status 类型数据转 int
int toEMErrorCode(EMErrorCode status) {
  int index = status.index;
  if(index >= 5)
    {
      if(index < 10)
        {
          index += 95;
        }
      else if(index < 28)
        {
          index += 190;
        }
      else if(index < 34)
        {
          index += 272;
        }
      else if(index < 40)
        {
          index += 366;
        }
      else if(index < 47)
        {
          index += 460;
        }
      else if(index < 53)
        {
          index += 553;
        }
      else if(index < 59)
        {
          index += 647;
        }
      else if(index < 75)
        {
          index += 741;
        }
      else if(index == 75)
        {
          index = 818;
        }
      else if(index == 76)
        {
          index = 819;
        }
    }

  return index;

}

class ChatItem extends StatefulWidget {
  final EaseMessageModel messageModel ;
  final ChatItemDelegate delegate;
  final bool showTime;
  final bool fromSearch;

  final ChatDelegate userDelegate;

  final  Map<String,ChatUserModel> _userInfoCache;

  ChatItem(this.userDelegate,this.delegate,this.messageModel, this.showTime,this._userInfoCache,{this.fromSearch = false});

  @override
  State<StatefulWidget> createState() {
    return  _ChatItemState();
  }

}

class _ChatItemState extends State<ChatItem> {
//  EMMessage message ;
//  ChatItemDelegate delegate;
//  bool showTime;
  int menuType;

  AnimationStatusListener _statusListener;

//
//   _ChatItemState() {
////    this.message = msg;
////    this.delegate = delegate;
////    this.showTime = showTime;
//  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _statusListener = (status)
    {
      if(status == AnimationStatus.forward)
      {
        menuType = -1;
      }
      else if(status == AnimationStatus.dismissed)
        {
          if(menuType != -1)
            {
              __onLongPressMessage(menuType);
            }
          menuType = -1;
        }
    };

    menuType = -1;
    String messageSender = widget.messageModel.message.from;
    if(widget.userDelegate != null  && widget.messageModel.userModel == null && messageSender != null)
      {
        var model = widget.messageModel;
        widget.userDelegate.getUserInfo(messageSender).then((userInfo)
        {
          if(userInfo != null) {
            widget._userInfoCache[userInfo.userId] = userInfo;
            if (model.userModel == null && model.message.from == userInfo.userId) {
              model.userModel = userInfo;
              if (identical(model, widget.messageModel) && mounted) {
                setState(() {});
              }
            }
            if (widget.messageModel.userModel == null && widget.messageModel.message.from == userInfo.userId && mounted) {
              setState(() {
                widget.messageModel.userModel = userInfo;
              });
            }
          }

        });
      }

  }

  @override
  void didUpdateWidget(ChatItem oldWidget) {
    // TODO: implement didUpdateWidget

    String messageSender = widget.messageModel.message.from;

    if(widget.userDelegate != null && !identical(oldWidget.messageModel, widget.messageModel) && widget.messageModel.userModel == null && messageSender != null)
      {
        var model = widget.messageModel;
         widget.userDelegate.getUserInfo(messageSender).then((userInfo)
         {
           if(userInfo != null) {
             widget._userInfoCache[userInfo.userId] = userInfo;
             if (model.userModel == null && model.message.from == userInfo.userId) {
               model.userModel = userInfo;
               if (identical(model, widget.messageModel) && mounted) {
                 setState(() {});
               }
             }
             if (widget.messageModel.userModel == null && widget.messageModel.message.from == userInfo.userId && mounted) {
               setState(() {
                 widget.messageModel.userModel = userInfo;
               });
             }
           }

         });
      }


    super.didUpdateWidget(oldWidget);
  }


  @override
  Widget build(BuildContext context) {

      return Container(
      padding: EdgeInsets.fromLTRB(10, 4, 10, 0),
      child:Column(
        children: <Widget>[
          if(widget.showTime)
            WidgetUtil.buildMessageTimeWidget(widget
              .messageModel.message
              .localTime),

        if(widget.messageModel.isRecallMsg)  //消息撤回
          Container(
             padding:EdgeInsets.only(top: 6,bottom: 6),
              child: Center(child: Text((widget.messageModel.message.body as EMTextMessageBody).message,
                style: TextStyle(fontSize: 13,color: Color(0xffB0B2B5)),)))
         else
          Row(
            children: <Widget>[
              subContent()
            ],
          )
        ],
      ),
    );
  }

  Widget subContent() {

    var maxWidth = MediaQuery.of(context).size.width - EMLayout
        .emConListPortraitSize * 2 - 16;

    if (widget.messageModel.message.direction == Direction.SEND) {

      Widget messageBodyWidget;
      if(widget.messageModel.message.status == Status.SUCCESS)
        {
          messageBodyWidget = Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                constraints: BoxConstraints(
                    maxWidth: maxWidth
                ),
                child: buildMessageWidget(),
              ),
            ],
          );
        }
      else if(widget.messageModel.message.status == Status.FAIL)
        {
          messageBodyWidget =
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
           children: <Widget>[
             GestureDetector(
               onTap: __onTapFailItem,
               child: Container(
                 child: Icon(Icons.error,color: Colors.red,),
                 padding: EdgeInsets.only(bottom: 6),
               ),
             ),

             Padding(padding: EdgeInsets.only(right: 1),),
             Container(
               constraints: BoxConstraints(
                 maxWidth: maxWidth
               ),
               child: buildMessageWidget(),
             ),
           ],
          );
        }
      else
        {
          messageBodyWidget =
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
              Container(
                  child:CupertinoActivityIndicator(radius: 8,),
                padding: EdgeInsets.only(bottom: 6),
              ),
                  Padding(padding: EdgeInsets.only(right: 1),),
                  Container(
                    constraints: BoxConstraints(
                        maxWidth: maxWidth
                    ),
                    child: buildMessageWidget(),
                  ),
                ],
              );
        }


      return Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: messageBodyWidget
//              Column(
//                children: <Widget>[
//
//                  Offstage(
//                    offstage: widget.messageModel.message.chatType != ChatType.Chat,
//                    child: Container(
//                      alignment: Alignment.centerRight,
//                      padding: EdgeInsets.fromLTRB(0, 0, 12, 0),
//                      child: Text(widget.messageModel.userModel == null ? '读取中' : widget.messageModel.userModel.nickname ,style: TextStyle(fontSize:
//                      11,color:
//                      Color(0xff9B9B9B))
//                      ),
//                    ),
//                  ),
//
//
//                ],
//              ),
            ),
            GestureDetector(
              onTap: () {
                __onTapedUserPortrait();
              },
              onLongPress: ()
              {
                __onLongPressUserPortrait();
              },
              child: WidgetUtil.buildUserPortrait(widget.messageModel.userModel),
            ),
          ],
        ),
      );
    }
    else if (widget.messageModel.message.direction == Direction.RECEIVE) {
      return Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                __onTapedUserPortrait();
              },
              onLongPress: ()
              {
                __onLongPressUserPortrait();
              },
              child: WidgetUtil.buildUserPortrait(widget.messageModel.userModel),
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  Offstage(
                    offstage: widget.messageModel.message.chatType ==
                        ChatType.Chat,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
                      child: Text(widget.messageModel.userModel == null ? '读取中' : widget.messageModel.userModel.nickname,style: TextStyle(fontSize:
                      11,color:
                      Color(0xff9B9B9B))),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        constraints: BoxConstraints(
                            maxWidth: maxWidth
                        ),
                        child: buildMessageWidget(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    else {
      return WidgetUtil.buildEmptyWidget();
    }
  }


  Widget buildMessageWidget() {

    EMMessageType msgType = widget.messageModel.message.type;

   int localTime = int.parse(widget.messageModel.message.localTime);
   int currentTime = DateTime.now().millisecondsSinceEpoch;

//    0 删除 1 复制 2 转发  3 撤回

    List <Widget> menusWidget = [];
    if (msgType == EMMessageType.TXT) {
      menusWidget.add(CupertinoContextMenuAction(
        child: const Text('复制', style: TextStyle(fontSize: 15)),
        trailingIcon: Icons.content_copy,
        onPressed: () {
          menuType = 1;
          Navigator.pop(context);
          __onLongPressMessage(1);
        },
      ));
    }

    if (!widget.fromSearch && EaseUIOptions.needRetransmit) {
      if (msgType != EMMessageType.VOICE) {
        menusWidget.add(CupertinoContextMenuAction(
          child: const Text('转发给朋友', style: TextStyle(fontSize: 15)),
          trailingIcon: Icons.reply,
          onPressed: () {
            menuType = 2;
            Navigator.pop(context);

          },
        ));
      }

      if ((currentTime - localTime) / 1000.0 < 300) {
        menusWidget.add(CupertinoContextMenuAction(
          child: const Text('撤回', style: TextStyle(fontSize: 15)),
          trailingIcon: Icons.cancel,
          onPressed: () {
            menuType = 3;
            Navigator.pop(context);
          },
        ));
      }


      menusWidget.add(CupertinoContextMenuAction(
        isDestructiveAction: true,
        child: const Text(
            '删除', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        trailingIcon: Icons.delete_forever,
        onPressed: () {
          menuType = 0;
          Navigator.pop(context);
        },
      ));
    }

    return
      Container(
        padding: EdgeInsets.fromLTRB(2, 4, 2, 10),
//        alignment: widget.message.direction == Direction.SEND
//            ? Alignment.centerRight
//            : Alignment.centerLeft,
          child:

          menusWidget.isEmpty ? FittedBox(
            child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  __onTapedMesssage();
                },
                child: MessageItemFactory(messageModel: widget.messageModel)),
            fit: BoxFit.contain,
          ) :
          CupertinoContextMenu(
            previewBuilder: (BuildContext context,
            Animation<double> animation,
            Widget child,)
            {
              animation.removeStatusListener(_statusListener);
              animation.addStatusListener(_statusListener);
              return child;
            },
          child:
//          widget.messageModel.message.type == EMMessageType.TXT ?
//          MessageItemFactory(messageModel: widget.messageModel):
          FittedBox(
            child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  __onTapedMesssage();
                },
                child: MessageItemFactory(messageModel: widget.messageModel)),
            fit: BoxFit.contain,
          ),
          actions: menusWidget,
        ));
  }


  void __onTapedMesssage() {
    if(widget.delegate != null) {
      widget.delegate.onTapMessageItem(widget.messageModel);
    }else {
      print("没有实现 ConversationItemDelegate");
    }
  }

  void __onLongPressMessage(int type) {
    if(widget.delegate != null) {
      widget.delegate.onLongPressMessageItem(widget.messageModel,type);
    }else {
      print("没有实现 ConversationItemDelegate");
    }
  }

  void __onTapedUserPortrait() {
    if(widget.delegate != null) {
      widget.delegate.onTapUserPortrait(widget.messageModel);
    }else {
      print("没有实现 ConversationItemDelegate");
    }
  }

  void __onLongPressUserPortrait() {
    if(widget.delegate != null) {
      widget.delegate.onLongPressUserPortrait(widget.messageModel);
    }else {
      print("没有实现 ConversationItemDelegate");
    }
  }

  void __onTapFailItem()
  {
    if(widget.delegate != null) {
      widget.delegate.onTapFailItem(widget.messageModel);
    }else {
      print("没有实现 ConversationItemDelegate");
    }
  }

}

abstract class ChatItemDelegate {
  //点击消息
  void onTapMessageItem(EaseMessageModel messageModel);
  //长按消息  menuType 0 删除 1 复制 2 转发  3 撤回
  void onLongPressMessageItem(EaseMessageModel messageModel,int menuType);
  //点击用户头像
  void onTapUserPortrait(EaseMessageModel messageModel);

  //长按用户头像
  void onLongPressUserPortrait(EaseMessageModel messageModel);

  //点击发送失败图标
  void onTapFailItem(EaseMessageModel messageModel);

}