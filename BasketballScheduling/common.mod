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

tuple PairRound {
   int pfirst;
   int plast;
};
int nbRounds = 18;
range rngRounds=1..nbRounds;
int nbPairs = nbRounds div 2;
int nbTeams = 9;


range Where=0..2;
int home=0;
int away=1;
int bbye=2;



