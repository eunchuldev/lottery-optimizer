import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:intl/intl.dart';
import 'state.dart';
import 'package:http/http.dart' as http;


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
    fetchWinningTicket();
    return ScopedModelDescendant<AppState>(
      builder: (context, child, model) => 
        ListView.separated(
          physics: const BouncingScrollPhysics(), 
          itemCount: model.favorites.length,
          itemBuilder: (context, index) => ListTile(
            leading: Text("#${index+1}"),
            title: Row( 
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("${DateFormat('MM-dd').format(model.favorites[index].createdAt)}"),
                Text("${(model.favorites[index].coverage5thPrize*100/8145060).toStringAsFixed(1)}%"),
                Row(
                  children: model.favorites[index].tickets[0].map((number) =>
                    Text("$number,"),
                  ).toList(),
                ),
              ]
            ),
          ),
          separatorBuilder: (context, index) => Divider(),
        ),
    );
  }
}

Future<void> fetchWinningTicket() async {
  final res = await http.get("https://m.dhlottery.co.kr/gameResult.do?method=byWin");
  for(int i=0, start=0, end=0; i<6; ++i) {
    start = res.body.indexOf('ball clr', end);
    end = res.body.indexOf('<', start);
    print(res.body.substring(start + 11, end));
  }
}
