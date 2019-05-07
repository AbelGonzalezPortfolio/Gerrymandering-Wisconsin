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
            graph_nx.add_edge(components[c][p][i]-1, main_component[idxs[p][i]][1]-1)
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


"""
    check_result(districts)

Check that demographics in DistrictData match actual demographic data.
If result are all 0 everything is correct.
"""
function check_result(districts::DistrictData)
    pop = [0 for i in 1:num_parts]
    rep = [0 for i in 1:num_parts]
    dem = [0 for i in 1:num_parts]
    for i in 1:nv(graph)
        d = districts.dis[i]

        pop[d] += demographic.pop[i]
        rep[d] += demographic.rep[i]
        dem[d] += demographic.dem[i]
    end
    return districts.pop - pop, districts.rep - rep, districts.dem - dem
end

"""
    get_lowest_district()

Returns the lowest possible for the data,
"""
function get_lowest_district()
    dem_share_arr = Float64[]
    for i in 1:nv(graph)
        dem_share = get_democratic_share(i)
        push!(dem_share_arr, dem_share)
    end
    if party == "dem"
        p = sortperm(dem_share_arr)
    elseif party == "rep"
        p = sortperm(dem_share_arr, rev = true)
    end
    n = collect(1:nv(graph))[p]

    to_draw_array = [false for i in 1:nv(graph)]
    pop = 0
    dem = 0
    rep = 0
    i = 1
    while pop < parity-1500
        to_draw_array[n[i]] = true
        pop += demographic.pop[n[i]]
        dem += demographic.dem[n[i]]
        rep += demographic.rep[n[i]]
        i += 1
    end
    if party == "dem"
        return dem/(dem+rep), pop
    elseif party == "rep"
        return rep/(dem+rep), pop
    end
end
