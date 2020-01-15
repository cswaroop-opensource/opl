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

/*********************************************
 * The model shows a Lagrangian relaxation for 
 * a location-transportation problem.
 * The original MIP is decomposed into two problems 
 * in order to deduce a multiplier for a particular 
 * constraint based on Lagrange relaxation. 
 *
 * The main purpose is to show multiple optimization 
 * through modifications of different models 
 * existing in a single environment. 
 *********************************************/

int nbCities = ...;
range cities = 1..nbCities;

int build_limit = ...; 
int ship_cost[cities, cities]  = ...;
int send[cities] = ...;
int request[cities] = ...; 



main {
  function maxArray(arr) {
    var max;
    if (arr.size <= 0)
      max = undefined;
    else {  
      max = arr[1];
      for (var i=2;i<=arr.size;i++)
        if (arr[i]>max)
          max = arr[i];
    }
    return max;
  }  

  thisOplModel.settings.mainEndEnabled = true;
  thisOplModel.generate();
  var data = thisOplModel.dataElements;

  writeln("--- LP Relaxation ---");
  var m1Source = new IloOplModelSource("relax.mod");
  var m1Cplex = new IloCplex();
  var m1Def = new IloOplModelDefinition(m1Source);
  var m1Opl = new IloOplModel(m1Def,m1Cplex);
  m1Opl.addDataSource(data);
  m1Opl.generate();
  if (m1Cplex.solve()) {
    var LB = m1Cplex.getObjValue();
  }
  m1Opl.end();
  m1Def.end();
  m1Cplex.end();
  m1Source.end();

  var m2Source = new IloOplModelSource("LowerBound.mod");
  var m2Cplex = new IloCplex();
  var m2Def = new IloOplModelDefinition(m2Source);
  // model used to retrieve data common at each iteration
  var m2_init = new IloOplModel(m2Def,m2Cplex);
  m2_init.addDataSource(data);
  var dataMult = new IloOplDataSource("mult.dat");
  m2_init.addDataSource(dataMult);
  m2_init.generate();
  var data2 = m2_init.dataElements;  
  
  var m3Source = new IloOplModelSource("UpperBound.mod");
  var m3Cplex = new IloCplex();
  var m3Def = new IloOplModelDefinition(m3Source);
  // model used to retrieve data common at each iteration
  var m3_init = new IloOplModel(m3Def,m3Cplex);
  m3_init.addDataSource(data);
  var dataSBuild = new IloOplDataSource("SBuild.dat");
  m3_init.addDataSource(dataSBuild);  
  m3_init.generate();
  var data3 = m3_init.dataElements;
  
  // begin the lagrangian calculation here   
  writeln();
  writeln(" beginning the lagrangian calculation here... ");
  // maximum number of iteration we want to run the loop  
  var iter_limit = 20;
  
  // initialize arrays and variables used in the loop that follows
  var same = 0;
  var same_limit = 3;
  var slack = new Array(thisOplModel.nbCities);
  var temp = new Array(thisOplModel.nbCities);
  var mult = new Array(thisOplModel.nbCities);
  var UB = 0;
  for (var i in thisOplModel.cities) {
    slack[i] = 0.0;
    UB += maxArray(thisOplModel.ship_cost[i]);
    temp[i] = 0.0;
    mult[i] = 0.0;
  } 
  var scale = 1.0;
  var norm = 0.0;
  var step = 0.0;
  
  //arrays to store the UB, LB, scale and step values at each iteration
  var LBlog = new Array(iter_limit);
  var UBlog = new Array(iter_limit);
  var scalelog = new Array(iter_limit);
  var steplog = new Array(iter_limit);

  // executes LowerBound and UpperBound model 
  for(var k=1; k<=iter_limit;k++) {
    LBlog[k] = 0.0;
    UBlog[k] = 0.0;
    scalelog[k] = 0.0;
    steplog[k] = 0.0;
    writeln();
    writeln(" ITERATION:  " , k );  
    var m2 = new IloOplModel(m2Def,m2Cplex);
    for (i in thisOplModel.cities){
      data2.mult[i] = mult[i];
    }
    m2.addDataSource(data2);  
    m2.generate();
    var Lagrangian;
    if (m2Cplex.solve()) { 
      Lagrangian = m2Cplex.getObjValue();
    }
    
    norm = 0;
    for(i in thisOplModel.cities) {
      slack[i] = 0;
      for (var j in thisOplModel.cities) { 
        slack[i]+= m2.Ship[j][i];        
      }
      slack[i] -= thisOplModel.request[i];
      norm += Opl.pow(slack[i],2);
    }
    
 
    writeln("lower bound obj value: ", Lagrangian); 
    if (Lagrangian > LB + 0.000001) {
      LB = Lagrangian();
      same = 0;  
    } else {   
      same ++; 
    }
    if (same == same_limit) {
     scale = scale/2;
     same = 0;    
    }
    
    step = scale * ((UB - Lagrangian) / norm);
    
        
    var sum1 = 0;
    var sum2 = 0;
    for (i in thisOplModel.cities) {
      sum1 += m2.send[i] * m2.Build[i];
      sum2 += m2.request[i];
    }
    sum2 -= 1.0/Math.pow(10,8)
    if (sum1 >= sum2) {
      // solve the model to get the Upper Bound
      var m3 = new IloOplModel(m3Def,m3Cplex);
      // get the dvar values of the model just solved
      // to use in Upper Bound model
      for (i in thisOplModel.cities)
        data3.SBuild[i] = m2.Build[i];
      m3.addDataSource(data3);    
      m3.generate();      
      if (m3Cplex.solve()) {
        writeln("upper bound model value: ", m3Cplex.getObjValue());
        if (m3Cplex.getObjValue() < UB)
          UB = m3Cplex.getObjValue(); 
      }
      m3.end(); 
      
    }
    
    // update mult to pass it as input data to LowerBound model in next iteration
    for(j in thisOplModel.cities) {
      temp[j] = mult[j]; 
      if (temp[j] - (step * slack[j]) > 0 )
        mult[j] = temp[j] - (step * slack[j]) ;
      else 
        mult[j] = 0; 
    }
    LBlog[k] = LB;
    UBlog[k] = UB; 
    scalelog[k] = scale;
    steplog[k] = step; 
    
    m2.end();
    
  } //end of main "for loop"
  dataMult.end();
  m2_init.end();
  dataSBuild.end();
  m3_init.end();

  writeln("---------------------");
  writeln();
  write("LBlog = ");
  for (i=1;i<=iter_limit;i++)  
    writeln(LBlog[i]);
  writeln();  
  writeln("UBlob = ");
  for (i=1;i<=iter_limit;i++)  
    writeln(UBlog[i]);
  writeln();  
  writeln("scalelog = ");
  for (i=1;i<=iter_limit;i++) 
    writeln(scalelog[i]);
  writeln();  
  writeln("steplog = ");
  for (i=1;i<=iter_limit;i++) 
    writeln(steplog[i]);
    
  m3Def.end();
  m3Cplex.end();
  m3Source.end(); 
      
  m2Def.end();
  m2Cplex.end();
  m2Source.end();    
      
      
    
    
}
