import 'package:go_router/go_router.dart';
import 'package:nearby_connect/screens/auth/login_screen.dart';
import 'package:nearby_connect/screens/auth/register_screen.dart';
import 'package:nearby_connect/screens/chat/chat_screen.dart';
import 'package:nearby_connect/screens/home/home_screen.dart';
import 'package:nearby_connect/screens/splash/splash_screen.dart';

final appRouter = GoRouter(
  initialLocation: Routes.splash,
  routes: [
    GoRoute(
      path: Routes.splash,
      name: Routes.splashName,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: Routes.login,
      name: Routes.loginName,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: Routes.register,
      name: Routes.registerName,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: Routes.home,
      name: Routes.homeName,
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'chat/:chatId',
          name: Routes.chatName,
          builder: (context, state) {
            final chatId = state.pathParameters['chatId']!;
            return ChatScreen(chatId: chatId);
          },
        ),
      ],
    ),
  ],
);

class Routes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';

  static const splashName = 'splash';
  static const loginName = 'login';
  static const registerName = 'register';
  static const homeName = 'home';
  static const chatName = 'chat';
}
