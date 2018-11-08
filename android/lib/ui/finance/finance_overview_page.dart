import 'package:android/config/config.dart';
import 'package:android/lucy_container.dart';
import 'package:android/model/finance_deposit.dart';
import 'package:android/model/finance_transaction.dart';
import 'package:android/repository/finance_deposit_repository.dart';
import 'package:android/repository/finance_transaction_repository.dart';
import 'package:android/ui/finance/category/finance_transaction_category_list_page.dart';
import 'package:android/ui/finance/finance_ui_utils.dart';
import 'package:android/ui/finance/transaction/finance_transaction_card.dart';
import 'package:android/ui/finance/transaction/finance_transaction_edit_page.dart';
import 'package:android/ui/finance/transaction/finance_transaction_list_page.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class FinanceOverviewPage extends StatefulWidget {
  @override
  _FinanceOverviewPageState createState() {
    return _FinanceOverviewPageState();
  }
}

class _FinanceOverviewPageState extends State<FinanceOverviewPage> {
  List<FinanceDeposit> _deposits;
  List<FinanceTransaction> _pendingTransactions;
  List<FinanceTransaction> _lastTransactions;
  bool _loaded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Finance overview'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => FinanceTransactionListPage()),
              );
              _load();
            },
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              var id = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => FinanceTransactionEditPage()),
              );

              if (id != null) {
                _load();
              }
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'Categories':
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            FinanceTransactionCategoryListPage()),
                  );
                  _load();
                  break;
              }
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem<String>(
                  value: 'Categories',
                  child: Text('Categories'),
                )
              ];
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

    _load();
  }

  Future<Null> _load() async {
    var depositRepository =
        LucyContainer().getRepository<FinanceDepositRepository>();

    var transactionsRepository =
        LucyContainer().getRepository<FinanceTransactionRepository>();

    var deposits = await depositRepository.findAll();
    var pendingTransactions = await transactionsRepository.findBy(
        onlyStates: [
          FinanceTransactionState.planned,
          FinanceTransactionState.blocked,
        ],
        futureType: FinanceTransactionQueryExecutionDate.maxCloseFuture,
        sort: FinanceTransactionQuerySort.oldestToNewest);
    var lastTransactions = await transactionsRepository.findBy(
        limit: 5,
        futureType: FinanceTransactionQueryExecutionDate.onlyPast,
        onlyStates: [FinanceTransactionState.executed]);

    setState(() {
      _loaded = true;
      _deposits = deposits;
      _pendingTransactions = pendingTransactions;
      _lastTransactions = lastTransactions;
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
    if (!_loaded) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    var children = <Widget>[];
    _buildMyDeposits(children);
    if (_pendingTransactions.length > 0) {
      _buildTransactions(
        children: children,
        transactions: _pendingTransactions,
        title: 'Pending transactions',
        moreText: 'all pending transactions...',
        onMore: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FinanceTransactionListPage(
                      defaultTab: FinanceTransactionListPageTab.pending,
                    )),
          );

          _load();
        },
      );
    }
    _buildSpendings(children);
    _buildTransactions(
      children: children,
      transactions: _lastTransactions,
      title: 'Last transactions',
      moreText: 'more transactions...',
      onMore: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FinanceTransactionListPage()),
        );

        _load();
      },
    );

    return RefreshIndicator(
      onRefresh: () async {
        await LucyContainer().syncManager.synchronize();
        await _load();
      },
      child: ListView(
        padding: EdgeInsets.only(bottom: 20),
        children: children,
      ),
    );
  }

  void _buildTransactions(
      {@required List<Widget> children,
      @required List<FinanceTransaction> transactions,
      @required String title,
      @required String moreText,
      @required VoidCallback onMore}) {
    children.add(Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8),
      child: Text(
        title,
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      ),
    ));
    children.add(Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Divider(),
    ));
    children.addAll(transactions.map((item) {
      return InkWell(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 14),
            child: FinanceTransactionCard(item),
          ),
        ),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FinanceTransactionEditPage(
                    transactionId: item.id,
                  ),
            ),
          );

          _load();
        },
      );
    }));
    children.add(
      Align(
        alignment: Alignment(1, 1),
        child: FlatButton(onPressed: onMore, child: Text(moreText)),
      ),
    );
  }

  void _buildSpendings(List<Widget> children) {
    children.add(Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8),
      child: Text(
        'Spendings',
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      ),
    ));
    children.add(Container(
      padding: EdgeInsets.all(10),
      height: 200,
      child: _buildDummyChart(),
    ));
    children.add(
      Align(
        alignment: Alignment(1, 1),
        child: FlatButton(onPressed: () {}, child: Text('more stats...')),
      ),
    );
  }

  void _buildMyDeposits(List<Widget> children) {
    children.add(Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8, top: 15),
      child: Text(
        'My deposits',
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      ),
    ));
    children.add(Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Divider(),
    ));
    children.addAll(_deposits.map((item) {
      return Container(
        height: 80,
        child: _buildDepositCard(item),
      );
    }).toList());
    children.add(
      Align(
        alignment: Alignment(1, 1),
        child: FlatButton(onPressed: () {}, child: Text('more deposits...')),
      ),
    );
  }

  charts.TimeSeriesChart _buildDummyChart() {
    return new charts.TimeSeriesChart(
      [
        new charts.Series<DaySpending, DateTime>(
          id: 'Sales',
          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          domainFn: (DaySpending sales, _) => sales.dateTime,
          measureFn: (DaySpending sales, _) => sales.spent,
          data: [
            new DaySpending(new DateTime(2017, 9, 11), 5),
            new DaySpending(new DateTime(2017, 9, 12), 25),
            new DaySpending(new DateTime(2017, 9, 13), 100),
            new DaySpending(new DateTime(2017, 9, 14), 75),
            new DaySpending(new DateTime(2017, 9, 15), 5),
            new DaySpending(new DateTime(2017, 9, 16), 25),
            new DaySpending(new DateTime(2017, 9, 17), 100),
            new DaySpending(new DateTime(2017, 9, 18), 75),
            new DaySpending(new DateTime(2017, 9, 19), 5),
            new DaySpending(new DateTime(2017, 9, 20), 25),
            new DaySpending(new DateTime(2017, 9, 21), 100),
            new DaySpending(new DateTime(2017, 9, 22), 75),
          ],
        )
      ],
      animate: true,
      primaryMeasureAxis: charts.NumericAxisSpec(
          renderSpec: charts.GridlineRendererSpec(
        labelStyle:
            charts.TextStyleSpec(fontSize: 10, color: charts.Color.white),
      )),
      domainAxis: charts.DateTimeAxisSpec(
          renderSpec: charts.GridlineRendererSpec(
            labelStyle:
                charts.TextStyleSpec(fontSize: 10, color: charts.Color.white),
          ),
          tickFormatterSpec: charts.AutoDateTimeTickFormatterSpec(
              day: charts.TimeFormatterSpec(
            format: 'dd',
            transitionFormat: 'dd',
          ))),
      // Optionally pass in a [DateTimeFactory] used by the chart. The factory
      // should create the same type of [DateTime] as the data provided. If none
      // specified, the default creates local date time.
      dateTimeFactory: const charts.LocalDateTimeFactory(),
    );
  }

  Widget _buildDepositCard(FinanceDeposit deposit) {
    return Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.grey, width: 0.3),
                  ),
                ),
                child: Center(
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(
                          deposit.type == FinanceDepositType.cash
                              ? Icons.account_balance_wallet
                              : Icons.account_balance,
                          size: 20,
                          color: deposit.type == FinanceDepositType.cash
                              ? Color.fromARGB(255, 222, 173, 1)
                              : Colors.grey,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          deposit.name,
                          style: TextStyle(fontSize: 15),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.grey, width: 0.3),
                  ),
                ),
                child: Center(
                  child: Text(
                    Config.currencyFormat.format(deposit.balance),
                    style: TextStyle(
                      color: getColorForDeposit(deposit),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3.0),
                        child: Text(
                          'Today',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text('15 used'),
                      Text('15 free'),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3.0),
                        child: Text(
                          'Month',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text('15 used'),
                      Text('15 free'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DaySpending {
  final DateTime dateTime;
  final double spent;

  DaySpending(this.dateTime, this.spent);
}
