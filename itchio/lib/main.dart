import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      title: 'Itch.io',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Itch.io'),
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
  late SharedPreferences prefs;
  @override
  void initState() {
    super.initState();
    initSharedPreferences();
    initUniLinks();
  }

  Future<void> initSharedPreferences() async {
     prefs = await SharedPreferences.getInstance();
  }

  Future<void> initUniLinks() async {
    // Handle the initial link
    try {
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        // Check if the initial link is not null
        handleLink(initialLink!);
      }
    } on PlatformException {
      // Handle exception, e.g., log the error
      logger.e('Failed to get initial link.');
    }

    // Subscribe to the link stream
    _sub = linkStream.listen((String? link) {
      if (link != null) {
        // Only handle non-null links
        handleLink(link);
      }
    }, onError: (err) {
      // Handle exception, e.g., log the error
      logger.e('Failed to subscribe to link stream: $err');
    });
  }

  void handleLink(String link) {
    if (link.startsWith('https://itch.io/user/itchio_app://oauth-callback')) {
      _incrementCounter();

      // Extract and process the token or authorization code from the link
      // Continue with OAuth process
      Uri uri = Uri.parse(link);
      Map<String, String> fragmentParameters = Uri.splitQueryString(uri.fragment);
      String? accessToken = fragmentParameters['access_token'];


      if (accessToken != null) {
        logger.e('token: $accessToken');
        handleAccessToken(accessToken);
      } else {
        logger.e('No access token found in the URL.');
      }
    } else {
      logger.e('Invalid link received: $link');
    }
  }

  void handleAccessToken(String accessToken) {
    saveAccessTokenToSharedPreferences(accessToken);
  }

  void saveAccessTokenToSharedPreferences(String accessToken) async {
    await prefs.setString('access_token', accessToken);
  }

  Future<String> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("access_token") ?? "No access token found";
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _incrementCounter() {
    setState(() {
      _counter *= 2;
    });
  }

  void _startOAuth() async {
    final Uri url = Uri.parse(
        'https://itch.io/user/oauth?client_id=e73c97e940189c0a6baac772262f5545&scope=profile%3Ame&response_type=token&redirect_uri=itchio_app%3A%2F%2Foauth-callback');
    logger.e('ciao');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  /*
  @override
  Widget build(BuildContext context) {
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
  }*/

  @override
  Widget build(BuildContext context) {
    List<String> items = [
      'assets/images/image1.jpg',
      'assets/images/image2.jpg',
      'assets/images/image3.jpg',
      'assets/images/image4.jpg'
    ];
    List<String> gridItems = [];/*
      'assets/images/grid_image1.jpg',
      'assets/images/grid_image2.jpg',
      'assets/images/grid_image3.jpg',
      'assets/images/grid_image4.jpg',
      'assets/images/grid_image5.jpg',
      'assets/images/grid_image6.jpg',
      // Altri percorsi delle immagini della griglia secondo necessità
    ];*/

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .inversePrimary,
        title: Text(widget.title),
      ),
      drawer: Drawer(
        // Aggiungi il tuo hamburger menu qui
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme
                    .of(context)
                    .colorScheme
                    .primary,
              ),
              child: const Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text("Opzione 1"),
              onTap: () {
                // Gestisci l'azione quando viene selezionata Opzione 1
              },
            ),
            ListTile(
              title: Text('Opzione 2'),
              onTap: () {
                // Gestisci l'azione quando viene selezionata Opzione 2
              },
            ),
            // Aggiungi altre voci del menu secondo necessità
          ],
        ),
      ),
      body: Column(
        children: [
          CarouselSlider(
            items: items.map((item) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
                    margin: EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                    ),
                    child: Center(
                      child: Text(
                        item,
                        style: TextStyle(fontSize: 24, color: Colors.white),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
            options: CarouselOptions(
              height: 200.0,
              initialPage: 0,
              enableInfiniteScroll: true,
              // Abilita il loop
              reverse: false,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 3),
              autoPlayAnimationDuration: Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              enlargeCenterPage: true,
              scrollDirection: Axis.horizontal,
            ),
          ),
          FutureBuilder<String>(
            future: getAccessToken(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // While the Future is still running, show a loading indicator or placeholder.
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                // If there was an error, display an error message.
                return Text("Error: ${snapshot.error}");
              } else {
                // If the Future is complete, display the result.
                return Center(
                  child: Text(snapshot.data ?? "No access token found"),
                );
              }
            },
          ),
          Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Numero di colonne nella griglia
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: gridItems.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.blue,
                      ),
                      child: Image.asset(
                        gridItems[index],
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startOAuth,
        tooltip: "auth Test",
        child: const Icon(Icons.add),
    )
    ,
    );
  }
}
