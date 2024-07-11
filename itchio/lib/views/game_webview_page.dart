import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:provider/provider.dart';
import '../providers/page_provider.dart';
import '../providers/favorite_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../models/game.dart';
import '../models/jam.dart';


class GameWebViewPage extends StatefulWidget {
  final String url;
  final Game? game;
  final Jam? jam;

  const GameWebViewPage({Key? key, required this.url, this.game, this.jam}) : super(key: key);

  @override
  _GameWebViewPageState createState() => _GameWebViewPageState();
}

class _GameWebViewPageState extends State<GameWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool isGame = true;

  @override
  void initState() {
    super.initState();
    isGame = widget.game != null;
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress == 100) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            _controller.runJavaScript(_hideUnwantedElementsScript);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));

    if (WebViewPlatform.instance is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (WebViewPlatform.instance as AndroidWebViewController).setMediaPlaybackRequiresUserGesture(false);
    }
  }

  static const String _hideUnwantedElementsScript = """
    // Your existing script to hide unwanted elements
  """;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Provider.of<PageProvider>(context, listen: false).goBack(),
        ),
        title: Text(isGame ? widget.game?.title ?? '' : widget.jam?.title ?? ''),
        actions: [
          Consumer<FavoriteProvider>(
            builder: (context, favoriteProvider, _) {
              final isFavorite = isGame
                  ? favoriteProvider.isFavoriteGame(widget.game!)
                  : favoriteProvider.isFavoriteJam(widget.jam!);
              return IconButton(
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                onPressed: () {
                  if (isGame) {
                    isFavorite
                        ? favoriteProvider.removeFavoriteGame(widget.game!)
                        : favoriteProvider.addFavoriteGame(widget.game!);
                  } else {
                    isFavorite
                        ? favoriteProvider.removeFavoriteJam(widget.jam!)
                        : favoriteProvider.addFavoriteJam(widget.jam!);
                  }
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => Share.share('Check this ${isGame ? 'game' : 'jam'} at ${widget.url}'),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}