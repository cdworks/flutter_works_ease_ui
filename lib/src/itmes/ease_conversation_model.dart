

import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:works_utils/works_utils.dart';

import '../../works_ease_ui.dart';

class EaseConversationModel
{
  final EMConversation conversation;

  ChatUserModel userModel; //用于单聊

  String detailText;
  String lastTime;
  String groupName;  //用于群组
  bool isAt; //是否at了我


  EaseConversationModel(this.conversation,EMMessage lastMessage)
  {
     isAt = false;
     detailText = "";
     EMMessageBody messageBody = lastMessage.body;
     lastTime = WorksDateFormat.formatterTimestamp(int.parse(lastMessage.msgTime));


     switch(lastMessage.type)
     {
       case EMMessageType.TXT:
         detailText = (messageBody as EMTextMessageBody).message;
         break;
       case EMMessageType.IMAGE:
         detailText = '[图片]';
         break;
       case EMMessageType.VOICE:
         detailText = '[语音]';
         break;
       case EMMessageType.LOCATION:
         detailText = '[位置]';
         break;
       case EMMessageType.VIDEO:
         detailText = '[视频]';
         break;
       case EMMessageType.FILE:
         detailText = '[文件]';
         break;
       default:
         break;
     }

  }
}