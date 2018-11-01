import 'package:android/lucy_container.dart';
import 'package:android/model/finance_transaction.dart';
import 'package:android/repository/finance_transaction_repository.dart';
import 'package:android/ui/finance/transaction/finance_transaction_card.dart';
import 'package:android/ui/finance/transaction/finance_transaction_edit_page.dart';
import 'package:flutter/material.dart';

class FinanceTransactionListPage extends StatefulWidget {
  @override
  _FinanceTransactionListPageState createState() {
    return _FinanceTransactionListPageState();
  }
}

class _FinanceTransactionListPageState
    extends State<FinanceTransactionListPage> {
  List<FinanceTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions'),
        actions: <Widget>[],
      ),
      body: _buildBody(context),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(
            builder: (context) => FinanceTransactionEditPage()
          ));

          _load();
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<Null> _load() async {
    this.transactions = null;
    var transactionRepository =
        LucyContainer().getRepository<FinanceTransactionRepository>();
    var transactions = await transactionRepository.findBy();
    setState(() {
      this.transactions = transactions;
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
            child: Container(
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: Theme.of(context).dividerColor))),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical:
                14),
                child: FinanceTransactionCard(transactions[index]),
              ),
            ),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FinanceTransactionEditPage(
                        transactionId: transactions[index].id,
                      ),
                ),
              );

              await _load();
            });
      },
    );
  }
}
