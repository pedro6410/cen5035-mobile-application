import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginLogoutWidget extends StatefulWidget {
  final Function(int) onLoginStatusChanged;
  final Function(String, String) onUserDataReceived;



  LoginLogoutWidget({required this.onLoginStatusChanged,
    required this.onUserDataReceived,

  });

  @override
  _LoginLogoutWidgetState createState() => _LoginLogoutWidgetState();
}

class _LoginLogoutWidgetState extends State<LoginLogoutWidget> {
  int loggedIn = 0;
  String userId = '';
  String password = '';
  String message = '';
  String loginUrl = 'https://h2oetj3vmokksdrajr6fzrc5na0uauyy.lambda-url.us-east-1.on.aws/';


  Future<void> _login() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Login'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                decoration: InputDecoration(labelText: 'User ID'),
                onChanged: (value) {
                  userId = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                onChanged: (value) {
                  password = value;
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Login'),
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  print('userId: ${userId}');
                  print('password: ${password}');
                  final response = await http.post(
                    Uri.parse(loginUrl),
                    headers: <String, String>{
                      'Content-Type': 'application/json; charset=UTF-8',
                    },
                    body: jsonEncode(<String, dynamic>{
                      'payload' : {
                      'user_id': userId,
                      'user_password': password,
                        }
                    }),
                  );

                  print('response.statusCode: ${response.statusCode}');

                  if (response.statusCode == 200) {
                    final responseBody = jsonDecode(response.body);
                    final empId = responseBody['employeeid'];
                    final employerId = responseBody['employerid'];
                    setState(() {
                      loggedIn = 1;
                      //message = 'Login successful';
                    });
                    widget.onLoginStatusChanged(1);
                    widget.onUserDataReceived(empId, employerId);
                  } else {
                    setState(() {
                      message = 'Login failed. Status code: ${response.statusCode}';
                    });
                  }
                } catch (e) {
                  setState(() {
                    message = 'Error: $e';
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _logout() {
    setState(() {
      loggedIn = 0;
      message = 'Logged out';
    });
    widget.onLoginStatusChanged(0);
  }



  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: loggedIn == 0 ? _login : _logout,
          child: Text(loggedIn == 0 ? 'Login' : 'Logout'),
        ),
        Text(message),
      ],
    );
  }
}