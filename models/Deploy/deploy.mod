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


/****************************************************************** 
 OPL Model for Multi-Product Deployment Example
 
This model is described in the documentation. 
See IDE and OPL > Language and Interfaces Examples.

 ******************************************************************/

// The network configuration
{string} Sites = ...;
{string} Articles = ...;

tuple link {
   string org;
   string dst;
}

{link} Links = ...;

tuple OnHandT{ 
	string Sites; 
	string Articles; 
	float value; 
};

{OnHandT} OnHandSet = ...;

tuple DemandT{ 
	string Sites; 
	string Articles; 
	float value; 
};

{DemandT} DemandSet = ...;

tuple CostT{ 
link Links; 	float value; 
};

{CostT} CostSet = ...;

tuple LinkExtraCostT{ 
link Links; 	float value; 
};

{LinkExtraCostT} LinkExtraCostSet = ...;

tuple LinkCapacityT{ 
link Links; 	float value; 
};

{LinkCapacityT} LinkCapacitySet = ...;

tuple SiteCapacityT{ 
	string Sites; 
	float value; 
};

{SiteCapacityT} SiteCapacitySet = ...;

tuple SiteExtraCostT{ 
	string Sites; 
	float value; 
};

{SiteExtraCostT} SiteExtraCostSet = ...;


float OnHand[Sites][Articles] = [ t.Sites : [t.Articles : t.value ]  | t in OnHandSet];
float Demand[Sites][Articles] = [ t.Sites : [t.Articles : t.value ]  | t in DemandSet];
float Cost[Links] = [ t.Links : t.value | t in CostSet];
float LinkExtraCost[Links] = [ t.Links : t.value | t in LinkExtraCostSet];
float LinkCapacity[Links] = [ t.Links : t.value | t in LinkCapacitySet];
float SiteCapacity[Sites] = [ t.Sites : t.value | t in SiteCapacitySet];
float SiteExtraCost[Sites] = [ t.Sites : t.value | t in SiteExtraCostSet];



// Extra storage capacity required at a node
dvar float+ SiteExtra[Sites];
  
// Extra transportation capacity required on the links 
dvar float+ LinkExtra[Links];

// Flow for each article on each link 
dvar float+ Flow[Links][Articles];

// Total transportation costs and extra storage costs
dexpr float TotalLinkCost = 
  sum(l in Links, a in Articles) 
    (Cost[l] * Flow[l][a] + LinkExtraCost[l] * LinkExtra[l]);

dexpr float TotalSiteCost =
  sum(i in Sites) SiteExtraCost[i]*SiteExtra[i];

  // Standard cost of flows  + Extra cost paid for flows over capacity + Cost of extra storage capacity  
minimize TotalLinkCost + TotalSiteCost;
   
subject to {

  // The transportation capacity constraint. It computes how much extra
  // transportation capacity is required   
  forall(l in Links) 
    ctLinkCapa: sum(a in Articles) Flow[l][a] <= LinkCapacity[l] + LinkExtra[l];

  // The storage capacity constraint. It computes how much extra storage
  // capacity is required
  forall(s in Sites) 
    ctSiteCapa: sum(a in Articles)   (  sum(l in Links: s == l.dst) Flow[l][a] -
                        sum(l in Links: s == l.org) Flow[l][a] +
                        OnHand[s][a] -
                        Demand[s][a] ) <= SiteCapacity[s] + SiteExtra[s];


  // At each node, the incoming quantities and the stock should cover the
  // demand plus the outgoing quantities
  forall(s in Sites, a in Articles)
    ctDemand: Demand[s][a] <= OnHand[s][a] + sum(l in Links: s == l.dst) Flow[l][a] -
                                   sum(l in Links: s == l.org) Flow[l][a];           
                                   
}

execute DISPLAY {
   writeln("LinkExtra = ", LinkExtra);
   writeln("SiteExtra = ", SiteExtra);
   writeln("Flow = ", Flow);
}


tuple FlowSolutionT{ 
	link Links;
 	string Articles; 
	float value; 
};
{FlowSolutionT} FlowSolution = {<i0,i1,Flow[i0][i1]> | i0 in Links,i1 in Articles};
tuple LinkExtraSolutionT{ 
	link Links; 	
	float value; 
};
{LinkExtraSolutionT} LinkExtraSolution = {<i0,LinkExtra[i0]> | i0 in Links};
tuple SiteExtraSolutionT{ 
	string Sites; 
	float value; 
};
{SiteExtraSolutionT} SiteExtraSolution = {<i0,SiteExtra[i0]> | i0 in Sites};
