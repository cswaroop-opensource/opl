Basketball Scheduling

This is an example using constraint programming to schedule the
ACC basketball conference. The original model is described by
G.L. Nemhauser and M.A. Trick, "Scheduling a Major College Basketball
Conference", Operations Research, 46: 1-8 (1998). Martin Henz created
an alternate formulation using constraint programming in M. Henz,
"Scheduling a Major College Basketball Conference - Revisited",
Operations Research, 49: 163-168 (2001). This has been adapted for OPL.

Execute the "Main" run configuration in "basketballscheduling" project. 
It contains a script, which schedules the ACC using the
constraints described in the Nemhauser/Trick and Henz papers.

The script uses 4 models files (.mod):

- common.mod contains the declaration and initialization of data common to all models.

- pattern.mod generates potential home/away patterns that teams can play
  to. The rules were described in the Nemhauser/Trick paper. The output
  of running pattern.mod is used to create the array patterns[], which
  is input data for patset.mod. These are the same 38 patterns that are
  in the Nemhauser/Trick paper.

- patset.mod generates pattern sets, which are groups of 9 patterns that
  represent a feasible schedule (right number of home/away games for
  each round, etc.). The output of running patset creates the array
  patset[] so that 17 pattern sets are obtained. This should be the same
  17 pattern sets generated in the Nemhauser/Trick paper.

- acc.mod uses both the pattern[] and patset[] arrays as input data,
  combined with weekday.dat and weekend.dat.

This is what generates feasible schedules (i.e., assignments of teams
to pattern sets, and hence a schedule). There are a couple of ways
to do this, dependent on how you want to choose the "best" schedule.

What was done here is that an objective function was created that
computes the number of A-slots, B-slots, and "bad slots" for a
given schedule, using the description at the top of page 4 of the
Nemhauser/Trick paper. Then the objective used is number_of_A_slots -
2*number_of_bad_slots . The schedule that gets computed has 7 A slots
for February, and no bad slots. By one measure, you could say it is
"better" than the schedule from the Nemhauser/Trick paper, but the
objective function for schedule quality is highly subjective.

Alternatively, one could just not use an objective, and loop through
all the possible schedules and have CPLEX Studio print each one of
them out.

How to run this example?
  * In CPLEX Studio IDE, import the example "Basketball Scheduling", 
right click on the run configuration "Main" and select "Run this"
  * In the command line, execute "oplrun -p <Install_dir>\opl\examples\opl\models\BasketballScheduling Main"

