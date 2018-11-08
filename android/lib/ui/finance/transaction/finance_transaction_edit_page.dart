import 'package:android/config/config.dart';
import 'package:android/lucy_container.dart';
import 'package:android/model/finance_deposit.dart';
import 'package:android/model/finance_transaction.dart';
import 'package:android/model/finance_transaction_category.dart';
import 'package:android/repository/finance_deposit_repository.dart';
import 'package:android/repository/finance_transaction_category_repository.dart';
import 'package:android/repository/finance_transaction_repository.dart';
import 'package:android/ui/finance/category/finance_transaction_categories_pick_page.dart';
import 'package:android/ui/finance/deposit/finance_deposit_list_page.dart';
import 'package:android/ui/finance/transaction/finance_transaction_state_list_page.dart';
import 'package:android/ui/flushbar_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_object_form_field/flutter_object_form_field.dart';
import 'package:uuid/uuid.dart';

class FinanceTransactionEditPage extends StatefulWidget {
  final String transactionId;

  FinanceTransactionEditPage({this.transactionId});

  @override
  _FinanceTransactionEditPageState createState() {
    return _FinanceTransactionEditPageState(transactionId);
  }
}

enum _Type { income, expense, transfer }

class _FinanceTransactionEditPageState
    extends State<FinanceTransactionEditPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final String transactionId;

  FinanceDepositRepository depositRepository;
  FinanceTransactionRepository transactionRepository;
  FinanceTransactionCategoryRepository categoryRepository;

  FinanceTransaction transaction;

  ValueNotifier<DateTime> executionDatetimeController;
  ValueNotifier<FinanceDeposit> sourceDepositController;
  ValueNotifier<FinanceDeposit> targetDepositController;
  ValueNotifier<Set<FinanceTransactionCategory>> categoriesController;
  TextEditingController valueController;
  TextEditingController nameController;
  TextEditingController noteController;
  ValueNotifier<FinanceTransactionState> stateController;


  bool loaded = false;
  _Type type = _Type.income;

  _FinanceTransactionEditPageState(this.transactionId) {
    depositRepository =
        LucyContainer().getRepository<FinanceDepositRepository>();
    transactionRepository =
        LucyContainer().getRepository<FinanceTransactionRepository>();
    categoryRepository =
        LucyContainer().getRepository<FinanceTransactionCategoryRepository>();
  }

  void _setType(_Type newType) {
    if (type == newType) {
      return;
    }

    if (newType == _Type.expense) {
      transaction.targetDepositId = null;
    } else if (newType == _Type.income) {
      transaction.sourceDepositId = null;
    }

    transaction.categoriesIds = Set();
    categoriesController.value = Set();

    setState(() {
      type = newType;
    });
  }

  _Type _detectType(FinanceTransaction transaction) {
    if (transaction.sourceDepositId == null) {
      return _Type.income;
    } else if (transaction.targetDepositId == null) {
      return _Type.expense;
    } else {
      return _Type.transfer;
    }
  }

  @override
  Widget build(BuildContext context) {
    var actions = <Widget>[];

    if (transactionId != null && loaded) {
      actions.add(IconButton(
        icon: Icon(Icons.delete),
        onPressed: () async {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Delete'),
                  content:
                      Text('Do you really wish to delete the transaction?'),
                  actions: <Widget>[
                    new FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('No'),
                    ),
                    new FlatButton(
                      onPressed: () async {
                        await transactionRepository.delete(transaction);
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

    var types = {
      'Expense': _Type.expense,
      'Income': _Type.income,
      'Transfer': _Type.transfer,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(this.transactionId == null
            ? 'Create transaction'
            : 'Edit transaction'),
        actions: actions,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Row(
              children: types.entries.map((item) {
                return Expanded(
                  child: Container(
                    decoration: type == item.value
                        ? BoxDecoration(
                            border:
                                Border(bottom: BorderSide(color: Colors.white)))
                        : null,
                    child: InkWell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          item.key,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      onTap: () {
                        _setType(item.value);
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      body: _buildBody(context),
      floatingActionButton: FloatingActionButton(
        child: Icon(transactionId == null ? Icons.done : Icons.save),
        onPressed: _save,
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _load();
  }

  Future<Null> _save() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      if (transactionId == null) {
        await transactionRepository.create(transaction);
      } else {
        await transactionRepository.update(transaction);
      }

      Navigator.pop(context, transaction.id);
      FlushbarService().show(FlushType.success, 'Transaction saved.', context);
    } else {
      FlushbarService().show(
          FlushType.error,
          'The form contains errors'
          '.',
          context);
    }
  }

  Future<Null> _load() async {
    if (transactionId == null) {
      transaction = FinanceTransaction(Uuid().v4());
      transaction.executionDatetime = DateTime.now();
      transaction.state = FinanceTransactionState.executed;
      transaction.creatorId = '58080d96-bd71-472c-805e-e1e0eea852ee';
      type = _Type.expense;
      transaction.categoriesIds = Set();
    } else {
      transaction = await transactionRepository.findById(this.transactionId);
      type = _detectType(transaction);
    }
    executionDatetimeController = ValueNotifier(transaction.executionDatetime);
    sourceDepositController = ValueNotifier<FinanceDeposit>(null);
    targetDepositController = ValueNotifier<FinanceDeposit>(null);
    nameController = TextEditingController(text: transaction.name);
    noteController = TextEditingController(text : transaction.note);
    valueController = TextEditingController(text: transaction.value?.toString
      ());
    stateController = ValueNotifier(transaction.state);
    categoriesController = ValueNotifier<Set<FinanceTransactionCategory>>(
        (await Future.wait(transaction.categoriesIds
                .map((categoryId) => categoryRepository.findById(categoryId))))
            .toSet());

    if (transaction.sourceDepositId != null) {
      sourceDepositController.value =
          await depositRepository.findById(transaction.sourceDepositId);
    }

    if (transaction.targetDepositId != null) {
      targetDepositController.value =
          await depositRepository.findById(transaction.targetDepositId);
    }

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

    var items = <Widget>[];

    if (type != _Type.income) {
      items.add(ObjectFormField<FinanceDeposit>(
        key: ValueKey('source'),
        decoration: InputDecoration(labelText: 'Source deposit'),
        objectToString: _depositToString,
        pickValue: _pickDeposit,
        controller: sourceDepositController,
        validator: (val) {
          if (val == null) {
            return 'Source deposit is required.';
          }
        },
        onSaved: (deposit) {
          transaction.sourceDepositId = deposit?.id;
        },
      ));
    }
    if (type != _Type.expense) {
      items.add(ObjectFormField<FinanceDeposit>(
        key: ValueKey('target'),
        decoration: InputDecoration(labelText: 'Target deposit'),
        objectToString: _depositToString,
        pickValue: _pickDeposit,
        validator: (val) {
          if (val == null) {
            return 'Target deposit is required.';
          }
        },
        controller: targetDepositController,
        onSaved: (deposit) {
          transaction.targetDepositId = deposit?.id;
        },
      ));
    }
    items.add(TextFormField(
      key: ValueKey('value'),
      controller: valueController,
      decoration: InputDecoration(
        labelText: 'Value',
      ),
      validator: (value) {
        if (value.isEmpty) {
          return 'Value cannot be empty';
        }
        if (double.parse(value) <= 0){
          return 'Must be greater than 0.';
        }
      },
      keyboardType:
          TextInputType.numberWithOptions(signed: true, decimal: true),
      onSaved: (value) {
        transaction.value = double.parse(value);
      },
    ));
    items.add(ObjectFormField<FinanceTransactionState>(
      key: ValueKey('state'),
      controller: stateController,
      showResetButton: false,
      objectToString: (value) {
        if (value == null) {
          return null;
        }

        switch (value) {
          case FinanceTransactionState.executed:
            return 'Executed';
          case FinanceTransactionState.blocked:
            return 'Blocked';
          case FinanceTransactionState.cancelled:
            return 'Cancelled';
          case FinanceTransactionState.planned:
            return 'Planned';
        }
      },
      pickValue: (oldValue) async {
        var state = await Navigator.push<FinanceTransactionState>(
          context,
          MaterialPageRoute(
            builder: (context) => FinanceTransactionStateListPage(),
          ),
        );

        if (state == FinanceTransactionState.executed &&
            oldValue != FinanceTransactionState.executed) {
          executionDatetimeController.value = DateTime.now();
          FlushbarService()
              .show(FlushType.success, 'Execution date set to now.', context);
        }

        return state ?? oldValue;
      },
      validator: (val) {
        if (val == null) {
          return 'State must be set.';
        }
      },
      onSaved: (val) {
        transaction.state = val;
      },
      decoration: InputDecoration(labelText: 'State'),
    ));
    items.add(ObjectFormField<DateTime>(
      key: ValueKey('executionDatetime'),
      controller: executionDatetimeController,
      showResetButton: false,
      validator: (val) {
        if (val == null) {
          return 'Execution date must be set.';
        }
      },
      decoration: InputDecoration(labelText: 'Execution date'),
      objectToString: (dateTime) =>
          dateTime != null ? Config.dateTimeFormat.format(dateTime) : null,
      pickValue: (currVal) async {
        var date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2018),
          lastDate: DateTime(2100),
        );

        if (date == null) {
          return currVal;
        }

        var time = await showTimePicker(
            context: context, initialTime: TimeOfDay.now());

        if (time == null) {
          return currVal;
        }

        return DateTime(
            date.year, date.month, date.day, time.hour, time.minute);
      },
      onSaved: (dateTime) {
        transaction.executionDatetime = dateTime;
      },
    ));
    items.add(TextFormField(
      key: ValueKey('name'),
      controller: nameController,
      decoration: InputDecoration(labelText: 'Name'),
      onSaved: (name) {
        transaction.name = name.isEmpty ? null : name;
      },
    ));
    items.add(TextFormField(
      key: ValueKey('note'),
      controller: noteController,
      decoration: InputDecoration(labelText: 'Note'),
      keyboardType: TextInputType.multiline,
      maxLines: null,
      onSaved: (note) {
        transaction.note = note;
      },
    ));
    if (type != _Type.transfer) {
      items.add(ObjectFormField<Set<FinanceTransactionCategory>>(
        key: ValueKey('categories'),
        controller: categoriesController,
        showResetButton: false,
        onSaved: (categories) {
          transaction.categoriesIds = categories.map((ca) => ca.id).toSet();
        },
        objectToString: (categories) {
          if (categories.length == 0) {
            return null;
          }

          return categories.map((cat) => cat.name).join(", ");
        },
        pickValue: (oldValue) async {
          var categories = await Navigator.push<Set<String>>(
            context,
            MaterialPageRoute(
              builder: (context) {
                return FinanceTransactionCategoriesPickPage(
                    oldValue.map((item) => item.id).toSet());
              },
            ),
          );

          if (categories == null) {
            return oldValue;
          }

          var res = (await Future.wait(
                  categories.map((id) => categoryRepository.findById(id))))
              .toSet();

          return res;
        },
        decoration: InputDecoration(labelText: 'Categories'),
      ));
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Form(
        key: _formKey,
        child: ListView(
          children: items,
        ),
      ),
    );
  }

  String _depositToString(deposit) {
    if (deposit == null) {
      return null;
    }

    return '${deposit.name} '
        '(${Config.currencyDetailedFormat.format(deposit.balance)})';
  }

  Future<FinanceDeposit> _pickDeposit(FinanceDeposit oldValue) async {
    var id = await Navigator.push<String>(context,
        MaterialPageRoute(builder: (context) => FinanceDepositListPage(true)));

    if (id == null) {
      return oldValue;
    }

    return await depositRepository.findById(id);
  }
}
