import 'package:flutter/material.dart';
import 'bookmark.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bookmarks = List<LottoRecord>();

    ///SAMPLE DATA
    for(int i=0;i<3;i++){
      LottoRecord sample = LottoRecord();
      sample.year = 1234;
      sample.month = 12;
      sample.date = 11;

      sample.reward = "X";
      List<int> list = List();
      list.add(1);
      list.add(2);
      list.add(3);
      list.add(4);
      list.add(5);
      list.add(6);
      sample.selected = list;
      bookmarks.add(sample);
    }

    ///버튼 위젯
    Color color=Theme.of(context).primaryColor;
    Widget buttonView=Container(
      color: Color.fromARGB(255, 26, 188, 156),
      padding : const EdgeInsets.all(30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          RaisedButton(///즐겨찾기
            //TODO onPressed: ,
              child: Icon(Icons.star, color: color)
          ),

          RaisedButton(///메인
            //TODO onPressed: ,
              child: Icon(Icons.looks_one, color: color)
          ),
        ],
      ),
    );

    Widget showMenu = Container(
      padding : const EdgeInsets.all(10),
      child: Bookmark(bookmarks: bookmarks,),
      height: 10000000,
    );

    return MaterialApp(
      title: 'Lotto Learning',
      home: Scaffold(
        appBar: AppBar(
          title: Text('로또번호 최적화'),
        ),
        body: ListView(
          children: <Widget>[
            buttonView,
            showMenu
          ],
        ),
      ),
    );
  }

  List<LottoRecord> bookmarks;
}