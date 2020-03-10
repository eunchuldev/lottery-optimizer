import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'state.dart';

class LotteryBall{
  Widget make(int number) =>
      Stack(
        alignment: Alignment.center,
        children:[
          Container(
            padding: EdgeInsets.all(18.0),
            decoration: new BoxDecoration(
              color: (number >= 40)? Colors.green :
              (number >= 30)? Colors.grey :
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
}

class LotteryNumberLoader{
  static List<LotterySet> list;
  static int round = 0;
  static int completed = 0;
  static int range = 20;

  static int getRound(){
    return round;
  }

  static void _updateDay(){
    DateTime time = DateTime.now();
    DateTime from = DateTime(2020,3,7,8,39);
    round = (time.millisecondsSinceEpoch - from.millisecondsSinceEpoch)~/(1000*60*60*24*7) + 901;
  }

  static int getLastRound(DateTime time){
    _updateDay();
    DateTime day = DateTime(time.year,time.month,time.day+7);
    DateTime from = DateTime(2020,3,7,8,41);
    int round = (day.millisecondsSinceEpoch - from.millisecondsSinceEpoch)~/(1000*60*60*24*7) + 901;
    return round;
  }

  static void Load() async{
    _updateDay();

    list = List<LotterySet>(round+1);
    completed = 0;

    for(int i=round;i>=round-range;i--){
      http.Response response = await http.get("https://www.dhlottery.co.kr/gameResult.do?method=byWin&drwNo="+i.toString());
      if(response.statusCode != 200){
        round = 0;
        return;
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

      list[i] = balls;
      completed++;
    }
  }
}
