import 'dart:convert';

import 'dart:math';
import 'package:questionnaires/configs/app_colors.dart';
import 'package:questionnaires/widgets/slider_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webviewx/webviewx.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;

Future<String> loadAsset(String file) async {
  return await rootBundle.loadString(file);
}

class HTMLScreen extends StatefulWidget {
  final String title;
  final String file;

  HTMLScreen({required this.title, required this.file});

  @override
  HTMLScreenState createState() {
    return HTMLScreenState();
  }
}

class HTMLScreenState extends State<HTMLScreen> {
  String get title => widget.title;
  String get file => widget.file;
  WebViewXController? webviewController;

  final initialContent =
      '<h4> This is some hardcoded HTML code embedded inside the webview <h4> <h2> Hello world! <h2>';
  final executeJsErrorMessage =
      'Failed to execute this task because the current content is (probably) URL that allows iframe embedding, on Web.\n\n'
      'A short reason for this is that, when a normal URL is embedded in the iframe, you do not actually own that content so you cant call your custom functions\n'
      '(read the documentation to find out why).';

  Size get screenSize => MediaQuery.of(context).size;

  @override
  Widget build(BuildContext context) {
    return ScalingWrapper(
        child: Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
          child: Container(
        padding: EdgeInsets.all(15),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20)),
          padding: EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
          child: ListView(
            children: <Widget>[
              buildSpace(direction: Axis.vertical, amount: 10.0, flex: false),
              Container(
                child: _buildWebViewX(),
              )
            ],
          ),
        ),
      )),
    ));
  }

  Widget _buildWebViewX() {
    return WebViewX(
      key: const ValueKey('webviewx'),
      initialContent: file,
      initialSourceType: SourceType.html,
      height: screenSize.height * 0.815,
      width: screenSize.width * 0.90,
      onWebViewCreated: (controller) {
        webviewController = controller;
        // webviewController!.loadContent(file, SourceType.html, fromAssets: true);
      },
      dartCallBacks: {
        DartCallback(
          name: 'TestDartCallback',
          callBack: (msg) => showSnackBar(msg.toString(), context),
        )
      },
      webSpecificParams: const WebSpecificParams(printDebugInfo: true),
      mobileSpecificParams: const MobileSpecificParams(
        androidEnableHybridComposition: true,
      ),
    );
  }

  void _setUrl() {
    webviewController!.loadContent(
      'https://flutter.dev',
      SourceType.url,
    );
  }

  void _setUrlBypass() {
    webviewController!.loadContent(
      'https://news.ycombinator.com/',
      SourceType.urlBypass,
    );
  }

  void _setHtml() {
    webviewController!.loadContent(file, SourceType.html, fromAssets: true);
  }

  void _setHtmlFromAssets() {
    webviewController!.loadContent(
      file,
      SourceType.html,
      fromAssets: true,
    );
  }

  Future<void> _goForward() async {
    if (webviewController != null) if (await webviewController!
        .canGoForward()) {
      await webviewController!.goForward();
      showSnackBar('Did go forward', context);
    } else {
      showSnackBar('Cannot go forward', context);
    }
  }

  Future<void> _goBack() async {
    if (webviewController != null) if (await webviewController!.canGoBack()) {
      await webviewController!.goBack();
      showSnackBar('Did go back', context);
    } else {
      showSnackBar('Cannot go back', context);
    }
  }

  void _reload() {
    if (webviewController != null) webviewController!.reload();
  }

  void _toggleIgnore() {
    if (webviewController != null) {
      final ignoring = webviewController!.ignoresAllGestures;
      webviewController!.setIgnoreAllGestures(!ignoring);
      showSnackBar('Ignore events = ${!ignoring}', context);
    }
  }

  Future<void> _evalRawJsInGlobalContext() async {
    try {
      final result = await webviewController!.evalRawJavascript(
        '2+2',
        inGlobalContext: true,
      );
      showSnackBar('The result is $result', context);
    } catch (e) {
      showAlertDialog(
        executeJsErrorMessage,
        context,
      );
    }
  }

  Future<void> _callPlatformIndependentJsMethod() async {
    try {
      await webviewController!
          .callJsMethod('testPlatformIndependentMethod', []);
    } catch (e) {
      showAlertDialog(
        executeJsErrorMessage,
        context,
      );
    }
  }

  Future<void> _callPlatformSpecificJsMethod() async {
    try {
      await webviewController!
          .callJsMethod('testPlatformSpecificMethod', ['Hi']);
    } catch (e) {
      showAlertDialog(
        executeJsErrorMessage,
        context,
      );
    }
  }

  Future<void> _getWebviewContent() async {
    try {
      final content = await webviewController!.getContent();
      showAlertDialog(content.source, context);
    } catch (e) {
      showAlertDialog('Failed to execute this task.', context);
    }
  }

  Widget buildSpace({
    Axis direction = Axis.horizontal,
    double amount = 0.2,
    bool flex = true,
  }) {
    return flex
        ? Flexible(
            child: FractionallySizedBox(
              widthFactor: direction == Axis.horizontal ? amount : null,
              heightFactor: direction == Axis.vertical ? amount : null,
            ),
          )
        : SizedBox(
            width: direction == Axis.horizontal ? amount : null,
            height: direction == Axis.vertical ? amount : null,
          );
  }

  void showAlertDialog(String content, BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => WebViewAware(
        child: AlertDialog(
          content: Text(content),
          actions: [
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  void showSnackBar(String content, BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(content),
          duration: const Duration(seconds: 1),
        ),
      );
  }

  Widget createButton({
    VoidCallback? onTap,
    required String text,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      ),
      child: Text(text),
    );
  }

  List<Widget> _buildButtons() {
    return [];
  }
/*   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: WebViewX(
        initialContent: '<h2> Hello, world! </h2>',
        initialSourceType: SourceType.html,
      onWebViewCreated: (controller) => webviewController = controller,
      ),
    );
  } 
  */

/*   _loadHtmlFromAssets() async {
    String fileText = await rootBundle.loadString(file);
    print(fileText);
    _controller.loadUrl(Uri.dataFromString(fileText,
            mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString());
  } 
*/
}
