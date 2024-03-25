import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:itchio/purchasedGamesPage.dart';
import 'package:provider/provider.dart';

import 'myGamesPage.dart';
import 'oauth_service.dart';
import 'profilePage.dart';


class HomePage extends StatefulWidget {
  final String title;
  const HomePage({Key? key, required this.title}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {

    final OAuthService oAuthService = Provider.of<OAuthService>(context);

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
              title: Text("Lista giochi sviluppati"),
              onTap: () async { // Make onTap async
                final accessToken = await oAuthService.getAccessToken();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyGamesPage(accessToken: accessToken),
                  ),
                );
              },
            ),
            ListTile(
              title: Text("Lista chiavi acquistate"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PurchasedGamesPage(accessToken: 'your_access_token_here')),
                );
              },
            ),
            ListTile(
              title: Text('Profile page'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage(accessToken: 'your_access_token_here')),
                );
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
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: const BoxDecoration(
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
            future: oAuthService.getAccessToken(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // While the Future is still running, show a loading indicator or placeholder.
                return const CircularProgressIndicator();
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
        onPressed: oAuthService.startOAuth,
        tooltip: "auth Test",
        child: const Icon(Icons.add),
    )
    ,
    );
  }

}