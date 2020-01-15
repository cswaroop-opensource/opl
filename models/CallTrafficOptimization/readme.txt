Call Traffic Optimization

We consider a telecommunications network with a given volume of
origin-to-destination traffic. We want to balance the call volume
throughout the network. Additionally, we want to limit the number
of "hops", the number of links a packet must travel to reach its
destination. Because the more hops a call takes, the worse is its
quality.

We use a multicommodity network flow model. Each commodity represents
the traffic between an origin and destination. We use a "surplus"
variable to represent the amount that the flow may be increased without
violating the arc capacities. A single surplus value is used for all
commodities. We balance the traffic by maximizing the surplus capacity
over each origin-destination pair.

The file "calls.mod" executes two separate models. First, it runs
a simple multicommodity flow model. In this model, there is no limit to
the number of hops each packet may take. Once this model is finished,
the script loads a second multicommodity flow model where the network
has been expanded by the number of hops. The number of possible hops
is increased until the surplus capacity is the same as the model
with unlimited hops. Finally, the surplus capacity is removed from
the simple model and it is reoptimized so that the solution may be
displayed.

How to run this example?
  * In CPLEX Studio IDE, import the example "Call Traffic Optimization" 
right click on the run configuration "Configuration 1" and select "Run this"
  * In the command line, execute "oplrun -p <Install_dir>\opl\examples\opl\models\CallTrafficOptimization"
