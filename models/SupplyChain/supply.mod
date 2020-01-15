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

/************************************************************
* Supply Chain Optimization
* 
* This model is described in the documentation. 
* See "IDE and OPL > Language and Interfaces Examples > OPL model library" 
*
* This model is greater than the size allowed in trial mode. 
* You therefore need a commercial edition of CPLEX Studio to run this example. 
* If you are a student or teacher, you can also get a full version through
* the IBM Academic Initiative.
*************************************************************/

execute {
   cplex.epgap = 0.001;
}

//********************* Data *********************************
int NumMonths = ...;
range Months = 1..NumMonths;

{string} Products = ...;

{string} Aplants = ...;    
{string} Bplants = ...;
{string} BExternal = ...;
{string} Cplants = ...;

{string} Acustomers = ...;
{string} Bcustomers = ...;
{string} Ccustomers = ...;


tuple custSource {        //Customers' information
  string cust;
  string Source;
  float  pricePerTon;
  float  distCostPerTon;
  float  markSalesCost;
}

tuple custMonthlyDemand { 
  string cust;
  float  monthlyDemand[Months];
}   

// Customer Information 
{custSource} CustSourceSetA = ...;
{custMonthlyDemand} CustMonDemandA = ...;

{custSource} CustSourceSetB = ...;
{custMonthlyDemand} CustMonDemandB = ...;

{custSource} CustSourceSetC = ...;
{custMonthlyDemand} CustMonDemandC = ...;


// Production Information
tuple BandCProductionData {
  string manPlanName;
  float  feedStockToDownProdRatio;
  float  conversionCost;     // $ per ton
  float  productionCap;      // tons per hour
  float  manuReliability;    // manufacturing reliability (%)
  float  finProdStorCap;     // finished product storage capacity - inventory max
  float  feedStockStorCap;   // feedstock storage capacity (tons)
}

tuple BandCfeedstockData {
  string manPlanName;
  string feedstockSource;  
  float  feedstockLogisticsCost;
  float  feedstockReplLotSize; //feedstock replenishment lot size
}

{BandCProductionData} BProductionData  = ...;
{BandCfeedstockData} BfeedstockData  = ...;
{BandCProductionData} CProductionData  = ...;
{BandCfeedstockData} CfeedstockData  = ...;
{BandCfeedstockData} CExfeedstockData = ...;

//Inventory at start 
float BegInvA[Aplants] = ...; 
float BegInvB[Bplants] = ...; 
float BegInvC[Cplants] = ...;

// Route Connections
tuple route {
  string o;   // Origin
  string d;   // Destination
}

// All routes from A to A's customers         
{route} ARoutesCust = { <o,d> | 
   <d, o, pricePerTon, distCostPerTon, markSalesCost> in CustSourceSetA };

// All routes from B to B's customers         
{route} BRoutesCust = { <o,d> | 
   <d, o, pricePerTon, distCostPerTon, markSalesCost> in CustSourceSetB };   

// All routes from C to C's customers         
{route} CRoutesCust = { <o,d> | 
   <d, o, pricePerTon, distCostPerTon, markSalesCost> in CustSourceSetC };         

// All routes from A's plants to B
{route} ARoutesPlant = { <o,d> | <d, o, feedstockLogisticsCost, feedstockReplLotSize 
         > in BfeedstockData };
// All routes from B's plants to C 
{route} BRoutesPlant = { <o,d> | <d, o, feedstockLogisticsCost, feedstockReplLotSize
         > in CfeedstockData };
// All routes from outsources to C
{route} BExternalRoutesPlant = { <o,d> | <d, o, feedstockLogisticsCost, feedstockRepLotSize
         > in CExfeedstockData };
     
// Production Quantities for each month at each plant
dvar float+ ProductionA[Months][Aplants];  
dvar float+ ProductionB[Months][Bplants];
dvar float+ ProductionC[Months][Cplants];

// Shipment on each route each month
dvar float+ ShipmentACust[Months][ARoutesCust];
dvar float+ ShipmentBCust[Months][BRoutesCust];
dvar float+ ShipmentCCust[Months][CRoutesCust];

dvar float+ ShipmentAPlants[Months][ARoutesPlant]; 
dvar float+ ShipmentBPlants[Months][BRoutesPlant];
dvar float+ ShipmentBExPlants[Months][BExternalRoutesPlant];
dvar int+ NumLotsShipAPlants[Months][ARoutesPlant] in 0..50;
dvar int+ NumLotsShipBPlants[Months][BRoutesPlant] in 0..50;
dvar int+ NumLotsShipBExPlants[Months][BExternalRoutesPlant] in 0..10;

// Inventories at each plant
range R0 = 0..NumMonths;
dvar float+ InventoryA[R0][Aplants];
dvar float+ InventoryB[R0][Bplants];
dvar float+ InventoryC[R0][Cplants];

// Spot Price
float SpotPrice[Acustomers] = ...;

// Costs
dvar float+ CostBFL[Months][Bplants];
dvar float+ CostBConversion[Months][Bplants];
dvar float+ CostCFL[Months][Cplants];
dvar float+ CostCFLEx[Months][Cplants];
dvar float+ CostCConversion[Months][Cplants];
dvar float+ CostCConversionEx[Months][Cplants];

dexpr float TotalCost =
 sum(mon in Months, b in Bplants) CostBFL[mon][b] + 
           sum(mon in Months, b in Bplants) CostBConversion[mon][b] + 
           sum(mon in Months, c in Cplants) CostCFL[mon][c] + 
           sum(mon in Months, c in Cplants) CostCConversion[mon][c] + 
           sum(mon in Months, c in Cplants) CostCFLEx[mon][c] + 
           sum(mon in Months, c in Cplants) CostCConversionEx[mon][c];
           
dexpr float ProfitSpotMarket =
  sum(c in Acustomers, i in Months, ar in ARoutesCust: ar.d == c) SpotPrice[c]*ShipmentACust[i][ar];      
           
minimize TotalCost - ProfitSpotMarket;

subject to {   
                           
  // conversion cost + feedstock logistics cost
  forall(mon in Months) {
    
    // From A Plants
    forall(bprod in BProductionData) {
      CostBFL[mon][bprod.manPlanName] == sum(bfeed in BfeedstockData: bprod.manPlanName == bfeed.manPlanName) 
            (ShipmentAPlants[mon][<bfeed.feedstockSource,bfeed.manPlanName>] * bfeed.feedstockLogisticsCost);  
      CostBConversion[mon][bprod.manPlanName] == bprod.conversionCost * 
            (sum(bfeed in BfeedstockData: bprod.manPlanName == bfeed.manPlanName) 
               (ShipmentAPlants[mon][<bfeed.feedstockSource,bfeed.manPlanName>]));
    }
      
    // From B Plants
    forall(cprod in CProductionData) {
      CostCFL[mon][cprod.manPlanName] == sum(cfeed in CfeedstockData: cprod.manPlanName == cfeed.manPlanName) 
            (ShipmentBPlants[mon][<cfeed.feedstockSource,cfeed.manPlanName>] * cfeed.feedstockLogisticsCost);    
      CostCConversion[mon][cprod.manPlanName] == cprod.conversionCost * 
            (sum(cfeed in CfeedstockData: cprod.manPlanName == cfeed.manPlanName) 
               (ShipmentBPlants[mon][<cfeed.feedstockSource,cfeed.manPlanName>]));
    }
           
    // From B External Plants
    forall(cprod in CProductionData) {
      CostCFLEx[mon][cprod.manPlanName] == sum(cfeed in CExfeedstockData: cprod.manPlanName == cfeed.manPlanName) 
            (ShipmentBExPlants[mon][<cfeed.feedstockSource,cfeed.manPlanName>] * cfeed.feedstockLogisticsCost);  
      CostCConversionEx[mon][cprod.manPlanName] == cprod.conversionCost * 
            (sum(cfeed in CExfeedstockData: cprod.manPlanName == cfeed.manPlanName) 
               (ShipmentBExPlants[mon][<cfeed.feedstockSource,cfeed.manPlanName>]));
    }    
  }
    
  // Inventory constraints
  // Set initial inventory
  forall(aplant in Aplants) InventoryA[0][aplant] == BegInvA[aplant];
  forall(bplant in Bplants) InventoryB[0][bplant] == BegInvB[bplant];
  forall(cplant in Cplants) InventoryC[0][cplant] == BegInvC[cplant];
   
  // Set Inventory Maximums
  // constraint constBInvStorCap[BProductionData][0..numMonths]; 
  forall(b in BProductionData, mon in 0..NumMonths)
    ctBInvStorCap:  
      InventoryB[mon][b.manPlanName] <= b.finProdStorCap;  
      
  forall(c in CProductionData, mon in 0..NumMonths)
    ctCInvStorCap:
      InventoryC[mon][c.manPlanName] <= c.finProdStorCap;
         
  // Production constraints
  forall(mon in Months, aplant in Aplants) 
    ProductionA[mon][aplant] + InventoryA[mon-1][aplant] ==
      sum(ar in ARoutesCust: ar.o == aplant) ShipmentACust[mon][ar] + 
      sum(ar in ARoutesPlant: ar.o == aplant) ShipmentAPlants[mon][ar] + 
      InventoryA[mon][aplant];                 
   
  forall(mon in Months, bplant in Bplants)
    ProductionB[mon][bplant] + InventoryB[mon-1][bplant] ==
      sum(br in BRoutesCust: br.o == bplant) ShipmentBCust[mon][br] + 
      sum(br in BRoutesPlant: br.o == bplant) ShipmentBPlants[mon][br] + 
      InventoryB[mon][bplant];

  forall(mon in Months, cplant in Cplants)
    ProductionC[mon][cplant] + InventoryC[mon-1][cplant] ==
    sum(cr in CRoutesCust: cr.o == cplant) ShipmentCCust [mon][cr] + 
    InventoryC[mon][cplant];
   
  // Lot size constraints
  forall(mon in Months) {
    forall(bfeed in BfeedstockData: bfeed.feedstockReplLotSize > 0) 
       ShipmentAPlants[mon][<bfeed.feedstockSource,bfeed.manPlanName>] == 
          bfeed.feedstockReplLotSize * NumLotsShipAPlants[mon][<bfeed.feedstockSource,bfeed.manPlanName>];

    forall(cfeed in CfeedstockData: cfeed.feedstockReplLotSize > 0) 
       ShipmentBPlants[mon][<cfeed.feedstockSource,cfeed.manPlanName>] == 
          cfeed.feedstockReplLotSize * NumLotsShipBPlants[mon][<cfeed.feedstockSource,cfeed.manPlanName>];

    forall(cfeed in CExfeedstockData: cfeed.feedstockReplLotSize > 0)
       ShipmentBExPlants[mon][<cfeed.feedstockSource,cfeed.manPlanName>] == 
          cfeed.feedstockReplLotSize * NumLotsShipBExPlants[mon][<cfeed.feedstockSource,cfeed.manPlanName>];
  }          


  // Maximum shipment from External B plants
  forall(mon in Months, bplant in BExternal)
    CtExtB:
       sum(be in BExternalRoutesPlant: be.o == bplant)  
          // *External Suppliers can supply a maximum of 25000 tons/month
          ShipmentBExPlants[mon][be] <= 25000;
 
  // Production at a "C" plant = feedStockToDownProdRatio * amount from B feedstock sources
  forall(mon in Months) {   
    forall(cprod in CProductionData) {
      ProductionC[mon][cprod.manPlanName] == 
          cprod.manuReliability * cprod.feedStockToDownProdRatio * 
           (/*internal*/ sum(cfeed in CfeedstockData: cprod.manPlanName == cfeed.manPlanName) 
                         ShipmentBPlants[mon][<cfeed.feedstockSource,cfeed.manPlanName>] + 
            /*external*/ sum(cfeed in CExfeedstockData: cprod.manPlanName == cfeed.manPlanName) 
                         ShipmentBExPlants[mon][<cfeed.feedstockSource,cfeed.manPlanName>]
           ); 
    }                       
  }
   
  // Production at a "B" plant = feedStockToDownProdRatio * amount from A feedstock sources
  forall(mon in Months) {   
    forall(bprod in BProductionData) {
      ProductionB[mon][bprod.manPlanName] == 
         bprod.manuReliability * bprod.feedStockToDownProdRatio * 
           (/*internal*/ sum(bfeed in BfeedstockData: bprod.manPlanName == bfeed.manPlanName) 
                         ShipmentAPlants[mon][<bfeed.feedstockSource,bfeed.manPlanName>]
           );                      
    }                       
  }
   

  // Feedstock Storage Capacity constraints - C plants
  forall(mon in Months, cprod in CProductionData)
    CtfeedStorCapC:
      10*cprod.feedStockStorCap >=  
            //internal
            sum(cfeed in CfeedstockData: cprod.manPlanName == cfeed.manPlanName) 
               ShipmentBPlants[mon][<cfeed.feedstockSource,cfeed.manPlanName>] +  
            sum(cfeed in CExfeedstockData: cprod.manPlanName == cfeed.manPlanName) 
               ShipmentBExPlants[mon][<cfeed.feedstockSource,cfeed.manPlanName>];

  // Feedstock Storage Capacity constraints - B plants
  forall(mon in Months, bprod in BProductionData)
    CtfeedStorCapB:
      10*bprod.feedStockStorCap >= 
         //internal 
         sum(bfeed in BfeedstockData: bprod.manPlanName == bfeed.manPlanName) 
            ShipmentAPlants[mon][<bfeed.feedstockSource,bfeed.manPlanName>];
   
  // Demand constraints
  forall(cm in CustMonDemandA, mon in Months)
    cm.monthlyDemand[mon] >=  
      sum(cs in CustSourceSetA: cm.cust == cs.cust) ShipmentACust[mon][<cs.Source,cs.cust>];  
                    
  forall(cm in CustMonDemandC, mon in Months)
    cm.monthlyDemand[mon] ==
      sum(cs in CustSourceSetC: cm.cust == cs.cust) ShipmentCCust[mon][<cs.Source,cs.cust>];
  
  forall(cm in CustMonDemandB, mon in Months)
    cm.monthlyDemand[mon] ==  
      sum(cs in CustSourceSetB: cm.cust == cs.cust) ShipmentBCust[mon][<cs.Source,cs.cust>];
      
}



tuple CostBFLSolutionT{ 
	int Months; 
	string Bplants; 
	float value; 
};
{CostBFLSolutionT} CostBFLSolution = {<i0,i1,CostBFL[i0][i1]> | i0 in Months,i1 in Bplants};
tuple CostBConversionSolutionT{ 
	int Months; 
	string Bplants; 
	float value; 
};
{CostBConversionSolutionT} CostBConversionSolution = {<i0,i1,CostBConversion[i0][i1]> | i0 in Months,i1 in Bplants};
tuple CostCFLSolutionT{ 
	int Months; 
	string Cplants; 
	float value; 
};
{CostCFLSolutionT} CostCFLSolution = {<i0,i1,CostCFL[i0][i1]> | i0 in Months,i1 in Cplants};
tuple CostCConversionSolutionT{ 
	int Months; 
	string Cplants; 
	float value; 
};
{CostCConversionSolutionT} CostCConversionSolution = {<i0,i1,CostCConversion[i0][i1]> | i0 in Months,i1 in Cplants};
tuple CostCFLExSolutionT{ 
	int Months; 
	string Cplants; 
	float value; 
};
{CostCFLExSolutionT} CostCFLExSolution = {<i0,i1,CostCFLEx[i0][i1]> | i0 in Months,i1 in Cplants};
tuple CostCConversionExSolutionT{ 
	int Months; 
	string Cplants; 
	float value; 
};
{CostCConversionExSolutionT} CostCConversionExSolution = {<i0,i1,CostCConversionEx[i0][i1]> | i0 in Months,i1 in Cplants};
tuple ShipmentACustSolutionT{ 
	int Months; 
route ARoutesCust; 	float value; 
};
{ShipmentACustSolutionT} ShipmentACustSolution = {<i0,i1,ShipmentACust[i0][i1]> | i0 in Months,i1 in ARoutesCust};
tuple ShipmentAPlantsSolutionT{ 
	int Months; 
route ARoutesPlant; 	float value; 
};
{ShipmentAPlantsSolutionT} ShipmentAPlantsSolution = {<i0,i1,ShipmentAPlants[i0][i1]> | i0 in Months,i1 in ARoutesPlant};
tuple ShipmentBPlantsSolutionT{ 
	int Months; 
route BRoutesPlant; 	float value; 
};
{ShipmentBPlantsSolutionT} ShipmentBPlantsSolution = {<i0,i1,ShipmentBPlants[i0][i1]> | i0 in Months,i1 in BRoutesPlant};
tuple ShipmentBExPlantsSolutionT{ 
	int Months; 
route BExternalRoutesPlant; 	float value; 
};
{ShipmentBExPlantsSolutionT} ShipmentBExPlantsSolution = {<i0,i1,ShipmentBExPlants[i0][i1]> | i0 in Months,i1 in BExternalRoutesPlant};
tuple InventoryASolutionT{ 
	int R; 
	string Aplants; 
	float value; 
};
{InventoryASolutionT} InventoryASolution = {<i0,i1,InventoryA[i0][i1]> | i0 in R0,i1 in Aplants};
tuple InventoryBSolutionT{ 
	int R; 
	string Bplants; 
	float value; 
};
{InventoryBSolutionT} InventoryBSolution = {<i0,i1,InventoryB[i0][i1]> | i0 in R0,i1 in Bplants};
tuple InventoryCSolutionT{ 
	int R; 
	string Cplants; 
	float value; 
};
{InventoryCSolutionT} InventoryCSolution = {<i0,i1,InventoryC[i0][i1]> | i0 in R0,i1 in Cplants};
tuple ProductionASolutionT{ 
	int Months; 
	string Aplants; 
	float value; 
};
{ProductionASolutionT} ProductionASolution = {<i0,i1,ProductionA[i0][i1]> | i0 in Months,i1 in Aplants};
tuple ProductionBSolutionT{ 
	int Months; 
	string Bplants; 
	float value; 
};
{ProductionBSolutionT} ProductionBSolution = {<i0,i1,ProductionB[i0][i1]> | i0 in Months,i1 in Bplants};
tuple ShipmentBCustSolutionT{ 
	int Months; 
	route BRoutesCust; 	
	float value; 
};
{ShipmentBCustSolutionT} ShipmentBCustSolution = {<i0,i1,ShipmentBCust[i0][i1]> | i0 in Months,i1 in BRoutesCust};
tuple ProductionCSolutionT{ 
	int Months; 
	string Cplants; 
	float value; 
};
{ProductionCSolutionT} ProductionCSolution = {<i0,i1,ProductionC[i0][i1]> | i0 in Months,i1 in Cplants};
tuple ShipmentCCustSolutionT{ 
	int Months; 
	route CRoutesCust; 	
	float value; 
};
{ShipmentCCustSolutionT} ShipmentCCustSolution = {<i0,i1,ShipmentCCust[i0][i1]> | i0 in Months,i1 in CRoutesCust};
tuple NumLotsShipAPlantsSolutionT{ 
	int Months; 
	route ARoutesPlant; 	
	int value; 
};
{NumLotsShipAPlantsSolutionT} NumLotsShipAPlantsSolution = {<i0,i1,NumLotsShipAPlants[i0][i1]> | i0 in Months,i1 in ARoutesPlant};
tuple NumLotsShipBPlantsSolutionT{ 
	int Months; 
	route BRoutesPlant; 	
	int value; 
};
{NumLotsShipBPlantsSolutionT} NumLotsShipBPlantsSolution = {<i0,i1,NumLotsShipBPlants[i0][i1]> | i0 in Months,i1 in BRoutesPlant};
tuple NumLotsShipBExPlantsSolutionT{ 
	int Months; 
	route BExternalRoutesPlant; 	
	int value; 
};
{NumLotsShipBExPlantsSolutionT} NumLotsShipBExPlantsSolution = {<i0,i1,NumLotsShipBExPlants[i0][i1]> | i0 in Months,i1 in BExternalRoutesPlant};
