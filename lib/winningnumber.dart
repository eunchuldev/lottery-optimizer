import 'package:flutter/material.dart';
import 'LotteryBall.dart';

class WinningNumbers extends StatefulWidget {
  @override
  _WinningNumbersState createState() => _WinningNumbersState();
}

class _WinningNumbersState extends State<WinningNumbers> {
  @override
  Widget build(BuildContext context) {
    int round = LotteryNumberLoader.getRound();

    if(LotteryNumberLoader.completed-2 < 0)
      return Scaffold();

    return Scaffold(
        appBar: AppBar(
          title: Text("최근 당첨번호"),
        ),
        body:Container(
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            itemCount: LotteryNumberLoader.completed-2,
            itemBuilder: (context, index) => ListTile(
              leading: Text("#${round-index}회"),
              title: LotteryBall().makeWinningNumber(LotteryNumberLoader.list[round - index])
            ),
            separatorBuilder: (context, index) => Divider(),
          ),
          key: ValueKey<int>(1),
        )
    );
  }
}