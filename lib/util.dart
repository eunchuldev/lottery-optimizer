import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;

import 'dart:math';
final RNG = new Random();
final N = 45;
final K = 6;

List<int> generateRandomCombination(int n, int r) {
    List perm = new List<int>.generate(n, (i) => i+1);
    perm.shuffle();
    perm = perm.sublist(0, r);
    perm.sort();
    return perm;
}
Future<String> loadOptimizedTicketsString(int count) async => 
    await rootBundle.loadString('assets/optimized_tickets/' + count.toString() + '.txt');



List<List<int>> generateRandomTickets(int count) => 
    new List.generate(count, (_) => generateRandomCombination(N, K));

Future<List<List<int>>> generateOptimizedTickets(int count) async {
    List perm = new List<int>.generate(count, (i) => i+1);
    perm.shuffle();
    List tickets = (await loadOptimizedTicketsString(count)).trim().split("\n").map((line)=>line.trim().split(" ").map(int.parse).toList()).toList();
    for(int i=0; i<N; ++i) {
        for(int j=0; j<K; ++j) 
            tickets[i][j] = perm[tickets[i][j]];
        tickets[i].sort();
    }
    return tickets;
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

List<int> coverage(int r, List<List<int>> tickets) {
    final nCr = combinations(N, r);
    if(r <= 3){
        final covered = new List<int>.filled(pow(N, r), 0);
        for(int i=0; i<tickets.length; ++i)
            for(int j=0; j<covered.length; ++j){
                int key=0;
                for(int k=0; k<nCr.length; ++k)
                    key = key*N + tickets[i][covered[j]]; 
                covered[key] += 1;
            }
        var coverd_count = 0;
    }
}

Future<int> coverageN_6(int r, List<List<int>> tickets) async {
    final nCr = combinations(6, r);
    final covered = new List<int>.filled(pow(N, 3), 0);
    int i,j,k,l,m,n, x,y, key;
    for(i=0; i<tickets.length; ++i)
        for(j=0; j<covered.length; ++j){
            int key=0;
            for(x=0; x<nCr.length; ++x){
                key=0;
                for(y=0; y<nCr[x].length; ++y)
                    key = key*N + tickets[i][nCr[x][y]]; 
                covered[key] += 1;
            }
        }
    var covered_count = 0;
    for(i=0; i<N-K+1; ++i)
        for(j=0; j<N-K+2; ++j){
            await Future.delayed(const Duration(microseconds: 1), () => "");
            for(k=0; k<N-K+3; ++k)
                for(l=0; l<N-K+4; ++l)
                    for(m=0; m<N-K+5; ++m)
                        for(n=0; n<N-K+6; ++n)
                            for(x=0; x<nCr.length; ++x){
                                key = 0;
                                for(y=0; y<nCr[x].length; ++y)
                                    key = key*N + [i,j,k,l,m,n][nCr[x][y]];
                                if(covered[key] > 0){
                                    covered_count += 1;
                                    break;
                                }
                            }
    }
    return covered_count;
}
