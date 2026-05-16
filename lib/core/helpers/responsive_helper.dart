import 'package:clean_boilerplate/config/util/dimensions.dart';
import 'package:clean_boilerplate/core/extensions/screen_matres_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ResponsiveHelper {
  const ResponsiveHelper._();

  static const double _smallMobile = 420;
  static const double _mobile = 650;
  static const double _smallTab = 850;
  static const double _tab = Dimensions.webMaxWidth - 100;

  static bool isMobilePhone() => !kIsWeb;
  static bool isWeb() => kIsWeb;

  static bool isMobile(BuildContext context) => context.screenWidth <= _mobile;
  static bool isSmallMobile(BuildContext context) => context.screenWidth <= _smallMobile;
  static bool isBigMobile(BuildContext context) => context.screenWidth > _smallMobile && context.screenWidth <= _mobile;

  static bool isTab(BuildContext context) => context.screenWidth > _mobile && context.screenWidth <= _tab;
  static bool isSmallTab(BuildContext context) => context.screenWidth > _mobile && context.screenWidth <= _smallTab;
  static bool isBigTab(BuildContext context) => context.screenWidth > _smallTab && context.screenWidth <= _tab;

  static bool isDesktop(BuildContext context) => context.screenWidth > _tab;
}
