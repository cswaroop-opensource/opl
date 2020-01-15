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

{string} Colors = ...;
int capacity[Colors] = ...;
int maxCapacity = max(c in Colors) capacity[c];


{string} Components = ...;
int demand[Components] = ...;
int maxDemand = max(c in Components) demand[c];
tuple Bin {
   key int id;
   string color;
   int n[Components];
};
{Bin} Bins = ...;
int nBins = card(Bins);


