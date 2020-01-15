Steel Production

This is a production and inventory model with backlogging. It helps
a plant manager to schedule production and inventories for multiple
products over time when facing limited resources such as labors,
materials, and machine capacities in each period. The objective is to
minimize the total cost of production, inventory, and backlogging. The
model can handle goals like reducing the backlogs at the end and
reaching the target inventory levels.

Features:

1) Bills of materials are considered.
2) The unit cost of production, inventory, and backlogging can change
   over time.
3) Backorders are allowed.
4) Bounds on the ending backorder levels can be enforced.
5) Target ending inventory levels can be specified.


How to run this example?
  * In CPLEX Studio IDE, import the example "Steel production", 
right-click on the run configuration "Basic Configuration" and select "Run this"
  * In the command line, execute "oplrun -p <Install_dir>\opl\examples\opl\models\Steelprod"
