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

int n = 300;
range r = 1..n;
int Values1[r][r];

execute INIT_Values1 {
  for( var i in r )
    for( var j in r )
      if ( i == 2*j ) 
        Values1[i][j] = i+j;
  writeln(Values1);          
}

int Values2[i in r][j in r] = (i==2*j) ? i+j : 0;

execute INIT_Values2 {
  writeln(Values2);
}

tuple T {
  int i;
  int j;
}
{T} indexes = { < i , 2 * i > | i in r };
int Values3[<i,j> in indexes] = i+j;

execute INIT_Values3 {
  writeln(Values3);
}
