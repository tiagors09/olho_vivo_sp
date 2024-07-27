import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:olho_vivo_sp/models/bus_stop_model.dart';
import 'package:olho_vivo_sp/util/environment.dart';

import '../models/hall_model.dart';

class ApiService extends ChangeNotifier {
  String? _sessionToken;

  Future<Null> authenticate() async {
    try {
      final response = await http.post(
        Uri.parse(
          '${Environment.base_url}${Environment.auth_endpoint}?token=${Environment.token}',
        ),
      );

      if (response.statusCode >= HttpStatus.ok &&
          response.statusCode < HttpStatus.multipleChoices) {
        _sessionToken = response.body;
      } else {
        throw Exception(Environment.failed_auth_msg);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<HallModel>> getHalls() async {
    try {
      if (_sessionToken == null) {
        await authenticate();
      }

      final response = await http.get(
        Uri.parse(
          '${Environment.base_url}${Environment.halls_endpoint}',
        ),
        headers: {
          'Authorization': 'Bearer $_sessionToken',
        },
      );

      if (response.statusCode >= HttpStatus.ok &&
          response.statusCode < HttpStatus.multipleChoices) {
        List<dynamic> data = jsonDecode(response.body);

        return data
            .map(
              (hall) => HallModel.fromMap(hall),
            )
            .toList();
      } else {
        throw Exception(Environment.failed_get_halls_msg);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<BusStopModel>> getBusStopsByHall(String? hallCode) async {
    try {
      if (_sessionToken == null) {
        await authenticate();
      }

      final response = await http.get(
        Uri.parse(
          '${Environment.base_url}${Environment.bus_stops_by_hall_endpoint}?codigoCorredor=${hallCode ?? ''}',
        ),
        headers: {
          'Authorization': 'Bearer $_sessionToken',
        },
      );

      if (response.statusCode >= HttpStatus.ok &&
          response.statusCode < HttpStatus.multipleChoices) {
        final List<dynamic> data = jsonDecode(response.body);

        return data
            .map(
              (busStop) => BusStopModel.fromMap(busStop),
            )
            .toList();
      } else {
        throw Exception('');
      }
    } catch (e) {
      rethrow;
    }
  }

  getArrivalForecast({String? busStopCode, String? busLineCode}) async {
    try {
      if (_sessionToken == null) {
        await authenticate();
      }

      print(
          '${Environment.base_url}${Environment.arrival_forecast_endpoint}?codigoParada=${busStopCode ?? ''}&codigoLinha=${busLineCode ?? ''}');

      final response = await http.get(
        Uri.parse(
          '${Environment.base_url}${Environment.arrival_forecast_endpoint}?codigoParada=${busStopCode ?? ''}&codigoLinha=${busLineCode ?? ''}',
        ),
        headers: {
          'Authorization': 'Bearer $_sessionToken',
        },
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      return data;
    } catch (e) {
      rethrow;
    }
  }
}
