Airline Yield Management

This OPL model is a tool for O&D (Origin & Destination) 
based airline yield management. The model is formulated as 
a deterministic linear program. A complete description 
of yield management and a derivation of the model formulation 
that is the basis for this OPL model can be found in the article:

    Talluri, K. and van Ryzin, G.J. (1998), "An Analysis of Bid-Price
    Controls for Network Revenue Management," Management Science, 44,
    1577-1593.

The model requires a set of flight legs, a maximally acceptable
connect time, and a set of itineraries. The model includes an assert
that ensures that each itinerary is feasible with respect to a minimum
passenger connection time.

How to run this example?
  * In CPLEX Studio IDE, import the example "Airline yield management", 
right-click on the run configuration "Basic Configuration" and select "Run this"
  * In the command line, execute "oplrun -p <Install_dir>\opl\examples\opl\models\Yield"
