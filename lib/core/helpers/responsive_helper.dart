import 'package:clean_boilerplate/core/extensions/screen_matres_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ResponsiveHelper {
  const ResponsiveHelper._();

  static bool isMobilePhone() {
    if (!kIsWeb) {
      return true;
    }else {
      return false;
    }
  }

  static bool isWeb() {
    return kIsWeb;
  }

  static bool isMobile(BuildContext context) {
    final screenWidth = context.screenWidth;
    if (screenWidth < 650 || !kIsWeb) {
      return true;
    } else {
      return false;
    }
  }

  static bool isTab(BuildContext context) {
    final screenWidth = context.screenWidth;
    if (screenWidth < 1100 && screenWidth >= 650) {
      return true;
    } else {
      return false;
    }
  }

  static bool isDesktop(BuildContext context) {
    final screenWidth = context.screenWidth;
    if (screenWidth >= 1100) {
      return true;
    } else {
      return false;
    }
  }

}