import 'dart:convert';
import 'dart:io';

import 'package:android/exception/forbidden_exception.dart';
import 'package:android/exception/not_found_exception.dart';
import 'package:android/exception/server_exception.dart';
import 'package:android/exception/server_unavailable_exception.dart';
import 'package:android/exception/unauthorized_exception.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

// todo: auth

/// Client used for communication between application and server.
class ServerClient {
  /// Date format to be used for exchanging information.
  static final DateFormat dateFormat = DateFormat("yyyy-MM-ddTHH:mm:ss");

  final Client client;
  final String host;

  ServerClient(this.host) : client = Client();

  /// Execute get request to the following URI. Add auth headers. Throw
  /// exception in case of an error.
  Future<Response> get(
    String uri, {
    Map<String, String> headers,
  }) async {
    try {
      var response = await client.get(
        '$host/$uri',
        headers: headers,
      );

      _throwIfError(response);

      return response;
    } on SocketException catch (e) {
      throw ServerUnavailableException(e.osError.message);
    }
  }

  /// Execute post request to the following URI. Add auth headers. Throw
  /// exception in case of an error.
  Future<Response> post(
    uri, {
    Map<String, String> headers,
    body,
    Encoding encoding,
  }) async {
    try {
      var response = await client.post(
        '$host/$uri',
        headers: headers,
        body: body,
        encoding: encoding,
      );

      _throwIfError(response);

      return response;
    } on SocketException catch (e) {
      throw ServerUnavailableException(e.osError.message);
    }
  }

  /// Execute put request to the following URI. Add auth headers. Throw
  /// exception in case of an error.
  Future<Response> put(
    uri, {
    Map<String, String> headers,
    body,
    Encoding encoding,
  }) async {
    try {
      var response = await client.put(
        '$host/$uri',
        headers: headers,
        body: body,
        encoding: encoding,
      );

      _throwIfError(response);

      return response;
    } on SocketException catch (e) {
      throw ServerUnavailableException(e.osError.message);
    }
  }

  /// Execute patch request to the following URI. Add auth headers. Throw
  /// exception in case of an error.
  Future<Response> patch(
    uri, {
    Map<String, String> headers,
    body,
    Encoding encoding,
  }) async {
    try {
      var response = await client.patch(
        '$host/$uri',
        headers: headers,
        body: body,
        encoding: encoding,
      );

      _throwIfError(response);

      return response;
    } on SocketException catch (e) {
      throw ServerUnavailableException(e.osError.message);
    }
  }

  /// Execute delete request to the following URI. Add auth headers. Throw
  /// exception in case of an error.
  Future<Response> delete(uri, {Map<String, String> headers}) async {
    try {
      var response = await client.delete('$host/$uri', headers: headers);

      _throwIfError(response);

      return response;
    } on SocketException catch (e) {
      throw ServerUnavailableException(e.osError.message);
    }
  }

  /// Close connection.
  void close() {
    client.close();
  }

  void _throwIfError(Response response) {
    if (response.statusCode > 399) {
      switch (response.statusCode) {
        case 401:
          throw UnauthorizedException(response.body);
        case 403:
          throw ForbiddenException(response.body);
        case 404:
          throw NotFoundException(response.body);
        default:
          throw ServerException(response.body);
      }
    }
  }
}
