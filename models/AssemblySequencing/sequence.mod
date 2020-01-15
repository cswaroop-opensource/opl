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

/*  ----------------------------------------------------
OPL Model for Computer Assembly Line Sequencing Example 

This model is to determine the processing order of a set of custom 
computers on an assembly line. Once the order is assigned, 
it is kept from start to finish.  The custom computers have 
different lists of components to be contained, which are given 
in the array "computer".  

The ordering of the computers is constrained by the assembly 
rules of each component:  
1) There must be a minimum number of computers in a row 
   that need this component ("minSeq"); 
2) There is an upper bound on the number of computers in a row 
   that can have that component;  
3) Each component also has a list of illegal followers 
   ("illegalFollowers") meaning that if a computer has this 
   component, then the next computer cannot have a component 
   that appears in the illegal followers list of this component.  
These restrictions may be due to set-up times, bottlenecks, etc.

----------------------------------------------------- */
using CP;


execute{
	}

// The number of computers we need to build
int     nComputers  = ... ;
range   AllComputers = 1..nComputers ;

{string} ComponentTypes = ...; ;

tuple ComponentInfo
{
   int maxSeq;
   int minSeq;
   {string} illegalFollowers;
};

// Assembly rules for each component 
ComponentInfo    components[ComponentTypes]  = ...;

// List of components needed by a computer
{string} computer[AllComputers] = ...;
assert {
   forall (a in AllComputers)
     forall (s in computer[a])
        s in ComponentTypes;
}

// Components that are actually in computers to build
{string} UsedComponentTypes = { c | c in ComponentTypes, a in AllComputers : c in computer[a] };
assert {
   forall (u in UsedComponentTypes)
      u in ComponentTypes;
}

// Components that have illegal followers
{string} HasIllegalFollowers = { c | c in UsedComponentTypes, d in UsedComponentTypes 
                                     : d in components[c].illegalFollowers };
assert {
   forall (u in HasIllegalFollowers)
      u in ComponentTypes;
}                                     
// Which computers contain the component
{int}  componentInComputer[c in UsedComponentTypes] = {i | i in AllComputers : c in computer[i] };
assert {
   forall (c in UsedComponentTypes)
      forall (u in componentInComputer[c]) {
         u >=1;
         u <= nComputers;
      }
}

/*  ----------------------------------------------------
 *   Variables:
 *   order -- if order[i]=j, it means computer[i] is jth in the 
 *          sequence
 *   --------------------------------------------------- */
dvar int order[AllComputers] in AllComputers;

/*  ----------------------------------------------------
 *   Constraints
 *   --------------------------------------------------- */

subject to
{
   allDifferent(order);

   // Min/Max sequences
   forall (c in UsedComponentTypes) {
      forall ( p in 1..nComputers - components[c].maxSeq )
         // If there are maxSeq # of component c in a row starting from position p to p+maxSeq-1, 
         // => the (p+ maxSeq)th computer must not contain component c.  
         (sum(s in p..p+components[c].maxSeq-1) (order[s] in componentInComputer[c]) == components[c].maxSeq) 
         => 
         //not (order[p+components[c].maxSeq] in componentInComputer[c]);
         order[p+components[c].maxSeq] not in componentInComputer[c];
        
      // The components in the 1st computer must appear at least minSeq # of times in a row.   
      (order[1] in componentInComputer[c]) 
      => 
      ((sum( s in 1..components[c].minSeq) (order[s] in componentInComputer[c])) >= components[c].minSeq);


      forall ( p in 1..nComputers-components[c].minSeq )
            // Every component that is not in computer p but appears in computer p+1
            // must appear minSeq # of times in a row from p+1 to p+minSeq.  
            (((order[p] not in componentInComputer[c])
               && (order[p+1] in componentInComputer[c])) =>
            (sum(s in p+1..p+components[c].minSeq) (order[s] in componentInComputer[c]))
                 == components[c].minSeq);
   };

   forall (c in HasIllegalFollowers) // for component c that has an illegal follower,
      forall( p in 1..nComputers-1)  // for computer p
         forall( c2 in UsedComponentTypes : c2 in components[c].illegalFollowers) 
            // If computer p has component c and c2 is c's illegal follower => 
            // c2 must not be in computer p+1 
            (order[p] in componentInComputer[c] )  =>
               (order[p+1] not in componentInComputer[c2]);
               
};

