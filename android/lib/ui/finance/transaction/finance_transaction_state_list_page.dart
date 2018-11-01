import 'package:android/ui/finance/finance_transaction_state_view.dart';
import 'package:flutter/material.dart';

class FinanceTransactionStateListPage extends StatefulWidget {
  @override
  _FinanceTransactionStateListPageState createState() {
    return _FinanceTransactionStateListPageState();
  }
}

class _FinanceTransactionStateListPageState
    extends State<FinanceTransactionStateListPage> {
  List<FinanceTransactionStateView> items =
      FinanceTransactionStateView.getMap().values.toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('States'),
        actions: <Widget>[],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        var item = items[index];

        return InkWell(
            child: Container(
              decoration: BoxDecoration(
                  border: Border(
                      bottom:
                          BorderSide(color: Theme.of(context).dividerColor))),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(item.label),
                    Icon(item.icon, color: item.color,),
                  ],
                ),
              ),
            ),
            onTap: () async {
              Navigator.pop(context, item.state);
            });
      },
    );
  }
}
