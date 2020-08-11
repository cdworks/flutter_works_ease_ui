import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:works_utils/works_utils.dart';
import 'package:toast/toast.dart';
import 'package:dart_notification_center/dart_notification_center.dart';

import 'chat_history_recorder_page.dart';
import 'chat_mute_duration_page.dart';
import 'chat_mute_list_page.dart';

import '../works_ease_ui.dart';
import 'chat_group_add_member_page.dart';
import 'chat_group_member_page.dart';

class ChatGroupDetailPageScaffold extends CupertinoPageScaffold {
  final String conversationChatter;
  final ChatDelegate delegate; //用于获取用户信息等的接口（代理）
  final String currentUserId; //当前用户id

  final Color titleColor;

  final ValueNotifier<int> groupCountNotifier = ValueNotifier(-1); //群成员人数变化
  final ValueNotifier<bool> allowAddMemberNotifier = ValueNotifier(false); //是否允许添加成员

  final ValueNotifier<EMGroup> groupNotifier = ValueNotifier(null); //是否允许添加成员

  @override
  // TODO: implement navigationBar
  ObstructingPreferredSizeWidget get navigationBar => WorksCupertinoNavigationBar(
        border: null,
        middle: GroupTitleWidget(groupCountNotifier, titleColor),
        trailing: GroupTrailingWidget(conversationChatter, allowAddMemberNotifier, titleColor, this.delegate, this.currentUserId, this.groupNotifier),
      );

  ChatGroupDetailPageScaffold(
    this.delegate,
    this.conversationChatter, {
    Key key,
    this.currentUserId,
    this.titleColor = Colors.white,
  }) : super(key: key, child: const Text(''));

  @override
  // TODO: implement child
  Widget get child => AnnotatedRegion<SystemUiOverlayStyle>(
      value: EaseUIOptions.statusStyle,
      child: SafeArea(
          top: false,
          child: ChatGroupDetailPage(
            this.conversationChatter,
            this.groupCountNotifier,
            this.allowAddMemberNotifier,
            this.delegate,
            this.titleColor,
            this.groupNotifier,
            currentUserId: this.currentUserId,
          )));
}

class GroupTitleWidget extends StatefulWidget {
  final ValueNotifier<int> groupCountNotifier;

  final Color titleColor;

  const GroupTitleWidget(this.groupCountNotifier, this.titleColor);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _GroupTitleWidget();
  }
}

class _GroupTitleWidget extends State<GroupTitleWidget> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FittedBox(fit: BoxFit.contain, child: Text(widget.groupCountNotifier.value > 0 ? '群详情(${widget.groupCountNotifier.value})' : '群详情', style: TextStyle(color: widget.titleColor, fontSize: 17)));
  }
}

class GroupTrailingWidget extends StatefulWidget {
  final ValueNotifier<bool> allowAddMemberNotifier;
  final Color titleColor;

  final ChatDelegate delegate; //用于获取用户信息等的接口（代理）
  final String currentUserId; //当前用户id
  final ValueNotifier<EMGroup> groupNotifier;
  final String conversationChatter;

  const GroupTrailingWidget(this.conversationChatter, this.allowAddMemberNotifier, this.titleColor, this.delegate, this.currentUserId, this.groupNotifier);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _GroupTrailingWidget();
  }
}

class _GroupTrailingWidget extends State<GroupTrailingWidget> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Visibility(
      visible: EaseUIOptions.needAddMember > 0 && widget.allowAddMemberNotifier.value,
      child: CupertinoButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).push(CupertinoPageRoute<void>(builder: (BuildContext context) {
              return ChatGroupAddMemberPageScaffold(
                widget.conversationChatter,
                widget.groupNotifier.value,
                widget.delegate,
                currentUserId: widget.currentUserId,
                titleColor: widget.titleColor,
              );
            }));
          },
          padding: EdgeInsets.only(top: 6, bottom: 6),
          minSize: 30,
          child: Icon(
            Icons.add_circle_outline,
            color: widget.titleColor,
            size: 30,
          )),
    );
  }
}

class ChatGroupDetailPage extends StatefulWidget {
  final ChatDelegate delegate;
  final String currentUserId; //当前用户id
  final String conversationChatter;
  final Color titleColor;
  final ValueNotifier<int> groupCountNotifier;
  final ValueNotifier<bool> allowAddMemberNotifier;
  final ValueNotifier<EMGroup> groupNotifier;

  const ChatGroupDetailPage(this.conversationChatter, this.groupCountNotifier, this.allowAddMemberNotifier, this.delegate, this.titleColor, this.groupNotifier, {Key key, this.currentUserId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChatGroupDetailPage();
}

class MemberModel {
  final String userId;
  ChatUserModel userModel;
  final bool isAdmin;

  MemberModel(this.userId, {this.isAdmin = false});
}

class _ChatGroupDetailPage extends State<ChatGroupDetailPage> implements EMGroupChangeListener {
  EMGroup _group;

  final Map<String, dynamic> _owner = Map(); //拥有者
  final List<MemberModel> _adminList = List();
  final List<MemberModel> _memberList = List();
  bool _isRemoving = true;
  String currentUserId;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isRemoving = true;
    EMClient.getInstance().groupManager().addGroupChangeListener(this);

    _group = widget.groupNotifier.value;
    currentUserId = widget.currentUserId;
    if (currentUserId == null) {
      EMClient.getInstance().getCurrentUser().then((value) {
        currentUserId = value;
      });
    }
    fetchGroupInfo();
  }

  void fetchGroupMembers() {
    EMClient.getInstance().groupManager().fetchGroupMembers(widget.conversationChatter, '', 5, onSuccess: (EMCursorResult result) {
      if (mounted) {
        setState(() {
          addMemberWithList(result.getData());
        });
      }
    }, onError: (int errorCode, String desc) {
      print('获取群成员失败!');
    });
  }

  void fetchGroupInfo() async {
    if (_group == null) {
      EMClient.getInstance().groupManager().getGroupFromServer(widget.conversationChatter).then((value) {
        if(mounted)
          {
            setState(() {
              _isRemoving = false;
            });
          }

        if (value == null) {
          print('获取群失败!');
          Toast.show("获取群详情失败!", context, gravity: Toast.CENTER, backgroundRadius: 8);
        } else {
          widget.groupCountNotifier.value = value.getMemberCount();
          bool isNeedShow = false;
          if (EaseUIOptions.needAddMember > 0) {
            var type = value.getPermissionType();
            bool isAdmin = (type == EMGroupPermissionType.EMGroupPermissionTypeAdmin || type == EMGroupPermissionType.EMGroupPermissionTypeOwner);
            if (isAdmin || (EaseUIOptions.needAddMember == 2 && value.isMemberAllowToInvite())) {
              isNeedShow = true;
            }
          }
          widget.groupNotifier.value = value;

          widget.allowAddMemberNotifier.value = isNeedShow;
          if (mounted) {
            setState(() {
              _group = value;
              updateOwner();
              addAdminWithList();
              fetchGroupMembers();
            });
          }
        }
      });
    } else {
      _isRemoving = false;
      updateOwner();
      addAdminWithList();
      fetchGroupMembers();
    }
  }

  void updateOwner() {
    _owner.clear();
    _owner['userId'] = _group.getOwner();

    if (widget.delegate != null) {
      widget.delegate.getUserInfo(_group.getOwner()).then((userInfo) {
        if (userInfo != null && _owner.containsKey('userId') && userInfo.userId == _owner['userId']) {
          if (mounted) {
            setState(() {
              _owner['userinfo'] = userInfo;
            });
          }
        }
      });
    }
  }

  void addAdminWithList() {
    _adminList.clear();
    if (widget.delegate != null) {
      for (var userId in _group.getAdminList()) {
        var model = MemberModel(userId, isAdmin: true);
        _adminList.add(model);
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
    } else {
      for (var userId in _group.getAdminList()) {
        _adminList.add(MemberModel(userId));
      }
    }
  }

  void addMemberWithList(List groupMember) {
    _memberList.clear();
    var len = groupMember.length;
    if (len > 0) {
      var members = groupMember.sublist(0, min(5, len));

      if (widget.delegate != null) {
        for (var userId in members) {
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
      } else {
        for (var userId in members) {
          _adminList.add(MemberModel(userId));
        }
      }
    }
  }

  Widget settingsWidget(int index) {
    if (index == 0) //群名称
    {
      bool isOwner = _group.getPermissionType() == EMGroupPermissionType.EMGroupPermissionTypeOwner;
      return
        GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: isOwner ? modifyGroupName : null,
            child:
            Container(
          height: 65,
          padding: EdgeInsets.only(left: 12, right: 12),
          child: Stack(alignment: Alignment.centerLeft, children: <Widget>[
            Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(child: Text(isOwner ? "修改群名称" : '群名称', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16, color: const Color(0xFF333333)))),
                  Padding(
                    padding: EdgeInsets.only(left: 5),
                  ),
                  Text(_group.getGroupName(), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16, color: const Color(0xFF999999))),
                  Padding(
                    padding: EdgeInsets.only(left: 5),
                  ),
                  if (isOwner)
                    Icon(
                      Icons.arrow_forward_ios,
                      color: const Color(0xFFe0e2e5),
                      size: 20,
                    )
                ],
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Divider(
                color: const Color(0xFFF0F2F5),
                indent: 12,
                endIndent: 12,
                height: 1,
                thickness: 1,
              ),
            )
          ])));
    } else if (index == 1) {
      return
        Container(
          height: 65,
          padding: EdgeInsets.only(left: 12, right: 12),
          child: Stack(alignment: Alignment.centerLeft, children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(child: Text('消息免打扰', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16, color: const Color(0xFF333333)))),
                Padding(
                  padding: EdgeInsets.only(left: 5),
                ),
                CupertinoSwitch(
                  value: !_group.isPushNotificationEnabled(),
                  onChanged: (isOn) {
                    print('onChanged:$isOn');
                    if (mounted) {
                      setState(() {
                        _isRemoving = true;
                      });
                    }
                    EMClient.getInstance().pushManager().updatePushServiceForGroup([_group.getGroupId()], isOn,onError: (int errorCode, String desc)
                    {
                      if (mounted) {
                        setState(() {
                          _isRemoving = false;
                        });
                      }
                    },
                    onSuccess: ()
                    {
                      if (mounted) {
                        _group.setPushNotificationEnable(!isOn);
                        setState(() {
                          _isRemoving = false;
                        });
                      }
                    });
                  },
                )
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Divider(
                color: const Color(0xFFF0F2F5),
                indent: 12,
                endIndent: 12,
                height: 1,
                thickness: 1,
              ),
            )
          ]));
    } else if (index == 2) {
      return
        GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: ()
            {
              showCupertinoDialog<bool>(
                  context: context,
                  builder: (ctx) {
                    var dialog = CupertinoAlertDialog(
                      content: Text(
                        '确定清除聊天记录?',
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
                            clearMessageRecorder();
                          },
                          child: Text('确定'),
                        ),
                      ],
                    );
                    return dialog;
                  });
            },
            child:
        Container(
          height: 65,
          padding: EdgeInsets.only(left: 12, right: 12),
          child: Stack(alignment: Alignment.centerLeft, children: <Widget>[

              Row(
                      children: <Widget>[
                        Expanded(child: Text('清空聊天记录', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16, color: const Color(0xFF333333)))),
                      ],
                    ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Divider(
                color: const Color(0xFFF0F2F5),
                indent: 12,
                endIndent: 12,
                height: 1,
                thickness: 1,
              ),
            )
          ])));
    } else if (index == 3) {
      return
        GestureDetector(
            onTap: () {
              Navigator.of(context, rootNavigator: true).push(CupertinoPageRoute<void>(builder: (BuildContext context) {
                return ChatSearchHistoryMessagePageScaffold(
                  widget.delegate,
                  widget.conversationChatter,
                  isGroup: true,
                  currentUserId: this.currentUserId,
                  titleColor: widget.titleColor,
                );
              }));
            },
            behavior: HitTestBehavior.opaque,
            child:
            Container(
          height: 65,
          padding: EdgeInsets.only(left: 12, right: 12),
          child: Stack(alignment: Alignment.centerLeft, children: <Widget>[
            Row(
                  children: <Widget>[
                    Expanded(child: Text('查找聊天记录', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16, color: const Color(0xFF333333)))),
                    Padding(
                      padding: EdgeInsets.only(left: 5),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: const Color(0xFFe0e2e5),
                      size: 20,
                    )
                  ],
                ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Divider(
                color: const Color(0xFFF0F2F5),
                indent: 12,
                endIndent: 12,
                height: 1,
                thickness: 1,
              ),
            )
          ])));
    } else if (index == 4) {
      return
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: ()
          {
            Navigator.of(context).push(CupertinoPageRoute<Map>(builder: (BuildContext context) {
              return ChatMuteListPageScaffold(
                groupId: _group.getGroupId(),
                delegate: widget.delegate,
                titleColor: widget.titleColor,
              );
            }));

          },
          child: Container(
              height: 65,
              padding: EdgeInsets.only(left: 12, right: 12),
              child: Stack(alignment: Alignment.centerLeft, children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(child: Text('禁言列表', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16, color: const Color(0xFF333333)))),
                    Padding(
                      padding: EdgeInsets.only(left: 5),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: const Color(0xFFe0e2e5),
                      size: 20,
                    )
                  ],
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Divider(
                    color: const Color(0xFFF0F2F5),
                    indent: 12,
                    endIndent: 12,
                    height: 1,
                    thickness: 1,
                  ),
                )
              ])),
        );
    } else {
      return Container(
          height: 65,
          padding: EdgeInsets.only(left: 12, right: 12),
          child: Stack(alignment: Alignment.centerLeft, children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(child: Text('删除特定时间内的聊天记录', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16, color: const Color(0xFF333333)))),
                Padding(
                  padding: EdgeInsets.only(left: 5),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: const Color(0xFFe0e2e5),
                  size: 20,
                )
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Divider(
                color: const Color(0xFFF0F2F5),
                indent: 12,
                endIndent: 12,
                height: 1,
                thickness: 1,
              ),
            )
          ]));
    }
  }


  //移除成员
  void removeMember(String userId,String userName) {
    if (!_isRemoving) {
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
    if (EaseUIOptions.addOrRemoveMemberBySDK) {
      if (mounted) {
        setState(() {
          _isRemoving = true;
        });
        EMClient.getInstance().groupManager().removeUserFromGroup(widget.conversationChatter, userId, onError: (code, msg) {
          if (mounted) {
            setState(() {
              _isRemoving = false;
            });
          }
          print('removeUsersToGroup error:$msg code:$code');
        }, onSuccess: () {
          if (mounted) {
            setState(() {
              _isRemoving = false;
            });
          }
          print('removeUsersToGroup ok!');
        });
      }
    } else if (widget.delegate != null) //从服务器执行添加功能
        {
      if (mounted) {
        setState(() {
          _isRemoving = true;
        });
      }

      widget.delegate.addGroupMember([]).then((value) {
        if (value.code == 0) {
          if (mounted) {
            setState(() {
              _isRemoving = false;
            });
          } else {
            if (mounted) {
              setState(() {
                _isRemoving = false;
              });
            }
            print('removeUsersToGroup error:${value.message} code:${value.code}');
          }
        }
      });
    } else {
      print('remove groupmember error:not ChatDelegate!');
    }
  }

  //禁言
  void muteMember(String userId,String userName) {

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
        
        EMClient.getInstance().groupManager().muteGroupMembers(_group.getGroupId(), [userId], (muteSeconds * 1000).toString(),onSuccess: (_)
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
        widget.delegate.muteGroupMember(_group.getGroupId(), userId, muteSeconds).then((value)
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

  //修改群名称
  void modifyGroupName() {
    showCupertinoDialog<bool>(
        context: context,
        builder: (ctx) {
          TextEditingController textController = TextEditingController(text: _group.getGroupName());
          var dialog = CupertinoAlertDialog(
            title: Container(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                '修改群名称',
                style: TextStyle(
                  color: const Color(0xff333333),
                  fontSize: 17,
                ),
                strutStyle: StrutStyle(
                  forceStrutHeight: true,
                  height: 2,
                ),
              ),
            ),
            content: WorksCupertinoTextField(
              controller: textController,
              placeholder: '请输入群名称',
              autofocus: true,
              showCursor: true,
              maxLines: 1,
              style: const TextStyle(
                color: const Color(0xff333333),
                fontSize: 15,
              ),
              placeholderStyle: const TextStyle(
                color: CupertinoColors.placeholderText,
                fontSize: 15,
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
                  toModifyName(textController.text);
                },
                child: Text('确定'),
              ),
            ],
          );
          return dialog;
        });
  }

  void toModifyName(String text) {
    if (text.isEmpty) {
      Toast.show("群组名不能为空!", context, gravity: Toast.CENTER, backgroundRadius: 8);
    } else {
      if (EaseUIOptions.modifyGroupNameBySdk) {
        if (mounted) {
          setState(() {
            _isRemoving = true;
          });
        }
        EMClient.getInstance().groupManager().changeGroupName(widget.conversationChatter, text, onError: (int errorCode, String desc) {
          if (mounted) {
            setState(() {
              _isRemoving = false;
            });
          }
          Toast.show("修改群组名失败:$desc", context, gravity: Toast.CENTER, backgroundRadius: 8);
        }, onSuccess: () {
          DartNotificationCenter.post(channel: EaseUIOptions.CHAT_GROUP_NAME_CHANGED_EVENT,options: {'groupId':_group.getGroupId(),'name':text});
          if (mounted) {
            setState(() {
              _group.setGroupName(text);
              _isRemoving = false;
            });
          }
        });
      } else if (widget.delegate != null) {
        if (mounted) {
          setState(() {
            _isRemoving = true;
          });
        }
        widget.delegate.modifyGroupMember(widget.conversationChatter, text).then((value) {

          if (value.code != 0) {
            Toast.show("修改群组名失败:${value.message}", context, gravity: Toast.CENTER, backgroundRadius: 8);
          }
          else
            {
              _group.setGroupName(text);
              DartNotificationCenter.post(channel: EaseUIOptions.CHAT_GROUP_NAME_CHANGED_EVENT,options: {'groupId':_group.getGroupId(),'name':text});
            }
          if (mounted) {
            setState(() {
              _isRemoving = false;
            });
          }
        });
      } else {
        print('error:chatdelegate null at modify group name!');
      }
    }
  }

  //清空聊天记录
  void clearMessageRecorder() {
      EMConversation(widget.conversationChatter).clearAllMessages().then((value)
      {
        DartNotificationCenter.post(channel: EaseUIOptions.CHAT_CONVERSATION_CLEAR_EVENT,options: _group.getGroupId());
      });

  }

  //查找聊天记录
  void searchChatRecorder() {}

  //删除特定时间段的消息内容
  void removeMessageAtTime() {}

  @override
  Widget build(BuildContext context) {
    int section0Len = 0;
    int section1Len = 0;
    int section2Len = 0;
    if (_group != null) {
      section0Len = min(3, 1 + _adminList.length) + 1;
      section1Len = min(4, 1 + _memberList.length) + 1;
      section2Len = 5;
      if (_group.getPermissionType() == EMGroupPermissionType.EMGroupPermissionTypeOwner || _group.getPermissionType() == EMGroupPermissionType.EMGroupPermissionTypeAdmin) {
        section2Len += 2;
      }
    }

    Color sectionColor = Color.fromARGB(255, 157, 170, 179);

    // TODO: implement build
    return Container(
      child: Stack(
        children: <Widget>[
          ListView.builder(
            itemBuilder: (context, index) {
              if (index == 0) //显示标题
              {
                return Container(
                  height: 36,
                  padding: EdgeInsets.only(left: 8),
                  color: sectionColor,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '群主/管理员',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                );
              } else if (index == section0Len) //显示标题
              {
                return Container(
                  padding: EdgeInsets.only(left: 8),
                  height: 36,
                  alignment: Alignment.centerLeft,
                  color: sectionColor,
                  child: Text(
                    '普通成员',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                );
              } else if (index == section1Len + section0Len) //显示标题
              {
                return Container(
                  padding: EdgeInsets.only(left: 8),
                  height: 36,
                  alignment: Alignment.centerLeft,
                  color: sectionColor,
                  child: Text(
                    '设置',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                );
              } else if (index == section1Len + section0Len - 1) {
                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).push(CupertinoPageRoute<void>(builder: (BuildContext context) {
                      return ChatGroupMemberPageScaffold(
                        _group,
                        widget.delegate,
                        currentUserId: widget.currentUserId,
                        titleColor: widget.titleColor,
                      );
                    }));
                  },
                  child: Container(
                    height: 65,
                    child: Center(
                        child: Text(
                      '查看更多',
                      style: TextStyle(color: Color(0xff333333), fontSize: 16),
                    )),
                  ),
                );
              } else if (index < section0Len) //群主管理员
              {
                String typeName = '管理员';
                ChatUserModel userModel;
                if (index == 1) {
                  typeName = '群主';
                  userModel = _owner.containsKey('userinfo') ? _owner['userinfo'] : null;
                } else {
                  int adminIndex = index - 2;

                  userModel = _adminList[adminIndex].userModel;
                }

                return MemberItemCell(
                  userModel,
                  typeName,
                  tapCallback: () {
                    String userId = index == 1 ? _owner['userId'] : _adminList[index - 2].userId;
                    if (currentUserId != null && userId != null && userId != currentUserId) {
                      showCupertinoModalPopup<int>(
                          context: context,
                          builder: (ctx) {
                            return CupertinoActionSheet(
                              cancelButton: CupertinoActionSheetAction(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                  },
                                  child: Text(
                                    "取消",
                                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
                                  )),
                              actions: <Widget>[
                                CupertinoActionSheetAction(
                                    onPressed: () async {
                                      Navigator.pop(ctx, 1);
                                      var newRoute = CupertinoPageRoute<void>(builder: (BuildContext context) => ChatPageScaffold(userId, EMConversationType.Chat, widget.delegate, currentUserId: widget.currentUserId));

                                      Navigator.of(context).pushAndRemoveUntil(newRoute, ModalRoute.withName(EaseUIOptions.CHAT_ROUTE_NAME));
                                    },
                                    child: Text('聊天', style: TextStyle(color: Colors.blue))),
                              ],
                            );
                          });
                    }
                  },
                );
              } else if (index < section0Len + section1Len) // 成员
              {
                ChatUserModel userModel = _memberList[index - section0Len - 1].userModel;
                return MemberItemCell(
                  userModel,
                  '',
                  tapCallback: () {
                    var model = _memberList[index - section0Len - 1];
                    String userId = model.userId;
                    if (currentUserId != null && userId != null && userId != currentUserId) {
                      var groupType = _group.getPermissionType();
                      bool isAdmin = (groupType == EMGroupPermissionType.EMGroupPermissionTypeAdmin || groupType == EMGroupPermissionType.EMGroupPermissionTypeOwner);
                      showCupertinoModalPopup<int>(
                          context: context,
                          builder: (ctx) {
                            return CupertinoActionSheet(
                              cancelButton: CupertinoActionSheetAction(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                  },
                                  child: Text(
                                    "取消",
                                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
                                  )),
                              actions: <Widget>[
                                CupertinoActionSheetAction(
                                    onPressed: () async {
                                      Navigator.pop(ctx, 1);
                                      var newRoute = CupertinoPageRoute<void>(builder: (BuildContext context) => ChatPageScaffold(userId, EMConversationType.Chat, widget.delegate, currentUserId: widget.currentUserId));

                                      Navigator.of(context).pushAndRemoveUntil(newRoute, ModalRoute.withName(EaseUIOptions.CHAT_ROUTE_NAME));
                                    },
                                    child: Text('聊天', style: TextStyle(color: Colors.blue))),
                                if (isAdmin)
                                  CupertinoActionSheetAction(
                                      onPressed: () async {
                                        Navigator.pop(ctx, 1);
                                        String userName;
                                        var userModel = _memberList[index - section0Len - 1].userModel;
                                        if(userModel != null)
                                          {
                                            userName = userModel.nickname;
                                          }
                                        muteMember(userId,userName);
                                      },
                                      child: Text('设置群内禁言', style: TextStyle(color: Colors.blue))),
                                if (EaseUIOptions.needRemoveMember && isAdmin)
                                  CupertinoActionSheetAction(
                                      onPressed: () async {
                                        Navigator.pop(ctx, 1);
                                        removeMember(userId,model.userModel != null ? model.userModel.nickname : model.userId);
                                      },
                                      child: Text('移除该成员', style: TextStyle(color: Colors.blue))),
                              ],
                            );
                          });
                    }
                  },
                );
              } else if (index > section1Len + section0Len) //设置
              {
                int settingIndex = index - section1Len - section0Len - 1;
                return settingsWidget(settingIndex);
              }

              return Container(
                height: 20,
              );
            },
            itemCount: section0Len + section1Len + section2Len,
          ),
          Visibility(
            visible: _isRemoving,
            child: Container(
              color: Colors.white12,
              child: Center(child: CupertinoActivityIndicator()),
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
    EMClient.getInstance().groupManager().removeGroupChangeListener(this);
  }

  /// GroupChangeListener

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
  Future<void> onMemberExited(String groupId, String member) async {
    // TODO: implement onMemberExited
    _group = await EMClient.getInstance().groupManager().getGroup(widget.conversationChatter);
    widget.groupNotifier.value = _group;
    fetchGroupMembers();
  }

  @override
  Future<void> onMemberJoined(String groupId, String member) async {
    // TODO: implement onMemberJoined
    _group = await EMClient.getInstance().groupManager().getGroup(widget.conversationChatter);
    widget.groupNotifier.value = _group;
    fetchGroupMembers();
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

class MemberItemCell extends CellEvent {
  final ChatUserModel itemModel;

  final String typeName;

  Widget buildUserPortrait() {
    Widget portraitWidget;

    if (itemModel != null) {
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

  MemberItemCell(this.itemModel, this.typeName, {GestureTapCallback tapCallback})
      : super(
          tapCallback: tapCallback,
        );

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    String title = '';

    if (itemModel != null) {
      title = itemModel.nickname;
      if (typeName.isNotEmpty) {
        title += ' [$typeName]';
      }
    }

    return BaseCell(
      child: Container(
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
              Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16, color: const Color(0xFF333333)))),
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
