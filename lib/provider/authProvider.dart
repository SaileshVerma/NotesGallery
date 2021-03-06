import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart' as http;

class Authh with ChangeNotifier {
  String? _token;
  String? _userId;
  DateTime? _expiryDate;

  bool get isAuth {
    return token != null;
  }

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String? get userId {
    return _userId;
  }

  // String get userId {
  //   return _userId;
  // }
  //f

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyDEck00lZfJiUAttZ5yT7HGF_edGhvTZoU-GC5upk9fHVA7ERg';
    //this both are genrated by firebase

    try {
      final response = await http.post(
        Uri(path: url),
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );

      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      //if response data is not null ie it has get values do this\

      _token = responseData['idToken'];
      _userId = responseData["localId"];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );

      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> signUp(String? email, String? password) async {
    return _authenticate(email!, password!, 'signUp');
  }

  Future<void> signIn(String? email, String? password) async {
    return _authenticate(email!, password!, 'signInWithPassword');
  }
}
