import 'dart:html';
import 'dart:async';

import 'package:mysql1/mysql1.dart';

Future<void> main() async {
  if (window.location.pathname!.endsWith('login.html')) {
    loginForm();
  } else if (window.location.pathname!.endsWith('registration.html')) {
    registrationForm();
  }
}

Future<dynamic> dbConn() async {
  var mysettings = ConnectionSettings(
      host: 'localhost', port: 3306, user: 'root', db: 'confidential_schema');
  var connection = await MySqlConnection.connect(mysettings);
  return connection;
}

Future<dynamic> formRegistration() async {
  var newUsername = (querySelector('#new_user') as InputElement).value;
  var newPasswd = (querySelector('#newPasswd') as InputElement).value;
  var confPasswd = (querySelector('#confPasswd') as InputElement).value;
  var firstName = (querySelector('#firstName') as InputElement).value;
  var lastName = (querySelector('#lastName') as InputElement).value;

  if (newPasswd != confPasswd) {
    querySelector('#terminateSms')!.text = "Password Mismatch";
  } else {
    var mysettings = ConnectionSettings(
        host: 'localhost', port: 3306, user: 'root', db: 'confidential_schema');
    var connection = await MySqlConnection.connect(mysettings);
    var insertData = await connection.query(
        "INSERT INTO registration values(?,?,?,?),[$firstName,$lastName,$newUsername,${confPasswd.hashCode}]");

    connection.close();
  }
}

void loginForm() {
  querySelector('#login')!.onSubmit.listen((event) {
    event.preventDefault();
    formLogin();
  });
}

void registrationForm() {
  querySelector('#register')!.onSubmit.listen((event) {
    event.preventDefault();
    formRegistration();
  });
}

void formLogin() async {
  var mysettings = ConnectionSettings(
      host: 'localhost', port: 3306, user: 'root', db: 'confidential_schema');
  var connection = await MySqlConnection.connect(mysettings);

  var username = (querySelector('#username') as InputElement).value;
  var passwd = (querySelector('#passwd') as InputElement).value;

  var values = await connection.query("select * from registration");
  for (var user in values.toList()) {
    var z = user[2].toString();

    if (z == username) {
      var dbpasswd = await connection.query(
          "select password from registration where userName = ?", [username]);
      var dbusername = await connection.query(
          "Select userName from registration where username = ?", [username]);
      var newpasswd = dbpasswd.toList()[0][0].toString();
      var newUsername = dbusername.toList()[0][0].toString();

      if (username == newUsername) {
        if (passwd.hashCode.toString() == newpasswd.toString()) {
        } else if (passwd != newpasswd) {}
      } else if (username != newUsername) {}
      connection.close();
    }
  }
}
