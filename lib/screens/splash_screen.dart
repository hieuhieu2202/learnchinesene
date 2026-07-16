import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.databaseReady});
  final Future<void> databaseReady;
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? error;
  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      await Future.wait([
        widget.databaseReady,
        Future<void>.delayed(const Duration(milliseconds: 900)),
      ]);
      if (mounted)
        Navigator.pushReplacementNamed(context, HomeScreen.routeName);
    } catch (_) {
      if (mounted)
        setState(() => error = 'Không thể chuẩn bị bài học ngoại tuyến.');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.redDark, AppColors.red, AppColors.orange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '学',
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w800,
                      color: AppColors.red,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Học tiếng Trung',
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Mỗi ngày tiến bộ một chút',
                  style: TextStyle(color: Color(0xE6FFFFFF), fontSize: 16),
                ),
                const SizedBox(height: 40),
                if (error == null)
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                else ...[
                  Text(
                    error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {
                      setState(() => error = null);
                      _start();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Thử lại'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
