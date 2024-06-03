import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:provider/provider.dart';
import '../helperClasses/Jam.dart';
import '../providers/page_provider.dart';
import '../providers/favorite_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../helperClasses/Game.dart';

class GameWebViewPage extends StatefulWidget {
  final String url;
  final Game? game;
  final Jam? jam;

  GameWebViewPage({required this.url, this.game, this.jam});

  @override
  _GameWebViewPageState createState() => _GameWebViewPageState();
}

class _GameWebViewPageState extends State<GameWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _elementsHidden = false;
  bool isGame = true;

  @override
  void initState() {
    isGame = widget.game != null;
    super.initState();
    initializeWebView();
  }

  void initializeWebView() {
    final params = createPlatformSpecificParams();
    _controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(createNavigationDelegate())
      ..loadRequest(Uri.parse(widget.url));

    configureAndroidWebView(_controller);
  }

  PlatformWebViewControllerCreationParams createPlatformSpecificParams() {
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      return WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      return const PlatformWebViewControllerCreationParams();
    }
  }

  NavigationDelegate createNavigationDelegate() {
    return NavigationDelegate(
      onProgress: (int progress) {
        setState(() {
          _isLoading = progress < 100;
        });
      },
      onPageStarted: (String url) {
        setState(() {
          _isLoading = true;
          _elementsHidden = false;
        });
      },
      onPageFinished: (String url) async {
        await _controller.runJavaScript(_hideUnwantedElementsScript);
        await Future.delayed(Duration(milliseconds: 500));
        setState(() {
          _isLoading = false;
          _elementsHidden = true;
        });
      },
      onHttpError: (HttpResponseError error) {},
      onWebResourceError: (WebResourceError error) {},
      onNavigationRequest: (NavigationRequest request) {
        if (request.url.startsWith('https://www.youtube.com/')) {
          return NavigationDecision.prevent;
        }
        return NavigationDecision.navigate;
      },
    );
  }

  void configureAndroidWebView(WebViewController controller) {
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
  }

  static const String _hideUnwantedElementsScript = """
    (function() {
      function hideElements() {
        var footer = document.getElementById('view_game_footer');
        if (footer) {
          footer.style.display = 'none';
        }
        var bottomBar = document.querySelector('.bottom-bar-class-name');
        if (bottomBar) {
          bottomBar.style.display = 'none';
        }
        var userTools = document.getElementById('user_tools');
        if (userTools) {
          userTools.style.display = 'none';
        }
        var header = document.querySelector('.jam_layout_header_widget');
        if (header) {
          header.style.display = 'none';
        }
      }
      
      if (document.readyState === 'complete') {
        hideElements();
      } else {
        window.addEventListener('load', hideElements);
      }

      var observer = new MutationObserver(hideElements);
      observer.observe(document.body, { childList: true, subtree: true });
    })();
  """;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        actions: [
          Consumer<FavoriteProvider>(
            builder: (context, favoriteProvider, child) {
              final isFavorite = isGame
                  ? favoriteProvider.isFavoriteGame(widget.game!)
                  : favoriteProvider.isFavoriteJam(widget.jam!);

              return IconButton(
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                onPressed: () {
                  if (isGame) {
                    if (isFavorite) {
                      favoriteProvider.removeFavoriteGame(widget.game!);
                    } else {
                      favoriteProvider.addFavoriteGame(widget.game!);
                    }
                  } else {
                    if (isFavorite) {
                      favoriteProvider.removeFavoriteJam(widget.jam!);
                    } else {
                      favoriteProvider.addFavoriteJam(widget.jam!);
                    }
                  }
                },
              );
            },
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Provider.of<PageProvider>(context, listen: false).clearExtraPage();
          },
        ),
      ),
      body: Stack(
        children: [
          if (_elementsHidden) WebViewWidget(controller: _controller),
          if (_isLoading) Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }


}
