import 'package:flutter/material.dart';
import 'package:ohmo/screen/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:ohmo/profile_data_provider.dart';
import 'package:app_links/app_links.dart';
import 'package:ohmo/screen/daylog_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ProfileData())],
      child: MaterialApp(
        theme: ThemeData(scaffoldBackgroundColor: Colors.white),
        home: const InitialScreenDecider(),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}

class InitialScreenDecider extends StatefulWidget {
  const InitialScreenDecider({super.key});

  @override
  State<InitialScreenDecider> createState() => _InitialScreenDeciderState();
}

class _InitialScreenDeciderState extends State<InitialScreenDecider> {
  late final AppLinks _appLinks;
  bool _isInitialLinkHandled = false;

  @override
  void initState() {
    super.initState();
    _initDeepLinkHandling();
  }

  void _initDeepLinkHandling() async {
    _appLinks = AppLinks();

    final uri = await _appLinks.getInitialLink();
    if (uri != null) {
      _navigateToDeepLink(uri);
    } else {
      if (mounted) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen()));
      }
    }

    if (mounted) {
      setState(() {
        _isInitialLinkHandled = true;
      });
    }

    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null && mounted) {
        _navigateToDeepLink(uri);
      }
    });
  }

  Future<void> _navigateToDeepLink(Uri uri) async {
    if (!mounted) {
      return;
    }
    if (uri.host == 'daylog') {
      final path = uri.path.trim().toLowerCase();
      if (path == '/todo') {
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (_) => DaylogScreen(
                  onTabChange: (index) {},
                  selectedDateNotifier: ValueNotifier(DateTime.now()),
                  showTodoSheet: true,
                ),
          ),
        );
      } else {
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (_) => DaylogScreen(
                  onTabChange: (index) {},
                  selectedDateNotifier: ValueNotifier(DateTime.now()),
                  showTodoSheet: false,
                ),
          ),
        );
      }
    } else {
      await Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialLinkHandled) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    } else {
      return Container();
    }
  }
}
