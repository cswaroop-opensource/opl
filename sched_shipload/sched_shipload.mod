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

int capacity = 8;
int nbTasks = 34;
range Tasks = 1..nbTasks;
int duration[Tasks] = [3, 4, 4, 6, 5, 2, 3, 4, 3, 2,
           3, 2, 1, 5, 2, 3, 2, 2, 1, 1,
           1, 2, 4, 5, 2, 1, 1, 2, 1, 3,
           2, 1, 2, 2];

int demand[Tasks] = [4, 4, 3, 4, 5, 5, 4, 3, 4, 8,
         4, 5, 4, 3, 3, 3, 6, 7, 4, 4,
         4, 4, 7, 8, 8, 3, 3, 6, 8, 3,
         3, 3, 3, 3 ];

tuple Precedences {
   int pre;
   int post;
};

{Precedences} setOfPrecedences = {
    <1, 2>, <1, 4>, <2, 3>, <3, 5>, <3, 7>, <4, 5>, <5, 6>,
    <6, 8>, <7, 8>, <8, 9>, <9, 10>, <9, 14>, <10, 11>, <10, 12>,
    <11, 13>, <12, 13>,  <13, 15>, <13, 16>, <14, 15>, <15, 18>,
    <16, 17>, <17, 18>, <18, 19>, <18, 20>, <18, 21>, <19, 23>,
    <20, 23>, <21, 22>, <22, 23>, <23, 24>, <24, 25>, <25, 26>, 
    <25, 30>, <25, 31>, <25, 32>, <26, 27>, <27, 28>, <28, 29>,
    <30, 28>, <31, 28>, <32, 33>, <33, 34> };


dvar interval a[t in Tasks] size duration[t];

cumulFunction res = sum(t in Tasks) pulse(a[t],demand[t]);

execute {
		cp.param.FailLimit = 10000;
}

minimize max(t in Tasks) endOf(a[t]);
subject to {
   forall(p in setOfPrecedences)  
     endBeforeStart(a[p.pre], a[p.post]);
   res <= capacity;
};

