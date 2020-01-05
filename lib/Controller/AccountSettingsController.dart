import 'package:flutter/material.dart';
import '../globals.dart' as globals;

class AccountSettings extends StatefulWidget {
  AccountSettings({Key key}) : super (key: key);

  @override
  AccountSettingsState createState() => new AccountSettingsState();
}

class AccountSettingsState extends State<AccountSettings> {
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  bool nameEmpty;
  bool emailEmpty;

  void initState() {
    super.initState();

    _nameController.text = globals.name;
    if(_nameController.text.length == 0) {
      setState(() {
        nameEmpty = true;
      });
    }else {
      setState(() {
        nameEmpty = false;
      });
    }
    _nameController.addListener(() {
      if(_nameController.text.length == 0) {
        setState(() {
          nameEmpty = true;
        });
      }else {
        setState(() {
          nameEmpty = false;
        });
      }
    });

    _emailController.text = globals.email;
    if(_emailController.text.length == 0) {
      setState(() {
        emailEmpty = true;
      });
    }else {
      setState(() {
        emailEmpty = false;
      });
    }
    _emailController.addListener(() {
      if(_emailController.text.length == 0) {
        setState(() {
          emailEmpty = true;
        });
      }else {
        setState(() {
          emailEmpty = false;
        });
      }
    });
  }

  profilePicture() {
    return new Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Container(
            width: 50.0,
            height: 50.0,
            decoration: new BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.purple,
              gradient: new LinearGradient(
                colors: [Colors.red, Colors.blue]
              )
            ),
            child: Center(child:Text(globals.name.substring(0,1), style: TextStyle(fontSize: 20)))
          )
        ]
      )
    );
  }

  name() {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        nameEmpty ? Container() : Text('Name', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        TextField(
          controller: _nameController,
          keyboardType: TextInputType.text,
          autocorrect: false,
          style: new TextStyle(
            fontSize: 13.0,
            color: Colors.white
          ),
          decoration: new InputDecoration(
            hintText: 'Name',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none
          ),
        )
      ]
    );
  }

  email() {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        emailEmpty ? Container() : Text('Email', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.text,
          autocorrect: false,
          style: new TextStyle(
            fontSize: 13.0,
            color: Colors.white
          ),
          decoration: new InputDecoration(
            hintText: 'Email',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none
          ),
        )
      ]
    );
  }

  settings() {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.all(5.0),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        gradient: new LinearGradient(
          begin: Alignment(0.0, -2.0),
          colors: [Colors.black, Colors.grey[850]]
        )
      ),
      child: Column(
        children: <Widget>[
          profilePicture(),
          Divider(
            height: 15,
            color: Colors.grey[700],
          ),
          name(),
          Divider(
            height: 15,
            color: Colors.grey[700],
          ),
          email()
        ]
      )
    );
  }

  password() {
    return GestureDetector(
      onTap: () {

      },
      child: Container(
        margin: EdgeInsets.all(5.0),
        padding: EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: new LinearGradient(
            begin: Alignment(0.0, -2.0),
            colors: [Colors.black, Colors.grey[850]]
          )
        ),
        child: Text('Password', style: TextStyle(fontWeight: FontWeight.bold))
      )
    );
  }

  buildBody() {
    return new Container(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  settings(),
                  password()
                ],
              ),
            )
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: new GestureDetector(
                  onTap: () {
                    
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                    // padding: const EdgeInsets.only(top: 0.0, bottom: 0.0),
                    constraints: const BoxConstraints(maxHeight: 35.0, minWidth: 200.0, minHeight: 35.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      gradient: new LinearGradient(
                        colors: [Color.fromARGB(255, 0, 61, 184), Colors.lightBlueAccent],
                      )
                    ),
                    child: Center(
                      child: Text(
                        'Save',
                        style: new TextStyle(
                          fontSize: 19.0,
                          fontWeight: FontWeight.w300
                        )
                      )
                    )
                  )
                )
              )
            ]
          ),
          Padding(padding: EdgeInsets.only(bottom: 24))
        ]
      )
    );
  }

  Widget build(BuildContext context) {
    return new Theme(
      data: new ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        primaryColor: globals.userColor,
        brightness: globals.userBrightness,
      ),
      child: Scaffold(
        appBar: new AppBar(
          title: new Text('Account Settings')
        ),
        body: new Stack(
          children: <Widget> [
            buildBody()
          ]
        )
      )
    );
  }
}