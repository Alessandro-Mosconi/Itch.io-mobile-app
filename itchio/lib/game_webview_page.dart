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
  bool _elementsHidden = false;

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
          _elementsHidden = false;
        });
      },
      onPageFinished: (String url) async {
        // Inject JavaScript to progressively hide unwanted elements
        await _controller.runJavaScript(
            """
          (function() {
            function hideElements() {
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
            }
            
            if (document.readyState === 'complete') {
              hideElements();
            } else {
              window.addEventListener('load', hideElements);
            }

            var observer = new MutationObserver(hideElements);
            observer.observe(document.body, { childList: true, subtree: true });
          })();
          """
        );
        // Check if elements are hidden
        await Future.delayed(Duration(milliseconds: 500)); // Wait for the elements to be hidden
        setState(() {
          _isLoading = false;
          _elementsHidden = true;
        });
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
          if (_elementsHidden) WebViewWidget(controller: _controller),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
