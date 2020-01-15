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

/* ------------------------------------------------------------

Problem Description:  
-------------------
The HR department of a company organizes an integration day to welcome new employees. 
The problem is to configure 10 teams of 6 people that respect the following rules:
There are 30 new employees and 30 existing employees. They work in 6 different services lettered A to F.
A team must have 3 existing employees and 3 new employees, and at most 4 people from the same service.
Some new employees are coached by an existing employee, and an existing employee can coach only one new employee.
A new employee who is coached must be in the team of his coach.
Furthermore, employees of services A and B cannot be in the same team; employees of services E and F cannot be in the same team.

Each person is represented by a number in 0-59; new employees are the even numbers, existing employees are the odd numbers.

Service       Range
  A          0-19 
  B          20-39 
  C          40-44
  D          45-49
  E          50-54
  F          55-59

In Service A: the couples coach/coached new employee are 0-1, 2-3, 4-5, 6-7, 8-9, 10-11 
In Service B: the couples coach/coached new employee are 20-21, 22-23, 24-25, 26-27, 28-29, 30-31 
In Services C,D,E,F, the couples coach/coached new employee are 40-41, 42-43, 45-46, 47-48, 50-51, 52-53, 55-56, 57-58


Additional constraints:

Person number 5 must be with either person 41 or person 51.
Person number 15 must be with either 40 or person 51.
Person number 25 must be with either 40 or person 50.
Furthermore, person 20 is with person 24, or person 22 is with person 50.



------------------------------------------------------------ */


using CP;

// 60 persons
range persons=0..59;
// 10 teams
range teams=1..10;


{string} serviceNames={"A","B","C","D","E","F"};
{int} service[serviceNames]=[asSet(0..19),asSet(20..39),asSet(40..44),
asSet(45..49),asSet(50..54),asSet(55..59)];

tuple pair
{
 int person1;
 int person2;  
};
{pair} coach_and_coached={<0,1>,<2,3>,<4,5>,<6,7>,<8,9>,<10,11>,<20,21>,
 <22,23>,<24,25>,<26,27>,<28,29>,<30,31>,<40,41>,<42,43>,<45,46>,<47,48>, 
 <50,51>,<52,53>,<55,56>,<57,58>};

dvar int team[persons] in teams;

subject to
{
  //A team must have 3 existing employees and 3 new employees, and at most 4 people from the same service.

  forall(t in teams)
  {
     count(all(existingemployee in persons:existingemployee % 2==1)team[existingemployee],t)==3;
     count(all(newemployee in persons:newemployee % 2==0)team[newemployee],t)==3;
     forall(f in serviceNames) count(all(person in service[f])team[person],t)<=4;
  }
  
  //Furthermore, employees of services A and B cannot be in the same team; 
  //employees of services E and F cannot be in the same team.
  
  forall(pA in service["A"],pB in service["B"]) team[pA]!=team[pB];
  forall(pE in service["E"],pF in service["F"]) team[pE]!=team[pF];
  
  //A new employee who is coached must be in the team of his coach.
  
  forall(c in coach_and_coached) team[c.person1]==team[c.person2];
  
  //Person number 5 wants to be with either person 41 or person 51.
  (team[5]==team[41]) || (team[5]==team[51]);

  //Person number 15 wants to be with either 40 or person 51.
  (team[15]==team[40]) || (team[15]==team[51]);
  
  //Person number 25 wants to be with either 40 or person 50.
  (team[25]==team[40]) || (team[25]==team[50]);
  
  //Furthermore, person 20 is with person 24, or person 22 is with person 50.
  (team[20]==team[24]) || (team[22]==team[50]);

 
 
}

{int} teamList[t in 1..10]={p | p in persons: team[p]==t};
tuple solutionT{
	int team;
	int id;
}
{solutionT} solution = {<t,p> | t in 1..10, p in persons: team[p]==t};









