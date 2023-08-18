import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'Model.dart' show FlutterChatModel, model;

// The one and only SocketIO instance.
late IO.Socket _io;

// ------------------------------ NONE-MESSAGE RELATED METHODS -----------------------------

void showPleaseWait() {
  print("## Connector.showPleaseWait()");

  showDialog(
      context: model.rootBuildContext,
      barrierDismissible: false,
      builder: (BuildContext inDialogContext) {
        return Dialog(
            child: Container(
                width: 150,
                height: 150,
                alignment: AlignmentDirectional.center,
                decoration: BoxDecoration(color: Colors.blue[200]),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  const Center(
                      child: SizedBox(height: 50, width: 50,
                          child: CircularProgressIndicator(value: null, strokeWidth: 10))),
                  Container(
                      margin: const EdgeInsets.only(top: 20),
                      child: Center(
                          child: Text("Please wait, contacting server...",
                              style: new TextStyle(color: Colors.white))))
                ])));
      });
}

/// Hide the please wait dialog.
void hidePleaseWait() {
  print("## Connector.hidePleaseWait()");

  Navigator.of(model.rootBuildContext).pop();
}

/// Connect to the server.  Called once from LoginDialog.
///
/// @param inCallback The function to call when the response comes back.
void connectToServer(final Function inCallback) {
  try {
    _io = IO.io('http://10.0.2.2:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    _io.connect();
    print("## Connector.connectToServer()");
    // Hook up message listeners.
    _io.on("newUser", newUser);
    _io.on("created", created);
    _io.on("closed", closed);
    _io.on("joined", joined);
    _io.on("left", left);
    _io.on("kicked", kicked);
    _io.on("invited", invited);
    _io.on("posted", posted);
    // Call the callback so the app can continue to start up.
    inCallback();
  } catch (e) {
    print(e.toString());
  }
}

// ------------------------------ MESSAGE SENDER METHODS ------------------------------

/// Validate the user.  Called from LoginDialog when there were no stored credentials for the user.
///
/// @param inUserName The username they entered.
/// @param inPassword The password they entered.
/// @param inCallback The function to call when the response comes back.  Is passed the status.
void validate(final String inUserName, final String inPassword, final Function inCallback) {
  print("## Connector.validate(): inUserName = $inUserName, inPassword = $inPassword");

  // Block screen while we call server.
  showPleaseWait();
  // Call server to validate.
  Map<String, dynamic> namePassword = {"userName": inUserName, "password": inPassword};
  _io.emitWithAck("validate", namePassword, ack: (inData) {
    hidePleaseWait();
    inCallback(inData["status"]);
  });
}

/// Get the current list of rooms on the server.
///
/// @param inCallback The function to call when the response comes back.  Is passed the map of room descriptors.
void listRooms(final Function inCallback) {
  print("## Connector.listRooms()");
  // Block screen while we call server.
  showPleaseWait();
  // Call server to create the room.
  _io.emitWithAck("listRooms", "{}", ack: (inData) {
    print("## Connector.validate(): callback: inData = $inData");
    // Hide please wait.
    hidePleaseWait();
    // Call the specified callback.
    inCallback(inData);
  });
}

/// Create a room.
///
/// @param inRoomName    The name of the room.
/// @param inDescription The description of the room.
/// @param inMaxPeople   The maximum number of people allowed in the room.
/// @param inPrivate     Whether the room is private or not.
/// @param inCreator     The userName of the user creating the room.
/// @param inCallback    The function to call when the response comes back.  Is passed the status and the map of
///                      of room descriptors.
void create(final String inRoomName, final String inDescription, final int inMaxPeople, final bool inPrivate, final String inCreator,
    final Function inCallback) {
  Map<String, dynamic> roomParam = {
    "roomName": inRoomName,
    "description": inDescription,
    "maxPeople": inMaxPeople,
    "private": inPrivate,
    "creator": inCreator
  };

  print("## Connector.create(): inRoomName = $inRoomName, inDescription = $inDescription, "
      "inMaxPeople = $inMaxPeople, inPrivate = $inPrivate, inCreator = $inCreator");

  // Block screen while we call server.
  showPleaseWait();
  // Call server to create the room.
  _io.emitWithAck("create", roomParam, ack: (inData) {
    print("## Connector.create(): callback: inData = $inData");
    // Hide please wait.
    hidePleaseWait();
    // Call the specified callback.
    inCallback(inData["status"], inData["rooms"]);
  });
}

/// Join a room.
///
/// @param inUserName The user's userName.
/// @param inRoomName The name of the room being joined.
/// @param inCallback The function to call when the response comes back.  Is passed the status and the map of
///                   room descriptor objects.
void join(final String inUserName, final String inRoomName, final Function inCallback) {
  Map<String, dynamic> roomParam = {"userName": inUserName, "roomName": inRoomName};

  print("## Connector.join(): inUserName = $inUserName, inRoomName = $inRoomName");

  // Block screen while we call server.
  showPleaseWait();
  // Call server to create the room.
  _io.emitWithAck("join", roomParam, ack: (inData) {
    print("## Connector.join(): callback: inData = $inData");
    // Hide please wait.
    hidePleaseWait();
    // Call the specified callback.
    inCallback(inData["status"], inData["room"]);
  });
}

/// Leave a room.
///
/// @param inUserName The user's userName.
/// @param inRoomName The name of the room being joined.
/// @param inCallback The function to call when the response comes back.
void leave(final String inUserName, final String inRoomName, final Function inCallback) {
  Map<String, dynamic> room = {"userName": inUserName, "roomName": inRoomName};

  print("## Connector.leave(): inUserName = $inUserName, inRoomName = $inRoomName");

  // Block screen while we call server.
  showPleaseWait();
  // Call server to create the room.
  _io.emitWithAck("leave", room, ack: (inData) {
    print("## Connector.leave(): callback: inData = $inData");
    // Hide please wait.
    hidePleaseWait();
    // Call the specified callback, passing it the response.
    inCallback();
  });
}

/// Get the current list of users on the server.
///
/// @param inCallback The function to call when the response comes back.  Is passed the map of user descriptor
///                   objects.
void listUsers(final Function inCallback) {
  print("## Connector.listUsers()");

  // Block screen while we call server.
  showPleaseWait();
  // Call server to create the room.
  _io.emitWithAck("listUsers", "{}", ack: (inData) {
    print("## Connector.listUsers(): callback: inData = $inData");
    // Hide please wait.
    hidePleaseWait();
    // Call the specified callback, passing it the response.
    inCallback(inData);
  });
}

/// Invite a user to a room.
///
/// @param inUserName    The name of the user being invited.
/// @param inRoomName    The name of the room being invited to.
/// @param inInviterName The name of the user inviting.
/// @param inCallback    The function to call when the response comes back.
void invite(final String inUserName, final String inRoomName, final String inInviterName, final Function inCallback) {
  Map<String, dynamic> roomParam = {"userName": inUserName, "roomName": inRoomName, "inviterName": inInviterName};

  print("## Connector.invite(): inUserName = $inUserName, inRoomName = $inRoomName, inInviterName = $inInviterName");

  // Block screen while we call server.
  showPleaseWait();
  // Call server to create the room.
  _io.emitWithAck("invite", roomParam, ack: (inData) {
    print("## Connector.invite(): callback: inData = $inData");
    // Hide please wait.
    hidePleaseWait();
    // Call the specified callback, passing it the response.
    inCallback();
  });
}

/// Posts a message to a room.
///
/// @param inUserName The name of the user being kicked.
/// @param inRoomName The name of the room being closed.
/// @param inCallback The function to call when the response comes back.
void post(final String inUserName, final String inRoomName, final String inMessage, final Function inCallback) {
  Map<String, dynamic> roomParam = {"userName": inUserName, "roomName": inRoomName, "message": inMessage};

  print("## Connector.post(): inUserName = $inUserName, inRoomName = $inRoomName, inMessage = $inMessage");

  // Block screen while we call server.
  showPleaseWait();
  _io.emitWithAck("post", roomParam, ack: (inData) {
    print("## Connector.post(): callback: inData = $inData");
    // Hide please wait.
    hidePleaseWait();
    // Call the specified callback, passing it the response.
    inCallback(inData["status"]);
  });
}

/// Close a room (creator function).
///
/// @param inRoomName The name of the room being closed.
/// @param inCallback The function to call when the response comes back.
void close(final String inRoomName, final Function inCallback) {
  print("## Connector.close(): inRoomName = $inRoomName");

  // Block screen while we call server.
  showPleaseWait();
  // Call server to create the room.
  _io.emitWithAck("close", {"roomName": inRoomName}, ack: (inData) {
    print("## Connector.close(): callback: inData = $inData");
    // Hide please wait.
    hidePleaseWait();
    // Call the specified callback, passing it the response.
    inCallback();
  });
}

/// Kick a user from a room (creator function).
///
/// @param inUserName The name of the user being kicked.
/// @param inRoomName The name of the room being closed.
/// @param inCallback The function to call when the response comes back.
void kick(final String inUserName, final String inRoomName, final Function inCallback) {
  Map<String, dynamic> room = {"userName": inUserName, "roomName": inRoomName};

  print("## Connector.kick(): inUserName = $inUserName, inRoomName = $inRoomName");

  // Block screen while we call server.
  showPleaseWait();
  // Call server to create the room.
  _io.emitWithAck("kick", room, ack: (inData) {
    print("## Connector.kick(): callback: inData = $inData");
    // Hide please wait.
    hidePleaseWait();
    // Call the specified callback, passing it the response.
    inCallback();
  });
}

// ------------------------------ MESSAGE RECEIVER METHODS ------------------------------

/// Received when a new user is created.  Receives the current list of users on the server.
///
/// @param inData The data sent from the server.
void newUser(inData) {
  print("## Connector.newUser(): inData = $inData");

  model.setUserList(inData);
}

/// Received when a room is created.  Receives the current list of rooms on the server.
///
/// @param inData The data sent from the server.
void created(inData) {
  print("## Connector.created(): inData = $inData");

  model.setRoomList(inData);
}

/// Received when a room is closed.  Receives the current list of rooms on the server.
///
/// @param inData The data sent from the server.
void closed(inData) {
  // с сервера приходят данные map{roomName : inData.roomName, rooms : rooms}
  // а метод .setRoomList для корректной работы принимает
  // map ввиде только map{rooms : rooms}
  model.setRoomList(inData["rooms"]);

  print("## Connector.closed(): inData = $inData");

  // If this user is in the room, boot 'em! (oh, also, be nice and tell 'em what happened).
  if (inData["roomName"] == model.currentRoomName) {
    // Clear the model attributes reflecting the user in this room.
    model.removeRoomInvite(inData["roomName"]);
    model.setCurrentRoomUserList({});
    model.setCurrentRoomName(FlutterChatModel.DEFAULT_ROOM_NAME);
    model.setCurrentRoomEnabled(false);
    // Tell the user the room was closed.
    model.setGreeting("The room you were in was closed by its creator.");
    // Route back to the home screen.
  }
}

/// Received when a user joins a room.  Receives the room descriptor.
///
/// @param inData The data sent from the server.
void joined(inData) {
  print("## Connector.joined(): inData = $inData");

  // Update the list of users in the room if this user is in the room.
  if (model.currentRoomName == inData["roomName"]) {
    model.setCurrentRoomUserList(inData["users"]);
  }
}

/// Received when a user leaves a room.  Receives the room descriptor.
///
/// @param inData The data sent from the server.
void left(inData) {
  print("## Connector.left(): inData = $inData");

  // Update the list of users in the room if this user is in the room.
  if (model.currentRoomName == inData["roomName"]) {
    model.setCurrentRoomUserList(inData["users"]);
  }
}

/// Received this user is kicked from a room.  Receives the room descriptor.
///
/// @param inData The data sent from the server.
void kicked(inData) {
  print("## Connector.kicked(): inData = $inData");

  // Clear the model attributes reflecting the user in this room.
  model.removeRoomInvite(inData["roomName"]);
  model.setCurrentRoomUserList({});
  model.setCurrentRoomName(FlutterChatModel.DEFAULT_ROOM_NAME);
  model.setCurrentRoomEnabled(false);

  // Tell the user they got the boot.
  model.setGreeting("What did you do?! You got kicked from the room! D'oh!");

  // Route back to the home screen.
  Navigator.of(model.rootBuildContext).pushReplacementNamed("/");
}

/// Received when the user is invited to a room.  Receives the room name and inviter name (and username, but
/// that's pretty irrelevant to this function).
///
/// @param inData The data sent from the server.
void invited(inData) async {
  print("## Connector.invited(): inData = $inData");

  // Grab necessary data from payload.
  String roomName = inData["roomName"];
  String inviterName = inData["inviterName"];

  // Add the invite to the model.
  model.addRoomInvite(roomName);
  ScaffoldMessenger.of(model.rootBuildContext).showSnackBar(SnackBar(
    backgroundColor: Colors.amber,
    duration: Duration(seconds: 60),
    content: Text("You`ve been invited to the room "
        "'$roomName' by user '$inviterName'.\n\n"
        "You can enter the room from the lobby."),
    action: SnackBarAction(label: "Ok", onPressed: () {}),
  ));
}

/// Received when a posts a message to a room.  Receives an object with roomName, userName and message.
///
/// @param inData The data sent from the server.
void posted(inData) {
  print("## Connector.posted(): inData = $inData");

  // If the user is currently in the room then add message to room's message list.
  if (model.currentRoomName == inData["roomName"]) {
    model.addMessage(inData["userName"], inData["message"]);
  }
}
