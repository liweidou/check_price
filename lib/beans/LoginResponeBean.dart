class LoginResponeBean {
  String _refresh;
  String _access;

  LoginResponeBean({String refresh, String access}) {
    this._refresh = refresh;
    this._access = access;
  }

  String get refresh => _refresh;
  set refresh(String refresh) => _refresh = refresh;
  String get access => _access;
  set access(String access) => _access = access;

  LoginResponeBean.fromJson(Map<String, dynamic> json) {
    _refresh = json['refresh'];
    _access = json['access'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['refresh'] = this._refresh;
    data['access'] = this._access;
    return data;
  }
}