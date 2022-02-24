import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavourite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.price,
    this.isFavourite = false,
  });
  void _setFavValue(bool oldValue) {
    isFavourite = oldValue;
    notifyListeners();
  }

  Future<void> toggleFavouriteStatus() async {
    final oldStatus = isFavourite;
    isFavourite = !isFavourite;
    notifyListeners();
    final url = Uri.parse(
        'https://shop-app-c69f0-default-rtdb.firebaseio.com/products/$id.json');
    try {
      final response = await http.patch(
        url,
        body: json.encode(
          {
            'isFavourite': isFavourite,
          },
        ),
      );
      if (response.statusCode >= 400) {
        _setFavValue(oldStatus);
      }
    } catch (error) {
      _setFavValue(oldStatus);
    }
  }
}
