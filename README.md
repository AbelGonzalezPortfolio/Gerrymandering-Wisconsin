# Gerrymandering-Wisconsin
This repository aimed to Gerrymander the state of Wisconsin following the continuity and equal population law.

This program uses a simulated annealing algorithm made from scratch to gerrymander the state of Wisconsin. The goal was to show
that the current law of continuity and similar populations in each district does not impact the ability to gerrymander the state.
We used data for democrats and republicans share in the wards level as well as the shape information.

We transform the shape data into a netork graph in order to speed up the algorithm. Which then creates an initial distribution
using the package metis to get as close as possible to equal population. Then we start making changes to the districts in order
to approach the desired results.

In the results folder there is a video of the algorithm in process.
