

import 'dart:collection';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:works_ease_ui/src/chat_group_detail_page.dart';

import 'package:works_utils/works_utils.dart';

import '../works_ease_ui.dart';
import 'package:toast/toast.dart';
import 'package:toast/toast.dart';

class ChatMuteListPageScaffold extends CupertinoPageScaffold {

  final String groupId;
  final Color titleColor;
  final ChatDelegate delegate;

  @override
  // TODO: implement navigationBar
  ObstructingPreferredSizeWidget get navigationBar {

    return WorksCupertinoNavigationBar(
//        isAutoWrapWithBackground: true,
      border: null,
      middle:FittedBox(
        fit: BoxFit.contain, child:
      Text(
          '禁言列表',
          style: TextStyle(color: titleColor)
      ),
      ),
    );
  }

  const ChatMuteListPageScaffold(
      {Key key,
        @required this.groupId,
        @required this.delegate,
        this.titleColor = Colors.white
      }) : super(key: key, child: const Text(''));

  @override
  // TODO: implement child
  Widget get child => AnnotatedRegion<SystemUiOverlayStyle>(
      value: EaseUIOptions.statusStyle,
      child:
      SafeArea(
          top: false,
          child:
           ChatMuteListPage(groupId: this.groupId,delegate: delegate,)));
}

class ChatMuteListPage extends StatefulWidget
{

  final String groupId;
  final ChatDelegate delegate;

   ChatMuteListPage({
  @required groupId, this.delegate}):assert(groupId != null),this.groupId = groupId;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return  _ChatMuteListPageState();
  }

}

class _ChatMuteListPageState extends State<ChatMuteListPage> {

  List<MemberModel> muteMembers = [];
  bool _isShowMore = false;
  final ScrollController _scrollController = ScrollController();
  bool isLoading;
  bool isLoadingMore = false;
  int _page = 1;
  bool isUnMuting;

  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isUnMuting = false;
    isLoadingMore = false;
    _page = 1;
    isLoading = true;
    muteMembers.clear();
    
    requestMuteMember();
    
    _scrollController.addListener(() {
      //此处要用 == 而不是 >= 否则会触发多次
      if (_isShowMore && _scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent && !isLoadingMore) {
        _loadMore();
      }
    });
  }

  void requestMuteMember()
  {

    EMClient.getInstance().groupManager().fetchGroupMuteList(widget.groupId, _page, 50,onError: (code,msg)
    {
      if(mounted) {
        setState(() {
          isLoading = false;
        });

        Toast.show("获取禁言列表失败:$msg", context,gravity: Toast.CENTER,backgroundRadius: 8);

      }
    },onSuccess: (list)
    {
      if(widget.delegate != null) {
        list.forEach((element) {
          final  model = MemberModel(element);
          muteMembers.add(model);
          widget.delegate.getUserInfo(element).then((userInfo)
          {
            if(userInfo != null) {
              if(mounted)
              {
                setState(() {
                  model.userModel = userInfo;
                });
              }
            }
          });
        });
      }
      else
      {
        list.forEach((element) => muteMembers.add(MemberModel(element)));
      }
      _isShowMore = list.length >= 50;
      if(mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }
  
  void _loadMore()
  {
    _page++;
    isLoadingMore = true;
    EMClient.getInstance().groupManager().fetchGroupMuteList(widget.groupId, _page, 50,onSuccess: (list)
    {
      isLoadingMore = false;
      if(mounted) {
        setState(() {
          if(widget.delegate != null) {
            list.forEach((element) {
             final  model = MemberModel(element);
              muteMembers.add(model);
              widget.delegate.getUserInfo(element).then((userInfo)
              {
                if(userInfo != null) {
                  if(mounted)
                  {
                    setState(() {
                      model.userModel = userInfo;
                    });
                  }
                }
              });
            });
          }
          else
            {
              list.forEach((element) => muteMembers.add(MemberModel(element)));
            }
          _isShowMore = list.length >= 50;
        });
      }
    },onError: (_,__)
    {
      isLoadingMore = false;
    });
  }

  void toUnMuteUser(MemberModel model)
  {

    if(EaseUIOptions.muteMemberBySdk)
      {
        if(mounted)
        {
          setState(() {
            isUnMuting = true;
          });
        }
        EMClient.getInstance().groupManager().unMuteGroupMembers(widget.groupId, [model.userId],onError: (code,msg)
        {
          if(mounted)
          {
            setState(() {
              isUnMuting = false;
            });
          }

          Toast.show("解除禁言失败:$msg", context,gravity: Toast.CENTER,backgroundRadius: 8);

        },onSuccess: (_)
        {
          
          muteMembers.remove(model);
          
          if(mounted)
          {
            setState(() {
              isUnMuting = false;
            });
          }

          Toast.show("解除禁言成功", context,gravity: Toast.CENTER,backgroundRadius: 8);

        });
      }
    else if(widget.delegate != null)
      {
        if(mounted)
        {
          setState(() {
            isUnMuting = true;
          });
        }
        widget.delegate.unMuteMember(widget.groupId, model.userId).then((value)
        {
          if(value.code == 0)
            {
              muteMembers.remove(model);
              Toast.show("解除禁言成功", context,gravity: Toast.CENTER,backgroundRadius: 8);
            }
          else
            {
              Toast.show("解除禁言失败:${value.message}", context,gravity: Toast.CENTER,backgroundRadius: 8);
            }

          if(mounted)
          {
            setState(() {
              isUnMuting = false;
            });
          }

        });
      }
    else
      {
        print('error:unMuteMember without chatdelegate!!');
      }



  }
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return
     Stack(
       children: <Widget>[
         ListView.builder(
           controller: _scrollController,
           itemBuilder: (ctx,index){

             if(muteMembers.isEmpty)
               {
                 return Container(child: Center(child: Text('暂无禁言成员',style: TextStyle(fontSize: 16, color: const Color(0xFF333333)),),),);
               }

             if(index < muteMembers.length)
             {
               var model =  muteMembers[index];
               return _MuteItemCell(
                 model.userModel,
                 '',
                 tapCallback: isUnMuting ? null : () {
                   showCupertinoDialog<bool>(
                       context: context,
                       builder: (ctx) {
                         String nickName = model.userModel == null ? model.userId : model.userModel.nickname;

                         var dialog = CupertinoAlertDialog(
                           content: Text(
                             '确定要解除对“$nickName”的禁言?',
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
                                 toUnMuteUser(model);
                               },
                               child: Text('确定'),
                             ),
                           ],
                         );
                         return dialog;
                       });
                 },
               );
             }
             return Container(child: Center(
               child: CupertinoActivityIndicator(),
             ),);
           },
           itemCount: isLoading ? 0 : (_isShowMore ?  muteMembers.length + 1 : muteMembers.isEmpty ? 1 : muteMembers.length),
           itemExtent: 65,
         ),
         Visibility(visible: isLoading || isUnMuting,child: Center(child: CupertinoActivityIndicator(),))
       ],
     );
  }
}


class _MuteItemCell extends CellEvent {
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

  _MuteItemCell(this.itemModel, this.typeName, {GestureTapCallback tapCallback})
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
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                  ),
                  Text('解除禁言', style: TextStyle(fontSize: 16, color: const Color(0xFFF66863))),
                  Padding(
                    padding: EdgeInsets.only(right: 12),
                  ),
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

