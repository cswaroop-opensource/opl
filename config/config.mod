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

int nbModel = ...;
int nbCard = ...;
int nbRack = ...;

range Models = 0..nbModel-1;
range Cards = 0..nbCard-1;
range Racks = 0..nbRack-1;

execute{
	}


tuple modelType {
   int power;
   int connectors;
   int price;
};

tuple cardType {
   int power;
   int quantity;
};

modelType model[Models] = ...;
cardType car[Cards] = ...;

int maxPrice = max(r in Models) model[r].price;
int maxCost = nbCard * maxPrice;
int powerData[i in Models] = model[i].power;
int connData[i in Models ] = model[i].connectors;
int priceData[i in Models ] = model[i].price;

dvar int rack[Racks] in Models;
dvar int counters[Racks][Cards] in 0..nbCard;
dvar int cost in 0..maxCost;

minimize
  cost;
subject to {
   forall(r in Racks)
      sum(c in Cards) counters[r][c] * car[c].power <= powerData[rack[r]];
   forall(r in Racks)
      sum(c in Cards) counters[r][c] <= connData[rack[r]];
   forall(c in Cards)
      sum(r in Racks) counters[r][c] == car[c].quantity;
   cost == sum(r in Racks) priceData[rack[r]];
};   

execute DISPLAY {
  writeln("cost = ", cost);
  writeln("rack = ", rack);
};

tuple countersSolutionT{ 
	int Racks; 
	int Cards; 
	int value; 
};
{countersSolutionT} countersSolution = {<i0,i1,counters[i0][i1]> | i0 in Racks,i1 in Cards};
tuple rackSolutionT{ 
	int Racks; 
	int value; 
};
{rackSolutionT} rackSolution = {<i0,rack[i0]> | i0 in Racks};

