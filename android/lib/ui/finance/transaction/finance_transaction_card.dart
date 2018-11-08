import 'package:android/config/config.dart';
import 'package:android/lucy_container.dart';
import 'package:android/model/finance_deposit.dart';
import 'package:android/model/finance_transaction.dart';
import 'package:android/model/finance_transaction_category.dart';
import 'package:android/repository/finance_deposit_repository.dart';
import 'package:android/repository/finance_transaction_category_repository.dart';
import 'package:android/ui/finance/finance_transaction_state_view.dart';
import 'package:android/ui/finance/finance_ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FinanceTransactionCard extends StatefulWidget {
  final FinanceTransaction transaction;

  FinanceTransactionCard(this.transaction);

  @override
  _FinanceTransactionCardState createState() {
    return _FinanceTransactionCardState();
  }
}

class _FinanceTransactionCardState extends State<FinanceTransactionCard> {
  FinanceDeposit sourceDeposit;
  FinanceDeposit targetDeposit;
  Set<FinanceTransactionCategory> categories;
  bool loaded = false;

  FinanceTransaction get transaction => widget.transaction;

  @override
  void initState() {
    super.initState();
    _initState();
  }

  Future<Null> _initState() async {
    var container = LucyContainer();
    var depositRepository = container.getRepository<FinanceDepositRepository>();
    var categoryRepository =
        container.getRepository<FinanceTransactionCategoryRepository>();

    if (transaction.sourceDepositId != null) {
      sourceDeposit =
          await depositRepository.findById(transaction.sourceDepositId);
    }

    if (transaction.targetDepositId != null) {
      targetDeposit =
          await depositRepository.findById(transaction.targetDepositId);
    }

    categories = (await Future.wait(transaction.categoriesIds
            .map((id) => categoryRepository.findById(id))))
        .toSet();

    setState(() {
      loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    var title = transaction.name;
    var titleSmall = categories.map((cat) => cat.name).join(", ");

    if (title == null && categories.length > 0) {
      title = titleSmall;
      titleSmall = '';
    }

    if (title == null) {
      title = 'Transaction';
    }

    var subtitle = '';

    if (sourceDeposit != null) {
      subtitle += '${sourceDeposit.name} ';
    }

    if (targetDeposit != null) {
      subtitle += '--> ${targetDeposit.name}';
    }

    var statusView = FinanceTransactionStateView.getMap()[transaction.state];

    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 14.0),
          child: Icon(
            statusView.icon,
            color: statusView.color,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Flexible(
                      flex: 3,
                      child: Text(
                        title,
                        style:
                            TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          '$titleSmall',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                subtitle,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white70),
              )
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(
              formatTransactionValue(transaction),
              style: TextStyle(
                  color: getColorForTransaction(transaction),
                  fontSize: 20),
            ),
            Divider(
              height: 2,
            ),
            Text(Config.dateFormat.format(transaction.executionDatetime))
          ],
        )
      ],
    );
  }
}
