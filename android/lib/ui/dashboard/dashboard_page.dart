import 'package:android/lucy_container.dart';
import 'package:android/routes.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() {
    return _DashboardPageState();
  }
}

class _Model {
  double balance;
  double todaySpent;
  double todayMax;
  double monthSpent;
  double monthMax;

  _Model({
    @required this.balance,
    @required this.todaySpent,
    @required this.todayMax,
    @required this.monthSpent,
    @required this.monthMax,
  });
}

class _DashboardPageState extends State<DashboardPage> {
  _Model model;
  bool synchronizing = false;

  @override
  void initState() {
    super.initState();

    model = _Model(
        balance: 12344,
        todaySpent: 1,
        todayMax: 10,
        monthSpent: 10,
        monthMax: 100);
  }

  @override
  Widget build(BuildContext context) {
    if (model == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    var barItems = <Widget>[
      Text("Lucy - your assistent"),
    ];

    if (synchronizing) {
      barItems.add(
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: barItems,
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.sync),
              onPressed: () async {
                setState(() {
                  synchronizing = true;
                });
                await LucyContainer().syncManager.synchronize();
                setState(() {
                  synchronizing = false;
                });
              }),
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: 140,
            child: InkWell(
              child: Row(
                children: [
                  _buildGridItem(routes[0], Colors.indigo),
                  _buildFinanceTile(),
                ],
              ),
              onTap: () => Navigator.pushNamed(context, '/finance'),
            ),
          ),
          Container(
            height: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  child: _buildGridItem(routes[1], Colors.black),
                  onTap: () => null,
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGridItem(LucyRoute route, Color color) {
    return InkWell(
      child: Card(
        color: color,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Icon(
                  route.icon,
                  size: 40,
                ),
              ),
              Text(
                route.name,
                style: TextStyle(fontSize: 15),
              )
            ],
          ),
        ),
      ),
      onTap: () => Navigator.pushNamed(context, route.path),
    );
  }

  Widget _buildFinanceTile() {
    return Expanded(
      child: Card(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('today spent:'),
                      Text('today free:'),
                      Divider(),
                      Text('month spent:'),
                      Text('month free:'),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(model.todaySpent.toString() + '€'),
                        Text((model.todayMax - model.todaySpent).toString() +
                            '€'),
                        Divider(),
                        Text(model.monthSpent.toString() + '€'),
                        Text((model.monthMax - model.monthSpent).toString() +
                            '€'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('current balance:'),
                  Text(
                    model.balance.toString() + '€',
                    style: TextStyle(fontSize: 20),
                  ),
                  Divider(
                    height: 10,
                  ),
                  InkWell(
                    child: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.indigo,
                      ),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.add,
                            size: 13,
                          ),
                          Divider(
                            indent: 4,
                          ),
                          Text(
                            'New transaction',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          )
                        ],
                      ),
                    ),
                    onTap: () => null,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
