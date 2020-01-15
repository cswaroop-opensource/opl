Fleet Assignment

The fleet assignment problem consists of assigning aircraft (fleets) to
flights in order to maximize net profit. Given a flight schedule, which
is a set of flight segments with specified departure and arrival times,
and a set of aircraft, the fleet assignment problem is to determine
which aircraft or fleet type should fly each flight segment.

Fleet type is a particular class of aircraft defined by:

1) seating capacity 
2) fuel consumption 
3) other factors that can affect revenues and costs. 

The objective is to maximize revenue minus operating costs.

1) Revenue is a function of the demand for the segment, the cost of
   tickets and the seating capacity of the plane.
2) Operating costs depend on the size and efficiency of the plane and
   the distance of the segment.

Opportunity (spill) costs include losing spilled (bumped) passengers due
to excess demand. These costs are a function of both demand for a flight
and aircraft capacity.

The constraints on the assignment model: 

1) There must be a plane at the airport for the flight. 
2) One-stop flights must have both legs assigned to the same fleet.
3) Each airport must begin and end the week with the same distribution
   of planes.

"Source" and "sink" airports are added so that we can build the third
type of constraint.

Reference:

"Recent Advances in Exact Optimization of Airline Scheduling Problems"
by R.A. Rushmeier, K.L.Hoffman, M.Padberg.


How to run this example?
  * In CPLEX Studio IDE, import the example "Fleet Assignment" 
right click on the run configuration "Basic Configuration" and select "Run this"
  * In the command line, execute "oplrun -p <Install_dir>\opl\examples\opl\models\Fleet"