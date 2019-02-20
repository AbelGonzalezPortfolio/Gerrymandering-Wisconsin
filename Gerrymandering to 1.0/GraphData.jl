#=
Abel Gonzalez
02/18/19

This module reads the graph data using pycall and converts the networkx graph
into a julia graph
=#
module GraphData

using PyCall
using LightGraphs
import Base.convert

export graph, demographics, districts

push!(PyVector(pyimport("sys")["path"]), "")
nx = pyimport("networkx")
pickle = pyimport("pickle")


function read_pickle_graph(filename)
    #=Function uses pycall to generate a networkx graph from the gpickle file
    previoulsy created
    Input{String}: filename with path included
    Output{PyObject}: networkx graph=#

    graph = nx[:read_gpickle](filename)
    return graph
end


function convert_graph(nx_graph::PyObject)
    #=Function that converts from a networkx Graph to a lighgraphs Graph
    Input: Light graph function, the nx_graph
    Output: Ligh graph graph=#

    matrix_nx = nx[:to_numpy_matrix](nx_graph::PyObject)
    return Graph(matrix_nx)
end

function get_demographics(nx_graph::PyObject)
    #=Function obtains the demographic information from networkx Graph
    and saves as a struct for ease of access
    Input= networkx graph
    Output= Struct Demographics_data
    =#
    pop = collect(values(sort(Dict{Integer, Int64}(nx[:get_node_attributes](nx_graph, "pop")))))
    pos = collect(values(sort(Dict{Integer, Tuple{Float64,Float64}}(nx[:get_node_attributes](nx_graph, "pos")))))
    dem = collect(values(sort(Dict{Integer, Int64}(nx[:get_node_attributes](nx_graph, "dem")))))
    rep = collect(values(sort(Dict{Integer, Int64}(nx[:get_node_attributes](nx_graph, "rep")))))
    area = collect(values(sort(Dict{Integer, Int64}(nx[:get_node_attributes](nx_graph, "rep")))))

    demographics = Demographics_data(pos, pop, dem, rep, area)
    return demographics
end

function get_districts(graph, no_districts, demographics)
    d_assignment = 1
    dis = []
    pop = zeros(Int64, no_districts)
    dem = zeros(Int64, no_districts)
    rep = zeros(Int64, no_districts)

    #Temporal until we get real districts
    for i in vertices(graph)
        if i > nv(graph)*(d_assignment/no_districts)
            d_assignment += 1
        end
        push!(dis, d_assignment)
    end
    for i in vertices(graph)
        pop[dis[i]] += demographics.pop[i]
        dem[dis[i]] += demographics.dem[i]
        rep[dis[i]] += demographics.rep[i]
    end
    districts = District_data(dis, dem, rep, pop)
end

struct Demographics_data
    pos::Array{Tuple{Float64, Float64}}
    pop::Array{Int64}
    dem::Array{Int64}
    rep::Array{Int64}
    area::Array{Float64}
end

mutable struct District_data
    dis::Array{Int64}
    dem::Array{Int64}
    rep::Array{Int64}
    pop::Array{Int64}
end

no_districts = 3

filename = "$(pwd())/data/wi_14.gpickle"
nx_graph = read_pickle_graph(filename)
graph = convert_graph(nx_graph)
demographics = get_demographics(nx_graph)
districts = get_districts(graph, no_districts, demographics)
end
