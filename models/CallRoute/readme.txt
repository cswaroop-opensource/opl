Call Routing

Construct a "route" from a set of end-to-end paths so that the
collection of paths satisfies the blocking criterion at a minimum
cost. This extends the two-arc path optimization algorithm in chapter
4 of Dynamic Routing in Telecommunications Networks by Gerald R. Ash
(McGraw Hill). This is a dynamic programming model with two global
constraints:

1. All paths are different
2. Blocking criterion

The "allDifferent" constraint is implemented explicitly to allow
duplicates of a dummy value at the end of the sequence. 
Pseudorandom cost and blocking data are generated within
the model.


How to run this example?
  * In CPLEX Studio IDE, import the example "Call route", 
right-click on the run configuration "Basic Configuration" and select "Run this"
  * In the command line, execute "oplrun -p <Install_dir>\opl\examples\opl\models\CallRoute"