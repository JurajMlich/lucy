import 'package:android/lucy_container.dart';
import 'package:android/model/finance_transaction_category.dart';
import 'package:android/repository/finance_transaction_category_repository.dart';
import 'package:android/ui/flushbar_service.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class FinanceTransactionCategoryEditPage extends StatefulWidget {
  final String categoryId;

  FinanceTransactionCategoryEditPage({this.categoryId});

  @override
  _FinanceTransactionCategoryEditPageState createState() {
    return _FinanceTransactionCategoryEditPageState(categoryId);
  }
}

class _FinanceTransactionCategoryEditPageState
    extends State<FinanceTransactionCategoryEditPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final String categoryId;

  FinanceTransactionCategoryRepository categoryRepository;

  FinanceTransactionCategory category;

  bool loaded = false;

  _FinanceTransactionCategoryEditPageState(this.categoryId) {
    categoryRepository =
        LucyContainer().getRepository<FinanceTransactionCategoryRepository>();
  }

  @override
  Widget build(BuildContext context) {
    var actions = <Widget>[];

    if (categoryId != null && loaded) {
      actions.add(IconButton(
        icon: Icon(Icons.delete),
        onPressed: () async {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Delete'),
                  content: Text('Do you really wish to delete the category?'),
                  actions: <Widget>[
                    new FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('No'),
                    ),
                    new FlatButton(
                      onPressed: () async {
                        await categoryRepository.delete(category);
                        Navigator.pop(context, false);
                        Navigator.pop(context, false);
                        FlushbarService().show(
                          FlushType.success,
                          'Succesfully deleted.',
                          context,
                        );
                      },
                      child: Text('Yes'),
                    )
                  ],
                );
              });
        },
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title:
            Text(this.categoryId == null ? 'Create category' : 'Edit category'),
        actions: actions,
      ),
      body: _buildBody(context),
      floatingActionButton: FloatingActionButton(
        child: Icon(categoryId == null ? Icons.done : Icons.save),
        onPressed: _save,
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    if (categoryId == null) {
      category = FinanceTransactionCategory(Uuid().v4());
      category.disabled = false;
      category.negative = false;

      loaded = true;
    } else {
      _loadCategory(categoryId);
    }
  }

  Future<Null> _save() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      if (categoryId == null) {
        await categoryRepository.create(category);
      } else {
        await categoryRepository.update(category);
      }

      Navigator.pop(context, category.id);
      FlushbarService().show(FlushType.success, 'Category saved.', context);
    } else {
      FlushbarService()
          .show(FlushType.error, 'The form contains errors.', context);
    }
  }

  Future<Null> _loadCategory(String id) async {
    category = await categoryRepository.findById(this.categoryId);

    setState(() {
      loaded = true;
    });
  }

  Widget _buildBody(BuildContext context) {
    if (!loaded) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            TextFormField(
              initialValue: category.name?.toString(),
              decoration: InputDecoration(
                labelText: 'Name',
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Name cannot be empty';
                }
              },
              onSaved: (value) {
                category.name = value;
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.all(0),
              title: const Text('Určené pre výdavky'),
              trailing: Switch(
                onChanged: (bool value) {
                  setState(() {
                    category.negative = value;
                  });
                },
                value: category.negative,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
