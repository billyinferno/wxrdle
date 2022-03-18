import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocalBox {
  static Box<dynamic>? myBox;

  static Future<void> init() async {
    if(myBox == null) {
      debugPrint("📦 initialize box");
      myBox = await Hive.openBox('local_storage');
    }
    else {
      // box already there, just compact the box
      debugPrint("🗜️ compact box");
      myBox!.compact();
    }
  }

  static Future<void> put({required String key, required dynamic value}) async {
    // check if box is null or not
    if(myBox == null) {
      await init();
    }

    myBox!.put(key, value);
  }

  static dynamic get({required String key}) {
    // check if box is null or not
    if(myBox == null) {
      return null;
    }
    else {
      if(myBox!.containsKey(key)) {
        return myBox!.get(key);
      }
      else {
        return null;
      }
    }
  }
}