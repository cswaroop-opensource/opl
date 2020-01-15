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

// Problem 6 from Model Building in Mathematical Programming, 3rd ed.
//   by HP Williams
// Refinery Optimization
// This model is described in the documentation. 
// See IDE and OPL > Language and Interfaces Examples.

{string} Crude = ...;
{string} Naptha = ...;
{string} Resid = ...;
{string} Oil = ...;
{string} ReformProd = ...;
{string} CrackProd = ...;
{string} Petrol = ...; 
{string} Fuel = ...;
{string} Lube = ...;

float DistillNaptha[Crude][Naptha] = ...;
float DistillOil[Crude][Oil] = ...;
float DistillResid[Crude][Resid] = ...;

float ResidProcess[Resid][Lube] = ...;
float ReformProcess[Naptha][ReformProd] = ...;
float CrackProcess[Oil][CrackProd] = ...;

float VaporOil[Oil] = ...;
float VaporResid[Resid] = ...;
float VaporCrkOil = ...;
float LimVaporJF = ...;

float LimCrude[Crude] = ...;
float LimDistill = ...;
float LimReform = ...;
float LimCrack = ...;
float LoLube[Lube] = ...;
float UpLube[Lube] = ...;

float OctaneNaptha[Naptha] = ...;
float OctaneReform[ReformProd] = ...;
float OctaneCG = ...;
float ReqOctane[Petrol] = ...;
float ReqRatioPetrol = ...;

float ReqOilFO[Oil] = ...;
float ReqCrkFO = ...;
float ReqResidFO[Resid] = ...;

float ProfitPetrol[Petrol] = ...;
float ProfitFuel[Fuel] = ...;
float ProfitLube[Lube] = ...;

dvar float+ Cr[c in Crude] in 0..LimCrude[c];
dvar float+ Nap[Naptha];
dvar float+ Napref[Naptha][ReformProd];
dvar float+ Napb[Naptha][Petrol];
dvar float+ Refb[ReformProd][Petrol];
dvar float+ Ref[ReformProd];
dvar float+ OilVar[Oil];
dvar float+ Oilcrk[Oil];
dvar float+ Oilb[Oil][Fuel];
dvar float+ Crk[CrackProd];
dvar float+ Crkg[Petrol];
dvar float+ Crko[Fuel];
dvar float+ ResidVar[Resid];
dvar float+ Residl[Resid][Lube];
dvar float+ Residbf[Resid][Fuel];
dvar float+ Fpf[Fuel]; 
dvar float+ Fpp[Petrol]; 
dvar float+ Fpl[l in Lube] in LoLube[l]..UpLube[l];

dexpr float TotalProfitFuel =
   sum(f in Fuel) ProfitFuel[f] * Fpf[f];
     
dexpr float TotalProfitPetrol =
   sum(p in Petrol) ProfitPetrol[p] * Fpp[p];
   
dexpr float TotalProfitLube = 
   sum(l in Lube) ProfitLube[l] * Fpl[l];
   
maximize TotalProfitFuel + TotalProfitPetrol + TotalProfitLube;

subject to {
  // Distillation capacity
  ctDistCap: sum(c in Crude) Cr[c] <= LimDistill;

  // Reforming capacity
  ctRefCap:
    sum(n in Naptha, r in ReformProd) Napref[n][r] <= LimReform;

  // Cracking capacity
  ctCrkCap: sum(o in Oil) Oilcrk[o] <= LimCrack;

  // Distillation products
  forall(n in Naptha)
    sum(c in Crude) DistillNaptha[c][n] * Cr[c] == Nap[n];     

  forall(o in Oil)
    sum(c in Crude) DistillOil[c][o] * Cr[c] == OilVar[o];     

  forall(r in Resid)
    sum(c in Crude) DistillResid[c][r] * Cr[c] == ResidVar[r];     

  // Reformer products
  forall (r in ReformProd)
    sum(n in Naptha) ReformProcess[n][r] * Napref[n][r] == Ref[r]; 
   
  // Cracking products
  forall(c in CrackProd)
    sum(o in Oil) CrackProcess[o][c] * Oilcrk[o] == Crk[c];

  Crk["CG"] == sum(p in Petrol) Crkg[p];
  Crk["CO"] == sum(f in Fuel) Crko[f];

  // Resid process
  forall(l in Lube)
    sum(r in Resid) ResidProcess[r][l] * Residl[r][l] == Fpl[l];

  // Balance constraints on Napthas
  forall(n in Naptha)
    sum(r in ReformProd) Napref[n][r] + sum(p in Petrol) Napb[n][p] == Nap[n];

  // Balance constraints on Oils
  forall(o in Oil)
    Oilcrk[o] + sum(f in Fuel) Oilb[o][f] == OilVar[o];   

  // Balance constraints on Resids
  forall(r in Resid)
    sum(f in Fuel) Residbf[r][f] + sum(l in Lube) Residl[r][l] == ResidVar[r];

  // Balance constraint on Reformer products
  forall(r in ReformProd)
    sum(p in Petrol) Refb[r][p] == Ref[r];

  // Balance constraints on Petrols
  forall(p in Petrol)
    sum(n in Naptha) Napb[n][p] + sum(r in ReformProd) Refb[r][p] + Crkg[p] == Fpp[p];

  // Balance constraint on Fuels
  forall(f in Fuel)
    sum(o in Oil) Oilb[o][f] + Crko[f] + sum(r in Resid) Residbf[r][f] == Fpf[f];
   
  // Fixed proportions required for Fuel Oil
  forall(o in Oil)
    Oilb[o,"FO"] == ReqOilFO[o] * Fpf["FO"];
  Crko["FO"] == ReqCrkFO * Fpf["FO"];
  forall(r in Resid)
    Residbf[r]["FO"] == ReqResidFO[r] * Fpf["FO"]; 

  // Required ratio between petrols
  cttReqRatio: Fpp["PMF"] >= ReqRatioPetrol * Fpp["RMF"];
   
  // Qualities
  // Octane
  forall(p in Petrol)
    ctOctane :      
      sum(n in Naptha) OctaneNaptha[n] * Napb[n][p] + 
      sum(r in ReformProd) OctaneReform[r] * Refb[r][p]
         + OctaneCG * Crkg[p] >= ReqOctane[p] * Fpp[p]; 

  // Vapor Pressure constraint on Jet Fuel
  ctVapPres: 
  sum(o in Oil) VaporOil[o] * Oilb[o]["JF"] + VaporCrkOil * Crko["JF"]
       + sum(r in Resid) VaporResid[r] * Residbf[r]["JF"] <= LimVaporJF * Fpf["JF"];
      
}



tuple FpfSolutionT{ 
	string Fuel; 
	float value; 
};
{FpfSolutionT} FpfSolution = {<i0,Fpf[i0]> | i0 in Fuel};
tuple FppSolutionT{ 
	string Petrol; 
	float value; 
};
{FppSolutionT} FppSolution = {<i0,Fpp[i0]> | i0 in Petrol};
tuple FplSolutionT{ 
	string Lube; 
	float value; 
};
{FplSolutionT} FplSolution = {<i0,Fpl[i0]> | i0 in Lube};
tuple CrSolutionT{ 
	string Crude; 
	float value; 
};
{CrSolutionT} CrSolution = {<i0,Cr[i0]> | i0 in Crude};
tuple NaprefSolutionT{ 
	string Naptha; 
	string ReformProd; 
	float value; 
};
{NaprefSolutionT} NaprefSolution = {<i0,i1,Napref[i0][i1]> | i0 in Naptha,i1 in ReformProd};
tuple OilcrkSolutionT{ 
	string Oil; 
	float value; 
};
{OilcrkSolutionT} OilcrkSolution = {<i0,Oilcrk[i0]> | i0 in Oil};
tuple NapSolutionT{ 
	string Naptha; 
	float value; 
};
{NapSolutionT} NapSolution = {<i0,Nap[i0]> | i0 in Naptha};
tuple OilVarSolutionT{ 
	string Oil; 
	float value; 
};
{OilVarSolutionT} OilVarSolution = {<i0,OilVar[i0]> | i0 in Oil};
tuple ResidVarSolutionT{ 
	string Resid; 
	float value; 
};
{ResidVarSolutionT} ResidVarSolution = {<i0,ResidVar[i0]> | i0 in Resid};
tuple RefSolutionT{ 
	string ReformProd; 
	float value; 
};
{RefSolutionT} RefSolution = {<i0,Ref[i0]> | i0 in ReformProd};
tuple CrkSolutionT{ 
	string CrackProd; 
	float value; 
};
{CrkSolutionT} CrkSolution = {<i0,Crk[i0]> | i0 in CrackProd};
tuple CrkgSolutionT{ 
	string Petrol; 
	float value; 
};
{CrkgSolutionT} CrkgSolution = {<i0,Crkg[i0]> | i0 in Petrol};
tuple CrkoSolutionT{ 
	string Fuel; 
	float value; 
};
{CrkoSolutionT} CrkoSolution = {<i0,Crko[i0]> | i0 in Fuel};
tuple ResidlSolutionT{ 
	string Resid; 
	string Lube; 
	float value; 
};
{ResidlSolutionT} ResidlSolution = {<i0,i1,Residl[i0][i1]> | i0 in Resid,i1 in Lube};
tuple NapbSolutionT{ 
	string Naptha; 
	string Petrol; 
	float value; 
};
{NapbSolutionT} NapbSolution = {<i0,i1,Napb[i0][i1]> | i0 in Naptha,i1 in Petrol};
tuple OilbSolutionT{ 
	string Oil; 
	string Fuel; 
	float value; 
};
{OilbSolutionT} OilbSolution = {<i0,i1,Oilb[i0][i1]> | i0 in Oil,i1 in Fuel};
tuple ResidbfSolutionT{ 
	string Resid; 
	string Fuel; 
	float value; 
};
{ResidbfSolutionT} ResidbfSolution = {<i0,i1,Residbf[i0][i1]> | i0 in Resid,i1 in Fuel};
tuple RefbSolutionT{ 
	string ReformProd; 
	string Petrol; 
	float value; 
};
{RefbSolutionT} RefbSolution = {<i0,i1,Refb[i0][i1]> | i0 in ReformProd,i1 in Petrol};

