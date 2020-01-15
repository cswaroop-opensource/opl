Production Planning

This model involves production planning for a computer assembly
plant. The plant is equipped to assemble three models of computers,
called MultimediaBusiness, MultimediaHome, and BasicHome. Assembly
consists of placing components, such as CPUs and
modems, into the appropriate computers. The first step is to decide
the total number of each type of computer to build and from where
to acquire the necessary components. Once the number of computers
to build is decided, the next step is to decide how many to build,
sell and hold in inventory in each period.

For each type of computer there is a minimum and maximum demand per
period. The total demands can be calculated for each computer type as
sums of the demands of that computer type over all the periods. There
is also a plant capacity that limits the total number of computers
that can be built in any given period.

The array "computers" tells which types of components go in which
types of computers, among other things. The components can be bought
from outside suppliers or can be manufactured in house. The price of
a component is a piecewise linear function that depends on the number
of components ordered. The prices and suppliers for each component
are detailed in the array "components".

The objective in the first step is to maximize net profit while
satisfying the demand constraints. The cost of building the computers
is based on the cost of purchasing (or manufacturing) the components,
and each computer type has a selling price which is considered to be
gross profit.

Once the optimal solution to the first model is found, the number of
computers of each type to be built is known. The second step of the
model is used to determine how many of each computer type to build
in each period. For a given computer type, the sum of the number
built over the periods must match the quantity computed in the first
step. Moreover, the number of a particular type of computer built in
a period must be no more than the maximum allowed to be built in a
period. The number of computers to be sold must fall within the maximum
and minimum demand for that computer type for the given period. For
each period, the number held over from the previous period plus the
number built in the current period minus the ones sold in the period
must equal the number held over to the next period. The number of
computers held over in inventory must fall below the given maximum
inventory size.

The objective in the second step is to find a feasible solution.


How to run this example?
  * In CPLEX Studio IDE, import the example "Production planning", 
right-click on the run configuration "Main" and select "Run this"
  * In the command line, execute "oplrun -p <Install_dir>\opl\examples\opl\models\Prodplan Main"
