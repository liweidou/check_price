class UploadPermissionResponeBean {
  int _code;
  String _msg;
  String _level;
  Result _result;

  UploadPermissionResponeBean(
      {int code, String msg, String level, Result result}) {
    this._code = code;
    this._msg = msg;
    this._level = level;
    this._result = result;
  }

  int get code => _code;
  set code(int code) => _code = code;
  String get msg => _msg;
  set msg(String msg) => _msg = msg;
  String get level => _level;
  set level(String level) => _level = level;
  Result get result => _result;
  set result(Result result) => _result = result;

  UploadPermissionResponeBean.fromJson(Map<String, dynamic> json) {
    _code = json['code'];
    _msg = json['msg'];
    _level = json['level'];
    _result =
    json['result'] != null ? new Result.fromJson(json['result']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this._code;
    data['msg'] = this._msg;
    data['level'] = this._level;
    if (this._result != null) {
      data['result'] = this._result.toJson();
    }
    return data;
  }
}

class Result {
  bool _permission;

  Result({bool permission}) {
    this._permission = permission;
  }

  bool get permission => _permission;
  set permission(bool permission) => _permission = permission;

  Result.fromJson(Map<String, dynamic> json) {
    _permission = json['permission'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['permission'] = this._permission;
    return data;
  }
}