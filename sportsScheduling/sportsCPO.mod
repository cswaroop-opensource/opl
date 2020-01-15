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

/// -- DATA ---
///
/// The number of teams in a division.
int nbTeamsInDivision = ...;
execute{
	cp.param.TimeLimit = 60;
  	writeln("Scheduling " + nbTeamsInDivision + " teams from each of the divisions.")
}

/// The number of games to play in and out of the division.
int nbIntraDivisional = ...;
int nbInterDivisional = ...;

int maxTeamsInDivision = ...;
assert nbTeamsInDivision <= maxTeamsInDivision; // Limited data

{string} teamDiv1 = ...;
{string} teamDiv2 = ...;

assert card(teamDiv1) >= nbTeamsInDivision;
assert card(teamDiv2) >= nbTeamsInDivision;
///
/// -- END DATA ---

/// There are two divisions.
int nbTeams = 2 * nbTeamsInDivision;
range Teams = 1..nbTeams;

/// Calculate the number of weeks necessary.
int nbWeeks = (nbTeamsInDivision-1) * nbIntraDivisional 
              + nbTeamsInDivision * nbInterDivisional;
range Weeks = 1..nbWeeks;
execute{
  writeln(nbWeeks + " games, " + (nbTeamsInDivision-1) * nbIntraDivisional + 
          " intradivisional, " + nbTeamsInDivision * nbInterDivisional + " interdivisional.")
}

/// Season is split into two halves.
range FirstHalfWeeks = 1..ftoi(floor(nbWeeks/2));
int nbFirstHalfGames = ftoi(floor(nbWeeks/3));

/// Game variables - value of plays[t][w] will be the team assigned to play team t in week w. 
dvar int plays[Teams][Weeks] in Teams;

/// Gain is for intradivisional pairings only.
int intraDivisionalPair[ t1 in Teams][t2 in Teams ] = 
  ( ((t2 <= nbTeamsInDivision) && (t1 <=nbTeamsInDivision)) || 
    ((t1 > nbTeamsInDivision) && (t2 > nbTeamsInDivision)) ) ? 1 : 0 ;

/// The goal is for intradivisional games to be played late in the schedule.
/// Only intradivisional pairings contribute to the overall gain.
int Gain[t1 in Teams][t2 in Teams][w in Weeks] = 
  ((intraDivisionalPair[t1][t2]==1) ? w*w : 0) ;

/// The objective is used to maximize the overall quality of solutions.
dexpr int DivisionalLateness =
  sum(t in Teams, w in Weeks) Gain[t][plays[t][w]][w];

///
/// Map unique team id to team name for formatted solution. 
tuple teamMapping{
  key int id;
  string name; 
};
{teamMapping} teamLeague = {<t, item(teamDiv1,t)> | t in 1..nbTeamsInDivision} union 
                           {<t+nbTeamsInDivision, item(teamDiv2,t)> 
                             | t in 1..nbTeamsInDivision};

maximize DivisionalLateness/2;

subject to { 
  forall (t in Teams, w in Weeks) {  	 
    // A team cannot play itself.
    cannotPlaySelf:
    plays[t][w] != t;
    // The plays function is symmetrical.
    symmetricalPairs:
    plays[plays[t][w]][w] == t; 
  }
  
  // Each week, each team is assigned to one game.
  forall (w in Weeks)
    playsExactlyOnce:
    allDifferent( all (t in Teams) plays[t][w] );
  
  // Each team plays the required number of (intra/inter) divisional matches.
  forall (t1 in Teams, t2 in Teams:  t1 < t2)
	correctNumberOfGames:
    count( all(w in Weeks) plays[t1][w], t2 ) == 
         (intraDivisionalPair[t1][t2] == 1 ? nbIntraDivisional : nbInterDivisional);
  
  // Games between the same teams cannot be on successive weeks.
  forall (w in Weeks, t in Teams) 
    cannotPlayAgain:
    if ( w < nbWeeks ) plays[t][w] != plays[t][w+1];
 
   // Some intradivisional games should be in the first half.
   forall (t1 in Teams)
    inDivisionFirstHalf:
    sum (t2 in Teams :  intraDivisionalPair[t1][t2] == 1)     
	  count (all(w in FirstHalfWeeks) plays[t1][w], t2 ) 
	>= nbFirstHalfGames;
}

/// Postprocess to output a formatted solution.
tuple Solution{
  int week;
  int isDivisional;
  string team1;
  string team2;
};
sorted {Solution} solution = {<w,
                               intraDivisionalPair[t][plays[t][w]],
                               item(teamLeague, <t>).name, 
                               item(teamLeague, <plays[t][w]>).name>  |
                              t in Teams, w in Weeks : t < plays[t][w]};

execute DEBUG {
  var week = 0;
  writeln("Intradivisional games are marked with a *");
  for (var s in solution) {
    if (s.week != week) {
      week = s.week;
      writeln("================================");
      writeln("On week " + week);
    }			
    if ( s.isDivisional ) {		
      writeln("	*" + s.team1 + " will meet the " + s.team2);
    }			    
    else {
      writeln("	 " + s.team1 + " will meet the " + s.team2)       	    
    }
  }
}
 
 