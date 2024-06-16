import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pan_tv/screens/main_page.dart';
import 'package:pan_tv/utils/player_provider.dart';
import 'package:pan_tv/utils/styles.dart';
import 'package:pan_tv/utils/theme.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Lock Orientation to avoid trouble
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Styles.primaryBlack,
  ));
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => PlayerProvider()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: MyTheme.myTheme,
      home: const MainPage(),
    );
  }
}
