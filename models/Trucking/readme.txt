Trucking

A shipping company has a hub and spoke system. The shipments to be
delivered are specified by an originating spoke, a destination spoke,
and a shipment volume. The trucks have different types defined by a
maximum capacity, a speed, and a cost per mile. The model is to assign
right number of trucks to each route in order to minimize the cost of
transshipment and meet the volume requirements. There is a minimum
departure time and a maximum return time for trucks at a spoke, and an
load and unload time at the hub. Trucks of different types travel in
different speeds. Therefore, shipments are available at each hub in a
timely manner. Volume availability constraints are considered, that
is,the shipments that will be carried back from a hub to a spoke by a
truck must be available for loading before the truck leaves.

The assumptions are:

- exactly the same # of trucks that go from spoke to hub return from hub
  to spoke;
- each truck arrives at a hub as early as possible and leaves as late as
  possible; and
- the shipments can be broken arbitrarily into smaller packages and
  shipped through different paths.


How to run this example?
  * In CPLEX Studio IDE, import the example "Trucking", 
right-click on the run configuration "Basic Configuration" and select "Run this"
  * In the command line, execute "oplrun -p <Install_dir>\opl\examples\opl\models\Trucking"