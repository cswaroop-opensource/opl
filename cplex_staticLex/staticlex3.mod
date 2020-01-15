// --------------------------------------------------------------------------
// Licensed Materials - Property of IBM
//
// 5725-A06 5725-A29 5724-Y48 5724-Y49 5724-Y54 5724-Y55
// Copyright IBM Corporation 1998, 2013. All Rights Reserved.
//
// Note to U.S. Government Users Restricted Rights:
// Use, duplication or disclosure restricted by GSA ADP Schedule
// Contract with IBM Corp.
// --------------------------------------------------------------------------

/****************************************************************** 
 * This example demonstrates how to use the CPLEX multi objective (lexicographic objectives) with OPL.
 * It is using a dummy model derived from the Life Game from Robert Bosch and Michael Trick, CP 2001, CPAIOR 2002.
 * Original model IP2 available at http://mat.gsia.cmu.edu/Life/
 * Basic integer program with birth constraints
 *
 * This model is greater than the size allowed in trial mode. 
 * You therefore need a commercial edition of CPLEX Studio to run this example. 
 * If you are a student or teacher, you can also get a full version through
 * the IBM Academic Initiative.
 *
 ******************************************************************/

//using CP;
int n=9;
int Half=n div 2;
range FirstHalf = 1..Half;
range LastHalf = n-Half+1..n; 
range States = 0..1;
range Bord = 0..(n+1);
range Interior = 1..n;

range obj = 0..(n*n);

tuple neighbors {
   int row;
   int col;
}

range Bord1 = 0..3;
int times[i in Bord1] = 5+i;
float gaps[i in Bord1] = 0.01;

execute{
cplex.lex_TimeLimits = times;
cplex.lex_GapLimits = gaps;
}

{neighbors} Neighbor = 
  {<(-1),(-1)>,<(-1),0>,<(-1),1>,<0,(-1)>,<0,1>,<1,(-1)>,<1,0>,<1,1>};

dvar int Life[Bord][Bord] in States;

dexpr float kpis[i in Bord1] = sum(i1 in Bord, j1 in Bord : i1 != i)Life[i1][j1];
dvar int Obj in obj;

float weigths[i in Bord1] = i+1;
float abstol[i in Bord1] = 0.0001;
float reltol[i in Bord1] = 0.0001;
int priorities[i in Bord1] = i;
maximize staticLexFull(kpis, weigths, priorities, abstol, reltol);

subject to {
    Obj == sum( i , j in Bord ) Life[i][j];
     
  forall( i , j in Interior ) {
  2*Life[i][j] - sum( nb in Neighbor ) Life[i+nb.row][j+nb.col] <= 0;
    3*Life[i][j] + sum( nb in Neighbor ) Life[i+nb.row][j+nb.col] <= 6;
    forall( ordered n1 , n2 , n3 in Neighbor ) {
        -Life[i][j]+Life[i+n1.row][j+n1.col]+Life[i+n2.row][j+n2.col]+Life[i+n3.row][j+n3.col]-sum( nb in Neighbor : nb!=n1 && nb!=n2 && nb!=n3 )  Life[i+nb.row][j+nb.col] <= 2;
    }
  }
  forall( j in Bord ) {
      Life[0][j] == 0;
      Life[j][0] == 0;
      Life[j][n+1] == 0;
      Life[n+1][j] == 0;
  }
  forall( i in Bord : i<n ) {
      Life[i][1]+Life[i+1][1]+Life[i+2][1] <= 2;
      Life[1][i]+Life[1][i+1]+Life[1][i+2] <= 2;
      Life[i][n]+Life[i+1][n]+Life[i+2][n] <= 2;
      Life[n][i]+Life[n][i+1]+Life[n][i+2] <= 2;
  }
    sum( i in FirstHalf , j in Bord ) Life[i][j] >= 
    sum( i in LastHalf , j in Bord ) Life[i][j];
    sum( i in Bord , j in FirstHalf ) Life[i][j] >= 
    sum( i in Bord , j in LastHalf ) Life[i][j];   
}


execute SCRIPT {
var multi = cplex.getMultiObjNsolves();
writeln("cplex.getMultiObjNsolves " + multi);
for (var i = 0; i < multi; i++) {
   writeln(i + " MultiObjTime " + cplex.getMultiObjInfo("MultiObjTime", i));
   writeln(i + " MultiObjObjValue " + cplex.getMultiObjInfo("MultiObjObjValue", i));
   writeln(i + " MultiObjBestObjValue " + cplex.getMultiObjInfo("MultiObjBestObjValue", i));
   writeln(i + " MultiObjPriority " + cplex.getMultiObjInfo("MultiObjPriority", i));
   writeln("\n");
 }     
} 


execute{
for (var j in Bord1) writeln(kpis[j]);
}