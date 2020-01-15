Bid Selection

Several bidders are bidding for a large contract. The contract is
divided into many tasks. Some tasks are critical and must be assigned
to a bidder. Others are not critical and a penalty is charged if
unassigned.

Each bidder can bid for a subset of tasks, and each task can be
optional or mandatory in the bid. An optional task bid can be accepted
separately, but mandatory task bids are all-or-nothing: mandatory
tasks must be all accepted or all rejected for each bid. The goal is
to find the cheapest assignment of tasks to bidders.


How to run this example?
  * In CPLEX Studio IDE, import the example bidding, 
right click on the run configuration "Default" and select "Run this"
  * In the command line, execute "oplrun -p <Install_dir>\opl\examples\opl\models\Bidding"
