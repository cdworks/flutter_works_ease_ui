import 'dart:async';
import 'dart:collection';

import 'package:asset_picker/asset_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'dart:io';

import 'package:works_image_picker/works_image_picker.dart';
import 'package:works_utils/works_utils.dart';

import '../ease_ui_options.dart';

class EaseAtTarget
{
  final String userId;
  final String nickname;

  EaseAtTarget(this.userId, this.nickname);

  @override
  // TODO: implement hashCode
  int get hashCode => '$userId$nickname'.hashCode;

  @override
  bool operator ==(other) {
    // TODO: implement ==
    return userId == other.userId && nickname == other.nickname;
  }


}

class BottomInputBar extends StatefulWidget {
  final BottomInputBarDelegate delegate;
  final WorksChangeNotifier closeExtNotifier;
  const BottomInputBar(Key key, this.delegate,this.closeExtNotifier):super(key:key);

  @override
  BottomInputBarState createState() => BottomInputBarState(this.delegate);
}

class BottomInputBarState extends State<BottomInputBar> {

  static const List<String>AllEmojCodes = [
    '\u{1F60a}',
    '\u{1F603}',
    '\u{1F609}',
    '\u{1F62e}',
    '\u{1F60b}',
    '\u{1F60e}',
    '\u{1F621}',
    '\u{1F616}',
    '\u{1F633}',
    '\u{1F61e}',
    '\u{1F62d}',
    '\u{1F610}',
    '\u{1F607}',
    '\u{1F62c}',
    '\u{1F606}',
    '\u{1F631}',
    '\u{1F385}',
    '\u{1F634}',
    '\u{1F615}',
    '\u{1F637}',
    '\u{1F62f}',
    '\u{1F60f}',
    '\u{1F611}',
    '\u{1F496}',
    '\u{1F494}',
    '\u{1F319}',
    '\u{1f31f}',
    '\u{1f31e}',
    '\u{1F308}',
    '\u{1F60d}',
    '\u{1F61a}',
    '\u{1F48b}',
    '\u{1F339}',
    '\u{1F342}',
    '\u{1F44d}'
  ];

  BottomInputBarDelegate delegate;
  WorksCupertinoTextField textField;
  Swiper emojPageView;

  Widget extWidget;

  FocusNode focusNode = FocusNode();
  InputBarStatus inputBarStatus;

//  String message;
  bool isChanged = false;
  int cursorIndex = -1;
  bool isShowVoiceAction = false;

  bool textIsEmpty = true;

  bool isShowKeyboard = false;

  String textFieldOldText = '';

  final controller = new TextEditingController();

  final Set<EaseAtTarget> _atTargets = HashSet();

  StreamSubscription<bool> _keyStream;

  BottomInputBarState(BottomInputBarDelegate delegate) {
    this.delegate = delegate;
    this.inputBarStatus = InputBarStatus.Normal;



    this.extWidget =Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.only(top: 20,bottom: 8),
                child:
                CupertinoButton(
                  onPressed: _selectPicture,
                  padding: EdgeInsets.zero,
                  child:
                  Column(
                    children: <Widget>[
                      Image.asset('easeuiImages/chat/chat_bar_more_photo.png',package: EaseUIOptions.packageName,),
                      Padding(padding: EdgeInsets.only(top: 5),),
                      Text('相册',style: TextStyle(fontSize: 12,color: Color(0xFF808080)),)
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.only(top: 20,bottom: 8),
                child:
                CupertinoButton(
                  onPressed: _takePicture,
                  padding: EdgeInsets.zero,
                  child:
                  Column(
                    children: <Widget>[
                      Image.asset('easeuiImages/chat/chat_bar_more_camera.png',package: EaseUIOptions.packageName),
                      Padding(padding: EdgeInsets.only(top: 5),),
                      Text('拍照',style: TextStyle(fontSize: 12,color: Color(0xFF808080)),)
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.only(top: 20,bottom: 8),
                child:
                CupertinoButton(
                  onPressed: _takeVideo,
                  padding: EdgeInsets.zero,
                  child:
                  Column(
                    children: <Widget>[
                      Image.asset('easeuiImages/chat/chat_bar_more_camera.png',package: EaseUIOptions.packageName),
                      Padding(padding: EdgeInsets.only(top: 5),),
                      Text('拍摄',style: TextStyle(fontSize: 12,color: Color(0xFF808080)),)
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.only(top: 20,bottom: 8),
                child:
                CupertinoButton(
                  onPressed: _takeLocation,
                  padding: EdgeInsets.zero,
                  child:
                  Column(
                    children: <Widget>[
                      Image.asset('easeuiImages/chat/chat_bar_more_location.png',package: EaseUIOptions.packageName),
                      Padding(padding: EdgeInsets.only(top: 5),),
                      Text('位置',style: TextStyle(fontSize: 12,color: Color(0xFF808080)),)
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.only(top: 8,bottom: 18),
                child:
                CupertinoButton(
                  onPressed: _takeFile,
                  padding: EdgeInsets.zero,
                  child:
                  Column(
                    children: <Widget>[
                      Image.asset('easeuiImages/chat/chat_bar_more_file.png',package: EaseUIOptions.packageName),
                      Padding(padding: EdgeInsets.only(top: 5),),
                      Text('文件',style: TextStyle(fontSize: 12,color: Color(0xFF808080)),)
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(),
            ),
          ],
        ),
      ],
    );

    this.textField = WorksCupertinoTextField(
      onSubmitted: _submittedMessage,
//      decoration: BoxDecoration(
//          color: Color(0xfff3f3f3),
////          border: _kDefaultRoundedBorder,
//          borderRadius: BorderRadius.all(Radius.circular(5.0))),

    onEditingComplete: ()
      {
//        _submittedMessage();
      },
//      onChanged: (text)
//      {
//        print('chaned:$text');
//      },

      controller: controller,
      showCursor: true,
      cursorColor: Colors.blue,
      style: TextStyle(fontSize: 15),
//      padding: EdgeInsets.fromLTRB(6, 8, 6, 8),
      maxLines: null,
      textInputAction: Platform.isIOS ? TextInputAction.send : TextInputAction
          .none,
      textAlignVertical: TextAlignVertical.center,
      focusNode: focusNode,
    );
  }

  void insertAtUser(String userId,String nickname,{bool addPre = true,int baseOffset})
  {
    if(!focusNode.hasFocus)
      {
        focusNode.requestFocus();
      }

    if(baseOffset != null)
      {

        controller.selection = TextSelection(baseOffset: baseOffset,extentOffset: baseOffset,affinity: controller.selection.affinity,isDirectional: controller.selection.isDirectional);
      }

    if(controller.text.isEmpty)
    {
      controller.text = addPre ? '@$nickname\u2004' : '$nickname\u2004';
    }
    else
    {
      int baseOffset = controller.selection.baseOffset;
      if(baseOffset < 0 || baseOffset == controller.text.length)
        {
          controller.text = addPre ? '${controller.text}@$nickname\u2004' : '${controller.text}$nickname\u2004';
        }
      else if(baseOffset == 0)
        {
          if(controller.text.length > 0) {
            cursorIndex = addPre ? '@$nickname\u2004'.length : '$nickname\u2004'.length;
          }
          controller.text = addPre ? '@$nickname\u2004${controller.text}' : '$nickname\u2004${controller.text}';
        }
      else
        {
          cursorIndex = controller.selection.baseOffset + (addPre ? '@$nickname\u2004'.length:'$nickname\u2004'.length);
          controller.text = controller.text.replaceRange(baseOffset,baseOffset,addPre ?'@$nickname\u2004':'$nickname\u2004');
        }

    }
    _atTargets.add(EaseAtTarget(userId, nickname));

  }

  @override
  void initState() {

    List<Widget> emojWidget = [];



//    text.substring(startIndex)

    int pageCount = (AllEmojCodes.length + 19) ~/ 20;

    for(int i = 0;i< pageCount;i++)
    {
      int sectionCount = 20;
      if(i == pageCount - 1)
      {
        sectionCount = AllEmojCodes.length - i * 20;
      }
      emojWidget.add(
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
            ),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              if(index == sectionCount)
              {
                return CupertinoButton(
                  onPressed: emojBackAction,
                  padding: EdgeInsets.zero,
                  minSize: 15,
                  child: Icon(Icons.backspace,size: 25,color: Color(0xFF999999),),
                );
              }
              else
              {
                return CupertinoButton(
                  onPressed: ()
                  {
                    emojDownAction(i*20 + index);
                  },
                  padding: EdgeInsets.zero,
                  minSize: 15,
                  child: DefaultTextStyle(
                      style: TextStyle(fontSize: 20),
                      child:

                      Text(AllEmojCodes[i*20 + index])),
                );
              }
            },
            itemCount: sectionCount + 1,
          )
      );
    }

    this.emojPageView = Swiper.children(
      pagination: new SwiperPagination(
          margin: new EdgeInsets.all(10.0),
          builder:  DotSwiperPaginationBuilder(
              activeColor: EaseUIOptions.pageDotActiveColor,
              color:  EaseUIOptions.pageDotNormalColor,
              size: 6,
              activeSize: 8,
              space: 5.0
          )
      ),
      children: emojWidget,
      loop: false,
    );

    widget.closeExtNotifier.addListener(shouldCloseExtBottom);
    textIsEmpty = controller.text.isEmpty;
    controller.addListener(textFieldDidChanged);
    super.initState();

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        _notifyInputStatusChanged(InputBarStatus.Normal);
      }
    });

    if(_keyStream != null)
      {
        _keyStream.cancel();
      }

    _keyStream = KeyboardVisibility.onChange.listen((bool visible) {
      print(visible);
      isShowKeyboard = visible;
      if(visible  == false)
      {
        focusNode.unfocus();
      }
      if(visible == false && inputBarStatus == InputBarStatus.Emoj ||
          inputBarStatus == InputBarStatus.Ext)
      {
        _notifyInputStatusChanged(inputBarStatus);
      }
    });


  }

  

  //点击空白处需要隐藏扩展内容，emoj、功能区
  void shouldCloseExtBottom()
  {
    if(focusNode.hasFocus) {
      focusNode.unfocus();
    }
    if(this.inputBarStatus != InputBarStatus.Voice && this.inputBarStatus !=
        InputBarStatus.Normal) {
      setState(() {
        this.inputBarStatus = InputBarStatus.Normal;
      });

      if (this.delegate != null) {
        this.delegate.inputStatusChanged(InputBarStatus.Normal,needUpdate: false);
      } else {
        print("没有实现 BottomInputBarDelegate");
      }
    }
    if(isShowKeyboard)
      {
        FocusScope.of(context).requestFocus(FocusNode());
      }
  }

  void _submittedMessage(String messageStr) {
    if (messageStr == null || messageStr.length <= 0) {
      print('不能为空');
      return;
    }
    if (this.delegate != null) {
      List<String> atList = [];
      for(var atItem in _atTargets)
        {
          if(messageStr.contains('@${atItem.nickname}\u2004'))
            {
              atList.add(atItem.userId);
            }
        }
      this.delegate.sendText(messageStr,atList);
    } else {
      print("没有实现 BottomInputBarDelegate");
    }
    this.textField.controller.text = '';
    _atTargets.clear();
//    this.message = '';
  }

//  switchExt() {
//    print("switchExtention");
//    if (focusNode.hasFocus) {
//      focusNode.unfocus();
//    }
//    InputBarStatus status = InputBarStatus.Normal;
//    if (this.inputBarStatus != InputBarStatus.Ext) {
//      status = InputBarStatus.Ext;
//    }
//    if (this.delegate != null) {
//      this.delegate.onTapExtButton();
//    } else {
//      print("没有实现 BottomInputBarDelegate");
//    }
//    _notifyInputStatusChanged(status);
//  }

//  sendMessages() {
//    if (message.isEmpty || message.length <= 0) {
//      print('不能为空');
//      return;
//    }
//    if (this.delegate != null && isChanged) {
//      print(message + '...');
//      this.delegate.sendText(message);
//    } else {
//      print("没有实现 BottomInputBarDelegate");
//    }
//    this.textField.controller.text = '';
//    this.message = '';
//  }

//  _onTapVoiceLongPress() {
//    print("_onTapVoiceLongPress");
//  }
//
//  _onTapVoiceLongPressEnd() {
//    print("_onTapVoiceLongPressEnd");
//  }

  void _notifyInputStatusChanged(InputBarStatus status) {
    setState(() {
      this.inputBarStatus = status;
    });

    if (this.delegate != null) {
      this.delegate.inputStatusChanged(status);
    } else {
      print("没有实现 BottomInputBarDelegate");
    }
  }

  Future<void> getAllPhoto() async {
    await showAssetPickNavigationDialog(
        maxNumber: 9,
        context: context,
        textColor: Colors.white,
        photoDidSelectCallBack: (assets) async {
          if (assets != null) {
            this.delegate.onTapItemPicture(assets);
          }
        });
  }

  //textfield 改变
  void textFieldDidChanged()
  {
//    message = controller.text;


  if(controller.text != textFieldOldText)
    {
      String text = controller.text;
      String oldText = text;
      bool changed = false;
      if(text.isNotEmpty && textFieldOldText.length == text.length + 1 && textFieldOldText.contains('\u2004'))
      {
        cursorIndex = -1;
        int textIndex = -1;
        final textRunes = text.runes;
        final oldRunes = textFieldOldText.runes;
        int textLength = textRunes.length;
        int oldLength = oldRunes.length;
        for(int i = 0;i<textLength;i++)
        {
          int reverseIndex = textLength - i - 1;
          int oldReverseIndex = oldLength - i -1;

          if(textRunes.elementAt(i) != oldRunes.elementAt(i))
          {
            textIndex = i;
            break;
          }
          if(textRunes.elementAt(reverseIndex) != oldRunes.elementAt(oldReverseIndex))
          {
            textIndex = oldReverseIndex;
            break;
          }
        }
        if(textIndex != 0 && textIndex != -1 && oldRunes.elementAt(textIndex) == 0x2004)
        {
          int atIndex = -1;
          for(int j = textIndex-1; j>=0;j--)
          {
            if(String.fromCharCode(oldRunes.elementAt(j)) == '@')
            {
              atIndex = j;
              break;
            }
            if(oldRunes.elementAt(j) == 0x2004)
            {
              break;
            }
          }
          if(atIndex != -1)
          {
            changed = true;
            if(atIndex ==0)
            {
              oldText = String.fromCharCodes(oldRunes,textIndex+1,oldLength);
            }
            else
            {
              if(textIndex == oldLength-1)
              {
                oldText = String.fromCharCodes(oldRunes,0,atIndex);
              }
              else
              {
                oldText = String.fromCharCodes(oldRunes,0,atIndex) + String.fromCharCodes(oldRunes,textIndex+1,oldLength);
              }

            }
          }
        }
      }
      else if(text.isNotEmpty && textFieldOldText.length == text.length - 1  && text.contains("@"))
        {

            if(text.split('@').length == textFieldOldText.split('@').length + 1)  //输入了@符号，需要选中要@的人
              {
                 if(delegate != null)
                   {
                     delegate.onSelectAtMember(controller.selection.baseOffset);
                   }
              }
        }


      textFieldOldText = oldText;

      if(changed) {
        int len = controller.text.length - oldText.length;
        final ts = controller.selection;

        int offset = ts.baseOffset - len;
        cursorIndex = offset;
        controller.text = oldText;
      }
      isChanged = true;
      if(oldText.isEmpty)
      {
        if(!textIsEmpty)
        {
          setState(() {
            textIsEmpty = true;
          });
        }
      }
      else
      {
        if(textIsEmpty)
        {
          setState(() {
            textIsEmpty = false;
          });
        }
      }
    }

  if(cursorIndex >= 0)
    {
      int index = cursorIndex;
      cursorIndex = -1;
      controller.selection = TextSelection(baseOffset: index,extentOffset: index,affinity: controller.selection.affinity,isDirectional: controller.selection.isDirectional);
    }

  }

  ///表情回退
  void emojBackAction()
  {
      if(controller.text.isNotEmpty)
        {
          var runes = controller.text.runes;
          if(runes.length == 1)
            {
              controller.text = '';
            }
          else
            {
              controller.text = String.fromCharCodes(runes,0,runes.length-1);
            }

        }
  }
  ///表情添加
  void emojDownAction(int index)
  {
    if(controller.text.isEmpty)
      {
        controller.text = AllEmojCodes[index];
      }
    else
      {
        controller.text = controller.text + AllEmojCodes[index];
      }

  }
  ///点击相册 选择图片
  void _selectPicture() async {

    _notifyInputStatusChanged(InputBarStatus.Normal);

    getAllPhoto();

  }

  ///点击相机拍照
  void _takePicture() async {
    _notifyInputStatusChanged(InputBarStatus.Normal);
    final Map info = await WorksImagePicker.pickImage(source: ImageSource.camera,
        imageQuality: Platform.isIOS ? 100 : 80);
    this.delegate.onTapItemCamera(info);
  }

  ///点击相机录像
  void _takeVideo() async {
    _notifyInputStatusChanged(InputBarStatus.Normal);

    final Map info = await WorksImagePicker.pickVideo(source: ImageSource.camera);
    this.delegate.onTapItemCameraVideo(info);

  }
  ///点击发送位置
  void _takeLocation() async {
    _notifyInputStatusChanged(InputBarStatus.Normal);

    this.delegate.onTapLocation();

  }
  ///点击发送文件
  void _takeFile() async {
    _notifyInputStatusChanged(InputBarStatus.Normal);

    this.delegate.onTapItemFile();
  }

  ///点击表情button
  void _emojButtonAction() {
    if (this.inputBarStatus == InputBarStatus.Emoj) {
      focusNode.requestFocus();
    } else {
      if(isShowKeyboard) {
        FocusScope.of(context).requestFocus(FocusNode());
        this.inputBarStatus = InputBarStatus.Emoj;
      }
      else {
        _notifyInputStatusChanged(InputBarStatus.Emoj);
      }
    }
  }

  ///点击扩展加号

  void _extButtonAction() {
    if(textIsEmpty)
      {
        if (this.inputBarStatus == InputBarStatus.Ext) {
          focusNode.requestFocus();
        } else {
          if(isShowKeyboard) {
            FocusScope.of(context).requestFocus(FocusNode());
            this.inputBarStatus = InputBarStatus.Ext;
          }
          else {
            _notifyInputStatusChanged(InputBarStatus.Ext);
          }
        }
      }
    else
      {
        _submittedMessage(controller.text);
      }
  }

  ///点击录音按钮
  void _recordButtonAction() {
    if (this.inputBarStatus == InputBarStatus.Voice) {
      focusNode.requestFocus();
    } else {
      focusNode.unfocus();
      setState(() {
        this.inputBarStatus = InputBarStatus.Voice;
      });

      if (this.delegate != null) {
        this.delegate.inputStatusChanged(InputBarStatus.Voice,needUpdate: false);
      } else {
        print("没有实现 BottomInputBarDelegate");
      }
    }
  }

  ///录音事件

  void recorderStatusChanged(VoiceStatus status)
  {

    if(this.delegate != null)
      {
        this.delegate.recordVoiceStatusChanged(status);
      }
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: 120,
      padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
      child:
      Column(
        children: <Widget>[
          Row(
//            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              CupertinoButton(
                onPressed: _recordButtonAction,
                minSize: 20,
                padding: EdgeInsets.only(left: 12, right: 10, bottom: 2),
                child: Image.asset(this.inputBarStatus == InputBarStatus.Voice
                    ? 'easeuiImages/chat/chat_bar_more_keyboard.png'
                    : 'easeuiImages/chat/chat_bar_record.png',package: EaseUIOptions.packageName),
              ),
              Expanded(
                flex: 1,
                  child:
                  Stack(
                children: <Widget>[
                  Offstage(
                    offstage: this.inputBarStatus == InputBarStatus.Voice,
                    child: Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        minHeight: 36

                      ),
                      child:
                      this.textField,
                    ),
                  ),
                  Offstage(
                    offstage: this.inputBarStatus != InputBarStatus.Voice,
                    child: VoiceItemWidget(recorderListener: recorderStatusChanged,),
                  ),
                ],
              )
              ),
              CupertinoButton(
                onPressed: _emojButtonAction,
                minSize: 20,
                padding: EdgeInsets.only(left: 10, right: 0, bottom: 2),
                child: Image.asset(this.inputBarStatus == InputBarStatus.Emoj
                    ? 'easeuiImages/chat/chat_bar_more_keyboard.png':'easeuiImages/chat/chat_bar_more_face.png',package: EaseUIOptions.packageName),
              ),

              Container(
                width: 55,
                height: 32,
                padding: EdgeInsets.only(left: 6,right: 6,bottom: 2),
                child: CupertinoButton(
                  onPressed: _extButtonAction,
                  minSize: 20,
                  padding: EdgeInsets.zero,
                  child: textIsEmpty ? Image.asset
                    ('easeuiImages/chat/chat_bar_more_more.png',package: EaseUIOptions.packageName):Container(
                    decoration: BoxDecoration(
                        color: EaseUIOptions.sendBtnBackgroundColor,
                        borderRadius: BorderRadius.all(Radius.circular(5.0))),
                    child: Center(child:Text('发送',style: TextStyle(color:
                    EaseUIOptions.sendBtnTitleColor,
                        fontSize: 14)),),
                  ),
                ),
              )
            ],
          ),

          Padding(padding: EdgeInsets.only(bottom: 8)),
          Divider(color: Color(0xFFEAEAEA),thickness: 1,
            height: 1,),
          Offstage(
            offstage: this.inputBarStatus != InputBarStatus.Emoj,
            child: Container(
                color: Color(0xFFFFFEFF),
                height: MediaQuery.of(context).size.width / 7 * 3 + 26,
                child:
                this.emojPageView
            ),
          ),
          Offstage(
            offstage: this.inputBarStatus != InputBarStatus.Ext,
            child: Container(
                color: Color(0xFFFFFEFF),
              child: this.extWidget
            ),
          )

        ],
      ),
    );
  }
  @override
  void dispose() {
    // TODO: implement dispose
    widget.closeExtNotifier.removeListener(shouldCloseExtBottom);
    controller.removeListener(textFieldDidChanged);
    if(_keyStream != null)
      {
        _keyStream.cancel();
      }
    super.dispose();
  }
}

enum InputBarStatus {
  Normal, //正常
  Voice, //语音输入
  Emoj, //表情
  Ext, //more 图片，视频，定位，文件等
}

enum VoiceStatus {
  None, //正常
  Start, //语音输入
  End, //表情
  Cancel, //more 图片，视频，定位，文件等
}

abstract class BottomInputBarDelegate {
  ///输入工具栏状态发生变更
  void inputStatusChanged(InputBarStatus status,{bool needUpdate = true});

  ///发送消息
  void sendText(String text,List atList);

  ///录音状态发送改变
  void recordVoiceStatusChanged(VoiceStatus status);


  ///点击了加号按钮
  void onTapExtButton();

  ///点击了相机照片
  void onTapItemCamera(Map imgInfo);

  ///点击了相机摄像
  void onTapItemCameraVideo(Map videoInfo);

  ///点击了相册
  void onTapItemPicture(List<Asset> assets);

  ///点击音频
  void onTapItemPhone();

  ///点击了选择文件
  void onTapItemFile();

  ///点击了位置

 void onTapLocation();

 ///选择at的人
 void onSelectAtMember(int offset);

}

///语音bottom控件

class VoiceItemWidget extends StatefulWidget {

  final ValueChanged<VoiceStatus> recorderListener;
  const VoiceItemWidget({Key key, this.recorderListener}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _VoiceItemWidget();
  }
}

class _VoiceItemWidget extends State<VoiceItemWidget> {

  VoiceStatus status = VoiceStatus.None;

  @override
  void initState() {
    // TODO: implement initState
    status = VoiceStatus.None;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: (DragStartDetails details) {
          if(widget.recorderListener != null)
            {
              widget.recorderListener(VoiceStatus.Start);
            }
          setState(() {
            status = VoiceStatus.Start;
          });
        },
        onPanEnd: (details) {
          if(widget.recorderListener != null)
          {
            widget.recorderListener(VoiceStatus.End);
          }
          setState(() {
            status = VoiceStatus.End;
          });
        },
        onPanCancel: () {
          if(widget.recorderListener != null)
          {
            widget.recorderListener(VoiceStatus.End);
          }
          setState(() {
            status = status = VoiceStatus.End;
          });
        },
        onPanUpdate: (DragUpdateDetails details) {
          var offset = details.localPosition;
          if(offset.dx < 5 || offset.dx > context.size.width || offset.dy <
              -100)
            {
              if(status != VoiceStatus.Cancel) {
                if(widget.recorderListener != null)
                {
                  widget.recorderListener(VoiceStatus.Cancel);
                }
                setState(() {
                  status = VoiceStatus.Cancel;
                });
              }
            }
          else
            {

              if(status != VoiceStatus.Start) {
                if(widget.recorderListener != null)
                {
                  widget.recorderListener(VoiceStatus.Start);
                }
                setState(() {
                  status = VoiceStatus.Start;
                });
              }
            }
        },
        child: Container(
          height: 36,
          decoration: BoxDecoration(
              color: status == VoiceStatus.None || status == VoiceStatus.End ? Colors
                  .white : Color
                (0xFFF5F5F5),
              border: Border.all(color: Color(0x33000000)),
              borderRadius: BorderRadius.all(Radius.circular(5.0))),
          child: Center(
              child: Text(
               status == VoiceStatus.None || status == VoiceStatus.End ? '按住说话':
              (status == VoiceStatus.Start ?
            '松开结束' : '松开取消发送'),
            style: TextStyle(fontSize: 15, color: const Color(0xFF999999)),
          )),
        ));
  }


}


