import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterchat/Model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'AppDrawer.dart';

class Home extends StatelessWidget {

  /// The build() method.
  ///
  /// @param  inContext The BuildContext for this widget.
  /// @return           A Widget.
  @override
  Widget build(final BuildContext inContext) {

    print("## Home.build()");

    return ScopedModel<FlutterChatModel>(
        model: model,
        child: ScopedModelDescendant<FlutterChatModel>(
            builder: (inContext, Widget? inChild, FlutterChatModel inModel) {
          return Scaffold(
              drawer: AppDrawer(),
              appBar: AppBar(title: Text("FlutterChat")),
              body: Center(child: Text(model.greeting)));
        }));
  }
}
