import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:scoped_model/scoped_model.dart';

class FlutterChatModel extends Model {
  /// The app's root widget build context.    Needed in a number of spots, so makes sense for it to be "global" even
  /// though it's not "state" per se (that's why we use the default setter: no need to call notifyListeners(), so
  /// no need for a explicit setter.
  late BuildContext rootBuildContext;

  /// The app's documents directory.  Needed in a number of spots, so makes sense for it to be "global" even
  /// though it's not "state" per se (that's why we use the default setter: no need to call notifyListeners(), so
  /// no need for a explicit setter.
  late Directory docsDir;

  /// The greeting to show on the home screen.
  String greeting = "";

  /// The userName of the logged in user.
  String userName = "";

  // The default text to show when not in a room.
  // ignore: non_constant_identifier_names
  static final String DEFAULT_ROOM_NAME = "Not currently in a room";

  /// The name of the room the user is currently in, if any.
  String currentRoomName = DEFAULT_ROOM_NAME;

  /// The list of users in the current room.
  List currentRoomUserList = [];

  /// Is the Current Room option in the drawer enabled? (only when in a room)
  bool currentRoomEnabled = false;

  /// The list of messages in the current room (not a complete list, just since the user joined it).  Each element
  /// is an Map in the form { userName : "", message : "" }.
  List currentRoomMessages = [];

  /// The list of rooms currently on the server.
  List roomList = [];

  /// The list of users currently on the server.
  List userList = [];

  /// Whether the creator functions on the room screen are enabled.
  bool creatorFunctionsEnabled = false;

  /// A map of rooms the user has been invited to.  Simple map of room names to boolean true.
  Map roomInvites = {};

  /// Set the greeting to show on the home screen.
  ///
  /// @param inGreeting The greeting.  Cannot be null.
  void setGreeting(final String inGreeting) {
    print("## FlutterChatModel.setGreeting(): inGreeting = $inGreeting");

    greeting = inGreeting;
    notifyListeners();
  }

  /// Set the userName of the logged in user.
  ///
  /// @param inUserName The userName.  Cannot be null.
  void setUserName(final String inUserName) {
    print("## FlutterChatModel.setUserName(): inUserName = $inUserName");

    userName = inUserName;
    notifyListeners();
  }

  /// Set the name of the room the user is currently in.
  ///
  /// @param inRoomName The name of the room (blank string if no current room).  Cannot be null.
  void setCurrentRoomName(final String inCurrentRoom) {
    print("## FlutterChatModel.setCurrentRoomName(): inRoomName = $inCurrentRoom");

    currentRoomName = inCurrentRoom;
    notifyListeners();
  }

  /// Set the enabled status of the creator functions on the room screen.
  ///
  /// @param inRoomName The name of the room (blank string if no current room).  Cannot be null.
  void setCreatorFunctiondEnabled(final bool inCreatorFuncrionsEnable) {
    print("## FlutterChatModel.setCreatorFunctionsEnabled(): inEnabled = $inCreatorFuncrionsEnable");

    creatorFunctionsEnabled = inCreatorFuncrionsEnable;
    notifyListeners();
  }

  /// Set the enabled status of the Current Room drawer option.
  ///
  /// @param inRoomName The name of the room (blank string if no current room).  Cannot be null.
  setCurrentRoomEnabled(final bool inCurrentRoomEnable) {
    print("## FlutterChatModel.setCurrentRoomEnabled(): inEnabled = $inCurrentRoomEnable");

    currentRoomEnabled = inCurrentRoomEnable;
    notifyListeners();
  }

  /// Add a message to the list of messages in the room.
  ///
  /// @param inUsername The name of the user that posted the message.
  /// @param inMessage  The message.
  void addMessage(final String inUserName, final String inMessage) {
    print("## FlutterChatModel.addMessage(): inUserName = $inUserName, inMessage = $inMessage");

    currentRoomMessages.add({"userName": inUserName, "message": inMessage});
    notifyListeners();
  }

  /// Set the list of rooms currently on the server.
  ///
  /// @param inRooms The map of room descriptor objects from the server.
  void setRoomList(final Map inRoomList) {
    print("## FlutterChatModel.setRoomList(): inRoomList = $inRoomList");

    List rooms = [];
    for (String roomName in inRoomList.keys) {
      Map room = inRoomList[roomName];
      rooms.add(room);
    }
    roomList = rooms;
    notifyListeners();
  }

  /// Set the list of users currently on the server.
  ///
  /// @param inUsers The map of user descriptor objects from the server.
  void setUserList(final Map inUserList) {
    print("## FlutterChatModel.setUserList(): inUserList = $inUserList");

    List users = [];
    for (String userName in inUserList.keys) {
      Map user = inUserList[userName];
      users.add(user);
    }
    userList = users;
    notifyListeners();
  }

  /// Set the list of users in the room the user is currently in.
  ///
  /// @param inUserList The list of users currently in the room.
  void setCurrentRoomUserList(final Map inCurrentRoomUserList) {
    print("## FlutterChatModel.setCurrentRoomUserList(): inCurrentRoomUserList = $inCurrentRoomUserList");

    List currentRoomUsers = [];
    for (String currentRoomName in inCurrentRoomUserList.keys) {
      Map currentRoomUser = inCurrentRoomUserList[currentRoomName];
      currentRoomUsers.add(currentRoomUser);
    }
    currentRoomUserList = currentRoomUsers;
    notifyListeners();
  }

  /// Add an invite for a room.
  ///
  /// @param inRoomName The name of the room to add an invite for.
  void addRoomInvite(final String inRoomName) {
    print("## FlutterChatModel.addRoomInvite(): inRoomName = $inRoomName");

    roomInvites[inRoomName] = true;
  }

  /// Remove an invite for a room.
  ///
  /// @param inRoomName The name of the room to remove an invite for.
  void removeRoomInvite(final String inRoomName) {
    print("## FlutterChatModel.removeRoomInvite(): inRoomName = $inRoomName");

    roomInvites.remove(inRoomName);
  }

  /// Clear all the messages for the current room.
  void clearCurrentRoomMessage() {
    print("## FlutterChatModel.clearCurrentRoomMessages()");

    currentRoomMessages = [];
  }
}

// The one and only instance of this model.
FlutterChatModel model = FlutterChatModel();
