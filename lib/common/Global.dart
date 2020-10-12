import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// 公共存储和取出本地数据
class Global {
  static JsonDecoder jsonDecoder = JsonDecoder();
  static SharedPreferences prefs;
  static Future getData() async {
    prefs = await SharedPreferences.getInstance();
    // prefs.remove('todolists');
    String todoLists = prefs.getString('todolists');
    if (todoLists == null || todoLists.isEmpty) return [];
    List todos = jsonDecoder.convert(todoLists);
    return todos;
  }

  static Future saveData(data) async {
    prefs = await SharedPreferences.getInstance();
    prefs.setString('todolists', jsonEncode(data));
  }
}
