
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:works_utils/works_utils.dart';
import '../works_ease_ui.dart';

class ChatContactPageScaffold extends CupertinoPageScaffold {

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
      fit: BoxFit.contain,child:Text(this.title,style: TextStyle(color: titleColor),)),
  );


  const ChatContactPageScaffold(
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
          ChatContactPage(
            this.delegate,
            this.customWidgets,
            currentUserId: this.currentUserId,
          )
      ));
}


class ChatContactPage extends StatefulWidget {

  final ChatDelegate delegate;
  final String currentUserId;  //当前用户id
  final List<Widget> customWidgets;


  const ChatContactPage(
      this.delegate,
      this.customWidgets,
      {Key key,this.currentUserId})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChatContactPage();
}

class _ChatContactPage extends State<ChatContactPage> {

  List<EMGroup> _groupList = List();
  List<ChatUserModel> _contacts = List();

  List<EMGroup> _searchGroupList;
  List<ChatUserModel> _searchContactList;




  TextEditingController textController = TextEditingController();


  void groupNameChanged(dynamic groupInfo)
  {
    if(mounted)
    {
      setState(() {
        _groupList.forEach((element) {
          if(element.getGroupId() == groupInfo['groupId'])
          {
            element.setGroupName(groupInfo['name']);
          }
        });
      });
    }
  }

  void getGroupList() async
  {

    var groupModels = await widget.delegate.getLocalGroups();
    if(groupModels != null && groupModels.isNotEmpty)
      {
        _groupList.clear();
        _groupList.addAll(groupModels);

        _groupList.sort((obj1,obj2)
        {
          return PinyinHelper.getPinyinE(obj1.getGroupName(),separator: '') .compareTo(PinyinHelper.getPinyinE(obj2.getGroupName(),separator: ''));
        });
      }


    EMClient.getInstance().groupManager().getJoinedGroupsFromServer(
        onSuccess: (List<EMGroup> groups)
    {
      if(mounted) {
        _groupList.clear();
        _groupList.addAll(groups);
        _groupList.sort((obj1,obj2)
        {
          return PinyinHelper.getPinyinE(obj1.getGroupName(),separator: '') .compareTo(PinyinHelper.getPinyinE(obj2.getGroupName(),separator: ''));
        });
        setSearchData(textController.text);
      }
    },onError: (int errorCode, String desc)
    {
      print('get groups from server error:code($errorCode),desc($desc)');
    });
  }

  void getContacts() async
  {
    var contacts = await widget.delegate.getLocalContacts();
    if(contacts != null && contacts.isNotEmpty)
    {
      contacts.sort((obj1,obj2)
      {
        return  PinyinHelper.getPinyinE(obj1.nickname,separator: '') .compareTo(PinyinHelper.getPinyinE(obj2.nickname,separator: ''));
      });
      _contacts.addAll(contacts);
    }

    widget.delegate.getContacts().then((value){
      if(mounted) {
        _contacts.clear();
        _contacts.addAll(value);

        _contacts.sort((obj1,obj2)
        {
          return PinyinHelper.getPinyinE(obj1.nickname,separator: '') .compareTo(PinyinHelper.getPinyinE(obj2.nickname,separator: ''));;
        });

        setSearchData(textController.text);
      }
    });

  }

  void setSearchData(String text)
  {
    if(mounted)
    {
      if(text == null || text.isEmpty)
      {
        setState(() {
          _searchGroupList = _groupList;
          _searchContactList = _contacts;
        });
      }
      else
      {
        List searchGroupList = List();
        List<ChatUserModel> searchContacts = List();

        for(var group in _groupList)
          {
            if(group.getGroupName().toLowerCase().contains(text.toLowerCase()))
            {
              searchGroupList.add(group);
            }
          }

        for(var contact in _contacts)
        {
          if(contact.nickname.toLowerCase().contains(text.toLowerCase()))
          {
            searchContacts.add(contact);
          }
        }

        if (mounted) {
          setState(() {
            _searchGroupList = searchGroupList;
            _searchContactList = searchContacts;
          });
        }
      }

    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    DartNotificationCenter.subscribe(channel: EaseUIOptions.CHAT_GROUP_NAME_CHANGED_EVENT,observer: this,onNotification: groupNameChanged);
    getGroupList();
    getContacts();
    _searchGroupList = _groupList;
    _searchContactList = _contacts;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    int total = _searchGroupList.length + _searchContactList.length + 3;
    int initialIndex = 1;
    if(widget.customWidgets != null)
    {
      total += widget.customWidgets.length;
      initialIndex += widget.customWidgets.length;
    }

    int groupCount = _searchGroupList.length;



    return
      NotificationListener<ScrollStartNotification>(
        onNotification: (scrollNotification) {
          if(scrollNotification.dragDetails != null)
            {
              FocusScope.of(context).requestFocus(FocusNode());
            }
          return true;
        },
        child: ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return Column(children: <Widget>[
                  Container(
                    height: 56,
                    padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
                    child: WorksSearchBar(
                      controller: textController,
                      padding: EdgeInsets.all(8),
                      placeHold: '输入名称',
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
                ]);
              }
              if (index < initialIndex) {
                return widget.customWidgets[index];
              }

              if (index == initialIndex) {
                return Container(
                  color: const Color(0xfff0f2f5),
                  padding: EdgeInsets.only(left: 12, top: 10, bottom: 10),
                  child: const Text('群组列表', style: TextStyle(fontSize: 17, color: const Color(0xFF333333))),
                );
              }

              int contactIndex = initialIndex + groupCount + 1;

              if (index == contactIndex) {
                return Container(
                  color: const Color(0xfff0f2f5),
                  padding: EdgeInsets.only(left: 12, top: 10, bottom: 10),
                  child: const Text('联系人列表', style: TextStyle(fontSize: 17, color: const Color(0xFF333333))),
                );
              }

              if (index > contactIndex) {
              ChatUserModel userModel = _searchContactList[index - contactIndex - 1];
              return _ContactItemCell(
                userModel,
                tapCallback: () {
                  Navigator.of(context,rootNavigator: true).push(
                      CupertinoPageRoute<void>(builder: (BuildContext context) {
                        return
                          ChatPageScaffold(userModel.userId, EMConversationType.Chat, widget.delegate, currentUserId: widget.currentUserId);
                      }
                      )
                  );


                },
              );
            } else {
              var groupModel = _searchGroupList[index - initialIndex - 1];
              return _ContactItemCell(
                groupModel,
                tapCallback: () {
                  String conversationId;
                  conversationId = groupModel.getGroupId();
                  Navigator.of(context,rootNavigator: true).push(
                      CupertinoPageRoute<void>(builder: (BuildContext context) {
                        return
                          ChatPageScaffold(conversationId, EMConversationType.GroupChat, widget.delegate, currentUserId: widget.currentUserId,conversationTitle: groupModel.getGroupName(),);
                      }
                      )
                  );

                },
              );
            }
          },
            itemCount: total),
      );

  }
  @override
  void dispose() {
    // TODO: implement dispose

    DartNotificationCenter.unsubscribe(observer: this);

    super.dispose();

  }
}

class _ContactItemCell extends CellEvent
{

  final dynamic itemModel;

  Widget buildUserPortrait() {
    Widget portraitWidget;

    if(itemModel is ChatUserModel)
    {
      if (itemModel.avatarURLPath != null && itemModel.avatarURLPath.isNotEmpty) {
        portraitWidget = CachedNetworkImage(
          fit: BoxFit.cover,
          imageUrl: itemModel.avatarURLPath,
        );
      } else if (itemModel.avatarFilePath != null && itemModel.avatarFilePath.isNotEmpty) {
        portraitWidget = Image.asset(
          itemModel.avatarFilePath,
          fit: BoxFit.cover,
        );
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

  _ContactItemCell(this.itemModel,{GestureTapCallback tapCallback}) :super(tapCallback: tapCallback,);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    String title;
    if(itemModel is EMGroup)
      {
        title = (itemModel as EMGroup).getGroupName();
      }
    else  {
        title = (itemModel as ChatUserModel).nickname;
      }

    return BaseCell(child: Container(
    height: 65,
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
            Expanded(
                child: Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 12),
              ),
              buildUserPortrait(),
              Padding(
                padding: EdgeInsets.only(left: 10),
              ),
                  Expanded(child:Text( title ,maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 17,color: const Color(0xFF333333)))),
            ])),
            Divider(
              color: const Color(0xFFF0F2F5),
              indent: 12,
              endIndent: 12,
              height: 1,
              thickness: 1,
            ),
          ])),
      tapCallback: tapCallback,
    );
  }


}

