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
/******************************************************************************
 * 
 * OPL Script for Investment Portfolio Problem
 *
******************************************************************************/

/*************************MODEL SUMMARY*****************************

  This OPL model is a tool for investment portfolio optimization. 
  The model is formulated as a Quadratic Programming (QP) problem.  
  A complete description of the theory of portfolio investment that 
  underlies this formulation can be found in the book:
  
  "Portfolio Selection:  Efficient Diversification of Investments", 
  Harry M. Markowitz, 2nd Ed, April 1991, Blackwell Pub
  
  and many of the articles in this text's bibliography.
   
  The model requires a set of investment options, their expected returns,
  a covariance matrix (must be positive semi-definite) summarizing the 
  dependencies between all investment options, a user defined parameter 
  indicating the preferred trade-off between risk and reward, and
  a user defined stopping criteria for the Benders iteration
  used to solve the QP.

*******************************************************************/
{string} Investments = ...;
float InvestReturn[Investments] = ...;
float  Covariance[Investments][Investments] = ...;
float Wealth = ...;
float EpsilonTolerance = ...;
float rho = ...;
float BigNumber = ...;

tuple t_BenderReturn {
  string invstmt;
  int i;
  float br;
}
{t_BenderReturn} BendersReturns = {};
tuple t_RHS {
  int id;
  float rhs;
}
{t_RHS} RHSset = {};

main {
    thisOplModel.settings.mainEndEnabled = true;
    thisOplModel.generate();

	// Investment data 
	var Investments = thisOplModel.Investments;
	var InvestReturn = thisOplModel.InvestReturn; // Expected return on investment
	var Covariance = thisOplModel.Covariance;  // Covariance matrix
	
	var Wealth = thisOplModel.Wealth; // Initial wealth
	var EpsilonTolerance = thisOplModel.EpsilonTolerance; // Stopping Criteria for the Benders iteration
	var rho = thisOplModel.rho; // Variance Penalty (increasing rho from 0.001 to 1.0 
                                //                   produces a distribution of funds 
                                //                   with smaller and smaller variability).
	var BigNumber = thisOplModel.BigNumber;
	
	writeln("Solve the portfolio problem using Benders decomposition");
	
	
	// Put in dummy Benders cut to get things started
	var NumberOfCuts = 1; // Number of Benders Cuts 
	var BendersReturns = thisOplModel.BendersReturns;
	var up = new Array();
	for (var i in Investments) 
	{
	   up[i] = 1;
	   BendersReturns.add(i,up[i],0);
	}
	var RHSup = 1;
	var RHSset = thisOplModel.RHSset;
	RHSset.add(RHSup,BigNumber);
	
	var Stop = 0; // Indicator Variable (Stop = 1 => Stop Iterating
	              //                     Stop = 0 => Continue Iterating
	
	var pbasis = new IloOplCplexBasis();
	
	while (Stop == 0) 
	{
		// Load portfolio model
		var portfolioSrc = new IloOplModelSource("portfolioModel.mod");
		var portfolioDef = new IloOplModelDefinition(portfolioSrc);
		var portfolio = new IloOplModel(portfolioDef,cplex);
		var portfolioData = new IloOplDataElements();
	    portfolioData.Investments = Investments;
	    portfolioData.InvestReturn = InvestReturn; 
	    portfolioData.Covariance = Covariance;  
	    portfolioData.Wealth = Wealth; 
	    portfolioData.EpsilonTolerance = EpsilonTolerance;
	    portfolioData.rho = rho;
	    portfolioData.BigNumber = BigNumber;
	    portfolioData.BendersReturns = BendersReturns;
	    portfolioData.RHSset = RHSset;
		portfolio.addDataSource(portfolioData);

	  	portfolio.generate();
	  	cplex.LPmethod = 2; // "dual"
	
	  	if (NumberOfCuts > 1)  
	    	pbasis.setBasis(cplex);
	  	if (cplex.solve()) 
	  	{
		     portfolio.postProcess();
	         pbasis.getBasis(cplex);
	         var currentAllocation = new Array();
		     var currentAlpha;
		     for (i in Investments) 
		     {
		       currentAllocation[i] = portfolio.allocation[i];
		     }
		     currentAlpha = portfolio.alpha;
		     var Objective = portfolio.Objective;
	         writeln("Objective Function Value = ", Objective);  
		     writeln("alpha                    = ", currentAlpha);
		     
		     if (Objective > currentAlpha) 
		     {
		        Stop = 1;
		        writeln("Error:  Outer Linearization in not an upper bound");
		        break;               
		     } 
		     else 
		     {
		       if(((currentAlpha - Objective)/Opl.abs(currentAlpha)) < EpsilonTolerance) 
		       {
	             Stop = 1;
		         writeln("\n\nThe Outer Linearization is tight enough.  Time to Stop Iterating.\n");
		         break;   
		       } 
		       else 
		       {
		         for (i in Investments) 
		         {
		           up[i] = up[i]+ 1;
		           var br = InvestReturn[i];
		           for (var j in Investments) 
		             br = br - rho*Covariance[i][j]*currentAllocation[j];
		           BendersReturns.add(i,up[i],br);  
		         }
		         RHSup = RHSup+1
		         var rhs = Objective;
		         for (j in Investments) {
		           for (var k in BendersReturns) {
		             if (k.invstmt==j && k.i== up[j])
		              rhs = rhs - k.br*currentAllocation[j];
		            }  
		         }  
		         RHSset.add(RHSup,rhs);
		         NumberOfCuts = NumberOfCuts + 1;
		         writeln("NumberOfCuts= ", NumberOfCuts);
		         writeln("Current relative gap = ",((currentAlpha - Objective)/Opl.abs(currentAlpha)));
	           }
	         }
		}
		else
		{
			writlen("Error:  LP did not return a solution");
		    Stop = 1;
		    break;   
		}
		portfolio.end();
	}
	writeln("Optimal Distribution of Funds:"); 
	for (i in Investments) 
	   writeln("allocation[",i, "]= ", currentAllocation[i]);  
	
	write("Expected Return on Investment: ");
	var expInvRet = 0;
	for (i in Investments)
	  expInvRet = expInvRet + InvestReturn[i]*currentAllocation[i];
	writeln(expInvRet);  
	
	write("Expected Variance of Investment: ");
	var expInvVar = 0; 
	for(i in Investments) 
	{
	  var tmp = 0 ; 
	  for (j in Investments)
	    tmp = tmp+Covariance[i][j]*currentAllocation[j];
	  expInvVar = expInvVar + currentAllocation[i]*tmp;
	}
	writeln(expInvVar);
}
