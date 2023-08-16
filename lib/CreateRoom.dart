import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterchat/AppDrawer.dart';
import 'package:flutterchat/Model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutterchat/Connector.dart' as connector;

class CreateRoom extends StatefulWidget {
  CreateRoom({Key? key}) : super(key: key);

  @override
  _CreateRoom createState() => _CreateRoom();
}

class _CreateRoom extends State {
  late String _title;
  late String _description;
  bool _private = false;
  double _maxPeople = 25;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(final BuildContext inContext) {
    return ScopedModel<FlutterChatModel>(
        model: model,
        child: ScopedModelDescendant<FlutterChatModel>(
            builder: (inContext, Widget? inChild, FlutterChatModel inModel) {
          return Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(title: Text("Create Room")),
              drawer: AppDrawer(),
              bottomNavigationBar: Padding(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                child: SingleChildScrollView(
                    child: Row(children: [
                  TextButton(
                      child: Text("Cancel"),
                      onPressed: () {
                        FocusScope.of(inContext).requestFocus(FocusNode());
                        Navigator.of(inContext).pop();
                      }),
                  Spacer(),
                  TextButton(
                      child: Text("Save"),
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }
                        _formKey.currentState!.save();
                        int maxPeople = _maxPeople.truncate();
                        connector.create(_title, _description, maxPeople,
                            _private, model.userName, (inStatus, inRoomList) {
                          if (inStatus == "created") {
                            model.setRoomList(inRoomList);
                            FocusScope.of(inContext).requestFocus(FocusNode());
                            Navigator.of(inContext).pop();
                          } else {
                            ScaffoldMessenger.of(inContext).showSnackBar(
                                SnackBar(
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 2),
                                    content: Text(
                                        "Sorry, that room already exists")));
                          }
                        });
                      })
                ])),
              ),
              body: Form(
                  key: _formKey,
                  child: ListView(children: [
                    ListTile(
                      leading: Icon(Icons.subject),
                      title: TextFormField(
                        decoration: InputDecoration(hintText: "Name"),
                        validator: (inValue) {
                          if (inValue!.length == 0 || inValue.length > 14) {
                            return "Please enter a name no more "
                                "than 14 characters long";
                          }
                          return null;
                        },
                        onSaved: (inValue) {
                          setState(() {
                            _title = inValue!;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.description),
                      title: TextFormField(
                        decoration: InputDecoration(hintText: "Description"),
                        onSaved: (inValue) {
                          setState(() {
                            _description = inValue!;
                          });
                        },
                      ),
                    ),
                    ListTile(
                        title: Row(children: [
                          Text("Max\nPeople"),
                          Slider(
                              min: 0,
                              max: 99,
                              value: _maxPeople,
                              onChanged: (double inValue) {
                                setState(() {
                                  _maxPeople = inValue;
                                });
                              })
                        ]),
                        trailing: Text(_maxPeople.toStringAsFixed(0))),
                    ListTile(
                        title: Row(children: [
                      Text("Private"),
                      Switch(
                          value: _private,
                          onChanged: (inValue) {
                            setState(() {
                              _private = inValue;
                            });
                          })
                    ]))
                  ])));
        }));
  }
}
