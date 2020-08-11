

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:works_utils/works_utils.dart';
import 'package:toast/toast.dart';

import '../works_ease_ui.dart';
import 'chat_mute_duration_page.dart';
import 'chat_group_detail_page.dart' show MemberModel,MemberItemCell;

class ChatGroupMemberPageScaffold extends CupertinoPageScaffold {

  final ChatDelegate delegate;  //用于获取用户信息等的接口（代理）
  final String currentUserId;  //当前用户id

  final Color titleColor;
  final bool fromAt; //是否是选中@的人
  final EMGroup group;

  @override
  // TODO: implement navigationBar
  ObstructingPreferredSizeWidget get navigationBar => WorksCupertinoNavigationBar(
    border: null,
    middle: FittedBox(
      fit: BoxFit.contain,child:Text(fromAt ? '选择提醒的人' : '群成员(${group.getMemberCount()})',style: TextStyle(color: titleColor),)),
  );


  const ChatGroupMemberPageScaffold(
      this.group,
      this.delegate,
      {Key key,
        this.currentUserId,
        this.fromAt = false,
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
          ChatGroupMemberPage(
            this.delegate,
            this.group,
            this.fromAt,
            this.titleColor,
            currentUserId: this.currentUserId,
          )
      ));
}


class ChatGroupMemberPage extends StatefulWidget {

  final ChatDelegate delegate;
  final String currentUserId;  //当前用户id
  final bool fromAt; //是否是选中@的人
  final EMGroup group;
  final Color titleColor;
  const ChatGroupMemberPage(
      this.delegate,
      this.group,
      this.fromAt,
      this.titleColor,
      {Key key,this.currentUserId})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChatGroupMemberPage();
}

class _ChatGroupMemberPage extends State<ChatGroupMemberPage>
    implements EMGroupChangeListener
{

  List<MemberModel> _memberList = List();

  List<MemberModel> _searchMemberList;

  String currentUserId;

  bool _isRemoving = false;

  TextEditingController textController = TextEditingController();


  void addMemberWithList(List groupMember)
  {
    _memberList.clear();
    
    if(widget.delegate != null)
    {
      if(!widget.fromAt || widget.currentUserId == null || widget.currentUserId != widget.group.getOwner()) {
        var ownerModel = MemberModel(widget.group.getOwner(), isAdmin: true);
        _memberList.add(ownerModel);
        widget.delegate.getUserInfo(ownerModel.userId).then((userInfo) {
          if (userInfo != null) {
            if (mounted) {
              setState(() {
                ownerModel.userModel = userInfo;
              });
            }
          }
        });
      }

      widget.group.getAdminList().forEach((element)
      {
        if(!widget.fromAt || widget.currentUserId == null || widget.currentUserId != element) {
          var model = MemberModel(element, isAdmin: true);
          _memberList.add(model);
          widget.delegate.getUserInfo(element).then((userInfo) {
            if (userInfo != null) {
              if (mounted) {
                setState(() {
                  model.userModel = userInfo;
                });
              }
            }
          });
        }
      });

      for(var userId in groupMember)
      {
        if(!widget.fromAt || widget.currentUserId == null || widget.currentUserId != userId) {
          var model = MemberModel(userId);
          _memberList.add(model);
          widget.delegate.getUserInfo(userId).then((userInfo) {
            if (userInfo != null) {
              if (mounted) {
                setState(() {
                  model.userModel = userInfo;
                });
              }
            }
          });
        }
      }
    }
    else
    {
      if(!widget.fromAt || widget.currentUserId == null || widget.currentUserId != widget.group.getOwner()) {
        _memberList.add(MemberModel(widget.group.getOwner()));
      }
      widget.group.getAdminList().forEach((element) {
        if(!widget.fromAt || widget.currentUserId == null || widget.currentUserId != element) {
          _memberList.add(MemberModel(element));
        }
      });
      for(var userId in groupMember)
      {
        if(!widget.fromAt || widget.currentUserId == null || widget.currentUserId != userId) {
          _memberList.add(MemberModel(userId));
        }
      }
    }
  }

  void getGroupMemberList() async
  {

    EMClient.getInstance().groupManager().fetchGroupMembers(widget.group.getGroupId(), '', -1,onSuccess: (EMCursorResult result)
    {
      if(mounted) {
        setState(() {
          addMemberWithList(result.getData());
          setSearchData(textController.text);
        });

      }
    },onError: (int errorCode, String desc)
    {
      print('获取群成员失败!');
    });
  }

  void setSearchData(String text)
  {
    if(mounted)
    {
      if(text == null || text.isEmpty)
      {
        setState(() {
          _searchMemberList = _memberList;
        });
      }
      else
      {
        List<MemberModel> searchMemberList = List();

        for(var member in _memberList)
        {
          if(member.userModel != null && member.userModel.nickname.toLowerCase().contains(text.toLowerCase()))
          {
            searchMemberList.add(member);
          }
        }

        setState(() {
          _searchMemberList = searchMemberList;
        });
      }

    }
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isRemoving = false;
    EMClient.getInstance().groupManager().addGroupChangeListener(this);

    currentUserId = widget.currentUserId;
    if(currentUserId == null)
    {
      EMClient.getInstance().getCurrentUser().then((value) {
        currentUserId = value;
      });
    }

    getGroupMemberList();
    _searchMemberList = _memberList;
  }


  //移除成员
  void removeMember(String userId,String userName)
  {
    if(!_isRemoving)
    {
      showCupertinoDialog<bool>(
          context: context,
          builder: (ctx) {
            var dialog = CupertinoAlertDialog(
              content: Text(
                '确定要从该群移除“$userName”?',
                style: TextStyle(
                  color: const Color(0xff333333),
                  fontSize: 17,
                ),
                strutStyle: StrutStyle(
                  forceStrutHeight: true,
                  height: 2,
                ),
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                  onPressed: () {
                    Navigator.pop(ctx);
                  },
                  child: Text('取消'),
                ),
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  onPressed: () {
                    Navigator.pop(ctx);
                    toRemoveMember(userId);
                  },
                  child: Text('确定'),
                ),
              ],
            );
            return dialog;
          });

    }

  }

  void toRemoveMember(String userId)
  {
    FocusScope.of(context).requestFocus(FocusNode());
    if(EaseUIOptions.addOrRemoveMemberBySDK)
    {
      if(mounted)
      {
        setState(() {
          _isRemoving = true;
        });
        EMClient.getInstance().groupManager().removeUserFromGroup(widget.group.getGroupId(), userId,
            onError: (code,msg)
            {
              if(mounted)
              {
                setState(() {
                  _isRemoving = false;
                });
              }
              print('removeUsersToGroup error:$msg code:$code');
            },onSuccess: ()
            {
              if(mounted) {
                setState(() {
                  _isRemoving = false;
                });
              }
              print('removeUsersToGroup ok!');
            });
      }

    }
    else if(widget.delegate != null)//从服务器执行添加功能
        {
      if (mounted) {
        setState(() {
          _isRemoving = true;
        });
      }

      widget.delegate.addGroupMember([]).then((value)
      {
        if(value.code == 0) {
          if (mounted) {
            setState(() {
              _isRemoving = false;
            });
          }
          else {
            if (mounted) {
              setState(() {
                _isRemoving = false;
              });
            }
            print('removeUsersToGroup error:${value.message} code:${value.code}');
          }
        }
      });
    }
    else
    {
      print('remove groupmember error:not ChatDelegate!');
    }
  }


  //禁言
  void muteMember(String userId,String userName)
  {
    Navigator.of(context, rootNavigator: true).push(CupertinoPageRoute<Map>(builder: (BuildContext context) {
      return ChatMuteDurationPageScaffold(
        titleColor: widget.titleColor,
      );
    })).then((value)
    {
      if(value != null && value.isNotEmpty)
      {

        final String nickName = userName ?? userId;

        showCupertinoDialog<bool>(
            context: context,
            builder: (ctx) {
              var dialog = CupertinoAlertDialog(
                content: Text(
                  '确定要对“$nickName”进行${value['title']}禁言?',
                  style: TextStyle(
                    color: const Color(0xff333333),
                    fontSize: 17,
                  ),
                  strutStyle: StrutStyle(
                    forceStrutHeight: true,
                    height: 2,
                  ),
                ),
                actions: <Widget>[
                  CupertinoDialogAction(
                    onPressed: () {
                      Navigator.pop(ctx);
                    },
                    child: Text('取消'),
                  ),
                  CupertinoDialogAction(
                    isDestructiveAction: true,
                    onPressed: () {
                      Navigator.pop(ctx);
                      toMuteUser(userId,value['duration']);
                    },
                    child: Text('确定'),
                  ),
                ],
              );
              return dialog;
            });
      }
    });
  }

  void toMuteUser(String userId,int muteSeconds)
  {
    if(EaseUIOptions.muteMemberBySdk)
    {
      if(mounted)
      {
        setState(() {
          _isRemoving = true;
        });
      }

      EMClient.getInstance().groupManager().muteGroupMembers(widget.group.getGroupId(), [userId], (muteSeconds * 1000).toString(),onSuccess: (_)
      {
        if (mounted) {
          setState(() {
            _isRemoving = false;
          });
        }
        Toast.show("禁言成功", context, gravity: Toast.CENTER, backgroundRadius: 8);
      },onError: (int errorCode, String desc)
      {
        Toast.show("禁言失败:$desc", context, gravity: Toast.CENTER, backgroundRadius: 8);
      });

    }
    else if(widget.delegate != null)
    {
      if(mounted)
      {
        setState(() {
          _isRemoving = true;
        });
      }
      widget.delegate.muteGroupMember(widget.group.getGroupId(), userId, muteSeconds).then((value)
      {
        if (value.code != 0) {
          Toast.show("禁言失败:${value.message}", context, gravity: Toast.CENTER, backgroundRadius: 8);
        }
        else
        {
          Toast.show("禁言成功", context, gravity: Toast.CENTER, backgroundRadius: 8);
        }
        if (mounted) {
          setState(() {
            _isRemoving = false;
          });
        }
      });
    }
    else
    {
      print('error: mute user without chatDelegate!!');
    }
  }


  void showOperator(String userId,String userName)
  {
    if(currentUserId != null && userId != null && userId != currentUserId) {

      var groupType = widget.group.getPermissionType();
      bool isAdmin = (groupType == EMGroupPermissionType.EMGroupPermissionTypeAdmin || groupType == EMGroupPermissionType.EMGroupPermissionTypeOwner);

      showCupertinoModalPopup<int>(
          context: context,
          builder: (ctx) {
            return CupertinoActionSheet(
              cancelButton: CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.pop(ctx);
                  },
                  child: Text("取消", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),)),
              actions: <Widget>[
                CupertinoActionSheetAction(
                    onPressed: () async {
                      FocusScope.of(context).requestFocus(FocusNode());
                      Navigator.pop(ctx, 1);
                      var newRoute = CupertinoPageRoute<void>(builder: (BuildContext context) =>
                          ChatPageScaffold(userId, EMConversationType.Chat, widget.delegate, currentUserId: widget.currentUserId)
                      );

                      Navigator.of(context).pushAndRemoveUntil(newRoute, ModalRoute.withName(EaseUIOptions.CHAT_ROUTE_NAME));
                    },
                    child: Text('聊天', style: TextStyle(color: Colors.blue))),
                if(isAdmin)
                  CupertinoActionSheetAction(
                      onPressed: () async {
                        FocusScope.of(context).requestFocus(FocusNode());
                        Navigator.pop(ctx, 1);
                        muteMember(userId,userName);
                      },
                      child: Text('设置群内禁言', style: TextStyle(color: Colors.blue))),
                if(EaseUIOptions.needRemoveMember && isAdmin)
                  CupertinoActionSheetAction(
                      onPressed: () async {
                        Navigator.pop(ctx, 1);
                        removeMember(userId,userName);
                      },
                      child: Text('移除该成员', style: TextStyle(color: Colors.blue))),
              ],
            );
          });
    }
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return
      Container(
        child: Stack(
          children: <Widget>[
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
                    else
                    {
                      var model = _searchMemberList[index - 1].userModel;

                      return MemberItemCell(
                        model,
                        '',
                        tapCallback: () {
                          MemberModel model =  _searchMemberList[index - 1];

                          if(widget.fromAt)
                            {
                               Navigator.of(context).pop(model);
                            }
                          else
                            {
                              String userId = model.userId;
                              showOperator(userId,model.userModel!= null ?model.userModel.nickname:model.userId);
                            }


                        },
                      );
                    }

                  },
                  itemCount: _searchMemberList.length + 1),
            ),
            Visibility(
              visible: _isRemoving,
              child: Container(
                color: Colors.white12,
                child: Center(child:CupertinoActivityIndicator()),
              ),
            )
          ],
        ),
      );

  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

  }

  ///

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

    getGroupMemberList();

  }

  @override
  void onMemberJoined(String groupId, String member) {
    // TODO: implement onMemberJoined
    getGroupMemberList();
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
