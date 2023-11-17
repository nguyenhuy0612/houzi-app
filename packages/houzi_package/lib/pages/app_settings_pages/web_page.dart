import 'package:flutter/material.dart';
import 'package:houzi_package/widgets/app_bar_widget.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebPage extends StatefulWidget{
  final String url;
  final String pageTitle;

  WebPage(this.url, this.pageTitle);

  @override
  State<WebPage> createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  // final Completer<WebViewController> _controller = Completer<WebViewController>();

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        appBarTitle: widget.pageTitle,
      ),
      body: SafeArea(
        child: WebView(
          initialUrl: widget.url,
          javascriptMode: JavascriptMode.unrestricted,
          // onWebViewCreated: (WebViewController _webViewController) async {
          //   // webViewController = _webViewController;
          //   _controller.complete(_webViewController);
          //   _webViewController.runJavascript("var email = document.getElementById('user_login');");
          //   await Future.delayed(Duration(seconds: 1));
          //   _webViewController.runJavascript("var password = document.getElementById('user_pass');");
          //   await Future.delayed(Duration(seconds: 1));
          //   _webViewController.runJavascript("email.value = '';");
          //   await Future.delayed(Duration(seconds: 1));
          //   _webViewController.runJavascript("password.value = '';");
          //   await Future.delayed(Duration(seconds: 1));
          //   _webViewController.runJavascript("document.getElementById('loginform').submit();");
          //
          // }
        ),
      ),
    );
  }
}