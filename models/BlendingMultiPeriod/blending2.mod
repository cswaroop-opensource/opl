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

// Problem 2 from Model Building in Mathematical Programming, 3rd ed.
//   by HP Williams
// Food Manufacture with extra conditions that make it a MIP
// Multi-period blending problem
//This model is described in the documentation. 
//See IDE and OPL > Language and Interfaces Examples.

{string} Raw = ...;

int NbMonths = ...;
range Months = 1..NbMonths;

float CostRaw[Months][Raw] = ...;
float HardRaw[Raw] = ...;
float ProfitProd = ...;
float IsVeg[Raw] = ...;
float IsOil[Raw] = ...;
float MaxVeg = ...;
float MaxOil = ...;
float CostStore = ...;
float StartEndStore = ...;
float MaxStore = ...;
float MinUse = ...;
float MaxNumRaw = ...;
float DepUse[Raw][Raw] = ...;

dvar float+ Buy[Raw][Months];
dvar float+ Store[Raw][0..NbMonths] in 0..MaxStore;
dvar float+ Use[Raw][Months];
dvar float+ p[Months];
dvar boolean IndUse[Raw][Months];


dexpr float Profit = 
  sum (m in Months) ProfitProd * p[m];
dexpr float Cost =
  sum(j in Raw, m in Months)
         (CostRaw[m][j] * Buy[j][m] + CostStore * Store[j][m]);
         
maximize Profit - Cost;


subject to {
 forall(m in Months) {
      
    // Maximum usage per month   
    ctMaxUseVeg: sum(j in Raw) IsVeg[j] * Use[j][m] <= MaxVeg;
    ctMaxUseOil: sum(j in Raw) IsOil[j] * Use[j][m] <= MaxOil;
     
    // Hardness constraints
    ctHard1: sum(j in Raw) HardRaw[j] * Use[j][m] - 6 * p[m] <= 0;
    ctHard2: sum(j in Raw) HardRaw[j] * Use[j][m] - 3 * p[m] >= 0;

    // Material balance constraints
    ctMatBal: sum(j in Raw) Use[j][m] - p[m] == 0;
        
  }

  // Inventory balance
  forall(j in Raw, m in Months)
    ctInvVal: Store[j][m-1] + Buy[j][m] == Use[j][m] + Store[j][m];

  // Starting and ending inventories are fixed
  forall(j in Raw) {
    ctStartInv: Store[j][0] == StartEndStore;
    ctEndInv: Store[j][NbMonths] == StartEndStore;
  }

  // Product must be made of a limited number of raw oils 
  forall(m in Months)  
    ctMaxRaw: sum(j in Raw) IndUse[j][m] <= MaxNumRaw;

  // If a raw oil is used, at least a minimum amount must be used
  forall(j in Raw, m in Months)  {
    ctMinInUse: Use[j][m] >= MinUse * IndUse[j][m];
    ctMaxInUse: Use[j][m] <= IsOil[j] * MaxOil * IndUse[j][m] +
                   IsVeg[j] * MaxVeg * IndUse[j][m];
  }

  // If one oil used, another must be used
  forall(ordered i, j in Raw, m in Months)
    ctOilUse: IndUse[i][m] * DepUse[j][i] <= IndUse[j][m];
      
}


//Display the plan for each month and each raw material
//plan[m][j] = <Buy[j][m], Use[j][m], Store[j][m]>
execute DISPLAY {
   for (var m in Months)
      for (var j in Raw)
         writeln("plan[",m,"][",j,"] = <buy:",Buy[j][m],",use:",Use[j][m],",store:",Store[j][m],">");
}
