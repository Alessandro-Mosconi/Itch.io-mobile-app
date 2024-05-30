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
        // Update loading bar
      },
      onPageStarted: (String url) {},
      onPageFinished: (String url) {
        _controller.runJavaScript(
          "document.querySelector('header').style.display='none'; document.querySelector('footer').style.display='none';",
        );
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
      body: WebViewWidget(controller: _controller),
    );
  }
}
