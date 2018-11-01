import 'package:android/lucy_container.dart';
import 'package:android/model/finance_transaction.dart';
import 'package:android/repository/finance_transaction_repository.dart';
import 'package:android/ui/finance/transaction/finance_transaction_edit_page.dart';
import 'package:flutter/material.dart';

class FinanceTransactionListPage extends StatefulWidget {
  @override
  _FinanceTransactionListPageState createState() {
    return _FinanceTransactionListPageState();
  }
}

class _FinanceTransactionListPageState extends State<FinanceTransactionListPage> {
  List<FinanceTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions'),
        actions: <Widget>[],
      ),
      body: _buildBody(context),
    );
  }

  @override
  void initState() {
    super.initState();

    var transactionRepository =
        LucyContainer().getRepository<FinanceTransactionRepository>();
    transactionRepository.findAll().then((transaction) {
      setState(() {
        this.transactions = transaction;
      });
    });
  }

  Widget _buildBody(BuildContext context) {
    if (transactions == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        return InkWell(
            child: Text(transactions[index].name),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FinanceTransactionEditPage(
                        transactionId: transactions[index].id,
                      ),
                ),
              );
            });
      },
    );
  }
}
