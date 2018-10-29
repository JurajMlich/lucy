import 'dart:convert';

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

  /// Execute get request to the following URI. Add auth headers.
  Future<Response> get(
    String uri, {
    Map<String, String> headers,
  }) async {
    var response = await client.get(
      '$host/$uri',
      headers: headers,
    );
    return response;
  }

  /// Execute post request to the following URI. Add auth headers.
  Future<Response> post(
    uri, {
    Map<String, String> headers,
    body,
    Encoding encoding,
  }) async {
    var response = await client.post(
      '$host/$uri',
      headers: headers,
      body: body,
      encoding: encoding,
    );
    return response;
  }

  /// Execute put request to the following URI. Add auth headers.
  Future<Response> put(
    uri, {
    Map<String, String> headers,
    body,
    Encoding encoding,
  }) async {
    var response = await client.put(
      '$host/$uri',
      headers: headers,
      body: body,
      encoding: encoding,
    );
    return response;
  }

  /// Execute patch request to the following URI. Add auth headers.
  Future<Response> patch(
    uri, {
    Map<String, String> headers,
    body,
    Encoding encoding,
  }) async =>
      await client.patch(
        '$host/$uri',
        headers: headers,
        body: body,
        encoding: encoding,
      );

  /// Execute delete request to the following URI. Add auth headers.
  Future<Response> delete(uri, {Map<String, String> headers}) async =>
      await client.delete('$host/$uri', headers: headers);

  /// Close connection.
  void close() {
    client.close();
  }
}
