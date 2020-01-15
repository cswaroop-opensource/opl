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

/***********************************************************************
* OPL Model for Staffing Example
* 
* This model is described in the documentation. 
* See "IDE and OPL > Language and Interfaces Examples > OPL model library" 
*
* This model is greater than the size allowed in trial mode. 
* You therefore need a commercial edition of CPLEX Studio to run this example. 
* If you are a student or teacher, you can also get a full version through
* the IBM Academic Initiative.
*************************************************************************/


  
//**************************** Data **************************************
int Totalshifts = ...; // Total # of shifts in a day
int Nbshifts = ...;    // Total # shifts a person should work in a day
range Shifts = 1..Totalshifts; 

{string} Skills = ...;     // Type of skills required
{string} Weekdays = ...;   // Set of work days 
{string} People = ...;     // Set of personnel

int Req[Weekdays][Shifts][Skills] = ...;  // # of persons of a skill type required in each shift
                  
// Data Structure
tuple shift {
  key string p;
  string w;
}

tuple PSkill {
  key string p;
  {string} s;
}

{PSkill} PeopleSkills = ...; //  List of skills that a person has 
{shift}  Unavailable = ...;  // Unavailability of each person

int Penalty = card(Weekdays)*Nbshifts+1; // Penalty for an unfilled slot

//********************************* Variables **********************************
        
dvar boolean Assign[Weekdays][Shifts][People][Skills];   // Indicates a shift assignment
dvar int Unfilled[Weekdays][Shifts][Skills] in 0..maxint;  // # of skilled persons unfilled in a shift
dvar int Pmin           in 0..card(Weekdays)*Nbshifts;     // Minimal # of shifts assigned 
dvar int Pmax           in 0..card(Weekdays)*Nbshifts;     // Maximal # of shifts assigned
dvar boolean Start[Weekdays][Shifts][People];             // People who start working in a shift
dvar int Personnel[Weekdays][Shifts] in 0..card(People);     // # of available personnel in a shift
dvar boolean Avail[Weekdays][Shifts][People];            // Indicates the availability of a person in a shift


// the total # of slots unfilled in a week
dexpr int TotUnfilled  =
  sum(w in Weekdays, s in Shifts, j in Skills) Unfilled[w][s][j];

/************************************* Model *********************************/

minimize TotUnfilled*Penalty + (Pmax-Pmin);
// Note:  Since the penalty is higher than the maximal 
// possible difference in the # of shifts assigned to the workers,
// the schedule always fills the demand first, and then balances the work load.

subject to {
   
  // The number of available personnel in a shift = 
  // the sum of the number of starting personnel in previous "nbshifts" shifts.
  forall(w in Weekdays, s in Shifts)   
    Personnel[w][s] == sum(i in Shifts: s-Nbshifts+1 <= i <= s, j in People) Start[w][i][j];
      
  // The number of personnel in a shift = total # of available persons. 
  forall(w in Weekdays, s in Shifts)  
    Personnel[w][s] == sum(j in People) Avail[w][s][j];
   
  // the total # of persons working in a shift <= the # of personnel in the shift.

  forall(w in Weekdays, s in Shifts)  
    ctPersonnel:       
      sum(p in People, j in Skills) Assign[w][s][p][j] <= Personnel[w][s];
      
  forall(w in Weekdays, s in Shifts,p in People) {
    // If a person starts in shift k, she will be available during next nbshifts shifts. 
    forall(k in Shifts: s-Nbshifts+1 <= k <= s) 
      Avail[w][s][p] >= Start[w][k][p];
    // If a person has started, she can't "start" again in any of the next nbshifts shifts. 
    forall(k in Shifts: s+1 <= k <= s+Nbshifts-1) 
      1-Start[w][s][p] >= Start[w][k][p];
  }
   
  // If a person is available, he must be assigned a job       
  forall(w in Weekdays, s in Shifts, p in People)
    sum(j in Skills) Assign[w][s][p][j] == Avail[w][s][p];       
    
  // In each shift,  # of people assigned to a type of task +
  //   unfilled slot >= # of people of that type required
  forall(w in Weekdays, s in Shifts, j in Skills)
    ctUnfilled:    
      sum(p in People) 
        Assign[w][s][p][j] + Unfilled[w][s][j] >= Req[w][s][j];
   
  forall(w in Weekdays, s in Shifts, t in PeopleSkills, k in Skills: k not in t.s)
    Assign[w][s][t.p][k] == 0;
        
  // Everyone should work no longer than 8 hours (2 shifts in this case)
  forall(w in Weekdays, p in People) 
    ctShifts:      
      sum(s in Shifts, j in Skills) 
        Assign[w][s][p][j] <= Nbshifts;
        
  // Unavailable person cannot be assigned on that day
  forall(<p,w> in Unavailable, s in Shifts, j in Skills)
    Assign[w][s][p][j] == 0;

  // Each person can take only one task in each shift     
  forall(w in Weekdays, s in Shifts, p in People) 
    ctTasks:      
      sum(j in Skills) 
        Assign[w][s][p][j] <= 1;
 
  // If a person is on a night shift, he cannot be assigned to the morning
  //  shift the next day
  forall(p in People, k in Skills) {   
    Assign["Tue"][1][p][k] <= 1 - sum(j in Skills) Assign["Mon"][Totalshifts][p][j];
    Assign["Wed"][1][p][k] <= 1 - sum(j in Skills) Assign["Tue"][Totalshifts][p][j];
    Assign["Thu"][1][p][k] <= 1 - sum(j in Skills) Assign["Wed"][Totalshifts][p][j];
    Assign["Fri"][1][p][k] <= 1 - sum(j in Skills) Assign["Thu"][Totalshifts][p][j];
  }
  
  //Each shift has at least a cook, a cleaner and a cashier
  forall(w in Weekdays, s in Shifts, j in Skills) 
    ctSkills:
      sum(p in People) Assign[w][s][p][j] >= 1;     
   
  // The workload of a person is bounded by pmin and pmax 
  forall(p in People)
    Pmin <= sum(w in Weekdays, s in Shifts, j in Skills) Assign[w][s][p][j];  
  forall(p in People)
    sum(w in Weekdays, s in Shifts, j in Skills) Assign[w][s][p][j] <= Pmax;  
       
}


tuple UnfilledSolutionT{ 
	string Weekdays; 
	int Shifts; 
	string Skills; 
	int value; 
};
{UnfilledSolutionT} UnfilledSolution = {<i0,i1,i2,Unfilled[i0][i1][i2]> | i0 in Weekdays,i1 in Shifts,i2 in Skills};
tuple PersonnelSolutionT{ 
	string Weekdays; 
	int Shifts; 
	int value; 
};
{PersonnelSolutionT} PersonnelSolution = {<i0,i1,Personnel[i0][i1]> | i0 in Weekdays,i1 in Shifts};
tuple StartSolutionT{ 
	string Weekdays; 
	int Shifts; 
	string People; 
	int value; 
};
{StartSolutionT} StartSolution = {<i0,i1,i2,Start[i0][i1][i2]> | i0 in Weekdays,i1 in Shifts,i2 in People};
tuple AvailSolutionT{ 
	string Weekdays; 
	int Shifts; 
	string People; 
	int value; 
};
{AvailSolutionT} AvailSolution = {<i0,i1,i2,Avail[i0][i1][i2]> | i0 in Weekdays,i1 in Shifts,i2 in People};
tuple AssignSolutionT{ 
	string Weekdays; 
	int Shifts; 
	string People; 
	string Skills; 
	int value; 
};
{AssignSolutionT} AssignSolution = {<i0,i1,i2,i3,Assign[i0][i1][i2][i3]> | i0 in Weekdays,i1 in Shifts,i2 in People,i3 in Skills};
