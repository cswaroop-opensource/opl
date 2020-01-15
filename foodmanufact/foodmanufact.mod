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

{string} Products = ...;

int NbMonths   = ...;
range Months = 1..NbMonths;
float Cost[Months][Products] = ...;

dvar float+ Produce[Months];
dvar float+ Use[Months][Products];
dvar float+ Buy[Months][Products];
dvar float Store[Months][Products] in 0..1000;


maximize 
  sum( m in Months ) 
    (150 * Produce[m] 
    - sum( p in Products ) 
      Cost[m][p] * Buy[m][p] 
    - 5 * sum( p in Products ) 
      Store[m][p]);
subject to {
  forall( p in Products )
    ctStore:
      Store[NbMonths][p] == 500;
  forall( m in Months ) {
    ctUse1:
      Use[m]["v1"] + Use[m]["v2"] <= 200;
    ctUse2:                
      Use[m]["o1"] + Use[m]["o2"] + Use[m]["o3"] <= 250;
    ctUse3:
      3 * Produce[m] <=
            8.8 * Use[m]["v1"] + 6.1 * Use[m]["v2"] +
            2   * Use[m]["o1"] + 4.2 * Use[m]["o2"] + 5 * Use[m]["o3"];
     ctUse4:
       8.8 * Use[m]["v1"] + 6.1 * Use[m]["v2"] +
            2   * Use[m]["o1"] + 4.2 * Use[m]["o2"] + 5 * Use[m]["o3"]
            <= 6 * Produce[m];
            
     ctUse5:
       Produce[m] == sum( p in Products ) Use[m][p];
   }
  forall( m in Months )
    forall( p in Products ) {
      ctUse6:  
        if (m == 1) {
          500 + Buy[m][p] == Use[m][p] + Store[m][p];
        }
        else {
          Store[m-1][p] + Buy[m][p] == Use[m][p] + Store[m][p];
        }
    }
    forall( m in Months ) {
      // Using some constraints as boolean expressions to state that at least
      // 2 of the given 5 constraints must be true.
      ctUse7:  
        (Use[m]["v1"] == 0) + (Use[m]["v2"] == 0) + (Use[m]["o1"] == 0) +
                   (Use[m]["o2"] == 0) + (Use[m]["o3"] == 0) >= 2;

      // Using the "or" operator, set each Use variable to be
      // zero or greater than 20.
      forall( p in Products )
        ctUse8:    
          (Use[m][p] == 0) || (Use[m][p] >= 20);

      // Using "or" and "implication" operator, set that if one of 2 given products 
      // is used more than 20 then a third one must be used more than 20 too.
      ctUse9:
        (Use[m]["v1"] >= 20) || (Use[m]["v2"] >= 20) => Use[m]["o3"] >= 20;
  }
};

// Expected result : 100278.70


tuple ProduceSolutionT{ 
	int Months; 
	float value; 
};
{ProduceSolutionT} ProduceSolution = {<i0,Produce[i0]> | i0 in Months};
tuple BuySolutionT{ 
	int Months; 
	string Products; 
	float value; 
};
{BuySolutionT} BuySolution = {<i0,i1,Buy[i0][i1]> | i0 in Months,i1 in Products};
tuple StoreSolutionT{ 
	int Months; 
	string Products; 
	float value; 
};
{StoreSolutionT} StoreSolution = {<i0,i1,Store[i0][i1]> | i0 in Months,i1 in Products};
tuple UseSolutionT{ 
	int Months; 
	string Products; 
	float value; 
};
{UseSolutionT} UseSolution = {<i0,i1,Use[i0][i1]> | i0 in Months,i1 in Products};

execute DISPLAY {   
  writeln(" Maximum profit = " , cplex.getObjValue());
  for (var i in Months) {
    writeln(" Month ", i, " ");
    write("  . Buy   ");
    for (var p in Products)
      write(Buy[i][p], "\t ");
    writeln();            
    write("  . Use   ");
    for (p in Products) 
      write(Use[i][p], "\t ");
    writeln();
    write("  . store ");
    for (p in Products) 
      write(Store[i][p], "\t ");
    writeln();
  }
}
 
