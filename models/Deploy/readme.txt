Product Deployment

Plan multi-product deployment processes in a single period. The
objective is to minimize the sum of transportation costs and storage
costs. The transportation costs include the regular costs for all
flows and extra costs for the amount of flows that are in excess of
the capacities of the links. The storage costs are charged only for
the amount of goods over the site capacity.

For each article, the program computes the flow of goods on each
link in order to cover the demand and minimize the total cost. It
also provides the optimal acquisition plan for extra storage and
link capacities.


How to run this example?
  * In CPLEX Studio IDE, import the example "Product deployment" 
right click on the run configuration "Basic Configuration" and select "Run this"
  * In the command line, execute "oplrun -p <Install_dir>\opl\examples\opl\models\Deploy"