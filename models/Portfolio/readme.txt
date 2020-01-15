Portfolio Optimization

This OPL model is a tool for investment portfolio optimization. The
model is formulated as a Quadratic Programming (QP) problem. A complete
description of the theory of portfolio investment that underlies this
formulation can be found in the book:

Portfolio Selection: Efficient Diversification of Investments by
Harry M. Markowitz

The model requires:

- a set of investment options with expected returns
- a positive semi-definite covariance matrix describing the
  dependencies between all investment options
- a user defined parameter indicating the preferred trade-off between
  risk and reward (called "rho")


How to run this example?
  * In CPLEX Studio IDE, import the example "Portfolio optimization", 
right-click on the run configuration "Basic Configuration" and select "Run this"
  * In the command line, execute "oplrun -p <Install_dir>\opl\examples\opl\models\Portfolio"
  
If you want to execute the script for the Benders Decomposition,
  * In CPLEX Studio IDE, right-click on the run configuration "Bender's Decomposition" and select "Run this"
  * In the command line, execute "oplrun -p <Install_dir>\opl\examples\opl\models\Portfolio "Bender's Decomposition""
