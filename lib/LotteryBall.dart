import 'package:flutter/material.dart';
import 'state.dart';

class LotteryBall{
  Widget ticketSetPannel(TicketSet set, int valueKey)=>
      Container(
        child: ListView.separated(
          physics: const BouncingScrollPhysics(),
          itemCount: set.tickets.length,
          itemBuilder: (context, index) => ListTile(
            leading: Text("#${index+1}"),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: set.tickets[index].map((number) =>
                  make(number),
              )?.toList() ?? [],
            ),
          ),
          separatorBuilder: (context, index) => Divider(),
        ),
        key: ValueKey<int>(valueKey),
      );

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
}