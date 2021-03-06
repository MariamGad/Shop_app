import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';
import 'dart:convert';
import 'product.dart';

class Products with ChangeNotifier {
  Products(this.authToken, this.userId, this._items);
  final String authToken;
  final String userId;
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];
  bool _showFavouritesOnly = false;

  List<Product> get items {
    // if (_showFavouritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavourite).toList();
    // }
    return [..._items];
  }

  List<Product> get favouriteItems {
    return _items.where((prodItem) => prodItem.isFavourite).toList();
  }
  // void showFavouritesOnly() {
  //   _showFavouritesOnly = true;
  //   notifyListeners();
  // }
  //
  // void showAll() {
  //   _showFavouritesOnly = false;
  //   notifyListeners();
  // }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url = Uri.parse(
        'https://shop-app-c69f0-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      url = Uri.parse(
          'https://shop-app-c69f0-default-rtdb.firebaseio.com/userFavourites/$userId.json?auth=$authToken');
      final favouriteResponse = await http.get(url);
      final favouriteDate = json.decode(favouriteResponse.body);
      // print(favouriteDate);
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          imageUrl: prodData['imageUrl'],
          price: prodData['price'],
          isFavourite:
              favouriteDate == null ? false : favouriteDate[prodId] ?? false,
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        'https://shop-app-c69f0-default-rtdb.firebaseio.com/products.json?auth=$authToken');
    try {
      final response = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
            // 'isFavourite': product.isFavourite,
            'creatorId': userId,
          }));
      // print(json.decode(response.body));
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);
      // _items.insert(0, newProduct); // add to the start of the list
      notifyListeners();
    } catch (error) {
      print(error);
      throw (error);
    }
  }

  Future<void> updateProduct(String id, Product product) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    final url = Uri.parse(
        'https://shop-app-c69f0-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
    await http.patch(url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
        }));
    if (prodIndex >= 0) {
      _items[prodIndex] = product;
      notifyListeners();
    }
  }

  Future<void> removeProduct(String id) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[prodIndex];
    if (prodIndex >= 0) {
      _items.removeAt(prodIndex);
      notifyListeners();
      final url = Uri.parse(
          'https://shop-app-c69f0-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
      final response = await http.delete(url);
      if (response.statusCode >= 400) {
        _items.insert(prodIndex, existingProduct);
        notifyListeners();
        throw HttpException('Could not delete product.');
      }
    }
  }

  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }

  void refreshFavourites() {
    if (!_showFavouritesOnly) {
      notifyListeners();
    }
  }
}
