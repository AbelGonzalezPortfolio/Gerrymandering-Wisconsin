# Gerrymandering-Wisconsin
This repository aimed to Gerrymander the state of Wisconsin following the continuity and equal population law.

This program uses a simulated annealing algorithm made from scratch to gerrymander the state of Wisconsin. The goal was to show
that the current law of continuity and similar populations in each district does not impact the ability to gerrymander the state.
The data being used has de shape as well as democratic and republican share in the wards level.

The shape data is transformed into a network graph in order to speed up the algorithm, which then creates an initial distribution using the package metis to get as close as possible to equal population. Then changes are made to the districts in order to approach the desired results.

In the results folder there is a video of the algorithm in process.
