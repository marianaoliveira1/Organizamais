import 'package:flutter/material.dart';

class SubcategoriesPage extends StatelessWidget {
  final String categoryName;
  final List<String> subcategories;

  const SubcategoriesPage({
    Key? key,
    required this.categoryName,
    required this.subcategories,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
      body: ListView.builder(
        itemCount: subcategories.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(subcategories[index]),
            leading: Icon(Icons.label, color: Colors.grey),
          );
        },
      ),
    );
  }
}
