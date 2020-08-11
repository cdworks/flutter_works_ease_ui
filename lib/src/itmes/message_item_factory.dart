
import 'package:asset_picker/asset_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:works_ease_ui/src/itmes/ease_message_model.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'dart:io';
import 'package:works_utils/works_utils.dart';
import 'dart:math';

import '../../works_ease_ui.dart';


class MessageItemFactory extends StatelessWidget {
  final EaseMessageModel messageModel;
  const MessageItemFactory({Key key, this.messageModel}) : super(key: key);

  ///获取文件类型的icon
  String getFileIcon(String fileName)
  {

    if(fileName != null)
      {
        String lowString = fileName.toLowerCase();
        if(lowString.endsWith(".pdf"))
        {
          return 'easeuiImages/chat/file_type_pdf.png';
        }
        else if(lowString.endsWith(".zip") ||
            lowString.endsWith(".rar") ||
            lowString.endsWith(".7z") ||
            lowString.endsWith(".tar") ||
            lowString.endsWith(".gz") ||
            lowString.endsWith(".xz"))
        {
          return 'easeuiImages/chat/file_type_zip.png';
        }
        else if(lowString.endsWith(".doc") || lowString.endsWith(".docx"))
        {
          return 'easeuiImages/chat/file_type_word.png';
        }
        else if(lowString.endsWith(".xls") || lowString.endsWith(".xlsx")
            || lowString.endsWith(".xlsm") || lowString.endsWith(".xlsb")
            || lowString.endsWith(".xltm")
        )
        {
          return 'easeuiImages/chat/file_type_excel.png';
        }
        else if(lowString.endsWith(".ppt") || lowString.endsWith(".pptx"))
        {
          return 'easeuiImages/chat/file_type_ppt.png';
        }
        else if(lowString.endsWith(".txt") || lowString.endsWith(".rtf"))
        {
          return 'easeuiImages/chat/file_type_text.png';
        }
        else if(lowString.endsWith(".mp3") ||
            lowString.endsWith(".wma") ||
            lowString.endsWith(".acc") ||
            lowString.endsWith(".amr"))
        {
          return 'easeuiImages/chat/file_type_voice.png';
        }
        else if(lowString.endsWith(".mp4") ||
            lowString.endsWith(".avi") ||
            lowString.endsWith(".rm") ||
            lowString.endsWith(".rmvb") ||
            lowString.endsWith(".mov") ||
            lowString.endsWith(".3gp") ||
            lowString.endsWith(".wmv")
        )
        {
          return 'easeuiImages/chat/file_type_video.png';
        }
      }


    return 'easeuiImages/chat/file_type_unkown.png';
  }

  ///文本消息 item
  Widget textMessageItem(double maxWidth) {

    EMMessage message = messageModel.message;
    EMTextMessageBody msg = message.body;
    return Container(
        constraints:  BoxConstraints(
          minWidth: 20.0,
          maxWidth: maxWidth,
        ),
      padding: EdgeInsets.only(top: 10,left: message.direction ==
          Direction.SEND ?
      10 : 18,right: message.direction ==
          Direction.SEND ?
          18 : 10,bottom: 12),
      child:Text( msg.message, style: TextStyle(fontSize: 15,color: message
          .direction == Direction.SEND ? EaseUIOptions.msgSenderTextColor:
      EaseUIOptions.msgReceiverTextColor
      ),),
    );
  }

  ///图片消息 item
  ///优先读缩略图，否则读本地路径图，否则读网络图
  Widget imageMessageItem(double scale) {

    EMMessage message = messageModel.message;

    EMImageMessageBody msg = message.body;

    double imageWidth = msg.width.toDouble();
    double imageHeight = msg.height.toDouble();
    if (msg.width == 0 || msg.height == 0) {
      imageWidth = 120;
      imageHeight = 120;
    }
    else if (msg.width > msg.height) {
      imageHeight = 130 / imageWidth * imageHeight;
      imageWidth = 130;
      if(imageHeight < 50)
        imageHeight = 50;
      else if(imageHeight > 800)
        imageHeight = 800;
    }
    else {
      imageWidth = 150 / imageHeight * imageWidth;
      imageHeight = 150;
      if(imageWidth < 30)
        imageWidth = 30;
      else if(imageWidth > 250)
        imageWidth = 250;
    }

    Widget widget;
//    if(msg.thumbnailLocalPath != null && msg.thumbnailLocalPath.isNotEmpty)
//      {
//        String path = MediaUtil.instance.getCorrectedLocalPath(msg.thumbnailLocalPath);
//        File file = File(path);
//        if(file != null && file.existsSync())
//          {
//            widget = Image.file(file,width: imageWidth,height: imageHeight,
//              fit: BoxFit.cover,cacheWidth: (imageWidth*scale).toInt(),
//              cacheHeight:
//    (imageHeight*scale).toInt(),);
//          }
//
//      }

    if(msg.thumbnailLocalPath != null &&  msg.thumbnailLocalPath.isNotEmpty)
    {
      File file = File(msg.thumbnailLocalPath);
      if(file != null && file.existsSync())
      {
        widget = Image(image: WorksFileImage(file,cacheWidth: (imageWidth*scale).toInt(),cacheHeight:
        (imageHeight*scale).toInt()),width: imageWidth,height:
        imageHeight,fit: BoxFit.cover);
//            Image.file(file,width: imageWidth,height: imageHeight,fit: BoxFit
//            .cover,
//          cacheWidth: (imageWidth*scale).toInt(),cacheHeight:
//          (imageHeight*scale).toInt(),);
      }
    }

    if(widget == null && msg.localUrl != null &&  msg.localUrl.isNotEmpty)
    {

      File file = File(msg.localUrl);
      if(file != null && file.existsSync())
      {
        widget = widget = Image(image: WorksFileImage(file,cacheWidth: (imageWidth*scale).toInt(),cacheHeight:
        (imageHeight*scale).toInt()),
          width:
        imageWidth,height:
        imageHeight,fit: BoxFit.cover,);
//            Image.file(file,width: imageWidth,height: imageHeight,fit: BoxFit
//            .cover,
//          cacheWidth: (imageWidth*scale).toInt(),cacheHeight:
//          (imageHeight*scale).toInt(),);
      }
      else if(Platform.isIOS && (message.status == null || message.status !=
          Status.SUCCESS))  //需要向native获取相片数据
        {
          int thumbWidth = (imageWidth * scale).toInt();
          int thumbHeight = (imageHeight * scale).toInt();
          widget =
          Container(
            width: imageWidth,
            height: imageHeight,
            child: AssetThumbImage(asset: Asset(msg.localUrl, thumbWidth,
                thumbHeight),width:
            thumbWidth,height: thumbHeight,index: 0,),
          );
        }
    }

    if(widget == null) {
      if (msg.thumbnailUrl != null && msg.thumbnailUrl.length > 0) {
        widget = Image(image:WorksNetworkImage(msg.thumbnailUrl,cacheWidth: (imageWidth*scale).toInt(),cacheHeight:
        (imageHeight*scale).toInt()),width:
        imageWidth,height:
        imageHeight,
          fit:
          BoxFit.cover,);
//            Image.network(msg.thumbnailUrl,cacheWidth: (imageWidth*scale).toInt(),cacheHeight:
//          (imageHeight*scale).toInt(),);
      } else {
        widget = Image(image:WorksNetworkImage(msg.remoteUrl,cacheWidth:
        (imageWidth*scale).toInt(),cacheHeight:
        (imageHeight*scale).toInt()),width:
        imageWidth,height:
        imageHeight,
          fit:
          BoxFit.cover,);
      }
    }
    return widget;
  }

  ///视频消息 item
  Widget videoMessageItem(double scale) {

    EMMessage message = messageModel.message;

    EMVideoMessageBody msg = message.body;
    double imageWidth = msg.thumbnailWidth;
    double imageHeight = msg.thumbnailHeight;

    if (msg.thumbnailWidth == 0 || msg.thumbnailHeight == 0) {
      imageWidth = 120;
      imageHeight = 120;
    }
    else if (msg.thumbnailWidth > msg.thumbnailHeight) {
      imageHeight = 130 / imageWidth * imageHeight;
      imageWidth = 150;
      if(imageHeight < 50)
        imageHeight = 50;
      else if(imageHeight > 800)
        imageHeight = 800;
    }
    else {
      imageWidth = 160 / imageHeight * imageWidth;
      imageHeight = 160;
      if(imageWidth < 50)
        imageWidth = 50;
      else if(imageWidth > 250)
        imageWidth = 250;
    }

    Widget widget;
    if(msg.thumbnailLocalPath != null && msg.thumbnailLocalPath.isNotEmpty)
      {
        File file = File(msg.thumbnailLocalPath);
        if(file != null && file.existsSync())
          {
            widget = Image(image: WorksFileImage(file,cacheWidth: (imageWidth*scale).toInt(),cacheHeight:
            (imageHeight*scale).toInt()),width: imageWidth,
                height:
            imageHeight,fit: BoxFit.cover);

//                Image.file(file,width: imageWidth,height: imageHeight,
//              fit: BoxFit.cover,cacheWidth: (imageWidth*scale).toInt(),
//              cacheHeight:
//    (imageHeight*scale).toInt(),);
          }

      }
    if(widget == null) {
      if (msg.thumbnailRemotePath != null && msg.thumbnailRemotePath.length > 0) {
        widget = Image(image:WorksNetworkImage(msg.thumbnailRemotePath,cacheWidth: (imageWidth*scale).toInt(),cacheHeight:
        (imageHeight*scale).toInt()),width:
        imageWidth,height:
        imageHeight,
          fit:
          BoxFit.cover,);


//            Image.network(msg.thumbnailRemotePath,width: imageWidth,height:
//        imageHeight,
//          fit:
//          BoxFit.cover,cacheWidth: (imageWidth*scale).toInt(),cacheHeight:
//          (imageHeight*scale).toInt(),);
      }
    }

    if(widget == null)
      {
        return Container(width: imageWidth,height: imageHeight,child:
        Image.asset('easeuiImages/image_download_fail.png',width:
        imageWidth,height: imageHeight,fit: BoxFit.contain,package: EaseUIOptions.packageName));
      }
    else
      {
        return Container(
          width: imageWidth,height: imageHeight,
          child: Stack(
            children: <Widget>[
              widget,
              Center(child:Icon(Icons.play_circle_outline,size: 50,color:
              Color(0xE3FFFFFF),)),
              Positioned(
                right: 5,
                bottom: 7,
                child: Text(WorksDateFormat.convertSecondsToHMS(msg.videoDuration.toInt()),style: TextStyle(color:
                Colors.white,
                    fontSize: 10.5),),
              )
            ],
          ),
        );
      }
  }

  ///音频消息
  Widget voiceMessageItem(double maxWidth)
  {
    EMMessage message = messageModel.message;
    EMVoiceMessageBody msg = message.body;
    final int duration = msg.voiceDuration == 0 ? 1 : msg.voiceDuration;

    double voiceWidth = min(maxWidth, 70 + (duration.toDouble()/40) *
        (maxWidth -
  70));

    String assetName;
    String assetPackage;

    if(msg.isMediaPlaying)
    {

      if(message.direction == Direction.SEND)
        {
          if(EaseUIOptions.msgSenderVoiceAnimateName == null)
          {

            assetName = 'easeuiImages/chat/chat_sender_play.gif';
            assetPackage = EaseUIOptions.packageName;
          }
          else
          {
            assetName = EaseUIOptions.msgSenderVoiceAnimateName;
          }
        }
      else
        {
          if(EaseUIOptions.msgReceiverVoiceAnimateName == null)
          {

            assetName = 'easeuiImages/chat/chat_receiver_play.gif';
            assetPackage = EaseUIOptions.packageName;
          }
          else
          {
            assetName = EaseUIOptions.msgReceiverVoiceAnimateName;
          }
        }
    }
    else
    {
      if(message.direction == Direction.SEND)
      {
        if(EaseUIOptions.msgSenderVoiceIconName == null)
        {

          assetName = 'easeuiImages/chat/chat_sender_audio_playing.png';
          assetPackage = EaseUIOptions.packageName;
        }
        else
        {
          assetName = EaseUIOptions.msgSenderVoiceIconName;
        }
      }
      else
      {
        if(EaseUIOptions.msgReceiverVoiceIconName == null)
        {

          assetName = 'easeuiImages/chat/chat_receiver_audio_playing.png';
          assetPackage = EaseUIOptions.packageName;
        }
        else
        {
          assetName = EaseUIOptions.msgReceiverVoiceIconName;
        }
      }
    }

     List<Widget> children = message.direction == Direction.SEND ? [
       Text('$duration ″',style: TextStyle(fontSize: 13,color: Colors.white)),
       Expanded(child: Container(),),
       Image.asset(assetName,package: assetPackage,)
     ]:[
       Image.asset(assetName,package: assetPackage,),
       Expanded(child: Container(),),
       Text('$duration ″',style: TextStyle(fontSize: 13,color:const Color(0xFF333333))),
     ];

    return Container(
      width: voiceWidth,
      height: 42,
      padding: EdgeInsets.only(right: message.direction == Direction.SEND ?
      18 : 6,left: message.direction == Direction.SEND ? 6 :18),
      child:
          Row(
            children: children,
          )

    );

  }

  ///位置消息

  Widget locationMessageItem(double maxWidth,double scale)
  {
    EMMessage message = messageModel.message;

    EMLocationMessageBody msg = message.body;

    var addressInfo = msg.address.split("<-?->");

    String name = addressInfo[0];
    String address = addressInfo[1];

    double width = maxWidth < 230 ? maxWidth:230;
    double imageHeight = width * 0.41;

    String urlString = 'https://restapi.amap.com/v3/staticmap?location=${msg
        .longitude.toStringAsFixed(6)},${msg.latitude.toStringAsFixed(6)
    }&zoom=14&size=${(width*scale).toInt()}*${(imageHeight*scale).toInt()}&markers=mid,'
        '0xff0000,O:${msg.longitude.toStringAsFixed(6)},${msg.latitude.toStringAsFixed(6)
    }&key=c90c7406f317b8adc92bc4234c334a06';


    return Container(
      width: width,

      decoration: new BoxDecoration(
        //背景
        color: Colors.white,
        //设置四周圆角 角度
        borderRadius: BorderRadius.all(Radius.circular(8)),
        //设置四周边框
        border: new Border.all(width: 1, color: const Color(0xFFE5E5E5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(padding: EdgeInsets.only(top: 8),),
          Container(
            padding: EdgeInsets.only(left: 10,right: 10),
            child:
             Text(name,maxLines: 1, overflow: TextOverflow.ellipsis,style:
             TextStyle
              (fontSize: 15,
              color:
              const Color(0xFF333333),
            )),),

          Container(
            padding: EdgeInsets.only(left: 10,right: 10),
            child:
            Text(address,maxLines: 2, overflow: TextOverflow.ellipsis,style:
            TextStyle(fontSize: 12,color: const Color(0xFF999999),)),),

          Padding(padding: EdgeInsets.only(bottom: 8),),
          Container(
              width: width,
              height: imageHeight,
              color: const Color(0xFFEAEAEA),
              child: CachedNetworkImage(
                imageUrl: urlString,
                placeholder: (context, url) =>
                    Center(child:CupertinoActivityIndicator()),
                errorWidget: (context, url, error) => Center(child:Icon(Icons
                    .error)),
                width: width,
                height: imageHeight,
                fit: BoxFit.cover,
              ))
        ],
      ),
    );
  }


  ///文件消息
  Widget fileMessageItem(double maxWidth,double scale) {

    EMFileMessageBody fileBody = messageModel.message.body;

    String fileSizeString = messageModel.fileSize;

    String fileName = messageModel.fileName;

    return Stack(
      children: <Widget>[
        Container(
          width: maxWidth,
          padding: EdgeInsets.only(left: 10,right: 12,top: 12,bottom: 12),
          decoration: new BoxDecoration(
            //背景
            color: Colors.white,
            //设置四周圆角 角度
            borderRadius: BorderRadius.all(Radius.circular(8)),
            //设置四周边框
            border: new Border.all(width: 1, color: const Color(0xFFE5E5E5)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      fileName ?? "未知文件名",
                      style: TextStyle(fontSize: 14, color: const Color(0xFF333333)),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 3),
                    ),
                    Text(
                      fileSizeString,
                      style: TextStyle(fontSize: 12, color: const Color(0xFF999999)),
                    ),
                  ],
                ),
              ),
              Image.asset(
                getFileIcon(fileName),
                width: 42,
                height: 42,
                package: EaseUIOptions.packageName,
              )
            ],
          ),
        ),
        Positioned(left: 0,right: 0,bottom: 0,top: 0,child:
            Offstage(
              offstage: messageModel.fileType != 0 || fileBody.downloadStatus != EMDownloadStatus.DOWNLOADING,
             child: Container(
               decoration: BoxDecoration(
                 color: const Color(0x15000000),
                 borderRadius: BorderRadius.circular(9),
               ),
               child: Center(child: CircularProgressIndicator(
                 value: messageModel.progress.toDouble()/100.0,
                 backgroundColor: const Color(0xffd0d0d0),
                 valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
               )),
             ),
            )
        )
      ],
    );
  }

  Widget messageItem(double scale,double maxWidth) {

    EMMessage message = messageModel.message;

    if (message.body is EMTextMessageBody) {
      return textMessageItem(maxWidth);
    } else if (message.body is EMImageMessageBody){
      return imageMessageItem(scale);
    } else if (message.body is EMVideoMessageBody){
      return videoMessageItem(scale);
    }else if (message.body is EMVoiceMessageBody){
      return voiceMessageItem(maxWidth);
    } else if (message.body is EMLocationMessageBody){
      return locationMessageItem(maxWidth,scale);
    }
    else if (message.body is EMFileMessageBody){
      return fileMessageItem(maxWidth,scale);
    }
    else {
      return Text("无法识别消息 ");
    }
  }

//  Color _getMessageWidgetBGColor(int messageDirection) {
//
//    EMMessage message = messageModel.message;
//
//    Color color = Color(0xffC8E9FD);
//    if(message.direction == Direction.RECEIVE) {
//      color = Color(0xffffffff);
//    }
//    return color;
//  }

  @override
  Widget build(BuildContext context) {


    EMMessage message = messageModel.message;

    double scale = MediaQuery.of(context).devicePixelRatio;
    double maxWidth = MediaQuery.of(context).size.width - 125;

    if (message.body is EMTextMessageBody || message.body is EMVoiceMessageBody)
      {

         String assetName;
         String assetPackage;

         if(message.direction == Direction.SEND)
           {
             if(EaseUIOptions.msgSenderBgName == null)
               {

                 assetName = 'easeuiImages/chat/chat_sender_bg.png';
                 assetPackage = EaseUIOptions.packageName;
               }
             else
               {
                 assetName = EaseUIOptions.msgSenderBgName;
               }
           }
         else
           {
             if(EaseUIOptions.msgReceiverBgName == null)
             {
               assetName = 'easeuiImages/chat/chat_receiver_bg.png';
               assetPackage = EaseUIOptions.packageName;
             }
             else
             {
               assetName = EaseUIOptions.msgReceiverBgName;
             }
           }


        return
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(assetName,package: assetPackage),
                    centerSlice: Rect
                        .fromLTWH(message.direction ==
                        Direction.SEND ? 10 : 18, 27, 20 , 4.5)
                )
            ),
//      color: _getMessageWidgetBGColor(toDirect(message.direction)),
            child:
            messageItem(scale,maxWidth),
          );
//          Container(
//          decoration: BoxDecoration(
//              image: DecorationImage(
//                  image: AssetImage(assetName,package: assetPackage),
//                  centerSlice: Rect
//                      .fromLTWH(message.direction ==
//                      Direction.SEND ? 10 : 18, 27, 20 , 4.5)
//              )
//          ),
////      color: _getMessageWidgetBGColor(toDirect(message.direction)),
//          child:
//          messageItem(scale,maxWidth),
//        );
      }
    else
      {
        return
        Container(
          padding: EdgeInsets.only( right: message.direction ==
              Direction.SEND ? 8 : 0,left: message.direction ==
              Direction.SEND ? 0 : 8),
          child: ClipRRect(child:
          Container(
            color: Color(0xFFEAEAEA),
            child:messageItem(scale,maxWidth),
          ),borderRadius:BorderRadius.all(Radius.circular(8))),
        );
      }


  }
}