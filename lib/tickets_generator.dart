import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'dart:math';
import 'dart:core';
import 'state.dart';


class TicketsGenerator extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TicketsGenerator();
}

class _TicketsGenerator extends State<TicketsGenerator> with AutomaticKeepAliveClientMixin<TicketsGenerator>, SingleTickerProviderStateMixin  {
  TicketSet ticketSet;
  int ticketsNum = 50;
  bool calculating = false;
  bool manualFeeding = false;
  bool keyboardUp = false;
  bool statsExpanded = false;
  TextEditingController _manualFeedingTextController = TextEditingController();

  //FocusNode focusNode = new FocusNode();


  int _count = 0;
  void generateRandomTicketSet(AppState model) {
    setState(() {
      ticketSet = TicketSet.random(ticketsNum);
      model.isFavorite = false;
      _count += 1;
    });
    calculateCoverage(model);
  }
  void generateOptimizedTicketSet(AppState model) {
    setState(() {
      model.isFavorite = false;
      _count += 1;
    });
    TicketSet.optimized(ticketsNum).then((_ticketsSet) {
      setState(() {
        ticketSet = _ticketsSet;
      });
      calculateCoverage(model);
    });
  }
  void calculateCoverage(AppState model) {
      setState(() {
        calculating = true;
        ticketSet = ticketSet;
      });
      ticketSet.calculateCoverage().then((res) {
        setState(() {
          calculating = false;
          ticketSet = ticketSet;
        });
        model.coverageUpdated();
      });
  }
  void manualFeedingStart() {
    _manualFeedingTextController.value = TextEditingValue(
      text: ticketSet?.tickets
        ?.map((ticket) => ticket.map((i) => i.toString()).join(" "))
        ?.join("\n") ?? "");
    setState(() {
      manualFeeding = true;
    });
  }
  void manualFeedingEnd(model) {
    Random rng = Random();
    setState(() {
      manualFeeding = false;
      if(_manualFeedingTextController.text == "")
        ticketSet = null;
      else
        ticketSet = TicketSet(
          _manualFeedingTextController.text
            .split("\n")
            .map((line)=>line.split(" ").map((str) => min(max(int.parse(str), 1), 45)).toList().cast<int>()..sort())
            .where((list) => list.length == 6)
            .map((list) {
              for(int i=0; i<list.length; ++i)
                while(list.indexOf(list[i]) != i)
                  list[i] = rng.nextInt(45)+ 1;
              return list;
            })
            .toList().cast<List<int>>()
        );
    });
    calculateCoverage(model);
  }

  TextStyle topPannelTextStyle() => DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.2, color: Colors.white);

  Widget ticketsNumField() =>
    ButtonTheme(
      minWidth: 60.0,
      textTheme: ButtonTextTheme.normal,
      child: RaisedButton(
        onPressed: () => showDialog<int>(
          context: context,
          builder: (BuildContext context) =>
            NumberPickerDialog.integer(
              minValue: 1,
              maxValue: 100,
              step: 1,
              initialIntegerValue: ticketsNum,
            ),
          ).then((num value) {
            if (value != null) {
              setState(() => ticketsNum = value);
            }
          }),
        child: Text("$ticketsNum", style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.2)),
        color: Colors.white,
        textColor: Colors.black,
        padding: const EdgeInsets.all(8.0),
      ),
    );
  Widget topPannel() =>
    Visibility(
      visible: !keyboardUp,
      child: Theme(
        data: Theme.of(context).copyWith(
          textTheme: TextTheme(bodyText2: TextStyle(color: Colors.white)),
          ),
        child: Card(
          margin: EdgeInsets.zero,
          //elevation: 4.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
          child: Container(
            color: Theme.of(context).primaryColor,
            padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0, bottom: 20.0),
            child: ListView (
              shrinkWrap: true,
              children: [
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("로또번호 갯수", style: topPannelTextStyle()),
                      Expanded(child:
                        Padding( 
                          padding: EdgeInsets.all(16.0),
                          child: Divider(
                            color: Color(0x55ffffff),
                          ))),
                      ticketsNumField(),
                    ],
                  ),
                ),
                ListTile(
                  title: Row(
                    children: [
                      Expanded( child: Padding(
                        child: ScopedModelDescendant<AppState>(
                          builder: (context, child, model) => RaisedButton(
                            child: Text("랜덤생성", style: topPannelTextStyle()),
                              elevation: 0.0,
                            color: Colors.grey[400],
                            onPressed: () => generateRandomTicketSet(model),
                            shape: RoundedRectangleBorder( borderRadius: new BorderRadius.circular(8.0),),
                          ),
                        ),
                        padding: EdgeInsets.only(right:8.0),
                      )),
                      Expanded( child: Padding(
                        child: RaisedButton(
                          child: Text("직접입력", style: topPannelTextStyle()),
                          elevation: 0.0,
                          color: Colors.grey[400],
                          onPressed: () => manualFeedingStart(),
                          shape: RoundedRectangleBorder( borderRadius: new BorderRadius.circular(8.0),),
                        ),
                        padding: EdgeInsets.only(left:8.0),
                      )),
                    ],
                  ),
                ),
                ListTile(
                  title: 
                    ScopedModelDescendant<AppState>(
                      builder: (context, child, model) => RaisedButton(
                        child: Text("최적화 로또번호세트 생성", style: topPannelTextStyle()),
                        elevation: 0.0,
                        onPressed: () => generateOptimizedTicketSet(model),
                        color: Colors.orange[700],
                        textColor: Colors.white,
                        shape: RoundedRectangleBorder( borderRadius: new BorderRadius.circular(8.0),),
                      ),),
                ),
              ],
            ),
          )),
      )
    );
  Widget lotteryBall(int number) =>
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

  Widget ticketSetPannel() => 
    Container(
      constraints: BoxConstraints(
        minWidth: double.infinity,
        minHeight: double.infinity,
      ),
      child: manualFeeding? 
        ScopedModelDescendant<AppState>(
          builder: (context, child, model) => 
            TextField(
              autofocus: true,
              expands: true,
              decoration: InputDecoration(
                hintText: "번호를 직접 입력해보세요. ex) 1 3 7 13 24 31", 
                contentPadding: const EdgeInsets.all(12.0),
              ),
              inputFormatters: [WhitelistingTextInputFormatter(RegExp(r'[\d\s]+')), LotteryBallTextFormatter()],
              controller: _manualFeedingTextController,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.done,
              maxLines: null,
              onTap: () {
                setState(() => keyboardUp = true);
              },
              onSubmitted: (String text) {
                manualFeedingEnd(model);
              },
            ),
          )
        : ticketSet == null? 
        Center(child:Padding(
          padding: EdgeInsets.all(20.0),
          child: Text("아직 생성된 번호가 없어요...", style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.2, color: Colors.grey)),
        )):
        ListView.separated(
          physics: const BouncingScrollPhysics(), 
          itemCount: ticketSet?.tickets?.length ?? 0,
          itemBuilder: (context, index) => /*ScopedModelDescendant<AppState>(
            builder: (context, child, model) => */
            ListTile(
              leading: Text("#${index+1}"),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ticketSet?.tickets[index].map((number) =>
                  lotteryBall(number),
                )?.toList() ?? [],
              ),
            ),
          separatorBuilder: (context, index) => Divider(),
        ),
      key: ValueKey<int>(_count),
    );

  Widget statsPannel() =>
    Visibility(
      visible: ticketSet != null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border(
            top: BorderSide(
              color: Colors.grey,
              width: 0.5,
            ),
          ),
        ),
        child: 
          FlatButton(
            padding: EdgeInsets.all(0),
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onPressed: () {
              setState(() => statsExpanded = !statsExpanded);
            },
            child:ListTile(
              leading: statsExpanded? 
                Icon(Icons.keyboard_arrow_down): Icon(Icons.keyboard_arrow_up),
              title: 
                IntrinsicHeight(
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [ ticketSet?.coverage5thPrize == null || calculating? 
                    Row(
                      children: [
                        Text("당첨확률 계산중..   "),
                        SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(),
                        ),
                      ],
                    ) :
                    statsExpanded? 
                      Expanded(
                        child: DefaultTextStyle(
                          style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 0.8),//, color: Colors.white),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical:4.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child:Center(child:Text("등수"))),
                                      Expanded(child:Center(child:Text("커버된수"))),
                                      Expanded(child:Center(child:Text("경우의수"))),
                                      Expanded(child:Center(child:Text("커버리지"))),
                                    ],
                              ))),
                              Divider(),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical:4.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child:Center(child:Text("1등"))),
                                      Expanded(child:Center(child:Text("${ticketSet.coverage1thPrize}"))),
                                      Expanded(child:Center(child:Text("${8145060}"))),
                                      Expanded(child:Center(child:Text("${((ticketSet.coverage1thPrize ?? 0)*100/8145060).toStringAsFixed(4)}%"))),
                                    ],
                              ))),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical:4.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child:Center(child:Text("2등"))),
                                      Expanded(child:Center(child:Text("${ticketSet.coverage2thPrize}"))),
                                      Expanded(child:Center(child:Text("${8145060*45}"))),
                                      Expanded(child:Center(child:Text("${((ticketSet.coverage2thPrize ?? 0)*100/8145060).toStringAsFixed(3)}%"))),
                                    ],
                              ))),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical:4.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child:Center(child:Text("3등"))),
                                      Expanded(child:Center(child:Text("${ticketSet.coverage3thPrize}"))),
                                      Expanded(child:Center(child:Text("${8145060}"))),
                                      Expanded(child:Center(child:Text("${((ticketSet.coverage3thPrize ?? 0)*100/8145060).toStringAsFixed(2)}%"))),
                                    ],
                              ))),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical:4.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child:Center(child:Text("4등"))),
                                      Expanded(child:Center(child:Text("${ticketSet.coverage4thPrize}"))),
                                      Expanded(child:Center(child:Text("${8145060}"))),
                                      Expanded(child:Center(child:Text("${((ticketSet.coverage4thPrize ?? 0)*100/8145060).toStringAsFixed(2)}%"))),
                                    ],
                              ))),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical:4.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child:Center(child:Text("5등"))),
                                      Expanded(child:Center(child:Text("${ticketSet.coverage5thPrize}"))),
                                      Expanded(child:Center(child:Text("${8145060}"))),
                                      Expanded(child:Center(child:Text("${((ticketSet.coverage5thPrize ?? 0)*100/8145060).toStringAsFixed(2)}%"))),
                                    ],
                              ))),
                            ],
                          )))
                      : Row(
                        children: [
                          Text("${((ticketSet.coverage5thPrize ?? 0)*100/8145060).toStringAsFixed(2)}%로 5등 당첨"), 
                          VerticalDivider(
                            color: Colors.grey[600],
                            indent: 12.0,
                            endIndent: 12.0,
                            thickness: 0.5,
                            ),
                          Text("${((ticketSet.coverage4thPrize ?? 0)*100/8145060).toStringAsFixed(2)}%로 4등 당첨"), 
                        ],
                      ),
                    Material(
                      child: ScopedModelDescendant<AppState>(
                        builder: (context, child, model) => 
                        InkWell(
                          onTap: () {
                            if(!model.isFavorite){
                              model.favorite(ticketSet);
                            }
                            else{
                              model.unfavoriteLast();
                            }
                          },
                          customBorder: CircleBorder(),
                          child: Container(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              model.isFavorite? Icons.star : Icons.star_border,
                              size: 30.0,
                              color: model.isFavorite? Colors.yellow[700] : Colors.black,
                              semanticLabel: '즐겨찾기',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]
                )),
            ),
        ),
      ),
    );

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        topPannel(),
        Expanded( child: 
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (Widget child, Animation<double> animation) => 
              FadeTransition(
                /*opacity: Tween<double>(
                  begin: 0,
                  end: 1,
                ).animate(animation),*/
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(0, -0.01),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
            child: ticketSetPannel(),
          ),
        ),
        statsPannel(),
        ]);
  }

  @override
  void initState() {
    super.initState();
    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) => setState(() {
        keyboardUp = visible;
      }),
    );
  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  bool get wantKeepAlive => true;

}
class LotteryBallTextFormatter extends TextInputFormatter {
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length == 0) {
      return newValue.copyWith(text: '');
    } else {
      List splited = newValue.text.split(RegExp('\\s+'))
        .where((l) => l != null)
        .toList();
      String formatted = splited.fold([[]], (list, x) =>
        list.last.length == 6 ? (list..add([x])) : (list..last.add(x))
      ).map((l) => l.join(" ")).join("\n");
      return TextEditingValue(
        text: formatted, 
        selection: TextSelection.collapsed(offset: min(newValue.selection.end, formatted.length),),
        );
    }
  }
}

extension IndexedIterable<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T f(E e, int i)) {
    var i = 0;
    return this.map((e) => f(e, i++));
  }
}
