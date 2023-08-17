import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterchat/Model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'Connector.dart' as connector;

// ignore: must_be_immutable
class LoginDialog extends StatelessWidget {

  // Key of the login form.  Note it has to be static final so that it doesn't get recreated multiple times
  // to avoid the keyboard popping up and disappearing (see here: https://github.com/flutter/flutter/issues/20042).
  // Note that this was moved from inside the build() method after book publication to address an issue that
  // occurred when a newer Flutter SDK was used.
  static final GlobalKey<FormState> _loginFormKey = new GlobalKey<FormState>();
  // UserName that the user enters.
  late String _userName;
  // Password that the user enters.
  late String _password;

  /// The build() method.
  ///
  /// @param  inContext The BuildContext for this widget.
  /// @return           A Widget.
  @override
  Widget build(final BuildContext inContext) {

    print("## LoginDialog.build()");

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
                          // The form is valid, save values to accessible variables.
                          _loginFormKey.currentState!.save();
                          // Trigger connection to server.
                          connector.connectToServer(() {
                            // Ok, we're connected, now try to validate the user.
                            connector.validate(
                                _userName, _password, (inStatus) async {
                              print("## LoginDialog: validate callback: inResponseStatus = $inStatus");
                              // Existing user logged in.
                              if (inStatus == "ok") {
                                // Store userName in model.
                                model.setUserName(_userName);
                                // Hide login dialog.
                                Navigator.of(model.rootBuildContext).pop();
                                // Show greeting on Home screen.
                                model.setGreeting("Welcom back $_userName!");
                                // Username is already taken (it COULD mean a bad password, but that SHOULD be impossible).
                              } else if (inStatus == "fail") {
                                // Alert user to the result.
                                ScaffoldMessenger.of(model.rootBuildContext)
                                    .showSnackBar(SnackBar(
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 2),
                                    content: Text(
                                        "Sorry, that username is already taken")));
                                // New user created.
                              } else if (inStatus == "created") {
                                // Write out credentials file.
                                var crendentialsFile =
                                File("${model.docsDir.path}crendentials");
                                await crendentialsFile.writeAsString(
                                    "$_userName============$_password");
                                // Store userName in model.
                                model.setUserName(_userName);
                                // Hide login dialog.
                                Navigator.of(model.rootBuildContext).pop();
                                // Show greeting on Home screen.
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

  /// Called when the user has stored credentials.
  ///
  /// @param inUserName The
  void validateWithStoredCredentials(final String inUserName,
      final String inPassword) {

    print("## LoginDialog.validateWithStoredCredentials(): inUserName = $inUserName, inPassword = $inPassword");

    // Trigger connection to server.
    connector.connectToServer(() {
      // Ok, we're connected, now try to validate the user.
      connector.validate(inUserName, inPassword,
          (inStatus){
            print("## LoginDialog: validateWithStoredCredentials callback: inStatus = $inStatus");
            // Existing user logged in (or server restarted and the username was available, which means we get created
            // back, and that should be treated the same as a valid login).
            if(inStatus == "ok" || inStatus == "created"){
              // Store userName in model.
              model.setUserName(inUserName);
              // Show greeting on Home screen.
              model.setGreeting("Welcom back, $inUserName!");
              // If we get a fail back then the only possible cause is the server restarted and the username stored is
              // already taken.  In that case, we'll delete the credentials file and let the user know.
            } else if(inStatus == "fail"){
              // Alert user to the result.
              showDialog(context: model.rootBuildContext,
                  barrierDismissible: false,
                  builder: (final BuildContext inDialogContext) =>
                AlertDialog(title: Text("Validation failed"),
                content: Text("It appears that the server has "
                    "restarted and the username you last used "
                    "was subsequently taken by someone else. "
                    "\n\nPlease re-start FlutterChat and choose "
                    "a different username."),
                  actions: [
                    // Delete the credentials file.
                    FloatingActionButton(child: Text("Ok"),
                      onPressed: (){
                        var credentialsFile = File("${model.docsDir.path}credentials");
                        credentialsFile.deleteSync();
                        // Exit the app.
                        exit(0);
                      })],
                )
              );
            }
          });
    });
  }
}
