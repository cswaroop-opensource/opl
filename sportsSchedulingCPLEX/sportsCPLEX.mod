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
using CPLEX;

/// -- DATA ---
///
/// The number of teams in a division.
int nbTeamsInDivision = ...;
execute{
  writeln("We will use " + nbTeamsInDivision + " teams from each of the divisions.")
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

/// All possible matches (pairings) and whether of not each is intradivisional.
tuple Match {
  int team1;
  int team2;
  int isDivisional;
};
{Match} Matches = {<t1,t2, 
                     (( t2 <= nbTeamsInDivision || t1 > nbTeamsInDivision) ? 1 : 0)>
                   | t1,t2 in Teams : t1 < t2};


/// Number of games to play between pairs depends on 
/// whether the pairing is intradivisional or not.
int nbPlay[m in Matches] = m.isDivisional==1 ? nbIntraDivisional : nbInterDivisional;

// Boolean decision variables : 1 if match m is played in week w, 0 otherwise.
dvar boolean plays[Matches][Weeks];

///
/// Map unique team id to team name for formatted solution. 
tuple teamMapping{
  key int id;
  string name; 
};
{teamMapping} teamLeague = {<t, item(teamDiv1,t)> | t in 1..nbTeamsInDivision} union 
                           {<t+nbTeamsInDivision, item(teamDiv2,t)> 
                             | t in 1..nbTeamsInDivision};

/// The goal is for intradivisional games to be played late in the schedule.
/// Only intradivisional pairings contribute to the overall gain.
int Gain[w in Weeks] = w * w;

// If an intradivisional pair plays in week w, Gain[w] is added to the objective.
maximize sum (m in Matches, w in Weeks) m.isDivisional * Gain[w] * plays[m][w];

subject to {

  // Each pair of teams must play the correct number of games.	
  forall (m in Matches)
	correctNumberOfGames:
	sum(w in Weeks) plays[m][w] == nbPlay[m];

  // Each team must play exactly once in a week.	 
  forall (w in Weeks, t in Teams)
    playsExactlyOnce:
    sum(m in Matches : (m.team1 == t || m.team2 == t)) plays[m][w] == 1;

  // Games between the same teams cannot be on successive weeks.
  forall (w in Weeks, m in Matches) 
    cannotPlayAgain:
    if ( w < nbWeeks ) plays[m][w] + plays[m][w+1] <= 1;

  // Some intradivisional games should be in the first half.    
  forall (t in Teams)
    inDivisionFirstHalf:
    sum(w in FirstHalfWeeks, m in Matches : (((m.team1 == t || m.team2 == t) 
                                             && m.isDivisional == 1 )))
              plays[m][w] >= nbFirstHalfGames;
}

/// Postprocess to output a formatted solution.
tuple Solution {
  int    week;
  int    isDivisional;
  string team1;
  string team2;
};
sorted {Solution} solution = {<w, m.isDivisional, 
                               item(teamLeague, <m.team1>).name, 
                               item(teamLeague, <m.team2>).name>
                              | m in Matches, w in Weeks : plays[m][w] == 1};

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
