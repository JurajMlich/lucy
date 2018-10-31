import 'package:android/lucy_container.dart';
import 'package:android/model/deposit.dart';
import 'package:android/repository/deposit_repository.dart';
import 'package:android/ui/finance/transaction/transaction_edit_page.dart';
import 'package:flutter/material.dart';

class FinancePage extends StatefulWidget {
  @override
  _FinancePageState createState() {
    return _FinancePageState();
  }
}

class _FinancePageState extends State<FinancePage> {
  List<Deposit> _deposits;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Finance overview'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TransactionEditPage()),
              );
            },
          )
        ],
      ),
      body: _buildBody(context),
    );
  }

  @override
  void initState() {
    super.initState();

    var depositRepository = LucyContainer().getRepository<DepositRepository>();
//    var transactionCategoryRepository = LucyContainer()
//        .getRepository<TransactionCategoryRepository>();
//    var moneyTransactionRepository = LucyContainer()
//        .getRepository<MoneyTransactionRepository>();
    depositRepository.findAll().then((deposits) {
      setState(() {
        _deposits = deposits;
      });
    });
//    moneyTransactionRepository.findAll().then((transactions) {
//      transactions.toString();
//    });
//
//    transactionCategoryRepository.findAll().then((categories) {
//      categories.toString();
//    });
  }

  Widget _buildBody(BuildContext context) {
    if (_deposits == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListView.builder(
      itemCount: _deposits.length,
      itemBuilder: (context, index) {
        return InkWell(
            child: Text(_deposits[index].name +
                ' ' +
                _deposits[index].balance.toString()),
            onTap: () {
              Navigator.pushNamed(context, '/deposits');
            });
      },
    );
  }
}
