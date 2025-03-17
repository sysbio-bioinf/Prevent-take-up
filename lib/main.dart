import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:questionnaires/configs/app_colors.dart';
import 'package:questionnaires/screens/home_screen.dart';
import 'package:questionnaires/configs/text_scaler.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<TextScaleProvider>(
            create: (_) => TextScaleProvider(),
          )
        ],
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              fontFamily: "Raleway",
              appBarTheme: AppBarTheme(elevation: 0, color: AppColors.green),
              scaffoldBackgroundColor: AppColors.green,
              cardColor: Colors.white,
              accentColor: Colors.white,
              selectedRowColor: AppColors.green,
              highlightColor: AppColors.green,
              hintColor: Colors.grey[300],
              focusColor: AppColors.green,
              primaryColor: Color.fromRGBO(58, 176, 152, 1),
              primaryIconTheme: Theme.of(context)
                  .primaryIconTheme
                  .copyWith(color: Colors.white),
              disabledColor: AppColors.lightgray,
              bottomAppBarColor: Colors.white,
            ),
            home: HomeScreen(),
          );
        });
  }
}
