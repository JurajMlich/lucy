import 'package:android/config/config.dart';
import 'package:android/lucy_container.dart';
import 'package:android/model/deposit.dart';
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

class _FinanceTransactionEditPageState
    extends State<FinanceTransactionEditPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final String transactionId;

  FinanceDepositRepository depositRepository;
  FinanceTransactionRepository moneyTransactionRepository;
  FinanceTransactionCategoryRepository transactionCategoryRepository;

  FinanceTransaction transaction;
  FinanceDeposit initialSourceDeposit;
  FinanceDeposit initialTargetDeposit;
  Set<FinanceTransactionCategory> initialCategories;

  ValueNotifier<DateTime> executionDatetimeController;

  _FinanceTransactionEditPageState(this.transactionId) {
    depositRepository =
        LucyContainer().getRepository<FinanceDepositRepository>();
    moneyTransactionRepository =
        LucyContainer().getRepository<FinanceTransactionRepository>();
    transactionCategoryRepository =
        LucyContainer().getRepository<FinanceTransactionCategoryRepository>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.transactionId == null
            ? 'Create transaction'
            : 'Edit transaction'),
        actions: <Widget>[],
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

    if (transactionId == null) {
      transaction = FinanceTransaction(Uuid().v4());
      transaction.executionDatetime = DateTime.now();
      transaction.state = FinanceTransactionState.executed;
      transaction.creatorId = '58080d96-bd71-472c-805e-e1e0eea852ee';
      transaction.categoriesIds = Set();

      initialCategories = Set();
      executionDatetimeController =
          ValueNotifier(transaction.executionDatetime);
    } else {
      _loadTransaction(transactionId);
    }
  }

  Future<Null> _save() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      var errorMessage = _validate();

      if (errorMessage != null) {
        FlushbarService().show(FlushType.ERROR, errorMessage, context);
        return;
      }

      if (transactionId == null) {
        await moneyTransactionRepository.create(transaction);
      } else {
        await moneyTransactionRepository.update(transaction);
      }

      Navigator.pop(context, transaction.id);
    } else {
      FlushbarService().show(
          FlushType.ERROR,
          'The form contains errors'
          '.',
          context);
    }
  }

  String _validate() {
    if (transaction.sourceDepositId == null &&
        transaction.targetDepositId == null) {
      return 'You must set either source deposit or target deposit';
    }

    return null;
  }

  Future<Null> _loadTransaction(String id) async {
    transaction = await moneyTransactionRepository.findById(this.transactionId);

    if (transaction.sourceDepositId != null) {
      initialSourceDeposit =
          await depositRepository.findById(transaction.sourceDepositId);
    }
    if (transaction.targetDepositId != null) {
      initialTargetDeposit =
          await depositRepository.findById(transaction.targetDepositId);
    }

    initialCategories = (await Future.wait(transaction.categoriesIds.map(
            (categoryId) =>
                transactionCategoryRepository.findById(categoryId))))
        .toSet();

    executionDatetimeController = ValueNotifier(transaction.executionDatetime);

    setState(() {});
  }

  Widget _buildBody(BuildContext context) {
    if (transaction == null) {
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
            ObjectFormField<FinanceDeposit>(
              decoration: InputDecoration(labelText: 'Source deposit'),
              objectToString: _depositToString,
              pickValue: _pickDeposit,
              initialValue: initialSourceDeposit,
              onSaved: (deposit) {
                transaction.sourceDepositId = deposit?.id;
              },
            ),
            ObjectFormField<FinanceDeposit>(
              decoration: InputDecoration(labelText: 'Target deposit'),
              objectToString: _depositToString,
              pickValue: _pickDeposit,
              initialValue: initialTargetDeposit,
              onSaved: (deposit) {
                transaction.targetDepositId = deposit?.id;
              },
            ),
            TextFormField(
              initialValue: transaction.value?.toString(),
              decoration: InputDecoration(
                labelText: 'Value',
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Value cannot be empty';
                }
                if (double.parse(value) == 0) {
                  return 'Cannot be 0';
                }
              },
              keyboardType:
                  TextInputType.numberWithOptions(signed: true, decimal: true),
              onSaved: (value) {
                transaction.value = double.parse(value);
              },
            ),
            ObjectFormField<FinanceTransactionState>(
              initialValue: transaction.state,
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
                  FlushbarService().show(
                      FlushType.SUCCESS, 'Execution date set to now.', context);
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
            ),
            ObjectFormField<DateTime>(
              controller: executionDatetimeController,
              showResetButton: false,
              validator: (val) {
                if(val == null) {
                  return 'Execution date must be set.';
                }
              },
              decoration: InputDecoration(labelText: 'Execution date'),
              objectToString: (dateTime) => dateTime != null
                  ? Config.dateTimeFormat.format(dateTime)
                  : null,
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
            ),
            TextFormField(
              initialValue: transaction.name,
              decoration: InputDecoration(labelText: 'Name'),
              onSaved: (name) {
                transaction.name = name.isEmpty ? null : name;
              },
            ),
            TextFormField(
              initialValue: transaction.note,
              decoration: InputDecoration(labelText: 'Note'),
              keyboardType: TextInputType.multiline,
              maxLines: null,
              onSaved: (note) {
                transaction.note = note;
              },
            ),
            ObjectFormField<Set<FinanceTransactionCategory>>(
              initialValue: initialCategories,
              showResetButton: false,
              onSaved: (categories) {
                transaction.categoriesIds =
                    categories.map((ca) => ca.id).toSet();
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

                var res = (await Future.wait(categories.map(
                        (id) => transactionCategoryRepository.findById(id))))
                    .toSet();

                return res;
              },
              decoration: InputDecoration(labelText: 'Categories'),
            ),
          ],
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
