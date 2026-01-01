import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/notifications/providers/notification_provider.dart';

class HomeScreen extends StatefulWidget {
  final Widget child;

  const HomeScreen({super.key, required this.child});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<_NavItem> _navItems = [
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home', path: '/home'),
    _NavItem(icon: Icons.book_outlined, activeIcon: Icons.book, label: 'Subjects', path: '/subjects'),
    _NavItem(icon: Icons.quiz_outlined, activeIcon: Icons.quiz, label: 'Quizzes', path: '/quizzes'),
    _NavItem(icon: Icons.chat_outlined, activeIcon: Icons.chat, label: 'Chat', path: '/chat'),
    _NavItem(icon: Icons.person_outlined, activeIcon: Icons.person, label: 'Profile', path: '/profile'),
  ];

  @override
  void initState() {
    super.initState();
    _updateIndexFromLocation();
  }

  void _updateIndexFromLocation() {
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < _navItems.length; i++) {
      if (location.startsWith(_navItems[i].path)) {
        if (_currentIndex != i) {
          setState(() {
            _currentIndex = i;
          });
        }
        break;
      }
    }
  }

  void _onNavTap(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
      context.go(_navItems[index].path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final notificationProvider = context.watch<NotificationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_navItems[_currentIndex].label),
        actions: [
          // Notifications
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => context.push('/notifications'),
              ),
              if (notificationProvider.unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      notificationProvider.unreadCount > 99
                          ? '99+'
                          : notificationProvider.unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          // Settings
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      drawer: _buildDrawer(context, authProvider),
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        items: _navItems.map((item) {
          return BottomNavigationBarItem(
            icon: Icon(item.icon),
            activeIcon: Icon(item.activeIcon),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AuthProvider authProvider) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                authProvider.user?.name.substring(0, 1).toUpperCase() ?? 'S',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            accountName: Text(
              authProvider.user?.name ?? 'Student',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(authProvider.user?.email ?? ''),
          ),
          _drawerItem(Icons.dashboard, 'Dashboard', '/home'),
          _drawerItem(Icons.book, 'My Subjects', '/subjects'),
          _drawerItem(Icons.video_library, 'Lessons', '/lessons'),
          _drawerItem(Icons.quiz, 'Quizzes', '/quizzes'),
          _drawerItem(Icons.assignment, 'Mock Exams', '/exams'),
          _drawerItem(Icons.task, 'Assignments', '/assignments'),
          _drawerItem(Icons.games, 'Games', '/games'),
          const Divider(),
          _drawerItem(Icons.library_books, 'Library', '/library'),
          _drawerItem(Icons.forum, 'Community', '/community'),
          _drawerItem(Icons.smart_toy, 'AI Tutor', '/ai-tutor'),
          const Divider(),
          _drawerItem(Icons.emoji_events, 'Achievements', '/achievements'),
          _drawerItem(Icons.card_membership, 'Certificates', '/certificates'),
          _drawerItem(Icons.payment, 'Payments', '/payments'),
          _drawerItem(Icons.support_agent, 'Support', '/support'),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text('Logout', style: TextStyle(color: AppColors.error)),
            onTap: () async {
              Navigator.pop(context);
              await authProvider.logout();
              if (context.mounted) {
                context.go('/auth/login');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, String path) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        context.go(path);
      },
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String path;

  _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.path,
  });
}
