import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:intl/intl.dart';
import 'state.dart';
import 'lotto.dart';

class Favorites extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Favorites();
}

class _Favorites extends State<Favorites> with AutomaticKeepAliveClientMixin<Favorites> {
  @override
  void initState() {
    super.initState();
  }
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ScopedModelDescendant<AppState>(
      builder: (context, child, model) =>
          ListView.separated(
            physics: const BouncingScrollPhysics(),
            itemCount: model.favorites.length,
            itemBuilder: (context, index) => ListTile(
                leading: Text("${DateFormat('MM월 dd일').format(model.favorites[index].createdAt)}"),
                title: GestureDetector(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: model.favorites[index].tickets[0].map((number) =>
                            LotteryBall().make(number),
                        )?.toList() ?? [],
                      ),
                      Text("${(model.favorites[index].coverage5thPrize*100/8145060).toStringAsFixed(1)}%"),
                    ],
                  ),
                  onTap: ()=>{
                    Navigator.push(context, MaterialPageRoute(builder:(context)=>LotteryList(tickets: model.favorites[index])))
                  },
                )
            ),
            separatorBuilder: (context, index) => Divider(),
          ),
    );
  }
}

class LotteryList extends StatefulWidget {
  TicketSet tickets;

  LotteryList({Key key, this.tickets}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LotteryList();
}

class _LotteryList extends State<LotteryList>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:LotteryBall().ticketSetPannel(widget.tickets, 0)
    );
  }
}