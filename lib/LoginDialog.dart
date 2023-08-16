import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterchat/Model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'Connector.dart' as connector;

class LoginDialog extends StatelessWidget {
  static final GlobalKey<FormState> _loginFormKey = new GlobalKey<FormState>();
  late String _userName;
  late String _password;

  @override
  Widget build(final BuildContext inContext) {
    return ScopedModel<FlutterChatModel>(
        model: model,
        child: ScopedModelDescendant<FlutterChatModel>(
            builder: (inContext, Widget? inChild, FlutterChatModel inModel) {
              return AlertDialog(
                content: Container(
                    height: 220,
                    child: Form(
                        key: _loginFormKey,
                        child: Column(children: [
                          Text(
                              "Enter a username and password to "
                                  "register with the server",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Theme
                                      .of(model.rootBuildContext)
                                      .colorScheme.secondary)),
                          SizedBox(height: 20),
                          TextFormField(
                              validator: (inValue) {
                                if (inValue!.length == 0 || inValue.length >
                                    10) {
                                  return "Please enter a username no "
                                      "more than 10 characters long";
                                }
                                return null;
                              },
                              onSaved: (inValue) {
                                _userName = inValue!;
                              },
                              decoration: InputDecoration(
                                  hintText: "Username", labelText: "Username")),
                          TextFormField(
                              obscureText: true,
                              validator: (inValue) {
                                if (inValue!.length == 0) {
                                  return "Please enter a password";
                                }
                                return null;
                              },
                              onSaved: (inValue) {
                                _password = inValue!;
                              },
                              decoration: InputDecoration(
                                  hintText: "Password", labelText: "Password"))
                        ]))),
                actions: [
                  FloatingActionButton(
                      child: Text("Log in"),
                      onPressed: () {
                        if (_loginFormKey.currentState!.validate()) {
                          _loginFormKey.currentState!.save();
                          connector.connectToServer(() {
                            connector.validate(
                                _userName, _password, (inStatus) async {
                              if (inStatus == "ok") {
                                model.setUserName(_userName);
                                Navigator.of(model.rootBuildContext).pop();
                                model.setGreeting("Welcom back $_userName!");
                              } else if (inStatus == "fail") {
                                ScaffoldMessenger.of(model.rootBuildContext)
                                    .showSnackBar(SnackBar(
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 2),
                                    content: Text(
                                        "Sorry, that username is already taken")));
                              } else if (inStatus == "created") {
                                var crendentialsFile =
                                File("${model.docsDir.path}crendentials");
                                await crendentialsFile.writeAsString(
                                    "$_userName============$_password");
                                model.setUserName(_userName);
                                Navigator.of(model.rootBuildContext).pop();
                                model.setGreeting(
                                    "Welcom to server, $_userName");
                              }
                            });
                          });
                        }
                      })
                ],
              );
            }));
  }

  void validateWithStoredCredentials(final String inUserName,
      final String inPassword) {
    connector.connectToServer(() {
      connector.validate(inUserName, inPassword,
          (inStatus){
            if(inStatus == "ok" || inStatus == "created"){
              model.setUserName(inUserName);
              model.setGreeting("Welcom back, $inUserName!");
            } else if(inStatus == "fail"){
              showDialog(context: model.rootBuildContext,
                  barrierDismissible: false,
                  builder: (final BuildContext inDialogContext) =>
                AlertDialog(title: Text("Validation failed"),
                content: Text("It appears that the server has "
                    "restarted and the username you last used "
                    "was subsequently taken by someone else. "
                    "\n\nPlease re-start FlutterChat and choose "
                    "a different username."),
                  actions: [FloatingActionButton(child: Text("Ok"),
                      onPressed: (){
                        var credentialsFile = File("${model.docsDir.path}credentials");
                        credentialsFile.deleteSync();
                        exit(0);
                      })],
                )
              );
            }
          });
    });
  }
}
