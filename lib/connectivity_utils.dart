import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';

class ConnectivityUtils {
  static void checkConnectivity(BuildContext context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      // Không có kết nối Internet
      ScaffoldMessenger.of(context)
          .hideCurrentSnackBar(); // Ẩn Snackbar hiện tại (nếu có)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Không có kết nối Internet',
            style: TextStyle(color: Colors.red),
          ),
          backgroundColor: Colors.white,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.red),
          ),
        ),
      );
    }
  }

  static Future<bool> checkConnectivityForFunction(BuildContext context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      // Không có kết nối Internet
      ScaffoldMessenger.of(context)
          .hideCurrentSnackBar(); // Ẩn Snackbar hiện tại (nếu có)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Không có kết nối Internet',
            style: TextStyle(color: Colors.red),
          ),
          backgroundColor: Colors.white,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.red),
          ),
        ),
      );
      return false; // Trả về false nếu không có kết nối Internet
    }
    return true; // Trả về true nếu có kết nối Internet
  }
}
