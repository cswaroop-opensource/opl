Assembly Sequencing

This model is to determine the order of a set of custom computers to
be processed on an assembly line. Once the order is assigned, it is
kept from start to finish. The custom computers have different lists
of components to be contained, which are given in the array "computer".

The ordering of the computers is constrained by the following assembly
rules for each component:

1) There must be a minimum number of computers in a row that need this
   component ("minSeq");
2) There is an upper bound on the number of computers in a row that can
   have that component;
3) Each component also has a list of illegal followers
   ("illegalFollowers") so that the next computer cannot have a
   component which appears in the illegal followers list for this
   component.

These restrictions may be due to set-up times, bottlenecks, etc.


How to run this example?
  * In CPLEX Studio IDE, import the example "Assembly Sequencing", 
right-click on the run configuration "Basic Configuration" and select "Run this"
  * In the command line, execute "oplrun -p <Install_dir>\opl\examples\opl\models\AssemblySequencing"
