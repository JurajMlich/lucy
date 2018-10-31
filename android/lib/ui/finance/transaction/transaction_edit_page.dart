import 'package:android/lucy_container.dart';
import 'package:android/model/deposit.dart';
import 'package:android/repository/deposit_repository.dart';
import 'package:flutter/material.dart';

class TransactionEditPage extends StatefulWidget {
  final String transactionId;

  TransactionEditPage({this.transactionId});

  @override
  _TransactionEditPageState createState() {
    return _TransactionEditPageState(transactionId);
  }
}

class _TransactionEditPageState extends State<TransactionEditPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<Deposit> deposits;
  String transactionId;

  _TransactionEditPageState(this.transactionId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.transactionId == null
            ? 'Create transaction'
            : 'Edit transaction'),
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
      setState(() {
        this.deposits = deposits;
      });
    });
  }

  Widget _buildBody(BuildContext context) {
    // todo: finish
    if (deposits == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return Container(
      child: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(labelText: 'Source depoist'),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Target depoist'),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Sum'),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'State'),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Execution date'),
              keyboardType: TextInputType.datetime,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Note'),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Categories'),
            ),
          ],
        ),
      ),
    );
  }
}
