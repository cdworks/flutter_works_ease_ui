import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:toast/toast.dart';
//import 'package:fluttertoast/fluttertoast.dart' as toast;
import 'package:sprintf/sprintf.dart';
import 'chat_delegate.dart';

import 'ease_ui_options.dart';

enum PromptBoxLocation { TOP, BOTTOM, CENTER }

class EmojUtil
{
//  static Rich
}

class TimeUtil {

  //将 unix 时间戳转换为特定时间文本，如年月日
  static String convertTime(int timestamp) {
    DateTime msgTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    DateTime nowTime = DateTime.now();

    String timeString =  sprintf('%02d:%02d',[msgTime.hour,msgTime.minute]);

    if(nowTime.year == msgTime.year) {//同一年
      if(nowTime.month == msgTime.month) {//同一月
        if(nowTime.day == msgTime.day) {//同一天 时:分
          return timeString;
        }else {
          if(nowTime.day - msgTime.day == 1) {//昨天
            return "昨天";
          }else if(nowTime.day - msgTime.day < 7 && nowTime.day > msgTime.day) {
            return _getWeekday(msgTime.weekday) + ' $timeString';
          }
          else
          {
            return msgTime.month.toString()+"月"+msgTime.day.toString()+'日 ' +
                timeString;
          }

        }
      }
      else
        {
           return msgTime.month.toString()+"月"+msgTime.day.toString()+'日 ' +
               timeString;
        }
    }
    return msgTime.year.toString() + "年"+msgTime.month.toString()+"月"+msgTime
        .day
        .toString()+'日 ' +
        timeString;
  }

  ///是否需要显示时间，相差 5 分钟
  static bool needShowTime(int sentTime1,int sentTime2) {
    return (sentTime1-sentTime2).abs() > 5 * 60 * 1000;
  }

  static String _getWeekday(int weekday) {
    switch (weekday) {
      case 1:return "星期一";
      case 2:return "星期二";
      case 3:return "星期三";
      case 4:return "星期四";
      case 5:return "星期五";
      case 6:return "星期六";
      default:return "星期日";
    }
  }
}

class EMLayout {
  static const double emConListPortraitSize = 46;
  static const double emConListItemHeight = 74;
  static const double emConListUnreadSize = 12;
  static const double emSearchBarHeight = 36;
  static const double emContactListPortraitSize = 38;
  static const double emContactListItemHeight = 58;

}

class EMFont{
  static const double emAppBarTitleFont = 18;
  static const double emSearchBarFont = 16;
  static const double emConListTitleFont = 16;
  static const double emConListTimeFont = 12;
  static const double emConUnreadFont = 12;
  static const double emConListContentFont = 14;
}

/*
 * 常用图片按钮
 */
class SimpleImageButton extends StatefulWidget {
  final String normalImage;
  final String pressedImage;
  final Function onPressed;
  final double width;
  final String title;

  const SimpleImageButton({
    Key key,
    @required this.normalImage,
    @required this.pressedImage,
    @required this.onPressed,
    @required this.width,
    this.title,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SimpleImageButtonState();
  }
}

class _SimpleImageButtonState extends State<SimpleImageButton> {
  @override
  Widget build(BuildContext context) {
    return ImageButton(
      normalImage: Image(
        image: AssetImage(widget.normalImage),
        width: widget.width,
        height: widget.width,
      ),
      pressedImage: Image(
        image: AssetImage(widget.pressedImage),
        width: widget.width,
        height: widget.width,
      ),
      title: widget.title == null ? '' : widget.title,
      //文本是否为空
      normalStyle: TextStyle(
          color: Colors.white, fontSize: 14, decoration: TextDecoration.none),
      pressedStyle: TextStyle(
          color: Colors.white, fontSize: 14, decoration: TextDecoration.none),
      onPressed: widget.onPressed,
    );
  }
}

/*
 * 图片 按钮
 */
class ImageButton extends StatefulWidget {
  //常规状态
  final Image normalImage;

  //按下状态
  final Image pressedImage;

  //按钮文本
  final String title;

  //常规文本TextStyle
  final TextStyle normalStyle;

  //按下文本TextStyle
  final TextStyle pressedStyle;

  //按下回调
  final Function onPressed;

  //文本与图片之间的距离
  final double padding;

  ImageButton({
    Key key,
    @required this.normalImage,
    @required this.pressedImage,
    @required this.onPressed,
    this.title,
    this.normalStyle,
    this.pressedStyle,
    this.padding,
  }) : super(key: key);

  @override
  _ImageButtonState createState() {
    return _ImageButtonState();
  }
}

class _ImageButtonState extends State<ImageButton> {
  var isPressed = false;

  @override
  Widget build(BuildContext context) {
    double padding = widget.padding == null ? 0 : widget.padding;
    return GestureDetector(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          isPressed ? widget.pressedImage : widget.normalImage, //不同状态显示不同的Image
          widget.title.isNotEmpty
              ? Padding(padding: EdgeInsets.fromLTRB(0, padding, 0, 0))
              : Container(),
          widget.title.isNotEmpty //文本是否为空
              ? Text(
            widget.title,
            style: isPressed ? widget.pressedStyle : widget.normalStyle,
          )
              : Container(),
        ],
      ),
      onTap: widget.onPressed,
      onTapDown: (d) {
        //按下，更改状态
        setState(() {
          isPressed = true;
        });
      },
      onTapCancel: () {
        //取消，更改状态
        setState(() {
          isPressed = false;
        });
      },
      onTapUp: (d) {
        //抬起，更改按下状态
        setState(() {
          isPressed = false;
        });
      },
    );
  }
}

class WidgetUtil {

  static const int INTERVAL_IN_MILLISECONDS = 60 * 1000;


  /// 会话页面加号扩展栏里面的 widget，上面图片，下面文本
  static Widget buildExtensionWidget(String iconPath,String text,bool
  _isDark,Function()clicked) {
    return Container(
      margin:  EdgeInsets.fromLTRB(1,0,1,0),
      decoration: BoxDecoration(
        border: Border.all(width: 6, color: Color(0xffe5e5e5)),
        borderRadius: const BorderRadius.all(const Radius.circular(8)),
        color: Colors.red,
      ),
      padding: EdgeInsets.fromLTRB(0,5,0,0),
      child: ImageButton(
        normalImage: Image.asset(iconPath),
        pressedImage: Image.asset(iconPath),
        title: text ,
        padding: 5 ,
        normalStyle: new TextStyle(),
        onPressed: (){
          if(clicked != null){
            clicked();
          }
        },
      ),
    );
  }

  /// 用户头像
  static Widget buildUserPortrait(ChatUserModel model) {
    Widget portraitWidget;
    if(model != null) {
      if (model.avatarURLPath != null && model.avatarURLPath.isNotEmpty) {
        portraitWidget = CachedNetworkImage(
          fit: BoxFit.cover,
          imageUrl: model.avatarURLPath,
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
        height: EMLayout.emConListPortraitSize,
        width: EMLayout.emConListPortraitSize,
        child: portraitWidget,
      ),
    );
  }

  /// 会话页面录音时的 widget，gif 动画
  static Widget buildVoiceRecorderWidget() {
    return Container(
      padding: EdgeInsets.fromLTRB(50, 0, 50, 200),
      alignment: Alignment.center,
      child: Container(
        width: 150,
        height: 150,
        child: Image.asset("assets/images/voice_recoder.gif"),
      ),
    );
  }

  /// 消息 item 上的时间
  static Widget buildMessageTimeWidget(String sentTime) {
    return Column(
      children: <Widget>[
        Padding(padding: EdgeInsets.only(top: 8),),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(left: 6, right: 6),
                  color: Color(0xffD0D2D5),
                  height: 22,
                  child: Text(
                    TimeUtil.convertTime(int.parse(sentTime)),
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  )),
            )
          ],
        ),
        Padding(padding: EdgeInsets.only(top: 17),),
      ],
    );
  }

  /// 长按的 menu，用于处理会话列表页面和会话页面的长按
  static void showLongPressMenu(BuildContext context,Offset tapPos,Map<String,String> map,Function(String key)onSelected) {
    final RenderBox overlay =Overlay.of(context).context.findRenderObject();
    final RelativeRect position = RelativeRect.fromLTRB(
        tapPos.dx, tapPos.dy,
        overlay.size.width - tapPos.dx,
        overlay.size.height - tapPos.dy
    );
    List<PopupMenuEntry<String>>  items = new List();
    map.keys.forEach((String key) {
      PopupMenuItem<String> p = PopupMenuItem(
        child: Container(
          alignment: Alignment.center,
          child: Text(map[key],textAlign: TextAlign.center,),
        ),
        value: key,
      );
      items.add(p);
    });
    showMenu<String>(
        context: context,
        position: position,
        items: items
    ).then<String>((String selectedStr) {
      if(onSelected != null) {
        if(selectedStr == null) {
          selectedStr = "UndefinedKey";
        }
        onSelected(selectedStr);
      }
      return selectedStr;
    });
  }


  /// 空白 widget ，用于处理非法参数时的占位
  static Widget buildEmptyWidget() {
    return Container(
      height: 1,
      width: 1,
    );
  }

  static bool isChinese(String str) {
    for(int i = 0; i < str.length;i ++) {
      int a = str.codeUnitAt(i);
      if(a > 0x4e00 && a < 0x9fff) {
        return true;
      }
    }
    return false;
  }

//  /// 提示框
//  static hintBoxWithDefault(String msg) {
////    Future.sync((){
////    });
//
//    toast.Fluttertoast.showToast(
//        msg: msg,
//        toastLength: toast.Toast.LENGTH_SHORT,
//        gravity: toast.ToastGravity.CENTER,
//        timeInSecForIos: 2,
//        backgroundColor: Colors.black,
//        textColor: Colors.white,
//        fontSize: 15.0
//    );
//  }

//  static hintBoxWithCustom(String msg, PromptBoxLocation location,int timeInSecForIos, Color backgroundColor, Color textColor, double fontSize) {
//    toast.ToastGravity gravity;
//    if(location == PromptBoxLocation.TOP) {
//      gravity = toast.ToastGravity.TOP;
//    } else if(location == PromptBoxLocation.CENTER){
//      gravity = toast.ToastGravity.CENTER;
//    } else {
//      gravity = toast.ToastGravity.BOTTOM;
//    }
//    toast.Fluttertoast.showToast(
//        msg: msg,
//        toastLength: toast.Toast.LENGTH_SHORT,
//        gravity: gravity,
//        timeInSecForIos: timeInSecForIos,
//        backgroundColor: backgroundColor,
//        textColor: textColor,
//        fontSize: fontSize
//    );
//  }

  ///判断消息时间间隔
  static bool isCloseEnough(String time1,String time2) {
    int lastTime = int.parse(time1);
    int afterTime = int.parse(time2);
    int delta = lastTime - afterTime;
    if (delta < 0) {
      delta = -delta;
    }
    return delta > INTERVAL_IN_MILLISECONDS;
  }

//  static AppBar buildAppBar(BuildContext context, String title){
//    return AppBar(
//      elevation: 0,
//      centerTitle : true,
//      backgroundColor: ThemeUtils.isDark(context) ? EMColor.darkAppMain : EMColor.appMain,
//      title: Text(title, style: TextStyle(fontSize:EMFont.emAppBarTitleFont, color: ThemeUtils.isDark(context) ? EMColor.darkText : EMColor.text)),
//    );
//  }
}