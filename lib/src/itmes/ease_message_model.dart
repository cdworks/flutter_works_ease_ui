
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import '../../works_ease_ui.dart';

class EaseMessageModel
{
  EMMessage message;
  bool isMessageRead; //是否已读
  ChatUserModel userModel;
  num progress = 0;

  bool isRecallMsg = false;

  int _messageFileType;  //若不为文件 返回 -1 否则  1 音频 2 视频 0 其他

  String _fileName; //文件有效

  String _fileSizeString; //文件有效

  get fileType => _messageFileType;

  get fileName => _fileName;

  get fileSize => _fileSizeString;

  ///判定文件类型  1 音频 2 视频 0 其他
  int _fileMessageType(String fileName)
  {

    if(fileName != null)
    {
      String lowString = fileName.toLowerCase();
      if(lowString.endsWith(".mp3") ||
          lowString.endsWith(".wma") ||
          lowString.endsWith(".acc") ||
          lowString.endsWith(".amr"))
      {
        return 1;
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
        return 2;
      }
    }


    return 0;
  }

  EaseMessageModel(this.message) {

    if(this.message.type == EMMessageType.TXT && this.message.ext() != null && this.message.ext().containsKey("work_easeui_recall"))
      {
          isRecallMsg = true;
      }

    if (this.message.type == EMMessageType.FILE) {
      EMNormalFileMessageBody fileMessageBody = message.body;

      String fileName = fileMessageBody.displayName;
      if (fileName == null) {
        var file = fileMessageBody.getFile();
        if (file != null) {
          var pathList = file.path.split("/");
          if (pathList != null && pathList.length > 1) {
            fileName = pathList.last;
          }
        }
      }

      if (fileName == null) {
        if (fileMessageBody.localUrl != null) {
          var pathList = fileMessageBody.localUrl.split("/");
          if (pathList != null && pathList.length > 1) {
            fileName = pathList.last;
          }
        }
      }

      this._fileName = fileName;

      int fileSize =  fileMessageBody.fileSize;

      String fileSizeString = "未知大小";

      if(fileSize != null)
      {
        if(fileSize >= 1073741824)
        {
          double sizeGB = fileSize/1073741824.0;
          fileSizeString = '${sizeGB.toStringAsFixed(1)} GB';
        }
        else if(fileSize >= 1048576)
        {
          double sizeMB = fileSize/1048576.0;
          fileSizeString = '${sizeMB.toStringAsFixed(1)} MB';
        }
        else if(fileSize >= 1024)
        {
          double sizeKB = fileSize/1024.0;
          fileSizeString = '${sizeKB.toStringAsFixed(1)} KB';
        }
        else
        {
          fileSizeString = '$fileSize B';
        }
      }

      this._fileSizeString = fileSizeString;

      _messageFileType = _fileMessageType(fileName);
    }
    else
      {
        _messageFileType = -1;
      }
  }

}
