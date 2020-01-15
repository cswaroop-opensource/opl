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

int RollWidth = ...;


range Items = 1..5;

int Size[Items] = ...;
float Duals[Items] = ...;

dvar int Use[Items] in 0..100000;


minimize
  1 - sum(i in Items) Duals[i] * Use[i];
subject to {
  ctFill:
    sum(i in Items) Size[i] * Use[i] <= RollWidth;
}
