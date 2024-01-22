import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:flutter/services.dart' show PlatformException;
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Test'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 1;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    initUniLinks();
  }

  Future<void> initUniLinks() async {
  // Handle the initial link
  try {
    final initialLink = await getInitialLink();
    if (initialLink != null) { // Check if the initial link is not null
      handleLink(initialLink);
    }
  } on PlatformException {
    // Handle exception, e.g., log the error
    logger.e('Failed to get initial link.');
  }

  // Subscribe to the link stream
  _sub = linkStream.listen((String? link) {
    if (link != null) { // Only handle non-null links
      handleLink(link);
    }
  }, onError: (err) {
    // Handle exception, e.g., log the error
    logger.e('Failed to subscribe to link stream: $err');
  });
}

  void handleLink(String link) {
    if (link.startsWith('itchio_app://oauth-callback')) {
      _incrementCounter();
      // Extract and process the token or authorization code from the link
      // Continue with OAuth process
    }
    else {
    logger.e('Invalid link received: $link');
    }
  
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }


  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter*=2;
    });
  }


  void _startOAuth() async {
    final Uri url = Uri.parse('https://itch.io/user/oauth?client_id=e73c97e940189c0a6baac772262f5545&scope=profile%3Ame&response_type=token&redirect_uri=itchio_app%3A%2F%2Foauth-callback');
    logger.e('ciao');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startOAuth,  
        tooltip: "auth Test", 
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
