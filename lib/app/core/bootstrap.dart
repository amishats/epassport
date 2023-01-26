import 'package:epassport/app/app.dart';
import 'package:epassport/config/config.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child: MaterialApp(
        title: APP_NAME,
        theme: AppTheme.theme,
        debugShowCheckedModeBanner: false,
        locale: const Locale('en'),
        localizationsDelegates: [
          FirebaseUILocalizations.withDefaultOverrides(const LabelOverrides()),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          FirebaseUILocalizations.delegate,
        ],
        initialRoute: AppRoute.initialRoute,
        routes: AppRoute.routes(),
      ),
    );
  }
}
