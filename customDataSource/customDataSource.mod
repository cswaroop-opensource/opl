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

int anInt = ...;
int anIntArray[1..3] = ...;
{float} floatIndices = {1.0, 1.5, 2.0, 2.5};
int anArrayIndexedByFloat[floatIndices] = ...;

{string} stringIndices = {"idx1", "idx2"};
int anArrayIndexedByString[stringIndices] = ...;

tuple t
{
 int i;
 float f;
 string s;
}

t aTuple = ...;
t aNamedTuple = ...;
{t} aTupleSet = ...;
t aTupleArray[1..3] = ...;
int anArrayIndexedByTuple[aTupleSet] = ...;
int a2DIntArray[1..2][1..3] = ...;
execute DISPLAY {
  writeln("anInt = ", anInt);
  writeln("anIntArray = ", anIntArray);
  writeln("anArrayIndexedByFloat = ", anArrayIndexedByFloat);
  writeln("anArrayIndexedByString = ", anArrayIndexedByString);
  writeln("aTuple = ", aTuple);
  writeln("aNamedTuple = ", aNamedTuple);
  writeln("aTupleSet = ", aTupleSet);
  writeln("aTupleArray = ", aTupleArray);
  writeln("anArrayIndexedByTuple = ", anArrayIndexedByTuple);
  writeln("a2DIntArray = ", a2DIntArray);
};
