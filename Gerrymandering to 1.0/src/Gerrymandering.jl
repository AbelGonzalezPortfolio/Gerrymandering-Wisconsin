push!(LOAD_PATH, "./src/")
module Gerrymandering

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
using Plots
using Pandas


export gerrymander_state

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
include("compactness.jl")
include("tmp.jl")


push!(PyVector(pyimport("sys")."path"), "./src/")
metis = pyimport("metis")
nx = pyimport("networkx")
gpd = pyimport("geopandas")
plt = pyimport("matplotlib.pyplot")
pd = pyimport("pandas")
widgets = pyimport("matplotlib.widgets")

## Graph Paramaters
const num_parts = 8
const par_thresh = 0.01
const party = "dem"
const pickle_filename = joinpath("data", "wi16.gpickle")
const shapef_filename = joinpath("data", "wi16", "wi16.shp")

## Simulated annealing parameters
const safe_percentage = 55
const safe_seats = 7 # It would be cool if we could calculate it
const max_moves = 4
const max_radius = 1
const max_tries = 5
const max_swaps = 600
const alpha = 0.95
const temperature_steps = 150


const T_min = alpha^temperature_steps
const graph, graph_nx, shapefile, demographic =
    initialize_data(pickle_filename, shapef_filename)
const parity = sum(demographic.pop)/num_parts
const percent_dem = 100*sum(demographic.dem)/(sum(demographic.dem)+sum(demographic.rep))
const non_safe_seats = num_parts - safe_seats
const throw_away_target = (num_parts*percent_dem-safe_percentage*safe_seats)/(num_parts-safe_seats)
const target = append!([throw_away_target for i in 1:(num_parts - safe_seats)],
    [safe_percentage for i in 1:safe_seats])


"""
    gerrymander_state()

Main function, creates initial districts and tries to gerrymander the state
"""
function gerrymander_state()
    ## Creates initial partition with Metis
    districts = initialize_districts_metis()

    draw_shape(districts, "0")
    info_init = record_info(districts)

    @time districts = simulated_annealing(districts)

    info = record_info(districts)
    print_info(info_init)
    print_info(info)

    println(check_result(districts))
end

gerrymander_state()
end #module Gerrymandering
