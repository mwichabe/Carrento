import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'services/auth_provider.dart';
import 'services/car_provider.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/user/home_screen.dart';
import 'screens/user/car_detail_screen.dart';
import 'screens/user/booking_screen.dart';
import 'screens/user/my_bookings_screen.dart';
import 'screens/user/profile_screen.dart';
import 'screens/user/explore_screen.dart';
import 'screens/admin/admin_shell.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_cars_screen.dart';
import 'screens/admin/admin_bookings_screen.dart';
import 'screens/admin/admin_users_screen.dart';
import 'screens/admin/car_form_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.primary,
  ));
  runApp(const CarRentoApp());
}

class CarRentoApp extends StatelessWidget {
  const CarRentoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CarProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final router = GoRouter(
            initialLocation: '/',
            redirect: (context, state) {
              final isAuth = auth.isAuthenticated;
              final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';
              final isSplash = state.matchedLocation == '/';
              if (isSplash) return null;
              if (!isAuth && !isAuthRoute) return '/login';
              if (isAuth && isAuthRoute) return '/home';
              return null;
            },
            routes: [
              GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
              GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
              GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
              ShellRoute(
                builder: (context, state, child) => MainShell(child: child),
                routes: [
                  GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
                  GoRoute(path: '/explore', builder: (_, __) => const ExploreScreen()),
                  GoRoute(path: '/bookings', builder: (_, __) => const MyBookingsScreen()),
                  GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
                ],
              ),
              GoRoute(path: '/car/:id', builder: (_, state) => CarDetailScreen(carId: state.pathParameters['id']!)),
              GoRoute(path: '/book/:carId', builder: (_, state) => BookingScreen(carId: state.pathParameters['carId']!)),
              ShellRoute(
                builder: (context, state, child) => AdminShell(child: child),
                routes: [
                  GoRoute(path: '/admin', builder: (_, __) => const AdminDashboardScreen()),
                  GoRoute(path: '/admin/cars', builder: (_, __) => const AdminCarsScreen()),
                  GoRoute(path: '/admin/bookings', builder: (_, __) => const AdminBookingsScreen()),
                  GoRoute(path: '/admin/users', builder: (_, __) => const AdminUsersScreen()),
                  GoRoute(path: '/admin/cars/new', builder: (_, __) => const CarFormScreen()),
                  GoRoute(path: '/admin/cars/edit/:id', builder: (_, state) => CarFormScreen(carId: state.pathParameters['id'])),
                ],
              ),
            ],
          );
          return MaterialApp.router(
            title: 'CarRento',
            theme: appTheme(),
            routerConfig: router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _routes = ['/home', '/explore', '/bookings', '/profile'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) {
            setState(() => _currentIndex = i);
            context.go(_routes[i]);
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: 'Explore'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Bookings'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
