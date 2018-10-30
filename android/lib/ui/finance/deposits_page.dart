import 'package:android/lucy_container.dart';
import 'package:android/model/deposit.dart';
import 'package:android/repository/deposit_repository.dart';
import 'package:flutter/material.dart';

class DepositsPage extends StatefulWidget {
  @override
  _DepositsPageState createState() {
    return _DepositsPageState();
  }
}

class _DepositsPageState extends State<DepositsPage> {
  List<Deposit> deposits;

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

    return ListView.builder(
      itemCount: deposits.length,
      itemBuilder: (context, index) {
        return InkWell(
            child: Text(deposits[index].name),
            onTap: () {
              Navigator.pushNamed(context, '/deposits');
            });
      },
    );
  }
}
