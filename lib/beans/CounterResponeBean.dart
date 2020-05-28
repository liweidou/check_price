class CounterResponeBean {
  int _code;
  String _msg;
  String _level;
  int _result;

  CounterResponeBean({int code, String msg, String level, int result}) {
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
  int get result => _result;
  set result(int result) => _result = result;

  CounterResponeBean.fromJson(Map<String, dynamic> json) {
    _code = json['code'];
    _msg = json['msg'];
    _level = json['level'];
    _result = json['result'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this._code;
    data['msg'] = this._msg;
    data['level'] = this._level;
    data['result'] = this._result;
    return data;
  }
}