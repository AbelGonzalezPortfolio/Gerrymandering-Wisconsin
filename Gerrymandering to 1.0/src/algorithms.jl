"""
    connect_graph!(graph, pos)

Find all disconnected_components of a graph and connect them

Iterate through the sorted (by length) list of components. Then create a main
graph out of all of the components except the first one. Finally find the
closest points from the disconnected component to the main graph.
"""
function connect_graph!(graph::SimpleGraph, graph_nx::PyObject, pos::Array)
    components = connected_components(graph)
    sort!(components, by=length)
    no_connected = length(connected_components(graph))
    for c in 1:no_connected-1
        main_component = collect(Iterators.flatten(components[c+1:end]))
        main_component_arr = Float64[pos[j][i] for i in 1:2, j in main_component]
        disconnected_component = Float64[pos[j][i] for i in 1:2, j in components[c]]

        kdtree = KDTree(main_component_arr)
        idxs, distance = knn(kdtree, disconnected_component, 1)

        p = sortperm(distance)
        for i in 1:Int(ceil(length(components[c])/10))
            add_edge!(graph, components[c][p][i], main_component[idxs[p][i]][1])
            graph_nx[:add_edge](components[c][p][i]-1, main_component[idxs[p][i]][1]-1)
        end
    end
end


"""
    all_parity(pop)

Check whther all of the district's populations are under the parity threshold
returns true or false
"""
function all_parity(pop::Array{Int64})
    parity_bool = true
    for i in 1:num_parts
        if !(abs(pop[i] - parity)/parity < par_thresh)
            parity_bool = false
            break
        end
    end
    return parity_bool
end


"""
    dem_percentages(districts)

Create list of democratic percentages and returns sorted list.
"""
function dem_percentages(districts::DistrictData)
    dem_percentages = []
    for i in 1:num_parts
        push!(dem_percentages, 100*(districts.dem[i]/(districts.dem[i]+districts.rep[i])))
    end
    return sort!(dem_percentages)
end
