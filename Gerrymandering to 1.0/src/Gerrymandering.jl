push!(LOAD_PATH, "./src/")
#module Gerrymandering

using Colors
using PyCall
using Compose
using GraphPlot
using Statistics
using LightGraphs
using LinearAlgebra
using NearestNeighbors
#import Cairo, Fontconfig

include("graph_data.jl")
include("score.jl")
include("topology.jl")
include("draw_image.jl")
include("algorithms.jl")
include("simulated_annealing.jl")



push!(PyVector(pyimport("sys")["path"]), "./src/")
metis = pyimport("metis")
nx = pyimport("networkx")
gpd = pyimport("geopandas")
plt = pyimport("matplotlib.pyplot")


pickle_filename = "./data/wi14.gpickle"
shapef_filename = "./data/shapef/Wards_Final_Geo_111312_2014_ED.shp"


## Graph Paramaters
const num_parts = 8
const par_thresh = 0.01
const graph, graph_nx, shapefile, demographic =
    initialize_data(pickle_filename, shapef_filename)


const parity = sum(demographic.pop)/num_parts
const percent_dem = 100*sum(demographic.dem)/(sum(demographic.dem)+sum(demographic.rep))


## Simulated annealing parameters
const safe_percentage = 55
const safe_seats = 7 # Placeholder
const max_moves = 2
const max_radius = 2
const max_tries = 10
const max_swaps = 50
const alpha = 0.95
const temperature_steps = 5
const T_min = alpha^temperature_steps


throw_away_target = (num_parts*percent_dem-safe_percentage*safe_seats)/(num_parts-safe_seats)
const target = append!([throw_away_target for i in 1:(num_parts - safe_seats)],
    [safe_percentage for i in 1:safe_seats])


## Creates initial partition with Metis(Necessary for almost everything)
districts = initialize_districts()


## Uncomment to draw the graph
#@time draw_graph(graph, districts.dis, "before") # Graph
#@time draw_graph(graph_nx, districts.dis, "before") # Shape

## Records the data before the simulated annealing
info_init = record_info(districts)

#end #module Gerrymandering
@time districts, st = simulated_annealing(districts)

## Records the data after the simulated annealing
info = record_info(districts)
print_info(info_init)
print_info(info)
println(st)

# @time draw_graph(graph, districts.dis, "after") # Graph
# @time draw_graph(graph_nx, districts.dis, "after") # Shape
