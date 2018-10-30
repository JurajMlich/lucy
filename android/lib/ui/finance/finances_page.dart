import 'package:android/lucy_container.dart';
import 'package:android/model/deposit.dart';
import 'package:android/repository/deposit_repository.dart';
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
        title: Text('Deposits'),
        actions: <Widget>[],
      ),
      body: _buildBody(context),
    );
  }

  @override
  void initState() {
    super.initState();

    var depositRepository = LucyContainer().getRepository<DepositRepository>();
    depositRepository.findAll().then((deposits) {
      setState((){
        _deposits = deposits;
      });
    });
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
            child: Text(_deposits[index].name),
            onTap: () {
              Navigator.pushNamed(context, '/deposits');
            });
      },
    );
  }
}
