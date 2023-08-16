import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'Model.dart' show FlutterChatModel, model;
import 'Home.dart';

late IO.Socket _io;

void showPleaseWait() {
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
                          child: SizedBox(
                              height: 50,
                              width: 50,
                              child: CircularProgressIndicator(
                                  value: null, strokeWidth: 10))),
                      Container(
                          margin: const EdgeInsets.only(top: 20),
                          child: Center(
                              child: Text("Please wait, contacting server...",
                                  style: new TextStyle(color: Colors.white))))
                    ])));
      });
}

void hidePleaseWait() {
  Navigator.of(model.rootBuildContext).pop();
}

void connectToServer(final Function inCallback) {
  try {
    _io = IO.io('http://10.0.2.2:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    _io.connect();

    _io.on("newUser", newUser);
    _io.on("created", created);
    _io.on("closed", closed);
    _io.on("joined", joined);
    _io.on("left", left);
    _io.on("kicked", kicked);
    _io.on("invited", invited);
    _io.on("posted", posted);

    inCallback();
  } catch (e) {
    print(e.toString());
  }
}

void validate(final String inUserName, final String inPassword,
    final Function inCallback) {
  Map<String, dynamic> namePassword = {"userName": inUserName, "password": inPassword};

  showPleaseWait();
  _io.emitWithAck("validate", namePassword,
      ack: (inData) {
    hidePleaseWait();
    inCallback(inData["status"]);
  });
}

void listRooms(final Function inCallback) {
  showPleaseWait();

  _io.emitWithAck("listRooms", "{}",
          ack: (inData) {
        hidePleaseWait();
        inCallback(inData);
      }
  );
}

void create(final String inRoomName, final String inDescription, final int inMaxPeople, final bool inPrivate,
    final String inCreator, final Function inCallback
    ) {
  Map<String, dynamic> roomParam = {"roomName" : inRoomName, "description" : inDescription,
  "maxPeople" : inMaxPeople, "private" : inPrivate, "creator" : inCreator};

  showPleaseWait();
  _io.emitWithAck("create", roomParam,
          ack: (inData) {
        hidePleaseWait();
        inCallback(inData["status"], inData["rooms"]);
      }
  );

}

void join(final String inUserName, final String inRoomName, final Function inCallback) {
  Map<String, dynamic> roomParam = {"userName" : inUserName, "roomName" : inRoomName};

  showPleaseWait();
  _io.emitWithAck("join", roomParam,
         ack: (inData) {
        hidePleaseWait();
        inCallback(inData["status"], inData["room"]);
      }
  );
}

void leave(final String inUserName, final String inRoomName, final Function inCallback) {
  Map<String, dynamic> room = {"userName" : inUserName, "roomName" : inRoomName};

  showPleaseWait();
  _io.emitWithAck("leave", room,
          ack: (inData) {
        hidePleaseWait();
        inCallback();
      }
  );
}

void listUsers(final Function inCallback) {
  showPleaseWait();

  _io.emitWithAck("listUsers", "{}",
      ack: (inData) {
        hidePleaseWait();
        inCallback(inData);
      }
  );
}

void invite(final String inUserName, final String inRoomName, final String inInviterName, final Function inCallback) {
  Map<String, dynamic> roomParam = {"userName" : inUserName, "roomName" : inRoomName, "inviterName" : inInviterName};

  showPleaseWait();
  _io.emitWithAck("invite", roomParam,
          ack: (inData) {
        hidePleaseWait();
        inCallback();
      }
  );
}

void post(final String inUserName, final String inRoomName, final String inMessage, final Function inCallback) {
  Map<String, dynamic> roomParam = {"userName" : inUserName, "roomName" : inRoomName, "message" : inMessage};

  showPleaseWait();
  _io.emitWithAck("post", roomParam,
          ack: (inData) {
        hidePleaseWait();
        inCallback(inData["status"]);
      }
  );
}

void close(final String inRoomName, final Function inCallback) {
  showPleaseWait();

  _io.emitWithAck("close", {"roomName" : inRoomName},
          ack: (inData) {
        hidePleaseWait();
        inCallback();
      }
  );
}

void kick(final String inUserName, final String inRoomName, final Function inCallback) {
  Map<String, dynamic> room = {"userName" : inUserName, "roomName" : inRoomName};

  // print("$inUserName kick");

  showPleaseWait();
  _io.emitWithAck("kick", room,
          ack: (inData) {
        hidePleaseWait();
        inCallback();
      }
  );
}

void newUser(inData) {
  model.setUserList(inData);
}

void created(inData) {
  model.setRoomList(inData);
}

void closed(inData) {
  // с сервера приходят данные map{roomName : inData.roomName, rooms : rooms}
  // а метод .setRoomList для корректной работы принимает
  // map ввиде только map{rooms : rooms}
  model.setRoomList(inData["rooms"]);

  if (inData["roomName"] == model.currentRoomName) {
    model.removeRoomInvite(inData["roomName"]);
    model.setCurrentRoomUserList({});
    model.setCurrentRoomName(FlutterChatModel.DEFAULT_ROOM_NAME);
    model.setCurrentRoomEnabled(false);
    model.setGreeting("The room you were in was closed by its creator.");
    // Navigator.of(model.rootBuildContext).pushReplacementNamed("/");
    // Navigator.of(model.rootBuildContext)
    //     .pushNamedAndRemoveUntil("/", ModalRoute.withName("/Lobby"));
  }
}

void joined(inData) {
  if (model.currentRoomName == inData["roomName"]) {
    model.setCurrentRoomUserList(inData["users"]);
  }
}

void left(inData) {
  if (model.currentRoomName == inData["roomName"]) {
    model.setCurrentRoomUserList(inData["users"]);
  }
}

void kicked(inData) {
  // print(inData["roomName"] + " room");

  model.removeRoomInvite(inData["roomName"]);
  model.setCurrentRoomUserList({});
  model.setCurrentRoomName(FlutterChatModel.DEFAULT_ROOM_NAME);
  model.setCurrentRoomEnabled(false);
  model.setGreeting("What did you do?! You got kicked from the room! D'oh!");
  // Navigator.of(model.rootBuildContext).pop();
  Navigator.of(model.rootBuildContext).pushReplacementNamed("/");
  // Navigator.of(model.rootBuildContext)
  //     .pushNamedAndRemoveUntil("/", ModalRoute.withName("/"));
}

void invited(inData) async {
  String roomName = inData["roomName"];
  String inviterName = inData["inviterName"];
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

void posted(inData) {
  if (model.currentRoomName == inData["roomName"]) {
    model.addMessage(inData["userName"], inData["message"]);
  }
}
