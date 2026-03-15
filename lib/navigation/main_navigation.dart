import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:wellness_ai/app/theme/app_colors.dart';
import 'package:wellness_ai/core/services/firebase_service.dart';
import 'package:wellness_ai/core/services/local_storage_service.dart';
import 'package:wellness_ai/features/coaches/cubit/coaches_cubit.dart';
import 'package:wellness_ai/features/coaches/view/coaches_screen.dart';
import 'package:wellness_ai/features/chat_history/cubit/chat_history_cubit.dart';
import 'package:wellness_ai/features/chat_history/view/chat_history_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final GlobalKey<ChatHistoryScreenState> _chatHistoryKey =
      GlobalKey<ChatHistoryScreenState>();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      BlocProvider(
        create: (context) => CoachesCubit(
          firebaseService: context.read<FirebaseService>(),
        )..loadCoaches(),
        child: const CoachesScreen(),
      ),
      BlocProvider(
        create: (context) => ChatHistoryCubit(
          localStorageService: context.read<LocalStorageService>(),
        )..loadHistory(),
        child: ChatHistoryScreen(key: _chatHistoryKey),
      ),
    ];
  }

  void _onTabSelected(int index) {
    setState(() => _currentIndex = index);
    if (index == 1) {
      _chatHistoryKey.currentState?.refreshHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 2),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.white.withValues(alpha: 0.55)),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadowColor,
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: SalomonBottomBar(
                    currentIndex: _currentIndex,
                    onTap: _onTabSelected,
                    itemPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                    selectedItemColor: AppColors.primary,
                    unselectedItemColor: AppColors.textSecondary,
                    backgroundColor: Colors.transparent,
                    items: [
                      SalomonBottomBarItem(
                        icon: Icon(PhosphorIcons.users(), size: 24),
                        activeIcon: Icon(PhosphorIcons.users(PhosphorIconsStyle.fill), size: 24),
                        title: const Text("Coaches", style: TextStyle(fontWeight: FontWeight.w600)),
                        selectedColor: AppColors.primary,
                      ),
                      SalomonBottomBarItem(
                        icon: Icon(PhosphorIcons.chatCircle(), size: 24),
                        activeIcon: Icon(PhosphorIcons.chatCircle(PhosphorIconsStyle.fill), size: 24),
                        title: const Text("Chat History", style: TextStyle(fontWeight: FontWeight.w600)),
                        selectedColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
