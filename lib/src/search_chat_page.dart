

import 'dart:collection';
import 'dart:io';
import 'dart:math';

import 'package:asset_picker/asset_picker.dart';
import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:works_utils/works_utils.dart';


import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import 'package:works_amap_map/works_amap_map_export.dart';
import 'chat_group_member_page.dart';
import 'chat_widget_util.dart';
import 'ease_ui_options.dart';
import 'chat_delegate.dart';
import 'itmes/chat_item.dart';
import 'itmes/bottom_input_bar.dart';
import 'package:toast/toast.dart';
import 'package:works_file_picker/works_file_picker.dart';

import 'itmes/ease_message_model.dart';


class SearchChatPageScaffold extends CupertinoPageScaffold {
  final String conversationTitle;  //群聊 为群组名 单聊 好友昵称
  final String userHeadImageUrl;   //单聊 好友头像
  final String conversationChatter;
  final EMConversationType conversationType;

  final EMMessage message;

  final Color titleColor;

  final ChatDelegate delegate;  //用于获取用户信息等的接口（代理）
  final String currentUserId;  //当前用户id




  @override
  // TODO: implement navigationBar
  ObstructingPreferredSizeWidget get navigationBar {

    return WorksCupertinoNavigationBar(
//        isAutoWrapWithBackground: true,
        border: null,
        middle: _MiddleTitleWidget(titleColor: titleColor,
          conversationType: conversationType,
          conversationChatter: conversationChatter,
          conversationTitle: conversationTitle,
          delegate: delegate,),
    );
  }

  const SearchChatPageScaffold(
      this.message,
      this.conversationChatter,
      this.conversationType,
      this.delegate,
      {Key key,
        this.currentUserId,
        this.conversationTitle,
        this.userHeadImageUrl,
        this.titleColor = Colors.white
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
          SearchChatPage(
            this.message,
            this.delegate,
            this.conversationChatter,
            this.conversationType,
            this.titleColor,
            conversationTitle: this.conversationTitle,
            userHeadImageUrl: this.userHeadImageUrl,
            currentUserId: this.currentUserId,
          )));
}


class _MiddleTitleWidget extends StatefulWidget
{
  final Color titleColor;
  final EMConversationType conversationType;
  final String conversationChatter;
  final String conversationTitle;
  final ChatDelegate delegate;

  const _MiddleTitleWidget({Key key, this.titleColor, this.conversationType, this.conversationChatter,this.conversationTitle,this.delegate}) : super(key: key);


  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return __MiddleTitleWidgetState();
  }
}

class __MiddleTitleWidgetState extends State<_MiddleTitleWidget>
{

  String conversationTitle;

  Future<EMGroup> getGroupName() async
  {

    var group = await EMClient.getInstance().groupManager().getGroup(widget.conversationChatter);

    if(group != null && group.getGroupName() != null && group.getGroupName().isNotEmpty)
    {
      return group;
    }
    return await EMClient.getInstance().groupManager().getGroupFromServer(widget.conversationChatter);

  }

  void groupNameChanged(dynamic groupInfo)
  {

    if(groupInfo['groupId'] == widget.conversationChatter)
    {
      if(mounted)
      {
        setState(() {
          conversationTitle = groupInfo['name'];
        });
      }
    }


  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    conversationTitle = widget.conversationTitle;
//    if(widget.conversationType == EMConversationType.GroupChat) {
//      DartNotificationCenter.subscribe(channel: EaseUIOptions.CHAT_GROUP_NAME_CHANGED_EVENT, observer: this, onNotification: groupNameChanged);
//    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
//    DartNotificationCenter.unsubscribe(observer: this);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    Widget middleWidget;

    if (conversationTitle != null && conversationTitle.isNotEmpty && conversationTitle != widget.conversationChatter) {
      middleWidget = Text(
          conversationTitle,
          style: TextStyle(color: widget.titleColor)
      );
    }
    else {
      if (widget.conversationType == EMConversationType.Chat) {
        middleWidget = FutureBuilder(
            future: widget.delegate.getUserInfo(widget.conversationChatter),
            builder: (BuildContext context, AsyncSnapshot<ChatUserModel> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  if (snapshot.hasError || snapshot.data == null) {
                    return const Text('');
                  }
                  conversationTitle = snapshot.data.nickname;
                  return
                    FittedBox(
                    fit: BoxFit.contain, child:
                  Text(
                      snapshot.data.nickname,
                      style: TextStyle(color: widget.titleColor)
                  ),
                  );
                default:
                  return const Text('');
              }
            }
        );
      }
      else //群聊
          {
        middleWidget = FutureBuilder(
            future: getGroupName(),
            builder: (BuildContext context, AsyncSnapshot<EMGroup> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  if (snapshot.hasError || snapshot.data == null) {
                    return const Text('Error get');
                  }

                  conversationTitle = snapshot.data.getGroupName();

                  return
                    FittedBox(
                      fit: BoxFit.contain, child:
                  Text(
                    snapshot.data.getGroupName(),
                    style: TextStyle(color: widget.titleColor),
                  )
                    );
                default:
                  return const Text("");
              }
            }
        );
      }
    }
    return middleWidget;
  }

}

class SearchChatPage extends StatefulWidget {
  final String conversationTitle;
  final String userHeadImageUrl;
  final String conversationChatter;
  final EMConversationType conversationType;
  final EMMessage message;
  final Color titleColor;
  final ChatDelegate delegate;

  final String currentUserId;  //当前用户id



  const SearchChatPage(
      this.message,
      this.delegate,
      this.conversationChatter,
      this.conversationType,
      this.titleColor,
      {Key key, this.conversationTitle, this.userHeadImageUrl,this.currentUserId})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChatPageState();
}

class _ChatPageState extends State<SearchChatPage>
    implements
        EMMessageListener,
        ChatItemDelegate,
        EMMessageStatus
{
//  String toChatUsername;
  EMConversation conversation;

  //头像昵称缓存
  Map<String,ChatUserModel> userInfoCache = HashMap();

  final ValueNotifier<VoiceStatus> recorderStateChangeNotifier =
  ValueNotifier(VoiceStatus.None);

//  final WorksChangeNotifier closeExtBottom = WorksChangeNotifier();

  String currentUserId;

//  GlobalKey<BottomInputBarState> bottomInputKey = GlobalKey();


//  final AudioPlayer player = AudioPlayer();

//  UserInfo user;
  int _pageSize = 50;
  bool isJoinRoom = false;
  bool _singleChat;
  String msgStartId = '';
  String afterLoadMessageId = '';


  bool isNeedLoadMore = true; //向前加载

  bool isNeedDownLoadMore = true;  //向后加载

  //已经在加载，则不加载
  bool isDownLoading = false;
  bool isLoading = false;

//  bool _isCancelRecorder = false;  //是否录音过程取消过

  List<EaseMessageModel> messageTotalList = List(); //消息数组
//  List<EMMessage> messageList = new List(); //消息数组
  List<EMMessage> msgListFromDB = new List();

  VoiceStatus currentStatus; //当前输入工具栏的状态

  EMVoiceMessageBody _currentPlayBody; //当前正在播放的音频body

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  int _currentIndex;

  bool _isInitFinish = false;

  bool _isJumpFinish = false;


  _ChatPageState();

  void addFrameCallback()
  {
    WidgetsBinding.instance.addPostFrameCallback((callback){
      if(!mounted)
        return;
      if(_isInitFinish && itemScrollController.isAttached)
      {
        var value = itemPositionsListener.itemPositions.value;


        if(value.isEmpty)
          {
            addFrameCallback();
          }
        else {

          int realIndex = isNeedLoadMore ? _currentIndex + 1 : _currentIndex;

          if (value.elementAt(0).index != realIndex) {
            itemScrollController.jumpTo(index: realIndex,alignment: 0.7);
            addFrameCallback();
          }
          else
            {

              if(mounted) {
                setState(() {
                  _isJumpFinish = true;
                });
              }
            }
        }
      }
      else
      {
        addFrameCallback();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _isInitFinish = false;
    _isJumpFinish = false;

    currentUserId = widget.currentUserId;

    if(currentUserId == null)
    {
      EMClient.getInstance().getCurrentUser().then((value) {
        currentUserId = value;
      });
    }

    currentStatus = VoiceStatus.None;

    EMClient.getInstance().chatManager().addMessageListener(this);
//    EMClient.getInstance().chatManager().loadAllConversations();
    EMClient.getInstance().chatManager().addMessageStatusListener(this);

    messageTotalList.clear();

//    toChatUsername = widget.conversationChatter;

    if (widget.conversationType == EMConversationType.Chat) {
      _singleChat = true;
    }

    if (widget.conversationType == EMConversationType.ChatRoom && !isJoinRoom) {
      _joinChatRoom();
    }

    _onConversationInit();


//    _scrollController.addListener(() {
//      //此处要用 == 而不是 >= 否则会触发多次
//      if (isNeedLoadMore && _scrollController.position.pixels ==
//          _scrollController.position.maxScrollExtent) {
//        _loadMessage();
//      }
//    });

  }

  @override
  Widget build(BuildContext context) {
    int len = 1;
    if(_isInitFinish)
      {
        len = messageTotalList.length;
        if(isNeedLoadMore)
        {
          len++;
        }
        if(isNeedDownLoadMore)
        {
          len++;
        }
      }
    return Container(
      color: const Color(0xFFF0F2F5),
      child: Stack(
        children: <Widget>[
          NotificationListener<ScrollEndNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification.metrics != null) {
                if (isNeedLoadMore && scrollNotification.metrics.minScrollExtent == scrollNotification.metrics.pixels && !isLoading)
                {
                  _loadMessage();
                }
                else if ( isNeedDownLoadMore && scrollNotification.metrics.maxScrollExtent == scrollNotification.metrics.pixels && !isDownLoading )
                {
                  _loadAfterMessage();
                }
              }
              return true;
            },
            child:
            ScrollablePositionedList.builder(
//                        key: ObjectKey(_scrollController),
//          shrinkWrap: true,
//              reverse: _isReverse,
              itemScrollController: itemScrollController,
              itemPositionsListener: itemPositionsListener,
              itemCount: len,
              itemBuilder: (BuildContext context, int index) {
                if (_isInitFinish) {
                  int realIndex = isNeedLoadMore ? index - 1 : index;

                  if (realIndex >= 0 && realIndex < messageTotalList.length) {
                    if (_currentIndex == realIndex) {
                      return Container(
                        foregroundDecoration: BoxDecoration(
                            color: Color(0x12000000)),
                        child: ChatItem(
                          widget.delegate,
                          this,
                          messageTotalList[realIndex],
                          _isShowTime(realIndex),
                          userInfoCache,
                          fromSearch: true,
                        ),
                      );
                    }
                    return ChatItem(
                      widget.delegate,
                      this,
                      messageTotalList[realIndex],
                      _isShowTime(realIndex),
                      userInfoCache,
                      fromSearch: true,
                    );
                  }

                  return Container(
                    height: 50,
                    child: Center(
                      child: CupertinoActivityIndicator(),
                    ),
                  );
                } else {
                  return WidgetUtil.buildEmptyWidget();
                }
              },
            ),
          ),
          Visibility(
            visible: !_isJumpFinish,
            child: Container(
              child: Center(child: CupertinoActivityIndicator(),),
              color: Color(0xFFF0F2F5),
            ),
          )
        ],
    ));
  }

  // ignore: non_constant_identifier_names
//  SelectView(IconData icon, String text, String id) {
//    return new PopupMenuItem<String>(
//        value: id,
//        child: new Row(
//          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//          children: <Widget>[
//            // ignore: non_constant_identifier_names
//            new Icon(icon, color: Colors.blue),
//            new Text(text),
//          ],
//        ));
//  }





  void msgClearEvent(dynamic conversationId)
  {
    msgListFromDB.clear();
    setState(() {
      messageTotalList.clear();
      isNeedLoadMore = false;
      isNeedDownLoadMore = false;
    });

  }


  void _onConversationInit() async {
    conversation = await
    EMClient.getInstance().chatManager().getConversation(
        widget.conversationChatter, widget.conversationType, true);


    _currentIndex = 0;

    if (conversation != null) {
      List<EMMessage> afterMsgListFromDB;
      conversation.markAllMessagesAsRead();

      //获取之前的
      msgListFromDB =
      await conversation.loadMoreMsgFromDB(widget.message.msgId, _pageSize);

      //获取之后的
      afterMsgListFromDB = await conversation.loadMoreMsgFromDB(
          widget.message.msgId, _pageSize, direction: EMSearchDirection.Down);
      if ((msgListFromDB != null && msgListFromDB.length > 0) ||
          (afterMsgListFromDB != null && afterMsgListFromDB.length > 0)) {

        if (msgListFromDB != null && msgListFromDB.length < _pageSize) {
          isNeedLoadMore = false;
        }

        if (afterMsgListFromDB != null && afterMsgListFromDB.length < _pageSize) {
          isNeedDownLoadMore = false;
        }

        List<EaseMessageModel> messageModels = List();


        if (msgListFromDB != null && msgListFromDB.length > 0) {
          afterLoadMessageId = msgListFromDB.first.msgId;
//        msgListFromDB.forEach((a) {
//          if (a.status == Status.INPROGRESS) {
//            a.status = Status.FAIL;
//          }
//        });

          msgListFromDB.sort((a, b) => a.localTime.compareTo(b.localTime));

          for (var message in msgListFromDB) {
            if (message.status == Status.INPROGRESS) {
              message.status = Status.FAIL;
            }
            var model = EaseMessageModel(message);
            if (message.from != null && message.from.isNotEmpty &&
                userInfoCache.containsKey(message.from)) {
              model.userModel = userInfoCache[message.from];
            }
            messageModels.add(model);
          }
        }



        _currentIndex = messageModels.length;

        if (_currentIndex > 0) {
          addFrameCallback();
        }
        else
          {
            _isJumpFinish = true;
          }

        messageModels.add(EaseMessageModel(widget.message));


        if (afterMsgListFromDB != null && afterMsgListFromDB.length > 0) {
          msgStartId = afterMsgListFromDB.last.msgId;
//        afterMsgListFromDB.forEach((a) {
//          if (a.status == Status.INPROGRESS) {
//            a.status = Status.FAIL;
//          }
//        });
          afterMsgListFromDB.sort((a, b) => a.localTime.compareTo(b.localTime));

          for (var message in afterMsgListFromDB) {
            if (message.status == Status.INPROGRESS) {
              message.status = Status.FAIL;
            }
            var model = EaseMessageModel(message);
            if (message.from != null && message.from.isNotEmpty &&
                userInfoCache.containsKey(message.from)) {
              model.userModel = userInfoCache[message.from];
            }
            messageModels.add(model);
          }
        }
        if (mounted) {
          setState(() {
            _isInitFinish = true;
            messageTotalList.addAll(messageModels);
          });
        }
      } else {
        if (mounted) {
          setState(() {
            messageTotalList.add(EaseMessageModel(widget.message));
            _isJumpFinish = true;
            _isInitFinish = true;
            isNeedLoadMore = false;
            isNeedDownLoadMore = false;
          });
        }
      }
    }
    else
      {
        messageTotalList.add(EaseMessageModel(widget.message));
        _isInitFinish = true;
        _isJumpFinish = true;
        isNeedLoadMore = false;
        isNeedDownLoadMore = false;
        return;
      }
  }

  void _loadMessage() async {
    isLoading = true;
    var loadList =
    await conversation.loadMoreMsgFromDB(afterLoadMessageId, _pageSize);
    isLoading = false;
    if (loadList.length > 0) {
      afterLoadMessageId = loadList.first.msgId;
//      loadList.sort((a, b) => b.msgTime.compareTo(a.msgTime));
//      await Future.delayed(Duration(seconds: 1), () {
      loadList.sort((a, b) => a.localTime.compareTo(b.localTime));
      List<EaseMessageModel> messageModels = List();
      for(var message in loadList)
      {
        var model = EaseMessageModel(message);
        if(message.from != null && message.from.isNotEmpty && userInfoCache.containsKey(message.from))
        {
          model.userModel = userInfoCache[message.from];
        }
        messageModels.add(model);
      }

      _currentIndex += messageModels.length;

      if(mounted) {
        setState(() {
          if (loadList.length < _pageSize) {
            isNeedLoadMore = false;
          }
          messageTotalList.insertAll(0,messageModels);
//        });
        });
      }

      if(isNeedLoadMore)
      {
        itemScrollController.jumpTo(index: messageModels.length);
      }
      else
      {
        itemScrollController.jumpTo(index: max(0,messageModels.length-1));
      }

//      _scrollController.animateTo(_scrollController.offset + 50,
//          duration: new Duration(milliseconds: 250), curve: Curves.ease);



//      isLoad = true;
    } else {
//      isLoad = true;
      if(mounted) {
        setState(() {
          isNeedLoadMore = false;
        });
      }
      print('没有更多数据了');
    }
    print(messageTotalList.length.toString() + '_loadMessage');
//    _scrollController.animateTo(_scrollController.offset,
//        duration: new Duration(seconds: 2), curve: Curves.ease);
  }

  void _loadAfterMessage() async {
    isDownLoading = true;
    var loadList =
    await conversation.loadMoreMsgFromDB(msgStartId, _pageSize,direction: EMSearchDirection.Down);
    isDownLoading = false;
    if (loadList.length > 0) {
      msgStartId = loadList.last.msgId;
//      loadList.sort((a, b) => b.msgTime.compareTo(a.msgTime));
//      await Future.delayed(Duration(seconds: 1), () {
      loadList.sort((a, b) => a.localTime.compareTo(b.localTime));
      List<EaseMessageModel> messageModels = List();
      for(var message in loadList)
      {
        var model = EaseMessageModel(message);
        if(message.from != null && message.from.isNotEmpty && userInfoCache.containsKey(message.from))
        {
          model.userModel = userInfoCache[message.from];
        }
        messageModels.add(model);
      }

      setState(() {
        if(loadList.length < _pageSize)
        {
          isNeedDownLoadMore = false;
        }
        messageTotalList.addAll(messageModels);
//        });
      });




//      _scrollController.animateTo(_scrollController.offset + 50,
//          duration: new Duration(milliseconds: 250), curve: Curves.ease);

//      isLoad = true;
    } else {
//      isLoad = true;
      if(mounted) {
        setState(() {
          isNeedDownLoadMore = false;
        });
      }
      print('没有更多数据了');
    }
    print(messageTotalList.length.toString() + '_loadMessage');
//    _scrollController.animateTo(_scrollController.offset,
//        duration: new Duration(seconds: 2), curve: Curves.ease);
  }

  ///如果是聊天室类型 先加入聊天室
  _joinChatRoom() {
    EMClient.getInstance().chatRoomManager().joinChatRoom(widget.conversationChatter,
        onSuccess: () {
          isJoinRoom = true;
        }, onError: (int errorCode, String errorString) {
          print('errorCode: ' +
              errorCode.toString() +
              ' errorString: ' +
              errorString);
        });
  }

  ///清除记录
  _cleanAllMessage() {
    if (null != conversation) {
      conversation.clearAllMessages();
      setState(() {
//        messageList = [];
        messageTotalList = [];
      });
    }
  }

  ///查看详情
  _viewDetails() async {
//    switch(widget.conversationType){
//      case EMConversationType.GroupChat:
//        Navigator.push<bool>(context,
//            new MaterialPageRoute(builder: (BuildContext context) {
//              return EMGroupDetailsPage(this.toChatUsername);
//            })).then((bool _isRefresh){
//          if(_isRefresh){
//            Navigator.pop(context, true);
//          }
//        });
//        break;
//      case EMConversationType.ChatRoom:
//        break;
//      default:
//        break;
//    }
  }

  /// 禁止随意调用 setState 接口刷新 UI，必须调用该接口刷新 UI
  void _refreshUI() {
    setState(() {});
  }


  void _showExtraCenterWidget(VoiceStatus status) {
    this.currentStatus = status;
    _refreshUI();
  }

  void checkOutRoom() {
    EMClient.getInstance().chatRoomManager().leaveChatRoom(widget.conversationChatter,
        onSuccess: () {
          print('退出聊天室成功');
        }, onError: (int errorCode, String errorString) {
          print('errorCode: ' +
              errorCode.toString() +
              ' errorString: ' +
              errorString);
        });
  }


  void toBrowser(EMImageMessageBody msg,Status status) {

    Map<String, dynamic> galleryItem;
//    print('msg status:${}')

    if (msg.localUrl != null && msg.localUrl.isNotEmpty) {
      File file = File(msg.localUrl);
      if (file != null && file.existsSync()) {
        galleryItem = {'key': 'msg', 'photo': file};
      } else if (Platform.isIOS &&
          (status == null || status != Status.SUCCESS)) //需要向native获取相片数据
          {
        galleryItem = {
          'key': 'msg',
          'photo': Asset(msg.localUrl, msg.width ?? 0, msg.height ?? 0)
        };
      }
    }
    if (galleryItem == null) {
      galleryItem = {'key': 'msg', 'photo': msg.remoteUrl};
      if(msg.thumbnailLocalPath != null && msg.thumbnailLocalPath.isNotEmpty)
      {
        galleryItem['thumbPath'] = msg.thumbnailLocalPath;
      }
    }

    Navigator.of(context, rootNavigator: true).push(new PageRouteBuilder(
        fullscreenDialog: true,
        transitionDuration: Duration(milliseconds: 10),
        pageBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          // 跳转的路由对象
          return WorksPhotoBrowser(0, [galleryItem]);
        },
        transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
            ) {
          return child;
        }));
  }

  Future<void> toPlayer(EMMessage message)
  async {

    if(message.type == EMMessageType.VIDEO) {
      EMVideoMessageBody msgBody = message.body;
      WorksVideoPlayerScaffold playerScaffold;

      if (msgBody.localUrl != null && msgBody.localUrl.isNotEmpty) {
        File file = File(msgBody.localUrl);
        if (file != null && file.existsSync()) {
          print('loalurl:${msgBody.localUrl}');
          playerScaffold = WorksVideoPlayerScaffold(videoPath: msgBody.localUrl,);
        }
      }
      if(playerScaffold == null && msgBody.remoteUrl != null && msgBody.remoteUrl
          .isNotEmpty) {

        playerScaffold = WorksVideoPlayerScaffold(videoUrl: msgBody
            .remoteUrl,isNeedLoad: Platform.isIOS,);
      }

//    playerScaffold = WorksVideoPlayerScaffold(videoUrl:'http://vfx.mtime.cn/Video/2019/03/19/mp4/190319222227698228.mp4');

      if (playerScaffold != null) {
        Navigator.of(context).push(
            CupertinoPageRoute<void>(
                fullscreenDialog: true,
                builder: (BuildContext context) {
                  return playerScaffold;
                }

            )
        );
      }
    }
    else //播放语音
        {
      EMVoiceMessageBody msgBody = message.body;
      if (msgBody.isMediaPlaying) {
        AudioRecorder.getInstance().stopPlay();
        setState(() {
          msgBody.isMediaPlaying = false;
        });
        _currentPlayBody = null;
      } else {

        setState(() {
          msgBody.isMediaPlaying = true;
          if(_currentPlayBody != null && _currentPlayBody != msgBody)
          {
            _currentPlayBody.isMediaPlaying = false;
          }
        });

        _currentPlayBody = msgBody;

        if (msgBody.localUrl != null && msgBody.localUrl.isNotEmpty) {
          AudioRecorder.getInstance()
              .playVoice(msgBody.localUrl)
              .then((isFinish) {
            if (isFinish) {
              setState(() {
                msgBody.isMediaPlaying = false;
              });
              _currentPlayBody = null;
            }
          });
        }
      }
    }
  }

  Future<void> toBrowserFile(EMMessage message,int type)
  async {

    EMNormalFileMessageBody msgBody = message.body;
    if(type == 1 || type == 2) {

      WorksVideoPlayerScaffold playerScaffold;

      if (msgBody.localUrl != null && msgBody.localUrl.isNotEmpty) {
        File file = File(msgBody.localUrl);
        if (file != null && file.existsSync()) {
          print('loalurl:${msgBody.localUrl}');
          playerScaffold = WorksVideoPlayerScaffold(videoPath: msgBody
              .localUrl,isAudio: type == 1,);
        }
      }
      if(playerScaffold == null && msgBody.remoteUrl != null && msgBody.remoteUrl
          .isNotEmpty) {
        print('remoteurl:${msgBody.remoteUrl}');
        playerScaffold = WorksVideoPlayerScaffold(videoUrl: msgBody
            .remoteUrl,isNeedLoad: Platform.isIOS,isAudio: type == 1);
      }


      if (playerScaffold != null) {
        Navigator.of(context).push(
            CupertinoPageRoute<void>(
                fullscreenDialog: true,
                builder: (BuildContext context) {
                  return playerScaffold;
                }

            )
        );
      }
    }
    else //文件浏览
        {

      print('url:${msgBody.localUrl}');

      WorksFilePicker.openFile(CupertinoTheme.of(context).barBackgroundColor.value,
          CupertinoTheme.of(context).primaryColor.value,msgBody.localUrl,(message.body as EMFileMessageBody).displayName ?? "");
    }
  }


  @override
  void onCmdMessageReceived(List<EMMessage> messages) {
    // TODO: implement onCmdMessageReceived
  }


  @override
  void onMessageChanged(EMMessage message) {
    // TODO: implement onMessageChanged

    if(message.msgId != null && message.msgId.isNotEmpty)
    {
      for(var localMessage in messageTotalList)
      {
        if(localMessage.message.msgId == message.msgId)
        {
          localMessage.message.status = message.status;
          localMessage.message.localTime = message.localTime;
          localMessage.message.msgTime = message.msgTime;
          localMessage.message.unread = message.unread;
          localMessage.message.acked = message.acked;
          localMessage.message.deliverAcked = message.deliverAcked;
          if(message.body !=null && localMessage.message.type != EMMessageType.TXT)
          {
            localMessage.message.body = message.body;
          }
          return;
        }
      }
    }



//    print(message.toString());
//
//    print('message did changed!!!');

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

    for (var message in messages) {
      String username;
      // group message
      if (message.chatType == ChatType.GroupChat ||
          message.chatType == ChatType.ChatRoom) {
        username = message.to;
      } else {
        // single chat message
        username = message.from;
      }
      // if the message is for current conversation
      if (username == widget.conversationChatter ||
          message.to == widget.conversationChatter ||
          message.conversationId == widget.conversationChatter) {
        conversation.markMessageAsRead(message.msgId);
      }

    }

    messages.sort((a, b) => b.localTime.compareTo(a.localTime));
    List<EaseMessageModel> messageModels = List();
    for(var message in messages)
    {
      var model = EaseMessageModel(message);
      if(message.from != null && message.from.isNotEmpty && userInfoCache.containsKey(message.from))
      {
        model.userModel = userInfoCache[message.from];
      }
      messageModels.add(model);
    }
    setState(() {
      messageTotalList.insertAll(0, messageModels);

//        });
    });

//    _onConversationInit();
  }

  @override
  void dispose() {
    super.dispose();
//    player.dispose();
    if(conversation != null && conversation.conversationId != null)
    {
      EMClient.getInstance().chatManager().deleteConversationIfEmpty(conversation.conversationId, true);
    }

//    DartNotificationCenter.unsubscribe(observer: this);
//
//    DartNotificationCenter.post(channel: EaseUIOptions.CHAT_EXIT_EVENT,options: false);
    AudioRecorder.getInstance().stopPlay();
    EMClient.getInstance().chatManager().removeMessageListener(this);
    EMClient.getInstance().chatManager().removeMessageStatusListener(this);

    messageTotalList.clear();

    if (isJoinRoom) {
      checkOutRoom();
    }
  }

  /// 判断时间间隔在60秒内不需要显示时间
  bool _isShowTime(int index) {
    if(index == 0){
      return true;
    }
//    print(messageTotalList.toString());
//    print(index);
    String lastTime = messageTotalList[index - 1].message.localTime;
//    print('before' + messageTotalList[index - 1].body.toString() + ' beforeTime:'+lastTime);
    String afterTime = messageTotalList[index].message.localTime;
//    print('after' + messageTotalList[index].body.toString() + ' afterTime:'+afterTime);
    return WidgetUtil.isCloseEnough(lastTime,afterTime);
  }


  @override
  void onLongPressMessageItem(EaseMessageModel messageModel, int menuType) {
    // TODO: implement didLongPressMessageItem
    print("长按了Item :$menuType");



//    EMMessageBody body = messageModel.message.body;
//    switch(menuType)
//    {
//      case 0: //删除
//        {
//          if(conversation == null)
//          {
//            Toast.show("未能获取到会话", context,gravity: Toast.CENTER,backgroundRadius: 8);
//          }
//          else
//          {
//            if(messageModel.message.msgId != null) {
//              conversation.removeMessage(messageModel.message.msgId);
//            }
//            if(mounted) {
//              setState(() {
//                messageTotalList.remove(messageModel);
//              });
//            }
//
//          }
//        }
//        break;
//      case 1: // 复制
//        {
//          Clipboard.setData(ClipboardData(text: (body as EMTextMessageBody).message));
//        }
//        break;
//      case 2:   //转发
//        {
//
//        }
//        break;
//      case 3:  //撤回
//        {
//
//        }
//        break;
//      default:
//    }

  }

  @override
  void onTapMessageItem(EaseMessageModel messageModel) {
    // TODO: implement didTapMessageItem
    EMMessage message = messageModel.message;
    print("点击了Item type: ${message.type}");
    FocusScope.of(context).requestFocus(FocusNode());
    if(message.type == EMMessageType.IMAGE)
    {

      bool isDownloaded = false;
      EMDownloadStatus downloadStatus = (message.body as
      EMImageMessageBody).downloadStatus;

      String url = (message.body as EMImageMessageBody).localUrl;

      if(url != null)
      {
        File file = new File(url);
        if(file.existsSync())
        {
          isDownloaded = true;
        }
      }

      if(!isDownloaded)
      {
        if(downloadStatus !=
            EMDownloadStatus.SUCCESSED && downloadStatus != EMDownloadStatus.DOWNLOADING) {
          (message.body as EMImageMessageBody).downloadStatus =
              EMDownloadStatus.DOWNLOADING;
          EMClient.getInstance().chatManager().downloadAttachment(message);
        }
      }
      toBrowser(message.body,message.status);
    }
    else if(message.type == EMMessageType.VIDEO || message.type ==
        EMMessageType.VOICE)
    {
      EMDownloadStatus downloadStatus;
      String url;

      if(message.type == EMMessageType.VOICE)
      {
        EMVoiceMessageBody voiceMessageBody = message.body;
        downloadStatus = voiceMessageBody.downloadStatus;
        url = voiceMessageBody.localUrl;
      }
      else
      {
        EMVideoMessageBody videoMessageBody = message.body;
        downloadStatus = videoMessageBody.downloadStatus;
        url = videoMessageBody.localUrl;
      }

      bool isDownloaded = false;

      if(url != null)
      {
        File file = new File(url);
        if(file.existsSync())
        {
          isDownloaded = true;
        }
      }

      if(!isDownloaded)
      {
        if(downloadStatus !=
            EMDownloadStatus.SUCCESSED && downloadStatus != EMDownloadStatus.DOWNLOADING) {
          if(message.type == EMMessageType.VOICE)
          {
            (message.body as EMVoiceMessageBody).downloadStatus =
                EMDownloadStatus.DOWNLOADING;
          }
          else
          {
            (message.body as EMVideoMessageBody).downloadStatus =
                EMDownloadStatus.DOWNLOADING;
          }
          EMClient.getInstance().chatManager().downloadAttachment(message);
        }
      }
      toPlayer(message);
    }
    else if(message.type == EMMessageType.LOCATION)
    {

      EMLocationMessageBody locationMessageBody = message.body;
      var addressInfo = locationMessageBody.address.split("<-?->");
      WorksAmapMap.startPotMapMap(CupertinoTheme.of(context).barBackgroundColor.value,CupertinoTheme.of(context).primaryColor.value,{
        "lat":locationMessageBody.latitude,
        "lon":locationMessageBody.longitude,
        "name":addressInfo[0],
        "address":addressInfo[1]
      });
    }
    else if(message.type == EMMessageType.FILE)
    {

      EMNormalFileMessageBody fileMessageBody = message.body;

      int fileType = messageModel.fileType;

      EMDownloadStatus downloadStatus = fileMessageBody.downloadStatus;

      bool isDownloaded = false;

      if(fileMessageBody.localUrl != null)
      {
        File file = new File(fileMessageBody.localUrl);
        if(file.existsSync())
        {
          isDownloaded = true;
        }

      }


      if(!isDownloaded)
      {
        if(downloadStatus !=
            EMDownloadStatus.SUCCESSED && downloadStatus != EMDownloadStatus.DOWNLOADING) {
          fileMessageBody.downloadStatus = EMDownloadStatus.DOWNLOADING;
          EMClient.getInstance().chatManager().downloadAttachment(message);
          if(fileType == 0){
            setState(() {

            });
          }
        }
      }

      if(fileType != 0 || isDownloaded == true)
      {
        toBrowserFile(message,fileType);
      }
      else
      {
        Toast.show("文件未下载完成，请稍后再试!", context,gravity: Toast.CENTER,backgroundRadius: 8);
      }
    }


  }

  @override
  void onTapUserPortrait(EaseMessageModel messageModel) {


//    if(widget.conversationType == EMConversationType.GroupChat && messageModel.message.direction == Direction.RECEIVE)
//    {
//      showCupertinoModalPopup<int>(
//          context: context,
//          builder: (ctx) {
//            return CupertinoActionSheet(
//              cancelButton: CupertinoActionSheetAction(
//                  onPressed: () {
//                    Navigator.pop(ctx);
//                  },
//                  child: Text("取消",style: TextStyle(color: Colors.blue,fontWeight: FontWeight.w600),)),
//              actions: <Widget>[
//                CupertinoActionSheetAction(
//                    onPressed: () async {
//                      Navigator.pop(ctx, 1);
//                      Navigator.of(context,rootNavigator: true).push(
//                          CupertinoPageRoute<void>(builder: (BuildContext context) {
//                            return
//                              ChatPageScaffold(messageModel.message.from, EMConversationType.Chat, widget.delegate, currentUserId: widget.currentUserId);
//                          }
//                          )
//                      );
//                    },
//                    child: Text('发消息',style: TextStyle(color: Colors.blue))),
//              ],
//            );
//          });
//    }

  }

  //长按用户头像
  @override
  void onLongPressUserPortrait(EaseMessageModel messageModel)
  {
//    if(widget.conversationType == EMConversationType.GroupChat
//        && messageModel.message.direction == Direction.RECEIVE
//        && messageModel.userModel != null
//        && messageModel.userModel.nickname.isNotEmpty
//    )
//    {
//      BottomInputBarState state = bottomInputKey.currentState;
//      if(state != null) {
//        state.insertAtUser(messageModel.userModel.userId,messageModel.userModel.nickname);
//      }
//      //at功能
////      if(messageModel.userModel)
//    }
  }

  //选择at的人
//  @override
//  void onSelectAtMember(int baseOffset) async
//  {
//    if(widget.conversationType == EMConversationType.GroupChat)
//    {
//
//      BottomInputBarState state = bottomInputKey.currentState;
//      if(state != null) {
//
//        EMGroup group = await EMClient.getInstance().groupManager().getGroup(widget.conversationChatter);
//        if(group != null)
//        {
//          //at功能
//          Navigator.of(context, rootNavigator: true).push(
//              CupertinoPageRoute<dynamic>(builder: (BuildContext context) {
//                return
//                  ChatGroupMemberPageScaffold(group, widget.delegate,currentUserId: widget.currentUserId,titleColor: widget.titleColor,fromAt: true,);
//              }
//              )
//          ).then((value) {
//            if(value != null)
//            {
//
//              ChatUserModel userModel = value.userModel;
//              if(userModel != null)
//              {
//                state.insertAtUser(userModel.userId,userModel.nickname,addPre: false,baseOffset: baseOffset);
//              }
//            }
//          });
//        }
//
//
//      }
//
//
//    }
//
//
//  }



  @override
  void onTapFailItem(EaseMessageModel messageModel)
  {
//    var msgMap = messageModel.message.toDataMap();
//    if(msgMap['attributes'] == null)
//    {
//      msgMap['attributes'] = {};
//    }
//    msgMap['body']['type'] =toType(messageModel.message.type);
//    EMMessage nMessage = new EMMessage.from(msgMap);
//    nMessage.status = Status.CREATE;
//
//    int index = messageTotalList.indexOf(messageModel);
//
//    setState(() {
//      messageModel.message = nMessage;
//    });
//
//
//    EMClient.getInstance().chatManager().resendMessage(nMessage, onSuccess: () {
//      setState(() {
//      });
//    },
//        onError: (int errorCode, String desc) {
//          EMErrorCode code = fromEMErrorCode(errorCode);
//          if(code == EMErrorCode.EMErrorNoType)
//          {
//            var statusList = desc.split("#");
//            if(statusList.length > 1)
//            {
//              nMessage.status = fromEMMessageStatus(int.parse(statusList[1]));
//            }
//          }
//          print('errorCode:$code  msg:$desc');
//          setState(() {}
//          );
//        });
  }

//  @override
//  void sendText(String text,List atList) {
//    // TODO: implement willSendText   发送文本消息
//    EMMessage message = EMMessage.createTxtSendMessage(text, widget.conversationChatter);
//    message.chatType =
//        fromChatType(toEMConversationType(widget.conversationType));
////    EMTextMessageBody body = EMTextMessageBody(text);
////    message.body = body;
////    isLoad = true;
//    message.msgTime = DateTime.now().millisecondsSinceEpoch.toString();
//    message.localTime = message.msgTime;
//    message.status = Status.CREATE;
//    if(atList.isNotEmpty) {
//      message.setAttribute(EaseUIOptions.CHAT_GROUP_MESSAGE_At_LIST, atList);
//    }
//
//    if(currentUserId != null && currentUserId.isNotEmpty)
//    {
//      message.from = currentUserId;
//    }
//
//    var model = EaseMessageModel(message);
//    if(message.from != null && message.from.isNotEmpty && userInfoCache.containsKey(message.from))
//    {
//      model.userModel = userInfoCache[message.from];
//    }
//
//    setState(() {
//      messageTotalList.insert(0, model);
//    });
//
////    print('local:' + message.msgTime);
//
//    EMClient.getInstance().chatManager().sendMessage(message, onSuccess: () {
//      setState(() {
//      });
////
////      print('-----------MessageStatus---------->' + message.status.toString());
//    },
//        onError: (int errorCode, String desc) {
//          EMErrorCode code = fromEMErrorCode(errorCode);
//          print('errorCode:$code  msg:$desc');
//          setState(() {}
//          );
//        });
//
//
////    _onConversationInit();
//  }


//  @override
//  Future<void> recordVoiceStatusChanged(VoiceStatus status) async {
//    recorderStateChangeNotifier.value = status;
//    _showExtraCenterWidget(status);
//    print('$status');
//    switch(status)
//    {
//
//      case VoiceStatus.None:
//      // TODO: Handle this case.
//        break;
//      case VoiceStatus.Start:
//      // TODO: Handle this case.
//        if(!_isCancelRecorder)
//        {
//          var status = await AudioRecorder.getInstance().start();
//          if(!status)
//          {
//            Toast.show('无法启动录音',context,gravity: Toast.CENTER,backgroundRadius: 8);
//          }
//        }
//
//        _isCancelRecorder = false;
//
//        break;
//      case VoiceStatus.End:
//      // TODO: Handle this case.
//
//        if(_isCancelRecorder)
//        {
//          AudioRecorder.getInstance().cancel();
//        }
//        else
//        {
//          var voiceInfo = await AudioRecorder.getInstance().stop();
//          if(voiceInfo['code'] != null)
//          {
//            if(voiceInfo['code'] == 1000)
//            {
//              Toast.show(voiceInfo['msg'],context,gravity: Toast.CENTER,backgroundRadius: 8);
//            }
//            else
//            {
//              Toast.show('录音错误',context,gravity: Toast.CENTER,backgroundRadius: 8);
//            }
//            return;
//          }
//
//          final String voicePath = voiceInfo['recordPath'];
//          final int duration = voiceInfo['duration'] ?? 0;
//          print('voicePath:$voiceInfo  duration:$duration');
//          if(voicePath == null || voicePath.isEmpty)
//          {
//            Toast.show('录音错误!',context,gravity: Toast.CENTER,backgroundRadius: 8);
//            return;
//          }
//
//
//          EMMessage voiceMessage = EMMessage.createVoiceSendMessage(voicePath,
//            duration,
//            widget.conversationChatter,);
//          if(currentUserId != null && currentUserId.isNotEmpty)
//          {
//            voiceMessage.from = currentUserId;
//          }
////    EMMessage.createImageSendMessage(imgPath, true, toChatUsername);
//          voiceMessage.chatType =
//              fromChatType(toEMConversationType(widget.conversationType));
//          voiceMessage.status = Status.CREATE;
//          voiceMessage.msgTime = DateTime.now().millisecondsSinceEpoch.toString();
//          voiceMessage.localTime = voiceMessage.msgTime;
//          var model = EaseMessageModel(voiceMessage);
//          if(voiceMessage.from != null && voiceMessage.from.isNotEmpty && userInfoCache.containsKey(voiceMessage.from))
//          {
//            model.userModel = userInfoCache[voiceMessage.from];
//          }
//          setState(() {
//            messageTotalList.insert(0, model);
//          });
//
//          EMClient.getInstance().chatManager().sendMessage(voiceMessage,
//              onSuccess: () {
//                setState(() {});
//              },onError: (int errorCode, String desc) {
//                EMErrorCode code = fromEMErrorCode(errorCode);
//                print('errorCode:$code  msg:$desc');
//                setState(() {});
//              });
//
////          print('path:${voiceInfo['recordPath']}  '
////              'duration:${voiceInfo['duration'].runtimeType}');
//        }
//        _isCancelRecorder = false;
//
//        break;
//      case VoiceStatus.Cancel:
//      // TODO: Handle this case.
//        _isCancelRecorder = true;
//
//        break;
//    }
//  }

//  Future<bool> _willPop() {
//    //返回值必须是Future<bool>
//    Navigator.of(context).pop(false);
//    return Future.value(false);
//  }

  @override
  void onProgress(Map map) {
    // TODO: implement onProgress

    if(map.containsKey("progressType"))
    {
      num progressType = map['progressType'];

      if(progressType.toInt() == 1)
      {
        String localMsgId = map['localMsgId'];
        num progress = map['progress'];

        if (messageTotalList.length != null &&
            messageTotalList.length > 0) {
          for(var messageModel in messageTotalList) {
            if(messageModel.message.msgId == localMsgId) {
              messageModel.progress = progress;
              if(progress.toInt() == 100)
              {
                EMFileMessageBody body = messageModel.message.body;
                body.downloadStatus = EMDownloadStatus.SUCCESSED;

              }

              if(mounted && messageModel.fileType == 0) {
                setState(() {
                });
              }

              break;
            }
          }
        }


      }
    }
  }

}

///语音动画控件
class VoiceIndicatorWidget extends StatefulWidget {
  final ValueNotifier<VoiceStatus> valueNotifier;

  const VoiceIndicatorWidget({Key key, this.valueNotifier}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _VoiceIndicatorWidget();
  }
}

class _VoiceIndicatorWidget extends State<VoiceIndicatorWidget> {
  void voiceStateChanged() {
    setState(() {});
  }


  @override
  void initState() {
    // TODO: implement initState
    if (widget.valueNotifier != null) {
      widget.valueNotifier.addListener(voiceStateChanged);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
      child: Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
              color: Color(0x88000000),
//            border: Border.all(color: Color(0x33000000)),
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'easeuiImages/chat/voice_mic.png',
                    width: 30,
                    height: 51,
                    fit: BoxFit.fill,package: EaseUIOptions.packageName,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                  ),
                  Image.asset('easeuiImages/chat/voice_anim.gif',
                    width: 30, height: 48, fit: BoxFit.fill,package: EaseUIOptions.packageName,),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 20),
              ),
              Text(
                widget.valueNotifier.value != VoiceStatus.Cancel
                    ? '手指上滑 '
                    '取消发送'
                    : '松开手指 取消发送',
                style: TextStyle(
                    fontSize: 13,
                    color: widget.valueNotifier.value != VoiceStatus.Cancel
                        ? Colors.white
                        : Color(0xFFCC0000)),
              ),
            ],
          )),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose

    if (widget.valueNotifier != null) {
      widget.valueNotifier.removeListener(voiceStateChanged);
    }



    super.dispose();
  }
}

//enum ChatStatus {
//  Normal, //正常
//  VoiceRecorder, //语音输入，页面中间回弹出录音的 gif
//}
