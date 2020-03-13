import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:lottery_optimizer/state.dart';

class LotteryBall{
  Widget make(int number) =>
      Stack(
        alignment: Alignment.center,
        children:[
          Container(
            padding: EdgeInsets.all(18.0),
            decoration: new BoxDecoration(
              color: (number >= 40)? Colors.green :
              (number >= 30)? Colors.cyan :
              (number >= 20)? Colors.red :
              (number >= 10)? Colors.blue :
              Colors.orange,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 2.0,
                  offset: Offset(
                    1.0,
                    2.0,
                  ),
                )
              ],
            ),
          ),
          Text("$number", style:TextStyle(color: Colors.white)),
        ],
      );

  Widget makeColorBall(int number, Color color) =>
      Stack(
        alignment: Alignment.center,
        children:[
          Container(
            padding: EdgeInsets.all(18.0),
            decoration: new BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 2.0,
                  offset: Offset(
                    1.0,
                    2.0,
                  ),
                )
              ],
            ),
          ),
          Text("$number", style:TextStyle(color: Colors.white)),
        ],
      );

  Widget makeWithCheck(int number, LotterySet list) =>
      list.numbers.contains(number)?
          make(number):
      Stack(
        alignment: Alignment.center,
        children:[
          Container(
            padding: EdgeInsets.all(18.0),
            decoration: new BoxDecoration(
              color: list.bonus == number ? Colors.purple:Colors.grey,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: list.bonus == number ? Colors.purple:Colors.grey,
                  blurRadius: 2.0,
                  offset: Offset(
                    1.0,
                    2.0,
                  ),
                )
              ],
            ),
          ),
          Text("$number", style:TextStyle(color: Colors.white)),
        ],
      );

  Widget makeWinningNumber(LotterySet list){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: list.numbers.map((number) =>
              LotteryBall().make(number),
          )?.toList() ?? [],
        ),
        Icon(Icons.add),
        makeColorBall(list.bonus, Colors.purple)
      ],
    );
  }
}

class LotterySet{
  List<int> numbers;
  int bonus;

  LotterySet();

  LotterySet.fromJson(Map<String, dynamic> json)
      : numbers = json['tickets'].map((ticket) => ticket.cast<int>()).toList(),
        bonus = json['bonus'];

  Map<String, dynamic> toJson() => {
    'tickets': numbers,
    'bonus': bonus,
  };
}

class LotteryNumberLoader{
  static List<LotterySet> list = List(99999);

  static int from = 0;
  static int round = 0;

  static int getRound(){
    return round;
  }

  static int getLastRound(DateTime time){
    DateTime day = DateTime(time.year,time.month,time.day+7);
    DateTime from = DateTime(2020,3,7,8,41);
    int round = (day.millisecondsSinceEpoch - from.millisecondsSinceEpoch)~/(1000*60*60*24*7) + 901;
    return round;
  }

  static calculatePrize(AppState model) async{
    bool changed = false;
    for(TicketSet ticket in model.favorites){
      if(ticket.prize != 0)
        continue;
      ticket.calculatePrize();
      changed = true;
    }
    if(changed)
      model.prizeUpdated();
  }

  static LoadWinningNumber(AppState model) async{
    int now = getLastRound(DateTime.now()) - 1;
    if(now == round)
      return;

    int until;
    if(round == 0)
      until = now - 20;
    else
      until = round;

    if(from == 0)
      from = until;

    for(int i=until + 1; i<=now; i++){
      http.Response response = await http.get("https://www.dhlottery.co.kr/gameResult.do?method=byWin&drwNo="+i.toString());
      if(response.statusCode != 200){
        round = i - 1;
        break;
      }
      dom.Document document = parser.parse(response.body);
      LotterySet balls = new LotterySet();
      balls.numbers = new List<int>();

      document.getElementsByClassName("num win").elementAt(0).getElementsByClassName("ball_645 lrg ball1").forEach((element) {
        balls.numbers.add(int.parse(element.text));
      });
      document.getElementsByClassName("num win").elementAt(0).getElementsByClassName("ball_645 lrg ball2").forEach((element) {
        balls.numbers.add(int.parse(element.text));
      });
      document.getElementsByClassName("num win").elementAt(0).getElementsByClassName("ball_645 lrg ball3").forEach((element) {
        balls.numbers.add(int.parse(element.text));
      });
      document.getElementsByClassName("num win").elementAt(0).getElementsByClassName("ball_645 lrg ball4").forEach((element) {
        balls.numbers.add(int.parse(element.text));
      });
      document.getElementsByClassName("num win").elementAt(0).getElementsByClassName("ball_645 lrg ball5").forEach((element) {
        balls.numbers.add(int.parse(element.text));
      });

      document.getElementsByClassName("num bonus").elementAt(0).getElementsByClassName("ball_645 lrg ball1").forEach((element) {
        balls.bonus = int.parse(element.text);
      });
      document.getElementsByClassName("num bonus").elementAt(0).getElementsByClassName("ball_645 lrg ball2").forEach((element) {
        balls.bonus = int.parse(element.text);
      });
      document.getElementsByClassName("num bonus").elementAt(0).getElementsByClassName("ball_645 lrg ball3").forEach((element) {
        balls.bonus = int.parse(element.text);
      });
      document.getElementsByClassName("num bonus").elementAt(0).getElementsByClassName("ball_645 lrg ball4").forEach((element) {
        balls.bonus = int.parse(element.text);
      });
      document.getElementsByClassName("num bonus").elementAt(0).getElementsByClassName("ball_645 lrg ball5").forEach((element) {
        balls.bonus = int.parse(element.text);
      });

      if(balls.numbers.length < 6)
        return;

      list[i] = balls;
      round = i;
      model.winningNumberUpdated();
      calculatePrize(model);
    }
  }
}
