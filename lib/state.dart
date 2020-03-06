import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:math';


class AppState extends Model {
  List<TicketSet> _favorites = [];
  void favorite(TicketSet ticketSet) {
    _favorites.insert(0, ticketSet);
    print(_favorites);
    notifyListeners();
    _save();
  }
  void unfavoriteLast() {
    _favorites.removeAt(0);
    notifyListeners();
    _save();
  }
  List<TicketSet> get favorites {
    return List.from(_favorites);
  }
  _load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var json_data = json.decode(prefs.getString("flutter.lottery_optimizer_app_state"));
    _favorites = json_data['favorites']?.map((ticket_json) => 
      TicketSet.fromJson(ticket_json))?.toList() ?? [];
  }
  _save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("flutter.lottery_optimizer_app_state", json.encode(toJson()));
  }
  Map<String, dynamic> toJson() => {
    'favorites': favorites.map((ticketSet)=>ticketSet.toJson()).toList(),
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
  DateTime _createdAt = DateTime.now();

  List<List<int>> get tickets => _tickets;
  int get coverage5thPrize => _coverage5thPrize;
  int get coverage4thPrize => _coverage4thPrize;
  DateTime get createdAt => _createdAt;
  TicketSet(this._tickets);
  TicketSet.empty();

  Map<String, dynamic> toJson() => {
    'tickets': _tickets,
    'coverage5thPrize': _coverage5thPrize,
    'coverage4thPrize': _coverage4thPrize,
    'createdAt': _createdAt.toIso8601String(),
  };
  TicketSet.fromJson(Map<String, dynamic> json)
    : _tickets = json['tickets'],
      _coverage5thPrize = json['coverage5thPrize'],
      _coverage4thPrize = json['coverage4thPrize'],
      _createdAt = DateTime.parse(json['createdAt']);

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
          .toList())
      .toList();
    for(int i=0; i<count; ++i) {
        for(int j=0; j<K; ++j) 
            tickets[i][j] = perm[tickets[i][j]-1]+1;
        tickets[i].sort();
    }
    return TicketSet(tickets);
  }
  Future<int> calculateCoverage() async {
    _coverage4thPrize = await compute(coverageN_6_4,  _tickets);
    _coverage5thPrize = await compute(coverageN_6_3,  _tickets);
    return _coverage5thPrize;
  }
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

int coverageN_6_4(List<List<int>> tickets) {
  final nCr = combinations(6, 4);
  final covered = <int, int>{};
  int n, a,b,c,d,e,f, x,y,key,covered_count=0;
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
            key = key*(N+1) + (temp[y]-1);
          if(!covered.containsKey(key)){
            covered_count += 1;
            covered[key] = 1;
          }
        }
    }
  }
  return covered_count;
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
    var covered_count = 0;
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
                                    covered_count += 1;
                                    break;
                                }
                            }
                          }
      }
    }
    return covered_count;
}
