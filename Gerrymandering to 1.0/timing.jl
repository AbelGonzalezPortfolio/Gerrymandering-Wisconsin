module timing

using LightGraphs, MetaGraphs

push!(LOAD_PATH, "$(pwd())")

using GraphData
export get_time

di = districts.dis

function fill_graph!(mgraph)
    for i in vertices(graph)
        set_prop!(mgraph, i, :pop, 296)
    end
end

# To get pop of vertex
function get_time()
    mgraph = MetaGraph(graph)
    fill_graph!(mgraph)
    mine = 0
    dr = 0
    for i in 1:1000
        dr += @elapsed [get_prop(mgraph, i, :pop) for i in 1:nv(graph)]
        mine += @elapsed [demographics.pop[i] for i in 1:nv(graph)]
    end
    println(mine/1000)
    println(dr/1000)
end

end
