import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:scoped_model/scoped_model.dart';
import 'state.dart';

class TicketsGenerator extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TicketsGenerator();
}

class _TicketsGenerator extends State<TicketsGenerator> with AutomaticKeepAliveClientMixin<TicketsGenerator> {
  TicketSet ticketSet;
  int ticketsNum = 50;
  bool favorite = false;

  int _count = 0;
  void generateRandomTicketSet() {
    setState(() {
      ticketSet = TicketSet.random(ticketsNum);
      favorite = false;
      _count += 1;
    });
    ticketSet.calculateCoverage().then((res) {
      setState(() {
        ticketSet = ticketSet;
      });
    });
  }
  void generateOptimizedTicketSet() {
    setState(() {
      favorite = false;
      _count += 1;
    });
    TicketSet.optimized(ticketsNum).then((_ticketsSet) {
      setState(() {
        ticketSet = _ticketsSet;
      });
      ticketSet.calculateCoverage().then((res) {
        setState(() {
          ticketSet = ticketSet;
        });
      });
    });
  }

  Widget ticketsNumField() =>
    ButtonTheme(
      minWidth: 50.0,
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
    Theme(
      data: Theme.of(context).copyWith(
        textTheme: TextTheme(body1: TextStyle(color: Colors.white)),
        ),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 4.0,
        child:Container(
          color: Theme.of(context).primaryColor,
          padding: const EdgeInsets.all(8.0),
          child: ListView (
            shrinkWrap: true,
            children: [
              ListTile(
                title: Text("로또번호 갯수"),
                trailing: ticketsNumField(),
              ),
              ListTile(
                title: Row(
                  children: [
                    Expanded( child: Padding(
                      child: RaisedButton(
                        child: Text("랜덤생성"),
                        onPressed: () => generateRandomTicketSet(),
                      ),
                      padding: EdgeInsets.only(right:8.0),
                    )),
                    Expanded( child: Padding(
                      child: RaisedButton(
                        child: Text("직접입력"),
                        onPressed: () => "",
                      ),
                      padding: EdgeInsets.only(left:8.0),
                    )),
                  ],
                ),
              ),
              ListTile(
                title: RaisedButton(
                  child: Text("최적화 로또번호세트 생성"),
                  onPressed: () async => await generateOptimizedTicketSet(),
                  color: Colors.orange,
                  textColor: Colors.white,
                ),
              ),
            ],
          ),
        )),
    );
  Widget LotteryBall(int number) => 
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
      child: ListView.separated(
        physics: const BouncingScrollPhysics(), 
        itemCount: ticketSet?.tickets?.length ?? 0,
        itemBuilder: (context, index) => ListTile(
          leading: Text("#${index+1}"),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ticketSet?.tickets[index].map((number) =>
              LotteryBall(number),
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
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: 
                IntrinsicHeight(
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ticketSet?.coverage5thPrize == null? 
                      Row(
                        children: [
                          Text("당첨확률 계산중..   "),
                          SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(),
                          ),
                        ],
                      ) :
                      Row(
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
                            if(!favorite){
                              model.favorite(ticketSet);
                              setState(() {
                                favorite = true;
                              });
                            }
                            else{
                              model.unfavoriteLast();
                              setState(() {
                                favorite = false;
                              });
                            }
                          },
                          customBorder: CircleBorder(),
                          child: Container(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              favorite? Icons.star : Icons.star_border, 
                              size: 30.0,
                              color: favorite? Colors.yellow[700] : Colors.black,
                              semanticLabel: '즐겨찾기',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]
                )),
            ),
          ],
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
  }

  @override
  bool get wantKeepAlive => true;

  }
