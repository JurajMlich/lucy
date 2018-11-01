import 'package:android/lucy_container.dart';
import 'package:android/model/finance_transaction_category.dart';
import 'package:android/repository/finance_transaction_category_repository.dart';
import 'package:android/ui/finance/category/finance_transaction_category_edit_page.dart';
import 'package:flutter/material.dart';

class FinanceTransactionCategoryListPage extends StatefulWidget {
  FinanceTransactionCategoryListPage();

  @override
  _FinanceTransactionCategoryListPageState createState() {
    return _FinanceTransactionCategoryListPageState();
  }
}

class _FinanceTransactionCategoryListPageState
    extends State<FinanceTransactionCategoryListPage> {
  List<FinanceTransactionCategory> categories;

  @override
  void initState() {
    super.initState();

    _load();
  }

  Future<Null> _load() async {
    var categoryRepository =
        LucyContainer().getRepository<FinanceTransactionCategoryRepository>();

    var categories = await categoryRepository.findAll();
    setState(() {
      this.categories = categories;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Categories'),
        actions: <Widget>[],
      ),
      body: _buildBody(context),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          var id = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => FinanceTransactionCategoryEditPage()));

          if (id != null) {
            _load();
          }
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
                ],
              ),
            ),
          ),
          onTap: () async {
            var id = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FinanceTransactionCategoryEditPage(
                      categoryId: category.id,
                    ),
              ),
            );

            if (id != null) {
              _load();
            }
          },
        );
      },
    );

    return child;
  }
}
