import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class Bookmark extends StatefulWidget {
  Bookmark({Key key, this.bookmarks}) : super(key: key);

  @override
  _BookmarkState createState() => _BookmarkState();

  List<LottoRecord> bookmarks;
}

class _BookmarkState extends State<Bookmark> {

  void ShowLoadingMessage(){
    Toast.show("즐겨찾기 로딩 중...", context, duration:2, gravity: 1);
  }


  @override
  Widget build(BuildContext context) {


    Widget messageView = Container(
        padding : const EdgeInsets.all(0),
        color: Color.fromARGB(255, 26, 188, 156),
        child:Text(
          "                  번호               당첨",
          style: TextStyle(color:Colors.white),
        )
    );

    Widget bookmarkView = Container(
        height: 1000000,
        child:ListView.builder(
            itemCount:widget.bookmarks.length * 2,
            itemBuilder:(context,index){
              if(index.isEven)
                return Divider();

              int listLoc = index.toInt()~/2;
              LottoRecord lotto = widget.bookmarks[listLoc];
              return ListTile(
                title:Text(
                    "#"+(listLoc+1).toString()+"  "+
//                        lotto.year.toString()+"/"+
//                        lotto.month.toString()+"/"+
//                        lotto.date.toString()+"/"+"    "+
                        lotto.selected.toString()+"    "+
                        lotto.reward
                ),
              );
            })
    );

    return Scaffold(
        body:ListView(
          children: <Widget>[
            messageView,
            bookmarkView
          ],
        )
    );
  }
}

class LottoRecord{
  int year;
  int month;
  int date;

  List<int> selected;
  String reward;
}