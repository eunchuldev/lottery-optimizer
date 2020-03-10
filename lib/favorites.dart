import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:intl/intl.dart';
import 'LotteryBall.dart';
import 'state.dart';

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

    int round = LotteryNumberLoader.round;

    return ScopedModelDescendant<AppState>(
      builder: (context, child, model) {
        for(TicketSet ticket in model.favorites){
          ticket.calculatePrize();
        }
        SizedBox loadingBox = SizedBox(
          width: 20, height: 20,
          child: CircularProgressIndicator(),
        );
        return ListView.separated(
          physics: const BouncingScrollPhysics(),
          itemCount: model.favorites.length,

          itemBuilder: (context, index){
            TicketSet ticket = model.favorites[index];
            return ListTile(
                leading: Text("${DateFormat('MM월 dd일').format(ticket.createdAt)}"),
                title: GestureDetector(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: ticket.tickets[0].map((number) =>
                            LotteryBall().make(number),
                        )?.toList() ?? [],
                      ),
                      LotteryNumberLoader.getLastRound(model.favorites[index].createdAt)>round?
                      ticket.coverage5thPrize == null?
                      loadingBox
                          :Text("${(ticket.coverage5thPrize*100/8145060).toStringAsFixed(1)}%")
                          :ticket.prize==0?loadingBox:Text(ticket.prize == 6?"꽝":ticket.prize.toString()+"등")
                    ],
                  ),
                  onTap: ()=>{
                    Navigator.push(context, MaterialPageRoute(builder:(context)=>LotteryList(tickets: model.favorites[index])))
                  },
                )
            );
          },
          separatorBuilder: (context, index) => Divider(),
        );
      }
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
    int last = LotteryNumberLoader.round;
    int to = LotteryNumberLoader.getLastRound(widget.tickets.createdAt);

    if(last < to || last - LotteryNumberLoader.range > to){
      return Scaffold(
          appBar: AppBar(
              title:Text("목록")
          ),
          body:Container(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: widget.tickets.tickets.length,
              itemBuilder: (context, index) => ListTile(
                leading: Text("#${index+1}"),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: widget.tickets.tickets[index].map((number) =>
                      LotteryBall().make(number),
                  )?.toList() ?? [],
                ),
              ),
              separatorBuilder: (context, index) => Divider(),
            ),
            key: ValueKey<int>(0),
          )
      );
    }
    else{
      LotterySet list = LotteryNumberLoader.list[to];
      return Scaffold(
          appBar: AppBar(
            title:LotteryBall().makeWinningNumber(list)
          ),
          body:Container(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: widget.tickets.tickets.length,
              itemBuilder: (context, index) => ListTile(
                leading: Text("#${index+1}"),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: widget.tickets.tickets[index].map((number) =>
                      LotteryBall().makeWithCheck(number, list),
                  )?.toList() ?? [],
                ),
              ),
              separatorBuilder: (context, index) => Divider(),
            ),
            key: ValueKey<int>(0),
          )
      );
    }
  }
}
