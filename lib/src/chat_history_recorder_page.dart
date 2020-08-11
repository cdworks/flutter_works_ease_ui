

import 'dart:collection';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:works_utils/works_utils.dart';

import '../works_ease_ui.dart';
import 'search_chat_page.dart';

class ChatSearchHistoryMessagePageScaffold extends CupertinoPageScaffold {

  final ChatDelegate delegate;  //用于获取用户信息等的接口（代理）
  final String currentUserId;  //当前用户id

  final String conversationId;
  final bool isGroup;
  final Color titleColor;


  @override
  // TODO: implement navigationBar
  ObstructingPreferredSizeWidget get navigationBar => WorksCupertinoNavigationBar(
    border: null,
    middle: FittedBox(
        fit: BoxFit.contain,child:Text('查找聊天记录',style: TextStyle(color: titleColor),)),
  );


  const ChatSearchHistoryMessagePageScaffold(
      this.delegate,
      this.conversationId,
      {Key key,
        this.currentUserId,
        this.isGroup = false,
        this.titleColor = Colors.white,
      })
      : super(key: key, child: const Text(''));

  @override
  // TODO: implement child
  Widget get child => AnnotatedRegion<SystemUiOverlayStyle>(
      value: EaseUIOptions.statusStyle,
      child:
      SafeArea(
          top: true,
          child:
          ChatSearchHistoryMessagePage(
            this.isGroup,
            this.delegate,
            this.conversationId,
            this.titleColor,
            currentUserId: this.currentUserId,
          )
      ));
}


class ChatSearchHistoryMessagePage extends StatefulWidget {

  final ChatDelegate delegate;
  final String currentUserId;  //当前用户id
  final String conversationId;
  final bool isGroup;
  final Color titleColor;

  const ChatSearchHistoryMessagePage(
      this.isGroup,
      this.delegate,
      this.conversationId,
      this.titleColor,
      {Key key,this.currentUserId})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChatSearchHistoryMessage();
}

class _HistoryMessageModel
{
  ChatUserModel userModel;
  final EMMessage message;

  String detailText;



  _HistoryMessageModel(this.message)
  {
    EMMessageBody messageBody = this.message.body;
    detailText = '';
    switch(this.message.type)
    {
      case EMMessageType.TXT:
        detailText = (messageBody as EMTextMessageBody).message;
        break;
      case EMMessageType.IMAGE:
        detailText = '[图片]';
        break;
      case EMMessageType.VOICE:
        detailText = '[语音]';
        break;
      case EMMessageType.LOCATION:
        detailText = '[位置]';
        break;
      case EMMessageType.VIDEO:
        detailText = '[视频]';
        break;
      case EMMessageType.FILE:
        detailText = '[文件]';
        break;
      default:
        break;
    }
  }
}

class _ChatSearchHistoryMessage extends State<ChatSearchHistoryMessagePage>
{

  TextEditingController textController = TextEditingController();

  EMConversation _conversation;

  List<_HistoryMessageModel> resultsSource = [];

  bool hasMore = false;

  bool isLoading = false;



  Map<String,ChatUserModel> userInfoCache = HashMap();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _conversation = EMConversation(widget.conversationId);
  }

  void setSearchData(String text)
  {
    if(mounted)
    {
      if(text == null || text.isEmpty)
      {
        setState(() {
          resultsSource.clear();
        });
      }
      else
      {
        setState(() {
          resultsSource.clear();
        });

         _conversation.searchMsgFromDB(text, DateTime.now().millisecondsSinceEpoch, 30,EMSearchDirection.Up).then((value)
         {
           print('value:$value');
            if(value != null)
              {

                List<_HistoryMessageModel> models = [];
                value.forEach((element)
                {
                  if(userInfoCache.containsKey(element.from))
                    {
                      var model = _HistoryMessageModel(element);
                      model.userModel = userInfoCache[element.from];
                      models.add(model);
                    }
                  else
                    {
                      models.add(_HistoryMessageModel(element));
                    }
                });

                if(mounted) {
                  setState(() {
                    if (value.length < 30) {
                      hasMore = false;
                    }
                    else {
                      hasMore = true;
                    }
                    resultsSource.addAll(models.reversed);
                  });
                }

              }
         });
      }
    }
  }

  void loadMore()
  {
    if(!isLoading) {
      if (resultsSource.isNotEmpty) {
        isLoading = true;
        _conversation.searchMsgFromDB(
            textController.text, int.parse(resultsSource.last.message.msgTime),
            30, EMSearchDirection.Up).then((value) {
              isLoading = false;
          if (value != null) {
            List<_HistoryMessageModel> models = [];
            value.forEach((element) {
              if (userInfoCache.containsKey(element.from)) {
                var model = _HistoryMessageModel(element);
                model.userModel = userInfoCache[element.from];
                models.add(model);
              }
              else {
                models.add(_HistoryMessageModel(element));
              }
            });

            if (mounted) {
              setState(() {
                if (value.length < 30) {
                  hasMore = false;
                }
                else {
                  hasMore = true;
                }
                resultsSource.addAll(models.reversed);
              });
            }
          }
        });
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build


    int total = resultsSource.length;
    if(hasMore)
      {
        total += 1;
      }
    return
      Container(
          child:
          Column(
            children: <Widget>[
              Column(children: <Widget>[
                Container(
                  height: 56,
                  padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
                  child: WorksSearchBar(
                    controller: textController,
                    padding: EdgeInsets.all(8),
                    placeHold: '输入搜索内容',
                    didBeginEditing: () {
                      print('didBeginEditing');
                    },
                    didEndEditing: () {
                      print('didEndEditing');
                    },
                    searchButtonClicked: (text) {},
                    cancelButtonClicked: () {
                      print('cancelButtonClicked');
                    },
                    textDidChange: (text) {

                      setSearchData(text);
                      print('did change:$text');
                    },
                  ),
                ),
                Divider(
                  height: 6,
                  thickness: 6,
                  color: const Color(0xFFf0f2f5),
                )
              ]),
              Expanded(
                child:  NotificationListener<ScrollStartNotification>(
                  onNotification: (scrollNotification) {
                    if(scrollNotification.dragDetails != null)
                    {
                      FocusScope.of(context).requestFocus(FocusNode());
                    }
                    return true;
                  },
                  child: ListView.builder(
                    
                      itemBuilder: (BuildContext context, int index) {

                        if(index < resultsSource.length) {
                          return _ConversationItem(
                            resultsSource[index],
                            widget.delegate,
                            widget.currentUserId,
                            userInfoCache,
                                () {
                                  Navigator.of(context, rootNavigator: true).push(
                                      CupertinoPageRoute<void>(builder: (BuildContext context) {
                                        return
                                          SearchChatPageScaffold(
                                            resultsSource[index].message,
                                            widget.conversationId,
                                            widget.isGroup ? EMConversationType.GroupChat : EMConversationType.Chat,
                                            widget.delegate,
                                            currentUserId: widget.currentUserId,
                                            titleColor: widget.titleColor,);
                                      }
                                      )
                                  );
                            },
                          );
                        }
                        return
                            GestureDetector(
                              onTap: loadMore,
                              child: Container(
                                height: 50,
                                child:
                                    Stack(
                                      children: <Widget>[
                                        Center(child: Text('点击加载更多',style: TextStyle(fontSize: 16,color: Colors.black),),),
                                        Positioned(left: 0,right: 0,bottom: 0,child: Divider(
                                          color: const Color(0xFFF0F2F5),
                                          indent: 12,
                                          endIndent: 12,
                                          height: 1,
                                          thickness: 1,
                                        ),)
                                      ],
                                    ),
                              ),
                            );

                      },
                      itemCount: total),
                ),
              )
            ],
          ),
      );
  }
}

class _ConversationItem extends StatefulWidget
{
//  easeuiImages/chat/chat_group_default.png

  final _HistoryMessageModel model;
  final String currentUserId;  //当前用户id

  final ChatDelegate userDelegate;

  final Map<String,ChatUserModel> userInfoCache;
  final GestureTapCallback tapCallback;

  _ConversationItem(this.model,this.userDelegate,this.currentUserId,this.userInfoCache,this.tapCallback);

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

    ChatUserModel model = widget.model.userModel;
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
    var model = widget.model;
    String messageSender = model.message.from;
    if(widget.userDelegate != null  && model.userModel == null && messageSender != null)
    {
      widget.userDelegate.getUserInfo(messageSender).then((userInfo)
      {

        if(userInfo != null) {
          widget.userInfoCache[userInfo.userId] = userInfo;
          if (model.userModel == null && model.message.from == userInfo.userId) {
            model.userModel = userInfo;

            if (identical(model, widget.model) && mounted) {
              setState(() {});
            }
          }
          if (widget.model.userModel == null && widget.model.message.from == userInfo.userId && mounted) {
            setState(() {
              widget.model.userModel = userInfo;
            });
          }
        }

      });
    }
  }


  @override
  void didUpdateWidget(_ConversationItem oldWidget) {
    // TODO: implement didUpdateWidget


    if(!identical(oldWidget.model, widget.model))
    {
      updateConversationInfo();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    String titleText = " ";

    if(widget.model.userModel != null)
    {
      titleText = widget.model.userModel.nickname ?? "";
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
                                      WorksDateFormat.formatterTimestamp(int.parse(widget.model.message.msgTime)),
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
                                      child:
                                      Text(
                                        widget.model.detailText,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 13, color: const Color(0xFFAAAAAA)),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 4),
                                    ),
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