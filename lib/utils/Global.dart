import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class Global {
  static String API_TOKEN = "";
  static String TOKEN_PREFIX = "Bearer";
  static String HAS_GUIDE_KEY = "has_guide_key";
  static String AGREE_USE_KEY = "agree_use_key";
  static String REFRESH_TOKEN_KEY = "refresh_token_key";
  static String USER_NAME = "pricetagsadmin";
  static String NO_REGISTER_DEVICE = "has_no_register_device_key";
  static String USER_PASSWORD = "Arenas@12345";
  static String BASE_URL = "http://pricetags.infitack.cn";
  static SharedPreferences preferences;
  static int colorPrimaryDark = 0xff8273BB;
  static int colorAccent = 0xffFFC526;
  static Timer timer;
}
