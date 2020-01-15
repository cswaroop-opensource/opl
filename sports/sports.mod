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

/* ------------------------------------------------------------

Problem Description
-------------------

The problem involves finding a schedule for a sports league. The league has 10 
teams that play games over a season of 18 weeks. Each team has a home arena and 
plays each other team twice during the season, once in its home arena and once in 
the opposing team's home arena. For each of these games, the team playing at its 
home arena is referred to as the home team; the team playing at the opponent's 
arena is called the away team. There are 90 games altogether.

Each of the 18 weeks in the season has five identical slots to which games can be 
assigned. Each team plays once a week. For each pair of teams, these two teams are 
opponents twice in a season; these two games must be scheduled in different halves 
of the season. Moreover, these two games must be scheduled at least six weeks 
apart. A team must play at home either the first or last week but not both.

A break is a sequence of consecutive weeks in which a team plays its games either 
all at home or all away. No team can have a break of three or more weeks in it. The
objective in this problem is to minimize the total number of breaks the teams play. 

------------------------------------------------------------ */

int n = 10;


assert(n%2 == 0);

int nbWeeks = 2 * (n - 1);
int nbGamesPerWeek = n div 2;
int nbGames = n * (n - 1);
float mid = nbWeeks / 2 + 1;
int overlap = (n>=6) ? minl(n div 2, 6) : 0;


dvar int games[1..nbWeeks][1..nbGamesPerWeek] in 1..nbGames;
dvar int home[1..nbWeeks][1..nbGamesPerWeek] in 1..n;
dvar int away[1..nbWeeks][1..nbGamesPerWeek] in 1..n;
dvar int weekOfGame[1..nbGames] in  1..nbWeeks;
dvar int allSlots[1..nbGames] in 1..nbGames;
dvar boolean playHome[1..n][1..nbWeeks];
dvar int allGames[1..nbGames] = all[1..nbGames](w in 1..nbWeeks, g in 1..nbGamesPerWeek) games[w][g];
dvar int teamBreaks[1..n] in 0..nbWeeks div 2;

//
// For each play slot, set up correspondence between game id,
// home team, and away team
tuple PlaySlotTuple {
   int home;
   int away;
   key int gameId;
};

{PlaySlotTuple} playSlots = {<h, a, (h-1) * (n-1) + a - (a > h)> | h, a in 1..n : a != h};


execute {
    var f = cp.factory;
    var phase = f.searchPhase(allGames, 
                              f.selectSmallest(f.varIndex(allGames)), 
                              f.selectRandomValue());
    cp.setSearchPhases(phase);
    cp.param.timeLimit=60;
    cp.param.logPeriod=10000;
    cp.param.DefaultInferenceLevel="Extended";
}


//
// Objective: minimize the number of `breaks'.  A break is
//            two consecutive home or away matches for a
//            particular team
dexpr int breakCount = sum(t in 1..n) teamBreaks[t];


minimize breakCount;
// minimize sum(t in 1..n) teamBreaks[t];
subject to {

   forall(w in 1..nbWeeks, g in 1..nbGamesPerWeek)
     allowedAssignments(playSlots, home[w][g], away[w][g], games[w][g]);


   //
   // All teams play each week
   //
   forall(w in 1..nbWeeks) {

     allDifferent(append(all(g in 1..nbGamesPerWeek) home[w][g], 
                         all(g in 1..nbGamesPerWeek) away[w][g])); 
                
   }
                         

    //
    // Dual representation: for each game id, the play slot is maintained
    //
    inverse(all [1..nbGames](w in 1..nbWeeks, g in 1..nbGamesPerWeek) games[w][g], allSlots); 
    forall(g in 1..nbGames)
      weekOfGame[g] == ((allSlots[g]-1) div nbGamesPerWeek) + 1;


    //
    // Two half schedules.  Cannot play the same pair twice in the same half.
    // Plus, impose a minimum number of weeks between two games involving
    // the same teams (up to six weeks)
    //
    forall (<i,j,g1> in playSlots, <j,i,g2> in playSlots  : i < j) {
       (weekOfGame[g1] >= mid) == (weekOfGame[g2] < mid); 
       if (overlap != 0)
          abs(weekOfGame[g1] - weekOfGame[g2]) >= overlap;
    }


               
    //
    // Can't have three homes or three aways in a row.
    //
    forall (t in 1..n, w in 1..nbWeeks) {
       playHome[t][w] == count(all(g in 1..nbGamesPerWeek) home[w][g], t);
    }

    forall (t in 1..n, w in 1..nbWeeks - 2) {
       1 <= sum(k in w..w+2) playHome[t][k] <= 2;
    }
  
    //
    // If we start the season home, we finish away and vice versa.
    //
    forall(t in 1..n)
       teamBreaks[t] == sum(w in 2..nbWeeks) (playHome[t][w-1] == playHome[t][w]);
       
    forall (t in 1..n)
      playHome[t][1] != playHome[t][nbWeeks];


    //
    // Catalyzing constraints
    //

    // Each team plays home the same number of times as away
    forall (t in 1..n) {
       sum(w in 1..nbWeeks) playHome[t][w] == nbWeeks div 2;
    }

    // Breaks must be even for each team
    forall(t in 1..n)
       teamBreaks[t] % 2 == 0;



    //    
    // Symmetry breaking constraints
    // 
    // Teams are interchangeable.  Fix first week.
    // Also breaks reflection symmetry of the whole schedule.
    forall (g in 1..nbGamesPerWeek) {
       home[1][g] == g*2 - 1;
       away[1][g] == g*2;
    }


    // Order of games in each week is arbitrary.
    // Break symmetry by forcing an order.
    forall (w in 1..nbWeeks)
      forall(g in 2..nbGamesPerWeek)
        games[w][g] > games[w][g-1];
       

}

int oponent[1..n][1..nbWeeks];

int breaks = sum(t in 1..n) teamBreaks[t];



execute {
   
      writeln("Solution at " + breaks);
      for (var j= 1; j <= nbWeeks; j++) {
         write("Week " + j + ": ");
         if (j < 10) write (" ");
         for (var i = 1; i <= nbGamesPerWeek; i++) {
            if (home[j][i] >= 10) 
              write(home[j][i]);
            else
              write(" " + home[j][i]);
            write("-");
            if (away[j][i] >= 10)
              write(away[j][i]);
            else
              write(away[j][i] + " ");
            write(" ");      
         }
         writeln();
      }
      writeln("Team schedules");
      for (i = 1; i <= n; i++) {
         write("T " + i + ":  ");
         var prev = -1;
         var brks = 0;
         for (j = 1; j <= nbWeeks; j++) {
            for (var k = 1; k <= nbGamesPerWeek; k++) {
               if (home[j][k] == i) {
                  oponent[i][j] = away[j][k];
                  if (away[j][k] >= 10)
                    write(away[j][k] + "H ")
                  else
                    write(" " + away[j][k] + "H ");
                  brks += (prev == 0);
                  prev = 0;    
               }
               if (away[j][k] == i) {
                  oponent[i][j] = home[j][k];
                  if (home[j][k] >= 10)
                    write(home[j][k] + "A ");
                  else
                    write(" " + home[j][k] + "A ");
                  brks += (prev == 1);
                  prev = 1;
               }
            }
         }
         writeln("  " + brks + " breaks");
      }
      writeln();
}




tuple solution2DimT{
	int i;
	int j;
	int value;
};
tuple solution1DimT{
	int i;
	int value;
};

{solution2DimT} gamesReport = {<i,j, games[i][j]> | i in 1..nbWeeks, j in 1..nbGamesPerWeek};
{solution2DimT} homeReport = {<i,j, home[i][j]> | i in 1..nbWeeks, j in 1..nbGamesPerWeek};
{solution1DimT} awayReport = {<i, away[i][j]> | i in 1..nbWeeks, j in 1..nbGamesPerWeek};
{solution1DimT} weekOfGameReport = {<i, weekOfGame[i]> | i in 1..nbGames};
{solution1DimT} allSlotsReport = {<i, allSlots[i]> | i in 1..nbGames};
{solution2DimT} playHomeReport = {<i,j, playHome[i][j]> | i in 1..n, j in 1..nbWeeks};
{solution1DimT} allGamesReport = {<i, allGames[i]> | i in 1..nbGames};
{solution1DimT} teamBreaksReport = {<i, teamBreaks[i]> | i in 1..n};
