class RefreshTokenResponeBean {
  String _access;

  RefreshTokenResponeBean({String access}) {
    this._access = access;
  }

  String get access => _access;
  set access(String access) => _access = access;

  RefreshTokenResponeBean.fromJson(Map<String, dynamic> json) {
    _access = json['access'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['access'] = this._access;
    return data;
  }
}