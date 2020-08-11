

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:works_utils/works_utils.dart';

import '../works_ease_ui.dart';

const List _muteDurationList = [
  {"title":"5分钟" ,"duration":300},
  {"title":"10分钟" ,"duration":600},
  {"title":"20分钟" ,"duration":1200},
  {"title":"半小时" ,"duration":1800},
  {"title":"1小时" ,"duration":3600},
  {"title":"2小时" ,"duration":7200},
  {"title":"4小时" ,"duration":14400},
  {"title":"6小时" ,"duration":21600},
  {"title":"8小时" ,"duration":28800},
  {"title":"12小时" ,"duration":43200},
  {"title":"1天" ,"duration":86400},
  {"title":"永久" ,"duration":0}];

class ChatMuteDurationPageScaffold extends CupertinoPageScaffold {

//  final String userId;
//  final String userName;

  final Color titleColor;

  @override
  // TODO: implement navigationBar
  ObstructingPreferredSizeWidget get navigationBar {

    return WorksCupertinoNavigationBar(
//        isAutoWrapWithBackground: true,
      border: null,
      middle:FittedBox(
        fit: BoxFit.contain, child:
      Text(
          '选择禁言时间',
          style: TextStyle(color: titleColor)
      ),
      ),
    );
  }

  const ChatMuteDurationPageScaffold(
      {Key key,
//        @required this.userId,
//        @required this.userName,
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
          const ChatMuteDurationPage()));
}

class ChatMuteDurationPage extends StatefulWidget
{
  const ChatMuteDurationPage();

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return  _ChatMuteDurationPageState();
  }

}

class _ChatMuteDurationPageState extends State<ChatMuteDurationPage>
{

  int _selectIndex = 0;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return
      Column(
        children: <Widget>[
          Expanded(child: ListView(
            itemExtent: 55,
            children: <Widget>[
              for(int index = 0; index < _muteDurationList.length;index++)
                Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: ()
                      {
                        if(_selectIndex != index && mounted) {
                          setState(() {
                            _selectIndex = index;
                          });
                        }
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(padding: EdgeInsets.only(left: 16),),
                          Expanded(child:Text(_muteDurationList[index]['title'],style: TextStyle(color: index == _selectIndex ?Colors.blue : Color(0xff333333),fontSize: 16),)),
                          Visibility(visible: index == _selectIndex ,child: Icon(Icons.check,color: Colors.blue,size: 25,)),
                          Padding(padding: EdgeInsets.only(right: 16),),
                        ],
                      ),
                    )
                    ,
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
                  ],
                )
            ],
          ),),

          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Divider(
                color: const Color(0xFFF0F2F5),
                indent: 12,
                endIndent: 12,
                height: 1,
                thickness: 1,
              ),

              Container(
                height: 65,
                padding: EdgeInsets.only(left: 16,right: 16,top: 12,bottom: 12),
                child:
                CupertinoButton(
                  onPressed: ()
                  {
                    print('pop');
                    Navigator.of(context).pop({'title':_muteDurationList[_selectIndex]['title'],'duration':_muteDurationList[_selectIndex]['duration']});
                  },
                  padding: EdgeInsets.zero,
                  borderRadius : const BorderRadius.all(Radius.circular(12.0)),
                  color: Colors.green,
                  child: Text('确定',style: TextStyle(color: Colors.white,fontSize: 17),),
                )
                ,
              )
            ],
          )
        ],
      );
  }

}