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

int   NbMetals = ...;
int   NbRaw = ...;
int   NbScrap = ...;
int   NbIngo = ...;

range Metals = 1..NbMetals;
range Raws = 1..NbRaw;
range Scraps = 1..NbScrap;
range Ingos = 1..NbIngo;

float CostMetal[Metals] = ...;
float CostRaw[Raws] = ...;
float CostScrap[Scraps] = ...;
float CostIngo[Ingos] = ...;
float Low[Metals] = ...;
float Up[Metals] = ...;
float PercRaw[Metals][Raws] = ...;
float PercScrap[Metals][Scraps] = ...;
float PercIngo[Metals][Ingos] = ...;

int Alloy  = ...;
dvar float+    p[Metals];
dvar float+    r[Raws];
dvar float+    s[Scraps];
dvar int+      i[Ingos];
dvar float    m[j in Metals] in Low[j] * Alloy .. Up[j] * Alloy;


minimize 
  sum(j in Metals) CostMetal[j] * p[j] +
  sum(j in Raws)   CostRaw[j]   * r[j] +
  sum(j in Scraps) CostScrap[j] * s[j] +
  sum(j in Ingos)  CostIngo[j]  * i[j];
subject to {
  forall( j in Metals )
    ct1:
      m[j] == 
      p[j] + 
      sum( k in Raws )   PercRaw[j][k] * r[k] +
      sum( k in Scraps ) PercScrap[j][k] * s[k] +
      sum( k in Ingos )  PercIngo[j][k] * i[k];
    ct2:  
      sum( j in Metals ) m[j] == Alloy;
}

tuple pSolutionT{ 
	int Metals; 
	float value; 
};
{pSolutionT} pSolution = {<i0,p[i0]> | i0 in Metals};
tuple rSolutionT{ 
	int Raws; 
	float value; 
};
{rSolutionT} rSolution = {<i0,r[i0]> | i0 in Raws};
tuple sSolutionT{ 
	int Scraps; 
	float value; 
};
{sSolutionT} sSolution = {<i0,s[i0]> | i0 in Scraps};
tuple iSolutionT{ 
	int Ingos; 
	int value; 
};
{iSolutionT} iSolution = {<i0,i[i0]> | i0 in Ingos};
tuple mSolutionT{ 
	int Metals; 
	float value; 
};
{mSolutionT} mSolution = {<i0,m[i0]> | i0 in Metals};







