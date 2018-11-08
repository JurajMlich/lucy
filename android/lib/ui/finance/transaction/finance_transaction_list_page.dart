import 'package:android/lucy_container.dart';
import 'package:android/model/finance_transaction.dart';
import 'package:android/repository/finance_transaction_repository.dart';
import 'package:android/ui/finance/transaction/finance_transaction_card.dart';
import 'package:android/ui/finance/transaction/finance_transaction_edit_page.dart';
import 'package:flutter/material.dart';

enum FinanceTransactionListPageTab { executed, pending, all }

class FinanceTransactionListPage extends StatelessWidget {
  final FinanceTransactionListPageTab defaultTab;

  FinanceTransactionListPage({
    this.defaultTab = FinanceTransactionListPageTab.executed,
  });

  @override
  Widget build(BuildContext context) {
    var initialTab = 0;

    if(defaultTab == FinanceTransactionListPageTab.pending) {
      initialTab = 1;
    } else if (defaultTab == FinanceTransactionListPageTab.all) {
      initialTab = 2;
    }

    return DefaultTabController(
      initialIndex: initialTab,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Transactions'),
          actions: <Widget>[],
          bottom: TabBar(tabs: [
            Tab(
              text: 'Executed',
            ),
            Tab(
              text: 'Pending',
            ),
            Tab(
              text: 'All',
            )
          ]),
        ),
        body: TabBarView(children: [
          _FinanceTransactionList(
            onlyState: [FinanceTransactionState.executed],
          ),
          _FinanceTransactionList(
            onlyState: [
              FinanceTransactionState.planned,
              FinanceTransactionState.blocked,
            ],
            sort: FinanceTransactionQuerySort.oldestToNewest,
          ),
          _FinanceTransactionList(),
        ]),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () async {
            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => FinanceTransactionEditPage()));
          },
        ),
      ),
    );
  }
}

class _FinanceTransactionList extends StatefulWidget {
  final List<FinanceTransactionState> onlyState;
  final FinanceTransactionQueryExecutionDate futureType;
  final FinanceTransactionQuerySort sort;

  @override
  _FinanceTransactionListState createState() {
    return _FinanceTransactionListState();
  }

  _FinanceTransactionList({
    this.onlyState,
    this.futureType = FinanceTransactionQueryExecutionDate.all,
    this.sort = FinanceTransactionQuerySort.newestToOldest,
  });
}

class _FinanceTransactionListState extends State<_FinanceTransactionList>
    with AutomaticKeepAliveClientMixin<_FinanceTransactionList> {
  List<FinanceTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (transactions == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await LucyContainer().syncManager.synchronize();
        await _load();
      },
      child: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          return InkWell(
              child: Container(
                decoration: BoxDecoration(
                    border: Border(
                        bottom:
                            BorderSide(color: Theme.of(context).dividerColor))),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
    var transactions = await transactionRepository.findBy(
      onlyStates: widget.onlyState,
      futureType: widget.futureType,
      sort: widget.sort,
    );
    setState(() {
      this.transactions = transactions;
    });
  }

  @override
  bool get wantKeepAlive => true;
}
