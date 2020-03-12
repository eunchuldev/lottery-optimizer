import 'package:lottery_optimizer/LotteryBall.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:math';
import 'native.dart';

class AppState extends Model {
  List<TicketSet> _favorites = [];
  bool isFavorite;
  void favorite(TicketSet ticketSet) {
    _favorites.insert(0, ticketSet);
    isFavorite = true;
    notifyListeners();
    _save();
  }
  void unfavorite(int index){
    _favorites.removeAt(index);
    if(index == 0)
      isFavorite = false;
    notifyListeners();
    _save();
  }
  void unfavoriteLast() {
    _favorites.removeAt(0);
    isFavorite = false;
    notifyListeners();
    _save();
  }
  void winningNumberUpdated(){
    notifyListeners();
    _save();
  }
  void coverageUpdated() {
    notifyListeners();
  }
  void prizeUpdated(){
    notifyListeners();
  }
  List<TicketSet> get favorites {
    return List.from(_favorites);
  }
  List<LotterySet> get winningNumbers{
    return List.from(LotteryNumberLoader.list);
  }
  _load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var jsonData = json.decode(prefs.getString("flutter.lottery_optimizer_app_state"));
    _favorites = jsonData['favorites']?.map((ticketJson) =>
      TicketSet.fromJson(ticketJson))?.toList()?.cast<TicketSet>() ?? [];
    LotteryNumberLoader.list = jsonData['winnings']?.map((winningJson)=>
      LotterySet.fromJson(winningJson))?.toList()?.cast<LotterySet>()??[];
    LotteryNumberLoader.from = jsonData['winningsFrom'];
    LotteryNumberLoader.round = jsonData['winningsTo'];
  }
  _save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("flutter.lottery_optimizer_app_state", json.encode(toJson()));
  }
  Map<String, dynamic> toJson() => {
    'favorites': favorites.map((ticketSet)=>ticketSet.toJson()).toList(),
    'winnings' : winningNumbers.map((lotterySet) =>lotterySet?.toJson()).toList(),
    'winningsFrom':LotteryNumberLoader.from,
    'winningsTo':LotteryNumberLoader.round
  };
  AppState() {
    _load();
  }
}

final N = 45;
final K = 6;

class TicketSet {
  List<List<int>> _tickets;
  int _coverage5thPrize;
  int _coverage4thPrize;
  int _coverage3thPrize;
  int _coverage2thPrize;
  int _coverage1thPrize;
  DateTime _createdAt = DateTime.now();
  int _prize = 0;

  List<List<int>> get tickets => _tickets;
  int get coverage5thPrize => _coverage5thPrize;
  int get coverage4thPrize => _coverage4thPrize;
  int get coverage3thPrize => _coverage3thPrize;
  int get coverage2thPrize => _coverage2thPrize;
  int get coverage1thPrize => _coverage1thPrize;
  DateTime get createdAt => _createdAt;
  int get prize => _prize;
  TicketSet(this._tickets);
  TicketSet.empty();

  Map<String, dynamic> toJson() => {
    'tickets': _tickets,
    'coverage5thPrize': _coverage5thPrize,
    'coverage4thPrize': _coverage4thPrize,
    'coverage3thPrize': _coverage3thPrize,
    'coverage2thPrize': _coverage2thPrize,
    'coverage1thPrize': _coverage1thPrize,
    'createdAt': _createdAt.toIso8601String(),
    'prize':_prize
  };
  TicketSet.fromJson(Map<String, dynamic> json)
    : _tickets = json['tickets'].map((ticket) => ticket.cast<int>()).toList().cast<List<int>>(),
      _coverage5thPrize = json['coverage5thPrize'],
      _coverage4thPrize = json['coverage4thPrize'],
      _coverage3thPrize = json['coverage3thPrize'],
      _coverage2thPrize = json['coverage2thPrize'],
      _coverage1thPrize = json['coverage1thPrize'],
      _createdAt = DateTime.parse(json['createdAt']),
      _prize = json['prize'];

  static TicketSet random(int count) {
    List<List<int>> tickets = List.generate(count, (_) {
      List<int> perm = List<int>.generate(N, (i) => i+1);
      perm.shuffle();
      perm = perm.sublist(0, K);
      perm.sort();
      return perm;
    });
    return TicketSet(tickets);
  }
  static Future<TicketSet> optimized(int count) async {
    List<int> perm = List<int>.generate(N, (i) => i);
    perm.shuffle();
    List<List<int>> tickets = (await rootBundle.loadString('assets/optimized_tickets/' + count.toString() + '.txt'))
      .trim()
      .split("\n")
      .map((line)=>
        line
          .trim()
          .split(" ")
          .map(int.parse)
          .toList().cast<int>())
      .toList();
    for(int i=0; i<count; ++i) {
        for(int j=0; j<K; ++j) 
            tickets[i][j] = perm[tickets[i][j]-1]+1;
        tickets[i].sort();
    }
    return TicketSet(tickets);
  }
  Future<int> calculateCoverage() async {
    _coverage1thPrize = await compute(coverageN_6_6, _tickets);
    _coverage3thPrize = await compute(coverageN_6_5,  _tickets);
    _coverage2thPrize = _coverage3thPrize;
    _coverage4thPrize = await compute(coverageN_6_4,  _tickets);
    _coverage5thPrize = await compute(coverage5thPrizeD,  _tickets);
    calculatePrize();
    return _coverage5thPrize;
  }
  void calculatePrize() async{
    _prize = getPrize(this);
  }
}

int getPrize(TicketSet tickets){
  DateTime createdAt = tickets.createdAt;

  int last = LotteryNumberLoader.round;
  int to = LotteryNumberLoader.getLastRound(createdAt);
  if(to > last){
    return 0;
  }

  LotterySet set = LotteryNumberLoader.list[to];
  if(set == null)
    return 0;

  int maxPrize = 6;
  for(List<int> list in tickets.tickets){
    int sames = 0;
    for(int i in list){
      if(set.numbers.contains(i))
        sames++;
    }
    int prize = 6;
    if(sames < 3)
      prize = 6;
    else if(sames==3)
      prize = 5;
    else if(sames==4)
      prize = 4;
    else if(sames==5)
      prize = 3;
    else if(sames==5 && list.contains(set.bonus))
      prize = 2;
    else if(sames == 6)
      prize = 1;
    if(maxPrize > prize)
      maxPrize = prize;
  }
  return maxPrize;
}

List<List<int>> combinations(int n, int r, {int i=0, int t=0, List<List<int>> res, List<int> ticket}) {
    if(t==0) {
        res = [];
        ticket = new List<int>(r);
    }
    if(t==r) {
        res.add(new List<int>.from(ticket));
        return res;
    }
    for(; i<n-r+t+1; ++i) {
        ticket[t] = i;
        combinations(n, r, i:i+1, t:t+1, res:res, ticket:ticket);
    }
    return res;
}

int coverageN_6_6(List<List<int>> tickets) {
  final covered = <int, int>{};
  int n, y, key, coveredCount = 0;
  for(n=0; n<tickets.length; ++n){
    key = 0;
    for(y=0; y<6; ++y)
      key = key*(N+1) + (tickets[n][y]-1);
    if(!covered.containsKey(key)){
      coveredCount += 1;
      covered[key] = 1;
    }
  }
  return coveredCount;
}
int coverageN_6_4(List<List<int>> tickets) {
  final nCr = combinations(6, 4);
  final covered = <int, int>{};
  int n, a,b,c,d,e,f, x,y,key,coveredCount=0;
  List<int> ticket;
  List<int> temp = [0,0,0,0,0,0];
  for(n=0; n<tickets.length; ++n){
    ticket = tickets[n];
    for(x=0; x<nCr.length; ++x){
      a = ticket[nCr[x][0]]; b = ticket[nCr[x][1]]; c = ticket[nCr[x][2]]; d = ticket[nCr[x][3]];
      for(e=1; e<=N; ++e)
        for(f=e+1; f<=45; ++f){
          if(e == a || e == b || e == c || e == d ||
            f == a || f == b || f == c || f == d)
            continue;
          temp[0] = a; temp[1] = b; temp[2] = c; temp[3] = d;
          temp[4] = e; temp[5] = f;
          temp.sort();
          key=0;
          for(y=0; y<6; ++y)
            key = key*N + (temp[y]-1);
          if(!covered.containsKey(key)){
            coveredCount += 1;
            covered[key] = 1;
          }
        }
    }
  }
  return coveredCount;
}
int coverageN_6_5(List<List<int>> tickets) {
  final nCr = combinations(6, 5);
  final covered = <int, int>{};
  int n, a,b,c,d,e,f, x,y,key,coveredCount=0;
  List<int> ticket;
  List<int> temp = [0,0,0,0,0,0];
  for(n=0; n<tickets.length; ++n){
    ticket = tickets[n];
    for(x=0; x<nCr.length; ++x){
      a = ticket[nCr[x][0]]; b = ticket[nCr[x][1]]; c = ticket[nCr[x][2]]; d = ticket[nCr[x][3]]; e = ticket[nCr[x][4]];
      for(f=1; f<=45; ++f){
        if(f == a || f == b || f == c || f == d || f == e)
          continue;
          temp[0] = a; temp[1] = b; temp[2] = c; temp[3] = d;
          temp[4] = e; temp[5] = f;
          temp.sort();
          key=0;
          for(y=0; y<6; ++y)
            key = key*(N+1) + (temp[y]-1);
          if(!covered.containsKey(key)){
            coveredCount += 1;
            covered[key] = 1;
          }
        }
    }
  }
  return coveredCount;
}

int coverageN_6_3(List<List<int>> tickets) {
    final nCr = combinations(6, 3);
    var covered = new List<int>.filled(pow(N, 3), 0);
    int i,j,k,l,m,n, x,y, key; 
    List<int> ticket = [0,0,0,0,0,0];
    for(i=0; i<tickets.length; ++i)
        for(x=0; x<nCr.length; ++x){
            key=0;
            for(y=0; y<nCr[x].length; ++y)
                key = key*N + (tickets[i][nCr[x][y]]-1); 
            covered[key] += 1;
        }
    var coveredCount = 0;
    for(i=1; i<=N-K+1; ++i){
        for(j=i+1; j<=N-K+2; ++j){
            for(k=j+1; k<=N-K+3; ++k)
                for(l=k+1; l<=N-K+4; ++l)
                    for(m=l+1; m<=N-K+5; ++m)
                        for(n=m+1; n<=N-K+6; ++n){
                            ticket[0]=i;
                            ticket[1]=j;
                            ticket[2]=k;
                            ticket[3]=l;
                            ticket[4]=m;
                            ticket[5]=n;
                            for(x=0; x<nCr.length; ++x){
                                key = 0;
                                for(y=0; y<nCr[x].length; ++y)
                                    key = key*N + (ticket[nCr[x][y]]-1);
                                if(covered[key] > 0){
                                    coveredCount += 1;
                                    break;
                                }
                            }
                          }
      }
    }
    return coveredCount;
}
