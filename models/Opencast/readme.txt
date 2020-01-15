Opencast Mining

Opencast mining from Model Building in Mathematical Programming
by H.P. Williams. The basic problem is to mine within a soil for
metals. The mining is done in levels in an upturned pyramid. The blocks
that can be mined overlap each other partially, level to level. Blocks
on one level must be mined before the blocks on the level below.

This is modeled by assigning an (x,y) center to each block, where each
block is 2 units wide. A block overlaps if its corners are the center
of the block below. The bottom level is centered at (0,0). The level
above has 4 blocks, centered 1 unit from the origin. The next level
has 9 blocks, centered at the origin, and 2 units from the origin, etc.

Each block has a purity level that corresponds to expected revenue,
but there is a cost for digging down deeper. The model uses variables
extract[] to represent whether each block is mined, and the xyz[]
variables are auxiliary to provide an interesting visualization.


How to run this example?
  * In CPLEX Studio IDE, import the example "Opencast mining", 
right click on the run configuration "Basic Configuration" and select "Run this"
Be sure to look at the "XYZ" array as the answer.
  * In the command line, execute "oplrun -p <Install_dir>\opl\examples\opl\models\Opencast"

