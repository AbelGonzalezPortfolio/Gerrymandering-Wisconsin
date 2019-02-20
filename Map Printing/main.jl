using PyCall
using LightGraphs, MetaGraphs
using GraphPlot
using Compose
using Colors
import Cairo

push!(PyVector(pyimport("sys")["path"]), "")

nx = pyimport("networkx")
pickle = pyimport("pickle")

function read_pickle_graph()
    filepath = "/home/abel/Documents/MTH-398-Independent-Study/Map Printing/whole_map_no_discontiguos.gpickle"
    graph = nx[:read_gpickle](filepath)
    return graph
end

function convert_to_mg(nx_graph)
    pop = collect(values(sort(Dict{Integer, Integer}(nx[:get_node_attributes](nx_graph, "pop")))))
    pos = collect(values(sort(Dict{Integer, Tuple{Float64,Float64}}(nx[:get_node_attributes](nx_graph, "pos")))))
    dem = collect(values(sort(Dict{Integer, Integer}(nx[:get_node_attributes](nx_graph, "rep")))))
    area = collect(values(sort(Dict{Integer, Integer}(nx[:get_node_attributes](nx_graph, "area")))))
    adj_matrix_nx = nx[:to_numpy_matrix](nx_graph)
    graph = Graph(adj_matrix_nx)
    for i in area
        println(typeof(i))
    end
    m_graph = MetaGraph(graph)

    for v in vertices(m_graph)
        set_props!(m_graph, v, Dict(:pop=>pop[v], :x=>pos[v][1], :y=>pos[v][2]))
    end
    return m_graph
end

function draw_graph(m_graph)
    color = colormap("Blues")

    nodefillc = []
    node_labels = collect(vertices(m_graph))
    pos_x = Array{Float64}(undef,0)
    pos_y = Array{Float64}(undef,0)
    for i in vertices(m_graph)
        push!(nodefillc, color[get_prop(m_graph, i, :pop)*99÷3905+1])
        push!(pos_x, get_prop(m_graph, i, :x))
        push!(pos_y, -get_prop(m_graph, i, :y))
    end
    draw(SVG("whole_map.svg"), gplot(m_graph, pos_x, pos_y, nodefillc=nodefillc))
    #gplot(m_graph, pos_x, pos_y)
end

nx_graph = read_pickle_graph()
m_graph = convert_to_mg(nx_graph)
draw_graph(m_graph)
