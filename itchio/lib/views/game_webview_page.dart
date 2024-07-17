import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:provider/provider.dart';
import '../providers/page_provider.dart';
import '../providers/favorite_provider.dart';
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
            _controller.runJavaScript(_initialHideScript);
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

  static const String _initialHideScript = """
    var style = document.createElement('style');
    style.textContent = `
      header, #view_game_footer, .footer, .bottom_bar, #user_tools, 
      .jam_layout_header_widget, .header_widget, #header, 
      .footer_widget, .bottom_panel, .footer_panel, .bottom-bar 
      { display: none !important; }
      body { padding-top: 0 !important; padding-bottom: 0 !important; }
    `;
    document.head.appendChild(style);
  """;

  static const String _hideUnwantedElementsScript = """
    function hideElements() {
      var elementsToHide = [
        'header',
        '#view_game_footer',
        '.footer',
        '.bottom_bar',
        '#user_tools',
        '.jam_layout_header_widget',
        '.header_widget',
        '#header',
        '.footer_widget',
        '.bottom_panel',
        '.footer_panel',
        '.bottom-bar'
      ];
      
      elementsToHide.forEach(function(selector) {
        var elements = document.querySelectorAll(selector);
        elements.forEach(function(element) {
          element.style.display = 'none';
        });
      });
      
      document.body.style.paddingTop = '0';
      document.body.style.paddingBottom = '0';
    }

    hideElements();

    var observer = new MutationObserver(function(mutations) {
      hideElements();
    });

    observer.observe(document.body, {
      childList: true,
      subtree: true
    });
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