import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

final DynamicLibrary dylib = DynamicLibrary.open('libverify.so');
final int Function(Pointer<Int32> tickets, int ticketNum) coverage5thPrizeC = 
  dylib
    .lookup<NativeFunction<Int32 Function(Pointer<Int32>, Int32)>>('coverage5thPrize')
    .asFunction();
int coverage5thPrizeD(List<List<int>> tickets) {
  //Int32Pointer p = Int32Pointer.asTypedList(tickets.length*6);
  //Pointer<Int32> p = Pointer<Int32>.asTypedList(tickets.length*6);//allocate<Int32>(tickets.length*6);
  Pointer<Int32> p = allocate<Int32>(count:tickets.length*6);
  for(int i=0; i<tickets.length; ++i) 
    for(int j=0; j<6; ++j) 
      p[i*6 + j] = tickets[i][j];
  return coverage5thPrizeC(p, tickets.length);
}
