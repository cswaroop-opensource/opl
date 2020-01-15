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

using CP;

include "common.mod";


PairRound mirror[1..nbPairs] = ...;

execute{
	cp.param.Workers = 1;
}

dvar int pattern[1..nbRounds] in Where;

tuple p
{
   int v[1..nbRounds];
}

{p} patterns;

subject to
 {
   forall (i in 1..nbPairs) 
      (pattern[mirror[i].pfirst] == home) && (pattern[mirror[i].plast] == away) ||
      (pattern[mirror[i].pfirst] == away) && (pattern[mirror[i].plast] == home) ||
      (pattern[mirror[i].pfirst] == bbye) && (pattern[mirror[i].plast] == bbye);
   
   sum (i in 1..nbRounds) (pattern[i] == home) == nbTeams - 1;
   sum (i in 1..nbRounds) (pattern[i] == away) == nbTeams - 1;
   sum (i in 1..nbRounds) (pattern[i] == bbye) == 2*(nbTeams % 2);
   pattern[nbRounds-1] == away => pattern[nbRounds] != away;
   forall (i in 1..nbRounds-2) 
      sum (j in i .. i+2) (pattern[j] == away) <= 2;
   forall (i in 1..nbRounds-2) 
      sum (j in i..i+2) (pattern[j] == home) <= 2;
   
   forall (i in 1..nbRounds-3) {
      sum (j in i..i+3) ((pattern[j] == away) || (pattern[j] == bbye)) <= 3;
   };
   forall (i in 1..nbRounds-4) {
      sum (j in i..i+4) ((pattern[j] == home) || (pattern[j] == bbye)) <= 4;
   };
   forall (i in 1..nbRounds-4 : i % 2 == 0) {
      sum (j in i..i+4 : j % 2 == 0) (pattern[j] == away) <= 2;
//      sum (j in i..i+4 : j % 2 == 0) (pattern[j] == home) <= 2;  /* Nemhauser Trick did not enforce this */
   };
   forall (i in 1..nbRounds-6 : i % 2 == 0) {
      sum (j in i..i+6 : j % 2 == 0) ((pattern[j] == away) || (pattern[j] == bbye)) <= 3;
   };
   forall (i in 1..nbRounds-6 : i % 2 == 0) {
      sum (j in i..i+6 : j % 2 == 0) ((pattern[j] == home) || (pattern[j] == bbye)) <= 3;
   };
   sum (j in 1..nbRounds : j % 2 == 0 ) (pattern[j] == home) == nbTeams div 2;
   sum (j in 1..nbRounds : j % 2 == 0 ) (pattern[j] == away) == nbTeams div 2;
   sum (j in 1..nbRounds : j % 2 == 0 ) (pattern[j] == bbye) == /*nbTeams % 2*/1;
   sum (j in 1..10 : j % 2 == 0 ) (( pattern[j] == home ) || ( pattern[j] == bbye )) >= 2;
    pattern[1] == bbye => pattern[nbRounds] == home;
   pattern[1] == bbye => pattern[nbRounds-1] == away;
   pattern[16] == bbye => pattern[nbRounds] == home;
/* Nemhauser/Trick did enforce the following */
   sum (i in 1..3) (pattern[i] == home) >= 1;
   sum (i in 16..18) (pattern[i] == home) >= 1;
};

execute
{
   patterns.add(pattern.solutionValue);
 writeln(pattern);  
}


main
{
   var  n=0;
   thisOplModel.generate();
   cp.startNewSearch();
   while (cp.next()) { 
     n++;
     writeln("solution ",n);  
     thisOplModel.postProcess();
      
   }
   
 writeln(thisOplModel.patterns);

}



   
