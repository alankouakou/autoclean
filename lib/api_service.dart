import 'dart:convert';
import 'package:autoclean/models/prestation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final apiServiceProvider = Provider.family<ApiService, String>((ref, periode) =>
    ApiService(
        endPointUrl: 'https://www.yrieehotel.com/api/nuiteesdumois/$periode'));

class ApiService {
  final String endPointUrl;

  ApiService({required this.endPointUrl});
  List<Prestation> prestations = [];

  Future<List<Prestation>> getData() async {
    try {
      var response = await http.get(Uri.parse(endPointUrl));
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List items = jsonData['rows'];
        prestations = items.map((item) => Prestation.fromJson(item)).toList();
      }
    } catch (ex) {
      print('inside apiService: ${ex.toString()}');
    }
    return prestations
        .where((element) => element.libelle.contains('flag'))
        .toList();
  }
}
