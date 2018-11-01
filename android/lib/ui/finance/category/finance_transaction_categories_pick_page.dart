import 'package:android/lucy_container.dart';
import 'package:android/model/finance_transaction_category.dart';
import 'package:android/repository/finance_transaction_category_repository.dart';
import 'package:flutter/material.dart';

class FinanceTransactionCategoriesPickPage extends StatefulWidget {
  final Set<String> originalCategoriesIds;

  FinanceTransactionCategoriesPickPage(this.originalCategoriesIds);

  @override
  _FinanceTransactionCategoriesPickPageState createState() {
    return _FinanceTransactionCategoriesPickPageState();
  }
}

class _FinanceTransactionCategoriesPickPageState extends State<FinanceTransactionCategoriesPickPage> {
  List<FinanceTransactionCategory> categories;
  Set<String> selectedCategoriesIds;

  @override
  void initState() {
    super.initState();

    selectedCategoriesIds = Set.from(widget.originalCategoriesIds);

    var categoryRepository =
        LucyContainer().getRepository<FinanceTransactionCategoryRepository>();

    categoryRepository.findAll().then((categories) {
      setState(() {
        this.categories = categories;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select categories'),
        actions: <Widget>[],
      ),
      body: _buildBody(context),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.done),
        onPressed: () async {
          Navigator.pop(context, selectedCategoriesIds);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (categories == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    Widget child = ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        var category = categories[index];

        return InkWell(
          child: Container(
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: Theme.of(context).dividerColor))),
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        category.name,
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
                  ),
                  !selectedCategoriesIds.contains(category.id)
                      ? Container(
                          width: 0,
                        )
                      : Icon(
                          Icons.done,
                          color: Colors.green,
                        )
                ],
              ),
            ),
          ),
          onTap: () {
            setState(() {
              if (selectedCategoriesIds.contains(category.id)) {
                selectedCategoriesIds.remove(category.id);
              } else {
                selectedCategoriesIds.add(category.id);
              }
            });
          },
        );
      },
    );

    return child;
  }
}
