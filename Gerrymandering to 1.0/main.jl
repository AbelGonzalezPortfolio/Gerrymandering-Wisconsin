using LightGraphs, MetaGraphs

push!(LOAD_PATH, "$(pwd())")
using GraphData
di = districts.dis
mgraph = MetaGraph(graph)

for i in vertices(graph)
    set_prop!(mgraph, i, :pop, 296)
end

# To get pop of vertex
function get_time()
    mine = 0
    dr = 0
    for i in 1:1000
        mine += @elapsed [demographics.pop[i] for i in 1:nv(graph)]
        dr += @elapsed [get_prop(mgraph, i, :pop) for i in 1:nv(graph)]
    end
    println(mine/1000)
    println(dr/1000)
end
get_time()

# To get pop of district of that vertex
#println(districts.pop[di[20]])
