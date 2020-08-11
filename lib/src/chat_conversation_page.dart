

import 'dart:collection';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:works_utils/works_utils.dart';

import 'package:toast/toast.dart';
import '../works_ease_ui.dart';
import 'itmes/ease_conversation_model.dart';

class ChatConversationPageScaffold extends CupertinoPageScaffold {

  final ChatDelegate delegate;  //用于获取用户信息等的接口（代理）
  final String currentUserId;  //当前用户id

  final String title;   //navigation bar title;

  final Color titleColor;

  final List<Widget> customWidgets; //自定义的控件，放在会话列表的顶部

  @override
  // TODO: implement navigationBar
  ObstructingPreferredSizeWidget get navigationBar => WorksCupertinoNavigationBar(
    border: null,
    middle: FittedBox(
      fit: BoxFit.contain,child:Text(this.title,style: TextStyle(color: this.titleColor),)),
  );


  const ChatConversationPageScaffold(
      this.title,
      this.delegate,
      {Key key,
        this.currentUserId,
        this.customWidgets,
        this.titleColor = Colors.white,
      })
      : super(key: key, child: const Text(''));

  @override
  // TODO: implement child
  Widget get child => AnnotatedRegion<SystemUiOverlayStyle>(
      value: EaseUIOptions.statusStyle,
      child:
      SafeArea(
          top: false,
          child:
          ChatConversationPage(
            this.delegate,
            this.customWidgets,
            currentUserId: this.currentUserId,
          )));
}


class ChatConversationPage extends StatefulWidget {

  final ChatDelegate delegate;
  final String currentUserId;  //当前用户id
  final List<Widget> customWidgets;

  const ChatConversationPage(
      this.delegate,
      this.customWidgets,
      {Key key,this.currentUserId})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChatConversationPage();
}

class _ChatConversationPage extends State<ChatConversationPage>
    implements EMMessageListener
{

  List<EaseConversationModel> _conversations = List(); //会话数组;

  Map<String,ChatUserModel> userInfoCache = HashMap();

  Map<String,String> groupNameCache = HashMap();

  final SlidableController slidableController = SlidableController();

  String currentUserId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    DartNotificationCenter.subscribe(channel: EaseUIOptions.CHAT_GROUP_NAME_CHANGED_EVENT,observer: this,onNotification: groupNameChanged);
    DartNotificationCenter.subscribe(channel: EaseUIOptions.CHAT_CONVERSATION_REFRESH_EVENT,observer: this,onNotification:(_)=>getConversationList());
    currentUserId = widget.currentUserId;
    EMClient.getInstance().chatManager().addMessageListener(this);
//    EMClient.getInstance().chatManager().onConversationUpdate(() => print('onConversationUpdatexxxx'));
    DartNotificationCenter.subscribe(channel: EaseUIOptions.CHAT_EXIT_EVENT,observer: this,onNotification:(options)=>getConversationList());
    getConversationList();

  }

  void groupNameChanged(dynamic groupInfo)
  {
    if(mounted)
      {
        setState(() {
          _conversations.forEach((element) {
            if(element.conversation.type == EMConversationType.GroupChat && element.conversation.conversationId == groupInfo['groupId'])
              {
                element.groupName = groupInfo['name'];
                groupNameCache[element.conversation.conversationId] = element.groupName;
              }
          });
        });
      }
  }


void getConversationList()
  {
    EMClient.getInstance().chatManager().getAllConversations().then((allConversation)
       async {
         List<EaseConversationModel> conversations = List();

         if(currentUserId == null)
           {
             currentUserId = await EMClient.getInstance().getCurrentUser();
           }
         for(EMConversation conversation in allConversation)
         {
           EMMessage lastMessage = await conversation.getLastMessage();
           if(lastMessage != null)
           {
             var model = EaseConversationModel(conversation,lastMessage);

             if(conversation.type == EMConversationType.GroupChat && lastMessage.ext() != null && lastMessage.ext().containsKey(EaseUIOptions.CHAT_GROUP_MESSAGE_At_LIST))
             {
               List atList = lastMessage.ext()[EaseUIOptions.CHAT_GROUP_MESSAGE_At_LIST];
               if(currentUserId != null && currentUserId.isNotEmpty)
               {
                 atList.forEach((element) {
                   if(element == currentUserId)
                   {
                     model.isAt = true;
                   }

                 });
               }
             }

             if(conversation.type == EMConversationType.Chat && userInfoCache.containsKey(conversation.conversationId))
             {
               model.userModel = userInfoCache[conversation.conversationId];
             }
             else if(conversation.type == EMConversationType.GroupChat && groupNameCache.containsKey(conversation.conversationId))
             {
               model.groupName = groupNameCache[conversation.conversationId];
             }
             conversations.add(model);
           }

         }
        if(mounted) {
          setState(()  {
            _conversations.clear();
            _conversations.addAll(conversations);
          });
        }

      });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    int total = _conversations.length;
    int initialIndex = 0;
    if(widget.customWidgets != null)
      {
        total += widget.customWidgets.length;
        initialIndex += widget.customWidgets.length;
      }
    return ListView.builder(
      itemBuilder: (BuildContext context1, int index) {

        if(index < initialIndex)
          {
            return widget.customWidgets[index];
          }

        var model = _conversations[index - initialIndex];

        return
          Slidable(
            key: Key(model.conversation.conversationId),
            controller: slidableController,
            dismissal: SlidableDismissal(
              child: SlidableDrawerDismissal(),
            ),
            actionPane: SlidableScrollActionPane(),
            actionExtentRatio: 0.2,
            child: _ConversationItem(model, widget.delegate,currentUserId,userInfoCache,groupNameCache,()
            {

              if(slidableController.activeState != null)
                {
                  if((slidableController.activeState.widget.key as ValueKey).value == model.conversation.conversationId)
                    {
                      slidableController.activeState.close();
                      return;
                    }
                  slidableController.activeState.close();
                }
              Navigator.of(context,rootNavigator: true).push(
                  CupertinoPageRoute<void>(builder: (BuildContext context) {
                    return
                      ChatPageScaffold(model.conversation.conversationId, _conversations[index - initialIndex].conversation.type, widget.delegate, currentUserId:currentUserId);
                  }
                  )
              );


            }),
//            actions: <Widget>[
//              IconSlideAction(
//                caption: 'Archive',
//                color: Colors.blue,
//                icon: Icons.archive,
//                onTap: () => print('Archive'),
//              ),
//              IconSlideAction(
//                caption: 'Share',
//                color: Colors.indigo,
//                icon: Icons.share,
//                onTap: () => print('Share'),
//              ),
//            ],
            secondaryActions: <Widget>[
              IconSlideAction(
                caption: '删除',
                color: Colors.red,
                icon: Icons.delete,
                onTap: () {
                  showCupertinoDialog<bool>(
                      context: context,
                      builder: (ctx)
                      {
                        var dialog = CupertinoAlertDialog(
                          content: Text('删除后，将清空该聊天的消息记录',
                            style: TextStyle(color: const Color(0xff333333),fontSize: 15,),
                            strutStyle: StrutStyle(forceStrutHeight: true, height: 2,),
                          ),
                          actions: <Widget>[
                            CupertinoDialogAction(
                              onPressed: ()
                              {
                                Navigator.pop(ctx);
                              },
                              child: Text('取消'),
                            ),
                            CupertinoDialogAction(
                              isDestructiveAction:true,
                              onPressed: ()
                              {
                                Navigator.pop(ctx);
                                EMClient.getInstance().chatManager().deleteConversation(model.conversation.conversationId, true).then((success){
                                  if(success)
                                    {
                                    if (mounted) {
                                      setState(() {
                                        _conversations.remove(model);
                                      });
                                    }
                                    }
                                  else
                                    {
                                      Toast.show("删除会话失败!", context,gravity: Toast.CENTER,backgroundRadius: 8);
                                    }
                                });
                              },
                              child: Text('删除'),
                            ),
                          ],
                        );
                        return dialog;
                      }
                  );
                },
              ),
            ],
          );
      },
      itemCount:total
    );
  }


  @override
  void dispose() {
    // TODO: implement dispose

    EMClient.getInstance().chatManager().removeMessageListener(this);
    DartNotificationCenter.unsubscribe(observer: this,);
    super.dispose();

  }

  @override
  void onCmdMessageReceived(List<EMMessage> messages) {
    // TODO: implement onCmdMessageReceived
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
  void onMessageReceived(List<EMMessage> messages)  {
    // TODO: implement onMessageReceived
     getConversationList();
  }
}

class _ConversationItem extends StatefulWidget
{
//  easeuiImages/chat/chat_group_default.png

  final EaseConversationModel conversationModel;
  final String currentUserId;  //当前用户id

  final ChatDelegate userDelegate;

  final Map<String,ChatUserModel> userInfoCache;
  final Map<String,String> groupNameCache;
  final GestureTapCallback tapCallback;

  _ConversationItem(this.conversationModel,this.userDelegate,this.currentUserId,this.userInfoCache,this.groupNameCache,this.tapCallback);

  @override
  State<StatefulWidget> createState() {
    return  __ConversationItem();
  }
}

class __ConversationItem extends State<_ConversationItem>
{

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    updateConversationInfo();
  }

  Widget buildUserPortrait() {
    Widget portraitWidget;

    if(widget.conversationModel.conversation.type == EMConversationType.Chat)
      {
        ChatUserModel model = widget.conversationModel.userModel;
        if(model != null) {
          if (model.avatarURLPath != null && model.avatarURLPath.isNotEmpty) {
            portraitWidget = CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl: model.avatarURLPath,
              placeholder: (context,url)
              {
                return Icon(Icons.account_box,size: 45,color: Colors.black12,);
              }
            );
          } else if (model.avatarFilePath != null && model.avatarFilePath.isNotEmpty) {
            portraitWidget = Image.asset(
              model.avatarFilePath,
              fit: BoxFit.cover,
            );
          }
        }

        if (portraitWidget == null) {
          portraitWidget = Image.asset(EaseUIOptions.msgUserHead ?? "easeuiImages/chat/default_header.png", package: EaseUIOptions.msgUserHead == null ? EaseUIOptions.packageName : null, fit: BoxFit.cover);
        }
      }
    else
      {
        portraitWidget = Image.asset(EaseUIOptions.msgGroupHead ?? "easeuiImages/chat/chat_group_default.png", package: EaseUIOptions.msgGroupHead == null ? EaseUIOptions.packageName : null, fit: BoxFit.cover);
      }



    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        height: 45,
        width: 45,
        child: portraitWidget,
      ),
    );
  }



  void updateConversationInfo()
  {
    EMConversation conversation = widget.conversationModel.conversation;
    var model = widget.conversationModel;
    if(conversation.type == EMConversationType.Chat)
    {
      String messageSender = conversation.conversationId;
      if(widget.userDelegate != null  && model.userModel == null && messageSender != null)
      {
        widget.userDelegate.getUserInfo(messageSender).then((userInfo)
        {

          if(userInfo != null) {
            widget.userInfoCache[userInfo.userId] = userInfo;
            if (model.userModel == null && model.conversation.conversationId == userInfo.userId) {
              model.userModel = userInfo;

              if (identical(model, widget.conversationModel) && mounted) {
                setState(() {});
              }
            }
            if (widget.conversationModel.userModel == null && widget.conversationModel.conversation.conversationId == userInfo.userId && mounted) {
              setState(() {
                widget.conversationModel.userModel = userInfo;
              });
            }
          }

        });
      }
    }
    else
    {
      if(widget.conversationModel.groupName == null)
      {

        EMClient.getInstance().groupManager().getGroup(conversation.conversationId).then((group)
        {
          if(group != null && group.getGroupName() != null && group.getGroupName().isNotEmpty) {

            widget.groupNameCache[group.getGroupId()] = group.getGroupName();

            if (model.groupName == null && model.conversation.conversationId == group.getGroupId()) {
              model.groupName = group.getGroupName();
              if (widget.conversationModel.conversation.conversationId == group.getGroupId() && mounted) {
                setState(() {});
              }
            }
            if (widget.conversationModel.groupName == null && widget.conversationModel.conversation.conversationId == group.getGroupId() && mounted) {
              setState(() {
                widget.conversationModel.groupName = group.getGroupName();
              });
            }

          }
          else
            {
              model.groupName = "";
                EMClient.getInstance().groupManager().getGroupFromServer(conversation.conversationId).then((serverGroup){
                  if(serverGroup != null) {
                    if(serverGroup.getGroupName() != null && serverGroup.getGroupName().isNotEmpty)
                    {
                      widget.groupNameCache[serverGroup.getGroupId()] = serverGroup.getGroupName();
                      if (model.groupName == null && model.conversation.conversationId == serverGroup.getGroupId()) {
                        model.groupName = serverGroup.getGroupName();
                        if (widget.conversationModel.conversation.conversationId == serverGroup.getGroupId() && mounted) {
                          setState(() {});
                        }
                      }
                      if (widget.conversationModel.groupName == null && widget.conversationModel.conversation.conversationId == serverGroup.getGroupId() && mounted) {
                        setState(() {
                          widget.conversationModel.groupName = serverGroup.getGroupName();
                        });
                      }
                    }

                  }
                });

            }
        });

      }
    }
  }


  @override
  void didUpdateWidget(_ConversationItem oldWidget) {
    // TODO: implement didUpdateWidget


    if(!identical(oldWidget.conversationModel, widget.conversationModel))
      {
        updateConversationInfo();
      }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    String titleText = " ";

    if(widget.conversationModel.conversation.type == EMConversationType.Chat)
      {
        if(widget.conversationModel.userModel != null)
          {
            titleText = widget.conversationModel.userModel.nickname ?? "";
          }
      }
    else
      {
        titleText = widget.conversationModel.groupName ?? "";
      }



    return
      BaseCell(
        tapCallback: widget.tapCallback,
        child:
        Container(
            height: 65,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 12),
                      ),
                      buildUserPortrait(),
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              height: 24,
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                      child: Text(
                                    titleText,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 16, color: const Color(0xFF333333)),
                                  )),
                                  Padding(
                                    padding: EdgeInsets.only(left: 4),
                                  ),
                                  Text(
                                    widget.conversationModel.lastTime,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 12, color: const Color(0xFFAAAAAA)),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              height: 20,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    child: widget.conversationModel.isAt
                                        ? RichText(
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      text: TextSpan(
                                          text: '[有人@你]',
                                        style: TextStyle(color: Colors.red, fontSize: 13.0),
                                          children: <TextSpan>[
                                              TextSpan(
                                                text: widget.conversationModel.detailText,
                                                style: TextStyle(fontSize: 13, color: const Color(0xFFAAAAAA)),
                                              )
                                            ]),
                                    ):
                                    Text(
                                      widget.conversationModel.detailText,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 13, color: const Color(0xFFAAAAAA)),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 4),
                                  ),
                                  Visibility(
                                    visible: widget.conversationModel.conversation.unreadMessagesCount > 0,
                                    child: Container(
                                      padding: EdgeInsets.only(left: 5, right: 5),
                                      margin: EdgeInsets.only(top: 2),
                                      constraints: BoxConstraints(minWidth: 17),
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(const Radius.circular(8.5)),
                                        color: Colors.red,
                                      ),
                                      height: 17,
                                      child: Center(
                                          child: Text(
                                        widget.conversationModel.conversation.unreadMessagesCount > 999 ? '999+' : '${widget.conversationModel.conversation.unreadMessagesCount}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 12, color: Colors.white),
                                      )),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 12),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: const Color(0xFFF0F2F5),
                  indent: 12,
                  endIndent: 12,
                  height: 1,
                  thickness: 1,
                ),
              ],
            )
        )
    );
  }

}
