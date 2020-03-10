#include<stdio.h>
const int N=45;
const int K=6;

extern int coverage5thPrize(int tickets[], int ticket_num) {
  int i,x,y,z,j;
  int t[6];
  char covered[43][44][45] = { 0 };
  int covered_count = 0;
  for(i=0; i<ticket_num; ++i)
    for(x=0; x<4; ++x)
      for(y=x+1; y<5; ++y)
        for(z=y+1; z<6; ++z)
          covered[tickets[i*6 + x]-1][tickets[i*6 + y]-1][tickets[i*6 + z]-1] += 1;
  for(t[0]=1; t[0]<=N-K+1; ++t[0]){
    for(t[1]=t[0]+1; t[1]<=N-K+2; ++t[1]){
      for(t[2]=t[1]+1; t[2]<=N-K+3; ++t[2]){
        for(t[3]=t[2]+1; t[3]<=N-K+4; ++t[3]){
          for(t[4]=t[3]+1; t[4]<=N-K+5; ++t[4]){
            for(t[5]=t[4]+1; t[5]<=N-K+6; ++t[5]){
              for(x=0; x<4; ++x)
                for(y=x+1; y<5; ++y)
                  for(z=y+1; z<6; ++z){
                    if(covered[t[x]-1][t[y]-1][t[z]-1] > 0){
                      if(z==5){
                        covered_count += 1;
                        goto combination_loop_end;
                      }
                      else if(z == 4){
                        covered_count += N-K+6 - t[5]+1;
                        goto end1;
                      }
                      else if(z == 3){
                        covered_count += N-K+6 - t[5]+1;
                        covered_count += (N-K+6 - t[4] - 1)*(N-K+6 - t[4])/2;
                        goto end2;
                      }
                      else if(z == 2){
                        covered_count += N-K+6 - t[5]+1;
                        covered_count += (N-K+6 - t[4] - 1)*(N-K+6 - t[4])/2;
                        for(t[3]+=1; t[3]<=N-K+4; ++t[3])
                          covered_count += (N-K+6 - (t[3]+1) + 1)*(N-K+6 - (t[3]+1))/2;
                        goto end3;
                      }
                      else{
                        covered_count += 1;
                        goto combination_loop_end;
                      }
                    }
                  }
              combination_loop_end:;
            }
            end1:;
          }
          end2:;
        }
        end3:;
      }
      end4:;
    }
    end5:;
  }
  return covered_count;
}



int main() {
  int tickets[1][6] = { {1,2,3,4,5,6} };
  printf("%d\n", coverage5thPrize(tickets, 1));
}
