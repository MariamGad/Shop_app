import 'package:flutter/material.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = 'edit-product';
  const EditProductScreen({Key? key}) : super(key: key);

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: ListView(
            children: [
              TextFormField(
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_priceFocusNode);
                },
              ),
              TextFormField(
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                focusNode: _priceFocusNode,
                decoration: InputDecoration(
                  labelText: 'Price',
                  labelStyle: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_descriptionFocusNode);
                },
              ),
              TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: 3,
                focusNode: _descriptionFocusNode,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 100.0,
                    height: 100.0,
                    margin: EdgeInsets.only(
                      right: 10,
                      top: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Colors.grey,
                      ),
                    ),
                    child: _imageUrlController.text.isEmpty
                        ? Text('Enter a URL')
                        : FittedBox(
                            child: Image.network(
                              _imageUrlController.text,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                  Expanded(
                    child: TextFormField(
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.url,
                      controller: _imageUrlController,
                      focusNode: _imageUrlFocusNode,
                      onEditingComplete: () {
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        labelText: 'Image URL',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
