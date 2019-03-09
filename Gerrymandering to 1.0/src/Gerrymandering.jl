push!(LOAD_PATH, "./src/")
module Gerrymandering

using LightGraphs
#using Colors
#using Compose
using GraphPlot
using PyCall
using NearestNeighbors
using LinearAlgebra
#import Cairo, Fontconfig


export graph, graph_nx, shapefile, demographic, districts, par_tresh, target, parity, par_thresh, num_parts

include("graph_data.jl")
include("draw_image.jl")
include("algorithms.jl")
include("score.jl")



push!(PyVector(pyimport("sys")["path"]), "./src/")
metis = pyimport("metis")
nx = pyimport("networkx")
gpd = pyimport("geopandas")
plt = pyimport("matplotlib.pyplot")


pickle_filename = "./data/wi14.gpickle"
shapef_filename = "./data/shapef/Wards_Final_Geo_111312_2014_ED.shp"


## Graph Paramaters
global percent_dem = 50
const num_parts = 8
const par_thresh = 0.01
const graph, graph_nx, shapefile, demographic =
    initialize_data(pickle_filename, shapef_filename)
const parity = sum(demographic.pop/num_parts)

## Simulated annealing parameters
const safe_percentage = 55
const safe_seats = 7 # Placeholder

need_name = (num_parts*percent_dem-safe_percentage*safe_seats)/(num_parts - safe_seats)
const target = append!([need_name for i in 1:(num_parts - safe_seats)],
    [safe_percentage for i in 1:safe_seats])

## Creates initial partition with Metis(Necessary for almost everything)
districts = initialize_districts()

## Uncomment to draw the graph
#@time draw_graph(graph, districts.dis) # Graph
#@time draw_graph(graph_nx, districts.dis) # Shape
districts.pop
score = get_score(districts)


end  # module Gerrymandering
