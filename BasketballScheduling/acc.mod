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




tuple p
{
   int v[1..nbRounds];
}

{p} patterns=...;
int nbPatterns=card(patterns);
range rngPatterns= 0..nbPatterns-1;

execute{
	cp.param.Workers = 1;
}


range rngTeams= 1..nbTeams;

PairRound mirror[1..nbPairs] = ...;
int rival[1..nbTeams] = [ 4, 6, 0, 1, 8, 2, 9, 5, 7];
assert forall (i in 1..nbTeams: i != 3) rival[rival[i]] == i;

tuple SpecialPairs {
   int  pfirst;
   int  psecond;
};
{SpecialPairs} special = { <6,9>, <2,9>, <4,6>, <2,4> };
{int} round1 = {1,3,4,9};
{int} round18 = {1,2,5,9};

int patternst[i in rngRounds, j in rngPatterns] = item(patterns,j).v[i];

tuple ps
{
   int v[0..nbTeams];
}

{ps} patset=...;
int nbPatset = card(patset)-1;
range rngPatset= 0..nbPatset;



int patsetc[i in rngPatset,j in 1..nbTeams] = item(patset,i).v[j];

range  Gametype=0..2;  

int mtA=0;
int mtB=1;
int mt0=2;

int weekday[1..nbTeams,1..nbTeams] = ...;
int weekend[1..nbTeams,1..nbTeams] = ...;


dvar int alpha[1..nbTeams,1..nbRounds] in 0..nbTeams;
dvar int alpha_nonz[1..nbTeams,1..nbRounds] in 1..nbTeams;
dvar int beta[1..nbTeams,1..nbRounds] in Where;
dvar int gamma[1..nbTeams] in 1..nbTeams;

dvar  int whichps in rngPatset;
dvar  int psrows[1..nbTeams] in rngPatterns;

dvar int roundtype[11..nbRounds] in Gametype;
dvar int Acount[11..nbRounds] in 0..4;
dvar int Bcount[11..nbRounds] in 0..4;

dvar int obj in 0..8;

maximize obj;
subject to {

   forall (t in 1..nbTeams) {
      psrows[t] == patsetc[whichps,gamma[t]];
   };
   forall(r in 1..nbRounds, t in 0..nbTeams) {
      sum (j in 1..nbTeams) (alpha[j,r] == t) <= 1;
   };
   forall (r in rngRounds, t1 in 1..nbTeams, t2 in 1..nbTeams) {
      (alpha[t1,r] == t2) == (alpha[t2,r] == t1);
   };
   forall (r in rngRounds, t in 1..nbTeams) {
      (alpha[t,r] == 0) == (beta[t,r] == bbye);
   };

   forall (r in rngRounds, t1 in 1..nbTeams, t2 in 1..nbTeams) {
      (alpha[t1,r] == t2) => 
          (((beta[t1,r]==home) && (beta[t2,r]==away)) ||
           ((beta[t1,r] == away) && (beta[t2,r] == home)));
   };


   forall(t1 in 1..nbTeams, t2 in 0..nbTeams : t1!=t2) {
      sum (r in 1..nbRounds) (alpha[t1,r] == t2) == 2;
   };

   forall(i in 1..nbPairs, t in 1..nbTeams) {
      alpha[t,mirror[i].pfirst] == alpha[t,mirror[i].plast];
   };

   forall(r in rngRounds, t in 1..nbTeams) {
      beta[t,r] == patternst[r,psrows[t]];
   };

   forall (t in 1..nbTeams : t != 3) {
      alpha[t,18] == rival[t] || (alpha[t,18] == 0) || (alpha[t,18] == 3);
   };
   forall (<t1,t2> in special) {
      sum (r in 11..nbRounds) ( alpha[t1,r] == t2 ) >= 1;
   };

   forall (r in 1..nbRounds-1, t in rngTeams) !(
      (beta[t,r] == away) && (beta[t,r+1] == away) &&
   ((alpha[t,r] == 2) || (alpha[t,r] == 6)) &&
      ((alpha[t,r+1] == 2) || (alpha[t,r+1] == 6)) );

   forall (r in 1..nbRounds-2, t in rngTeams) !(
      ((alpha[t,r] == 2) || (alpha[t,r] == 6) || (alpha[t,r] == 9)) &&
      ((alpha[t,r+1] == 2) || (alpha[t,r+1] == 6) || (alpha[t,r+1] == 9)) &&
      ((alpha[t,r+2] == 2) || (alpha[t,r+2] == 6) || (alpha[t,r+2] == 9)));

   alpha[2,11] == 6;
   alpha[2,18] == 6;
   alpha[1,2] == 6;
   beta[2,16] == bbye;
   beta[9,17] != home;
   beta[9,1] == bbye;
   beta[3,18] != bbye;
   beta[7,18] != bbye;
   beta[6,1] != bbye;
   forall (t in round1) {
     beta[t,1] != away;
   };
   forall (t in round18) {
     beta[t,18] != away;
   };

   forall (t in 1..nbTeams, r in 1..nbRounds) {
      (alpha[t,r] > 0) => (alpha_nonz[t,r] == alpha[t,r]);
      (alpha[t,r] == 0) => (alpha_nonz[t,r] == t);
   };


   forall (j in 11..nbRounds : j % 2 == 1 ) {
      Acount[j] == (sum (t in 1..nbTeams) (
         (beta[t,j] == home) && (weekday[t,alpha_nonz[t,j]] == mtA)));
      Bcount[j] == sum (t in 1..nbTeams) (
         (beta[t,j] == home) && (weekday[t,alpha_nonz[t,j]] == mtB)); 
   };
   forall (j in 11..nbRounds: j % 2 == 0) {
      Acount[j] == sum (t in 1..nbTeams) (
        (beta[t,j] == home) && (weekend[t,alpha_nonz[t,j]] == mtA));
      Bcount[j] == sum (t in 1..nbTeams) (
         (beta[t,j] == home) && (weekend[t,alpha_nonz[t,j]] == mtB));
   };
   forall (j in 11..nbRounds) {
      ((Acount[j] >= 1) || (Bcount[j] == 2)) => roundtype[j] == mtA;
      ((Acount[j] == 0) && (Bcount[j] == 1)) => roundtype[j] == mtB;
      ((Acount[j] == 0) && (Bcount[j] == 0)) => roundtype[j] == mt0;
   }; 
   obj == sum (r in 11..nbRounds) (roundtype[r] == mtA) -
         2*( sum (r in 11..nbRounds) (roundtype[r] == mt0));


};

int res[j in 1..nbTeams,k in 1..nbRounds]=
(beta[j,k]==home)?(alpha[j][k]):
((beta[j,k]==away)?(-alpha[j][k]):0);

execute
{
 writeln(res);  
}
   
