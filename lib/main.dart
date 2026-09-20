
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:life_line/features/auth/data/firebase/firebase_service.dart';
import 'package:life_line/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:life_line/features/auth/presentation/cubits/auth_state.dart';
import 'package:life_line/features/auth/presentation/pages/auth_page.dart';
import 'package:life_line/features/home/data/fireabase_hasta_service.dart';
import 'package:life_line/features/home/presenatation/cubits/hasta_cubit.dart';
import 'package:life_line/features/home/presenatation/pages/bottom_bar_page.dart';
import 'package:life_line/features/home/presenatation/search_cubits/search_cubit.dart';
import 'package:life_line/features/home/presenatation/today_meds_cubits/today_meds_cubit.dart';
import 'package:life_line/features/widgets/common/colors.dart';
import 'package:life_line/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  initializeDateFormatting('tr_TR', null).then((_) => runApp(const MyApp()));
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
  statusBarColor: AppColors.background, // senin tema rengin
  statusBarIconBrightness: Brightness.dark, // ikonları koyu yap
));

  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return App();
  }
}

class App extends StatelessWidget {
  App({super.key});
  final authRepo = FirebaseService();
  final hastaRepo = FirebaseHastaService();




  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MultiBlocProvider(providers: [
        BlocProvider(create: (context) => AuthCubit(authRepo)..checkAuth()),
        BlocProvider(create: (context) => HastaCubit(hastaRepo)..loadHastaList()),
        BlocProvider<HastaSearchCubit>(
          create: (context) => HastaSearchCubit(),
        ),
        BlocProvider<TodayMedsCubit>(
          create: (context) => TodayMedsCubit()..loadToday(),
        ),
      ], child: MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: const [
        Locale('tr'),
        Locale('en'),
      ],
        debugShowCheckedModeBanner: false,
        title: 'Life Line',
        theme: ThemeData(
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Colors.white,     // takvim arka planı
              todayForegroundColor: MaterialStateProperty.all(AppColors.primary),
              todayBackgroundColor: MaterialStateProperty.all(AppColors.primary.withOpacity(0.2)),
              dayBackgroundColor: MaterialStateProperty.resolveWith<Color?>((states) {
                  if (states.contains(MaterialState.selected)) {
                    return AppColors.buttonColor; // seçili gün yazı rengi
                  }
                  return Colors.white; // normal gün yazı rengi
                }),
                dayForegroundColor: MaterialStateProperty.resolveWith<Color?>((states) {
                  if (states.contains(MaterialState.selected)) {
                    return Colors.white; // seçili gün yazı rengi
                  }
                  return Colors.black; // normal gün yazı rengi
                }),
              cancelButtonStyle: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(AppColors.buttonColor),
              ),
              confirmButtonStyle: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(AppColors.buttonColor),
              ),
            ),
          scaffoldBackgroundColor: AppColors.background,
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.border),
              borderRadius: BorderRadius.circular(8.0),
            ),
            focusedBorder: OutlineInputBorder(
              
              borderSide: BorderSide(color: AppColors.border),
              borderRadius: BorderRadius.circular(8.0),
            ),
            focusColor: AppColors.border,
            floatingLabelStyle: TextStyle(color: AppColors.border),
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
        home: BlocConsumer<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AuthAuthenticated) {
              return const BottomBarPage();
            } else if (state is AuthUnauthenticated) {
              return const AuthPage();
            } else if (state is AuthSignUp) {
              return const AuthPage();
            } else if (state is AuthError) {
              return Scaffold(
                body: Center(
                  child: Text(state.message),
                ),
              );
            }
            return const AuthPage();
          },
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
        ),
      )),
    );
  }
}