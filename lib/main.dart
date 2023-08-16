import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'LoginDialog.dart';
import 'Model.dart' show FlutterChatModel, model;
import 'Home.dart';
import 'Lobby.dart';
import 'CreateRoom.dart';
import 'UserList.dart';
import 'Room.dart';

var exists;
var credentials;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  startMeUp() async {
    Directory docsDir = await getApplicationDocumentsDirectory();
    model.docsDir = docsDir;

    var credentialsFile = File("${model.docsDir.path}credentials");
    exists = await credentialsFile.exists();

    if (exists) {
      credentials = await credentialsFile.readAsString();
    }
    runApp(FlutterChat());
  }
  startMeUp();
}

class FlutterChat extends StatelessWidget {
  @override
  Widget build(final BuildContext context) {
    return MaterialApp(home: Scaffold(body: FlutterChatMain()));
  }
}

class FlutterChatMain extends StatelessWidget {
  @override
  Widget build(final BuildContext inContext) {
    model.rootBuildContext = inContext;
    WidgetsBinding.instance.addPostFrameCallback((_) => executeAfterBuild());

    return ScopedModel<FlutterChatModel>(
        model: model,
        child: ScopedModelDescendant<FlutterChatModel>(
            builder: (inContext, Widget? inChild, FlutterChatModel inModel) {
          return MaterialApp(
              initialRoute: "/",
              routes: {
                "/Lobby": (screenContext) => Lobby(),
                "/Room": (screenContext) => Room(),
                "/UserList": (screenContext) => UserList(),
                "/CreateRoom": (screenContext) => CreateRoom()
              },
              home: Home());
        }));
  }

  Future<void> executeAfterBuild() async {
    if (exists) {
      List credParts = credentials.split("============");
      LoginDialog().validateWithStoredCredentials(credParts[0], credParts[1]);
    } else {
      await showDialog(
          context: model.rootBuildContext,
          barrierDismissible: false,
          builder: (BuildContext inDialogContext) {
            return LoginDialog();
          });
    }
  }
}
