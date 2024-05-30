import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'custom_app_bar.dart';

class GameWebViewPage extends StatefulWidget {
  final String gameUrl;

  GameWebViewPage({required this.gameUrl});

  @override
  _GameWebViewPageState createState() => _GameWebViewPageState();
}

class _GameWebViewPageState extends State<GameWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeWebView();
  }

  void initializeWebView() {
    final params = createPlatformSpecificParams();
    _controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(createNavigationDelegate())
      ..loadRequest(Uri.parse(widget.gameUrl));

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
        });
      },
      onPageFinished: (String url) {
        setState(() {
          _isLoading = false;
        });
        // Inject JavaScript to hide unwanted elements with null checks
        _controller.runJavaScript(
            """
          (function() {
            var header = document.getElementById('header');
            if (header) {
              header.style.display = 'none';
            }
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
          })();
          """
        );
      },
      onHttpError: (HttpResponseError error) {},
      onWebResourceError: (WebResourceError error) {},
      onNavigationRequest: (NavigationRequest request) {
        // Prevent navigation to specific URLs if needed
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

      // Enable Hybrid Composition
      (controller.platform as AndroidWebViewController)
          .setHybridComposition(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _controller.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
