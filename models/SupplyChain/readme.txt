Multistage Supply Chain

Consider a three-echelon supply chain. Plant As produce primary
products A, which can be either fed into Plant Bs to produce
intermediary products B or sold on spot markets. There are customers
for product B, which is also an input to the final product C. There
are customers for product C and Plant Cs may have external sources
for B. A diagram is presented in the excel file "WedgeData.xls".

At each stage, a conversion ratio applies from input materials to
products. Manufacturing process is not perfectly reliable, and only
certain percentage of the production is good. There are processing
capacities and storage capacities for both raw materials and product.

The objective is to minimize the production and logistics costs to
meet the demand.


How to run this example?
  * In CPLEX Studio IDE, import the example "Multi-stage supply chain", 
right-click on the run configuration "Basic Configuration" and select "Run this"
  * In the command line, execute "oplrun -p <Install_dir>\opl\examples\opl\models\SupplyChain"