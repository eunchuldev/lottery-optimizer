import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'tickets_generator.dart';
import 'favorites.dart';
import 'state.dart';

void main() => runApp(MyApp());


class MyApp extends StatelessWidget {
  final model = AppState();
  @override
  Widget build(BuildContext context) {
    return ScopedModel<AppState>(
      model: model,
      child: MaterialApp(
        home: DefaultTabController(
          length: 3,
          initialIndex: 1,
          child: Scaffold(
            appBar: AppBar(
              bottom: TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.star)),
                  Tab(icon: Icon(Icons.grain)),
                  Tab(icon: Icon(Icons.more_horiz)),
                ],
              ),
              title: Text("로또번호 최적화"),
              elevation: 0.0,
            ),
            body: TabBarView(
              children: [
                Favorites(),
                TicketsGenerator(),
                Icon(Icons.directions_transit),
              ],
            ),
          ),
        ),
        theme: ThemeData(
          primarySwatch: Colors.teal,
          splashFactory: InkRipple.splashFactory,
          //textTheme: TextTheme(body1: TextStyle(fontSize: 30.0)),
        ),
      ),
    );
  }
}
