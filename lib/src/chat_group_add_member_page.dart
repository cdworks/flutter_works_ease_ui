
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:works_utils/works_utils.dart';

import '../works_ease_ui.dart';

class ChatGroupAddMemberPageScaffold extends CupertinoPageScaffold {

  final ChatDelegate delegate;  //用于获取用户信息等的接口（代理）
  final String currentUserId;  //当前用户id
  final ValueNotifier<int> selectMemberNotifier = ValueNotifier(0);//是否允许添加成员

  @override
  createState() {
    // TODO: implement createState
    return super.createState();
  }

  final WorksChangeNotifier addMemberNotifier = WorksChangeNotifier();  //确定按钮点击事件


  final EMGroup group;

  final String groupId;

  final Color titleColor;

  
  @override
  // TODO: implement navigationBar
  ObstructingPreferredSizeWidget get navigationBar => WorksCupertinoNavigationBar(
    border: null,
    middle:FittedBox(
      fit: BoxFit.contain,child: Text('选择联系人',style: TextStyle(color: titleColor),)),
    trailing: GroupAddMemberTrailingWidget(titleColor, selectMemberNotifier,this.delegate,this.addMemberNotifier),
  );


   ChatGroupAddMemberPageScaffold(
       this.groupId,
      this.group,
      this.delegate,
      {Key key,
        this.currentUserId,
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
          ChatGroupAddMemberPage(
            this.groupId,
            this.group,
            this.delegate,
            this.selectMemberNotifier,
            this.addMemberNotifier,
            currentUserId: this.currentUserId,
          )
      ));
}

class GroupAddMemberTrailingWidget extends StatefulWidget
{
  final ValueNotifier<int> selectMemberNotifier;
  final Color titleColor;
  final ChatDelegate delegate;  //用于获取用户信息等的接口（代理）

  final WorksChangeNotifier addMemberNotifier;
  const GroupAddMemberTrailingWidget(this.titleColor,this.selectMemberNotifier,this.delegate,this.addMemberNotifier);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _GroupAddMemberTrailingWidget();
  }

}

class _GroupAddMemberTrailingWidget extends State<GroupAddMemberTrailingWidget>
{


  void numberDidChanged()
  {
    if (mounted) {
      setState(() {

      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.selectMemberNotifier.addListener(numberDidChanged);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return CupertinoButton(
        onPressed: widget.selectMemberNotifier.value > 0 ? () {
            widget.addMemberNotifier.notifyListeners();
        } : null,
        padding: EdgeInsets.only(top: 6, bottom: 6),
        child: FittedBox(
            fit: BoxFit.contain,
            child: Text(
              widget.selectMemberNotifier.value <= 0 ? '确定' : '确定(${widget.selectMemberNotifier.value})',
              style: TextStyle(color: widget.selectMemberNotifier.value > 0 ? widget.titleColor : Color(0xffd8d8da)),
            )));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    widget.selectMemberNotifier.removeListener(numberDidChanged);
  }

}

class ChatGroupAddMemberPage extends StatefulWidget {

  final ChatDelegate delegate;
  final String currentUserId;  //当前用户id
  final ValueNotifier<int> selectMemberNotifier;
  final WorksChangeNotifier addMemberNotifier;
  final EMGroup group;

  final String groupId;

  const ChatGroupAddMemberPage(
      this.groupId,
      this.group,
      this.delegate,
      this.selectMemberNotifier,
      this.addMemberNotifier,
      {Key key,this.currentUserId})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChatGroupAddMemberPage();
}


class _ChatGroupAddMemberPage extends State<ChatGroupAddMemberPage>
    implements EMGroupChangeListener
{

  List<_MemberSltModel> _contacts = List();

  List<_MemberSltModel> _searchContactList;

  TextEditingController textController = TextEditingController();

  List<dynamic> _groupMembers;

  EMGroup _group;

  bool _isAdding = false;


  void getData({bool isNeedLoadContacts = true})
  {

    if(_group == null || _group.getOccupants().length < _group.getMemberCount()) {
      EMClient.getInstance().groupManager().fetchGroupMembers(widget.group.getGroupId(), '', -1, onSuccess: (EMCursorResult result) {
        _groupMembers = result.getData();
        if(isNeedLoadContacts) {
          getContacts();
        }
        else if(_contacts.isNotEmpty && mounted)
          {
            if (mounted) {
              setState(() {
                _contacts.forEach((element) {
                  if (_groupMembers.contains(element.userModel.userId)) //不可选
                      {
                    if (element.status == 1) {
                      widget.selectMemberNotifier.value = max(0, widget
                          .selectMemberNotifier.value - 1);
                    }
                    element.status = -1;
                  }
                  else //可选
                      {
                    if (element.status == -1) {
                      element.status = 0;
                    }
                  }
                });
              });
            }

          }
      }, onError: (int errorCode, String desc) {
        print('获取群成员失败!');
      });
    }
    else
      {
          _groupMembers = _group.getOccupants();
          if(isNeedLoadContacts) {
            getContacts();
          }
          else if(_contacts.isNotEmpty && mounted)
          {
            setState(() {
              _contacts.forEach((element) {
                if(_groupMembers.contains(element.userModel.userId))  //不可选
                    {
                  if (element.status == 1) {
                    widget.selectMemberNotifier.value = max(0, widget.selectMemberNotifier.value - 1);
                  }
                  element.status = -1;

                }
                else  //可选
                    {
                  if(element.status == -1)
                  {
                    element.status = 0;
                  }
                }
              });
            });

          }
      }


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
      List<_MemberSltModel> models = [];
      if(_groupMembers.isNotEmpty)
        {
          contacts.forEach((element) {
            var model = _MemberSltModel(element);
            if (_groupMembers.contains(element.userId)) {
               model.status = -1;
            }
            models.add(model);
          });
        }
      else
        {
          contacts.forEach((element) {
            models.add(_MemberSltModel(element));
          });
        }
      if(mounted) {
        setState(() {
          _contacts.addAll(models);
        });

      }
    }

    widget.delegate.getContacts().then((value){
      if(mounted) {
        _contacts.clear();

        List<_MemberSltModel> models = [];
        if(_groupMembers.isNotEmpty)
        {
          value.forEach((element) {
            var model = _MemberSltModel(element);
            if (_groupMembers.contains(element.userId)) {
              model.status = -1;
            }
            models.add(model);
          });
        }
        else
        {
          value.forEach((element) {
            models.add(_MemberSltModel(element));
          });
        }

        _contacts.addAll(models);

        _contacts.sort((obj1,obj2)
        {
          return PinyinHelper.getPinyinE(obj1.userModel.nickname,separator: '') .compareTo(PinyinHelper.getPinyinE(obj2.userModel.nickname,separator: ''));;
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
          _searchContactList = _contacts;
        });
      }
      else
      {
        List<_MemberSltModel> searchContacts = List();
        for(var contact in _contacts)
        {
          if(contact.userModel.nickname.toLowerCase().contains(text.toLowerCase()))
          {
            searchContacts.add(contact);
          }
        }

        setState(() {
          _searchContactList = searchContacts;
        });
      }

    }
  }

  void addMember()
  {
    if(!_isAdding)
      {
        FocusScope.of(context).requestFocus(FocusNode());

        if(EaseUIOptions.addOrRemoveMemberBySDK)
        {
          List<String> members = [];
          _contacts.forEach((element) {
            if(element.status == 1) members.add(element.userModel.userId);
          });
          if(members.isNotEmpty && mounted)
            {
              setState(() {
                _isAdding = true;
              });
              EMClient.getInstance().groupManager().addUsersToGroup(widget.groupId, members,
                  onError: (code,msg)
              {
                if(mounted)
                  {
                    setState(() {
                      _isAdding = false;
                    });
                  }
                print('addUsersToGroup error:$msg code:$code');
              },onSuccess: ()
              {
                if(mounted) {
                  setState(() {
                    _isAdding = false;
                  });
                }
                Navigator.of(context).pop();
                print('addUsersToGroup ok!');
              });
            }
          else if(members.isEmpty)
            {
              print('no add user!');
            }

        }
        else if(widget.delegate != null)//从服务器执行添加功能
            {
          setState(() {
            _isAdding = true;
          });

          List<String> members = [];
          _contacts.forEach((element) {
            if(element.status == 1) members.add(element.userModel.userId);
          });
          if(members.isNotEmpty && mounted) {
            widget.delegate.addGroupMember(members).then((value) {
              if (value.code == 0) {
                if (mounted) {
                  setState(() {
                    _isAdding = false;
                  });
                  Navigator.of(context).pop();
                }
                else {
                  if (mounted) {
                    setState(() {
                      _isAdding = false;
                    });
                  }
                  print('addUsersToGroup error:${value.message} code:${value.code}');
                }
              }
            });
          }
          else if(members.isEmpty)
          {
            print('no add user!');
          }
        }
        else
        {
          print('add groupmember error:not ChatDelegate!');
        }

      }

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isAdding = false;
    widget.addMemberNotifier.addListener(addMember);
    EMClient.getInstance().groupManager().addGroupChangeListener(this);

    _group = widget.group;
    getData();

    _searchContactList = _contacts;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return
    Container(
      child:
          Stack(
           children: <Widget>[
             Column(
               children: <Widget>[
                 Column(children: <Widget>[
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

                           var model = _searchContactList[index];

                           return _ContactItemCell(
                             model,
                             tapCallback: () {
                               if(model.status != -1) {
                                 if (model.status == 1) {
                                   widget.selectMemberNotifier.value = max(0, widget.selectMemberNotifier.value - 1);
                                 }
                                 else {
                                   widget.selectMemberNotifier.value = widget.selectMemberNotifier.value + 1;
                                 }
                                 setState(() {
                                   model.status = (model.status + 1) % 2;
                                   print('stats:${model.status}');
                                 });
                               }

                             },
                           );
                         },
                         itemCount: _searchContactList.length),
                   ),
                 )
               ],
             ),
             Visibility(
               visible: _isAdding,
               child: Container(
                 color: Colors.white12,
                 child: Center(child:CupertinoActivityIndicator()),
               ),
             )
           ],
          )
    );

  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    widget.addMemberNotifier.removeListener(addMember);
    EMClient.getInstance().groupManager().removeGroupChangeListener(this);
  }


  /// EMGroupChangeListener

  @override
  void onAdminAdded(String groupId, String administrator) {
    // TODO: implement onAdminAdded
  }

  @override
  void onAdminRemoved(String groupId, String administrator) {
    // TODO: implement onAdminRemoved
  }

  @override
  void onAnnouncementChanged(String groupId, String announcement) {
    // TODO: implement onAnnouncementChanged
  }

  @override
  void onAutoAcceptInvitationFromGroup(String groupId, String inviter, String inviteMessage) {
    // TODO: implement onAutoAcceptInvitationFromGroup
  }

  @override
  void onGroupDestroyed(String groupId, String groupName) {
    // TODO: implement onGroupDestroyed
  }

  @override
  void onInvitationAccepted(String groupId, String invitee, String reason) {
    // TODO: implement onInvitationAccepted
  }

  @override
  void onInvitationDeclined(String groupId, String invitee, String reason) {
    // TODO: implement onInvitationDeclined
  }

  @override
  void onInvitationReceived(String groupId, String groupName, String inviter, String reason) {
    // TODO: implement onInvitationReceived
  }

  @override
  void onMemberExited(String groupId, String member) {
    // TODO: implement onMemberExited

    if(mounted) {
      getData(isNeedLoadContacts: false);
    }
  }

  @override
  void onMemberJoined(String groupId, String member) {
    // TODO: implement onMemberJoined
    if(mounted) {
      getData(isNeedLoadContacts: false);
    }
  }

  @override
  void onMuteListAdded(String groupId, List mutes, int muteExpire) {
    // TODO: implement onMuteListAdded
  }

  @override
  void onMuteListRemoved(String groupId, List mutes) {
    // TODO: implement onMuteListRemoved
  }

  @override
  void onOwnerChanged(String groupId, String newOwner, String oldOwner) {
    // TODO: implement onOwnerChanged
  }

  @override
  void onRequestToJoinAccepted(String groupId, String groupName, String accepter) {
    // TODO: implement onRequestToJoinAccepted
  }

  @override
  void onRequestToJoinDeclined(String groupId, String groupName, String decliner, String reason) {
    // TODO: implement onRequestToJoinDeclined
  }

  @override
  void onRequestToJoinReceived(String groupId, String groupName, String applicant, String reason) {
    // TODO: implement onRequestToJoinReceived
  }

  @override
  void onSharedFileAdded(String groupId, EMMucSharedFile sharedFile) {
    // TODO: implement onSharedFileAdded
  }

  @override
  void onSharedFileDeleted(String groupId, String fileId) {
    // TODO: implement onSharedFileDeleted
  }

  @override
  void onUserRemoved(String groupId, String groupName) {
    // TODO: implement onUserRemoved
  }
}
class _MemberSltModel
{
  int status; //-1 不能选择 0 未选中 1 选中
  final ChatUserModel userModel;

  _MemberSltModel(this.userModel,{this.status = 0});
}

class _ContactItemCell extends StatelessWidget
{

  final _MemberSltModel _itemModel;

  final GestureTapCallback tapCallback;

  Widget buildUserPortrait() {
    Widget portraitWidget;

    ChatUserModel userModel = _itemModel.userModel;

    if (userModel.avatarURLPath != null && userModel.avatarURLPath.isNotEmpty) {
      portraitWidget = CachedNetworkImage(
        fit: BoxFit.cover,
        imageUrl: userModel.avatarURLPath,
      );
    } else if (userModel.avatarFilePath != null && userModel.avatarFilePath.isNotEmpty) {
      portraitWidget = Image.asset(
        userModel.avatarFilePath,
        fit: BoxFit.cover,
      );
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

  _ContactItemCell(this._itemModel,{this.tapCallback});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    String title = _itemModel.userModel.nickname;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: Container(
        height: 65,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
          Expanded(
              child:
              Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 12),
                ),
                if(_itemModel.status == 0)
                  Icon(Icons.radio_button_unchecked,size: 30,color: Colors.black26,)
                else if(_itemModel.status == 1)
                  Icon(Icons.check_circle,size: 30,color: Colors.blue,)
                else
                  Icon(Icons.check_circle,size: 30,color: Colors.black26,),
                Padding(
                  padding: EdgeInsets.only(left: 8),
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
      onTap: tapCallback,
    );
  }


}
