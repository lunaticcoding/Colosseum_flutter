import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'dart:async';
import 'package:path/path.dart' as p;

class LocalFileWebview extends StatefulWidget {
  FlutterWebviewPlugin flutterWebviewPlugin;
  String path;
  String htmlFile;
  List<String> jsFiles;

  LocalFileWebview({this.flutterWebviewPlugin, this.path, this.htmlFile, this.jsFiles});

  @override
  _LocalFileWebviewState createState() => _LocalFileWebviewState();
}

class _LocalFileWebviewState extends State<LocalFileWebview> {

  @override
  void initState() {
    super.initState();
    for(String jsFile in widget.jsFiles) {
      _loadJS(jsFile);
    }
  }

  void _loadJS(String jsFile) async {
    var givenJS = rootBundle.loadString(p.join(widget.path + jsFile));
    givenJS.then((String js) {
      widget.flutterWebviewPlugin.onStateChanged.listen((viewState) async {
        if (viewState.type == WebViewState.finishLoad) {
          widget.flutterWebviewPlugin.evalJavascript(js);
        }
      });
    });
  }

  Future<String> _loadLocalHTML() async {
    return await rootBundle.loadString(p.join(widget.path + widget.htmlFile));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _loadLocalHTML(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return WebviewScaffold(
            withJavascript: true,
            appCacheEnabled: true,
            url: new Uri.dataFromString(snapshot.data, mimeType: 'text/html')
                .toString(),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text("${snapshot.error}"),
            ),
          );
        }
        return Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}



