import 'package:android/config/config.dart';
import 'package:android/lucy_container.dart';
import 'package:android/model/deposit.dart';
import 'package:android/repository/finance_deposit_repository.dart';
import 'package:android/ui/finance/finance_deposit_view.dart';
import 'package:flutter/material.dart';

class FinanceDepositListPage extends StatefulWidget {
  final bool selectMode;

  FinanceDepositListPage(this.selectMode);

  @override
  _FinanceDepositListPageState createState() {
    return _FinanceDepositListPageState();
  }
}

class _FinanceDepositListPageState extends State<FinanceDepositListPage> {
  List<FinanceDeposit> deposits;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectMode ? 'Select deposit' : 'Deposits'),
        actions: <Widget>[],
      ),
      body: _buildBody(context),
    );
  }

  @override
  void initState() {
    super.initState();

    var depositRepository =
        LucyContainer().getRepository<FinanceDepositRepository>();
    depositRepository.findAll().then((deposits) {
      setState(() {
        this.deposits = deposits;
      });
    });
  }

  Widget _buildBody(BuildContext context) {
    if (deposits == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    Widget child = ListView.builder(
      itemCount: deposits.length,
      itemBuilder: (context, index) {
        var deposit = deposits[index];

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
                  Icon(
                    deposit.type == FinanceDepositType.cash
                        ? Icons.account_balance_wallet
                        : Icons.account_balance,
                    size: 20,
                    color: deposit.type == FinanceDepositType.cash
                        ? Color.fromARGB(255, 222, 173, 1)
                        : Colors.grey,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        deposit.name,
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
                  ),
                  Text(
                    Config.currencyDetailedFormat.format(deposit.balance),
                    style: TextStyle(
                      color: getColorForDeposit(deposit),
                    ),
                  ),
                ],
              ),
            ),
          ),
          onTap: () {
            if (widget.selectMode) {
              Navigator.pop(context, deposit.id);
            }
          },
        );
      },
    );

    return child;
  }
}
