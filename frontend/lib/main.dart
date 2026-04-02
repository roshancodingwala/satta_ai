import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/emotion_provider.dart';
import 'providers/history_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/checkin_screen.dart';
import 'screens/result_screen.dart';
import 'screens/crisis_screen.dart';
import 'screens/history_screen.dart';

void main() {
  runApp(const SattvaApp());
}

class SattvaApp extends StatelessWidget {
  const SattvaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HistoryProvider()..load()),
        ChangeNotifierProxyProvider<HistoryProvider, EmotionProvider>(
          create: (_) => EmotionProvider(),
          update: (_, history, emotion) {
            final ep = emotion ?? EmotionProvider();
            ep.onCheckInComplete = (data) async {
              await history.addEntry(HistoryEntry(
                date: DateTime.now(),
                primaryEmotion: data.primaryEmotion,
                stressLevel: data.stressLevel,
                energyFrequency: data.energyFrequency,
                fable: data.fable,
                niti: data.niti,
                raagaName: data.raaga?['raaga_name'] as String?,
              ));
            };
            return ep;
          },
        ),
      ],
      child: MaterialApp(
        title: 'SattvaAI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        initialRoute: '/splash',
        routes: {
          '/splash':   (_) => const SplashScreen(),
          '/':         (_) => const HomeScreen(),
          '/checkin':  (_) => const CheckInScreen(),
          '/result':   (_) => const ResultScreen(),
          '/crisis':   (_) => const CrisisScreen(),
          '/history':  (_) => const HistoryScreen(),
        },
      ),
    );
  }
}
