import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterchat/AppDrawer.dart';
import 'package:flutterchat/Model.dart';
import 'package:scoped_model/scoped_model.dart';

class UserList extends StatelessWidget {

  /// The build() method.
  ///
  /// @param  inContext The BuildContext for this widget.
  /// @return           A Widget.
  @override
  Widget build(final BuildContext inContext) {

    print("## UserList.build()");

    return ScopedModel<FlutterChatModel>(
        model: model,
        child: ScopedModelDescendant<FlutterChatModel>(
          builder: (inContext, Widget? inChild, FlutterChatModel inModel) {
            return Scaffold(
                drawer: AppDrawer(),
                appBar: AppBar(title: Text("User List")),
                body: GridView.builder(
                    itemCount: model.userList.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3),
                    itemBuilder: (BuildContext inContext, int inIndex) {
                      Map user = model.userList[inIndex];
                      return Padding(
                          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                          child: Card(
                              child: Padding(
                                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                  child: GridTile(
                                      child: Center(
                                          child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 0, 0, 20),
                                              child: Image.asset(
                                                  "assets/user.png"))),
                                      footer: Text(user["userName"],
                                          textAlign: TextAlign.center)))));
                    }));
          },
        ));
  }
}
