import 'package:android/redux/app/app_action.dart';
import 'package:android/redux/app/app_state.dart';
import 'package:android/redux/dasboard/dashboard_action.dart';
import 'package:android/redux/dasboard/dashboard_state.dart';
import 'package:android/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

class DashboardPage extends StatefulWidget {
  final Store<AppState> store;

  DashboardPage(this.store);

  @override
  _DashboardPageState createState() {
    return _DashboardPageState();
  }
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    widget.store.dispatch(DashboardInitializeAction());
  }

  @override
  void dispose() {
    super.dispose();
    widget.store.dispatch(DashboardDisposeAction());
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (context, state) {
        if (!state.dashboardState.initialized) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        var barItems = <Widget>[
          Text("Lucy - your assistent"),
        ];

        if (state.synchronizing) {
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
                onPressed: () => widget.store.dispatch(AppSynchronizeAction()),
              )
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
                      _buildFinanceTile(state.dashboardState),
                    ],
                  ),
                  onTap: () => null,
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
      },
    );
  }

  Widget _buildGridItem(LucyRoute route, Color color) {
    return Card(
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
    );
  }

  Widget _buildFinanceTile(DashboardState state) {
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
                        Text(state.todaySpent.toString() + '€'),
                        Text((state.todayMax - state.todaySpent).toString() +
                            '€'),
                        Divider(),
                        Text((state.todayMax - state.todaySpent).toString() +
                            '€'),
                        Text((state.todayMax - state.todaySpent).toString() +
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
                    state.balance.toString() + '€',
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
