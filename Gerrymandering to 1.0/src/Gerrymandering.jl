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
using ConcaveHull
using StatsBase
using Random
#using Debugger

struct DemographicData
    pos::Array{Tuple{Float64, Float64}, 1}
    pop::Array{Int64,1}
    dem::Array{Int64,1}
    rep::Array{Int64,1}
    area::Array{Float64,1}
end

mutable struct DistrictData
    dis::Array{Int64,1}
    dem::Array{Int64,1}
    rep::Array{Int64,1}
    pop::Array{Int64,1}
    dis_arr::Array{Array{Int64,1},1}
end
include("graph_data.jl")
include("score.jl")
include("topology.jl")
include("draw_image.jl")
include("algorithms.jl")
include("simulated_annealing.jl")
include("initial_districts.jl")


push!(PyVector(pyimport("sys")."path"), "./src/")
metis = pyimport("metis")
nx = pyimport("networkx")
gpd = pyimport("geopandas")
plt = pyimport("matplotlib.pyplot")


pickle_filename = joinpath("data", "wi14.gpickle")
shapef_filename = joinpath("data","shapef", "Wards_Final_Geo_111312_2014_ED.shp")


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
const non_safe_seats = num_parts - safe_seats
const max_moves = 4
const max_radius = 1
const max_tries = 5
const max_swaps = 600
const alpha = 0.95
const temperature_steps = 150
const T_min = alpha^temperature_steps


const throw_away_target = (num_parts*percent_dem-safe_percentage*safe_seats)/(num_parts-safe_seats)
const target = append!([throw_away_target for i in 1:(num_parts - safe_seats)],
    [safe_percentage for i in 1:safe_seats])

## Creates initial partition with Metis(Necessary for almost everything)
districts = initialize_districts()
dem_percentages(districts)

## Uncomment to draw the graph
draw_graph(graph, districts.dis, "before") # Graph
draw_graph(graph_nx, districts.dis, "before") # Shape

## Records the data befo re the simulated annealing
info_init = record_info(districts)

## Redistrict the graph
@time districts = simulated_annealing(districts)

## Records the data after the simulated annealing
info = record_info(districts)
print_info(info_init)
print_info(info)
#
draw_graph(graph, districts.dis, "after") # Graph
draw_graph(graph_nx, districts.dis, "after") # Shape
# #districts = initialize_districts()
#end
