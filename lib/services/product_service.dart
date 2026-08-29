import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:semana4/models/product.dart';

class ProductService {
  static const String _baseurl = 'https://dummyjson.com';

  Future<List<Product>> getProduct({int limit = 30}) async {
    final url = Uri.parse('$_baseurl/products?limit=$limit');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Error procesando productos ${response.statusCode}');
    }
    final Map<String, dynamic> data = jsonDecode(response.body);
    final List<dynamic> jsonList = data['products'];

    return jsonList.map((j) => Product.fromJson(j)).toList();
  }
}