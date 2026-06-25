import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/cat/presentation/pages/cat_list_page.dart';
import '../../features/cat/presentation/pages/cat_detail_page.dart';
import '../../features/cat/presentation/pages/add_cat_page.dart';
import '../../features/cat/presentation/pages/manual_add_cat_page.dart';
import '../../features/cat/presentation/pages/recognize_cat_page.dart';
import '../../features/log/presentation/pages/add_log_page.dart';
import '../../features/calendar/presentation/pages/calendar_page.dart';
import '../../features/achievement/presentation/pages/achievement_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/export_page.dart';
import '../../features/settings/presentation/pages/privacy_settings_page.dart';
import '../../features/settings/presentation/pages/backup_page.dart';
import '../../features/settings/presentation/pages/contact_page.dart';
import '../../features/tnr/presentation/pages/tnr_guide_page.dart';

/// 路由名称常量
class RouteNames {
  static const String splash = 'splash';
  static const String home = 'home';
  static const String catList = 'catList';
  static const String catDetail = 'catDetail';
  static const String addCat = 'addCat';
  static const String manualAddCat = 'manualAddCat';
  static const String recognizeCat = 'recognizeCat';
  static const String editCat = 'editCat';
  static const String addLog = 'addLog';
  static const String calendar = 'calendar';
  static const String achievement = 'achievement';
  static const String settings = 'settings';
  static const String export = 'export';
  static const String privacySettings = 'privacySettings';
  static const String backup = 'backup';
  static const String contact = 'contact';
  static const String tnrGuide = 'tnrGuide';
}

/// 路由路径常量
class RoutePaths {
  static const String splash = '/';
  static const String home = '/home';
  static const String catList = '/cats';
  static const String catDetail = '/cats/:catId';
  static const String addCat = '/cats/add';
  static const String manualAddCat = '/cats/add/manual';
  static const String recognizeCat = '/cats/add/recognize';
  static const String editCat = '/cats/:catId/edit';
  static const String addLog = '/cats/:catId/logs/add';
  static const String calendar = '/calendar';
  static const String achievement = '/achievements';
  static const String settings = '/settings';
  static const String export = '/settings/export';
  static const String privacySettings = '/settings/privacy';
  static const String backup = '/settings/backup';
  static const String contact = '/settings/contact';
  static const String tnrGuide = '/tnr-guide';
}

/// GoRouter Provider
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true,
    routes: [
      // 启动页
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashPage(),
      ),

      // 首页
      GoRoute(
        path: RoutePaths.home,
        name: RouteNames.home,
        builder: (context, state) => const HomePage(),
      ),

      // 猫咪列表
      GoRoute(
        path: RoutePaths.catList,
        name: RouteNames.catList,
        builder: (context, state) => const CatListPage(),
      ),

      // 猫咪详情
      GoRoute(
        path: RoutePaths.catDetail,
        name: RouteNames.catDetail,
        builder: (context, state) {
          final catId = int.parse(state.pathParameters['catId']!);
          return CatDetailPage(catId: catId);
        },
      ),

      // 添加猫咪
      GoRoute(
        path: RoutePaths.addCat,
        name: RouteNames.addCat,
        builder: (context, state) => const AddCatPage(),
      ),

      // 手动添加猫咪
      GoRoute(
        path: RoutePaths.manualAddCat,
        name: RouteNames.manualAddCat,
        builder: (context, state) => const ManualAddCatPage(),
      ),

      // 拍照识别
      GoRoute(
        path: RoutePaths.recognizeCat,
        name: RouteNames.recognizeCat,
        builder: (context, state) => const RecognizeCatPage(),
      ),

      // 编辑猫咪
      GoRoute(
        path: RoutePaths.editCat,
        name: RouteNames.editCat,
        builder: (context, state) {
          final catId = int.parse(state.pathParameters['catId']!);
          return ManualAddCatPage(catId: catId);
        },
      ),

      // 添加日志
      GoRoute(
        path: RoutePaths.addLog,
        name: RouteNames.addLog,
        builder: (context, state) {
          final catId = int.parse(state.pathParameters['catId']!);
          return AddLogPage(catId: catId);
        },
      ),

      // 日历
      GoRoute(
        path: RoutePaths.calendar,
        name: RouteNames.calendar,
        builder: (context, state) => const CalendarPage(),
      ),

      // 成就
      GoRoute(
        path: RoutePaths.achievement,
        name: RouteNames.achievement,
        builder: (context, state) => const AchievementPage(),
      ),

      // 设置
      GoRoute(
        path: RoutePaths.settings,
        name: RouteNames.settings,
        builder: (context, state) => const SettingsPage(),
      ),

      // 导出
      GoRoute(
        path: RoutePaths.export,
        name: RouteNames.export,
        builder: (context, state) => const ExportPage(),
      ),

      // 隐私设置
      GoRoute(
        path: RoutePaths.privacySettings,
        name: RouteNames.privacySettings,
        builder: (context, state) => const PrivacySettingsPage(),
      ),

      // 备份
      GoRoute(
        path: RoutePaths.backup,
        name: RouteNames.backup,
        builder: (context, state) => const BackupPage(),
      ),

      // 联系方式
      GoRoute(
        path: RoutePaths.contact,
        name: RouteNames.contact,
        builder: (context, state) => const ContactPage(),
      ),

      // TNR 科普
      GoRoute(
        path: RoutePaths.tnrGuide,
        name: RouteNames.tnrGuide,
        builder: (context, state) => const TnrGuidePage(),
      ),
    ],

    // 错误页面
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🐱', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text('页面走丢了'),
            const SizedBox(height: 8),
            Text(state.error?.toString() ?? '未知错误'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go(RoutePaths.home),
              child: const Text('返回首页'),
            ),
          ],
        ),
      ),
    ),
  );
});
