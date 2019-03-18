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

function simulated_annealing(districts)
    bunch_radius = max_radius
    current_score = get_score(districts)
    println("Initial Score: ", current_score)
    T = 1.0
    steps_remaining = Int(round(temperature_steps))
    swaps = [max_swaps, 0]
    while T > T_min
        i = 1
        while i <= swaps[1]
            new_districts = deepcopy(districts)
            new_districts = shuffle_nodes(new_districts, bunch_radius)

            new_score = get_score(new_districts)

            ap = acceptance_prob(current_score, new_score, T)
            if ap > rand()
                if new_score < current_score
                    #println("Score: ", new_score)
                end
                swaps[2] += 1
                districts = new_districts
                current_score = new_score
            end
            i += 1
        end
        steps_remaining -= 1
        bunch_radius = Int(floor(max_radius - (max_radius / temperature_steps) * (temperature_steps - steps_remaining)))
        #par_thresh = 0.1 - ((0.1-0.01)/temperature_steps)*(temperature_steps - steps_remaining)
        # println("-------------------------------------")
        # println("Steps Remaining: ", steps_remaining)
        # println("Bunch Radius: ", bunch_radius)
        T = T * alpha
        # println("T = ", T)
        # dem_percents = sort!(dem_percentages(districts))
        # println("Dem percents: ", sort(dem_percents))
        # println("Parity: ", [100.0*((p-parity)/parity) for p in sort(districts.pop)])
        # println("-------------------------------------")
    end
    return districts
end

function acceptance_prob(old_score, new_score, T)
    ap = exp((old_score - new_score)/T)
    if ap > 1
        return 1
    else
        return ap
    end
end

function shuffle_nodes(districts, bunch_radius)
    districts_tmp = deepcopy(districts)
    part_to = rand(1:num_parts)
    num_moves = rand(1:max_moves)

    for i in 1:num_moves
        part_to, success = move_nodes(districts, part_to, bunch_radius)
        if success == false
            return districts_tmp
        end
    end
    return districts
end

function move_nodes(districts, part_to, bunch_radius)
    boundary = collect(get_boundary(districts.dis_arr[part_to]))
    for i in 1:max_tries
        base_node_to_move = rand(boundary)
        part_from = districts.dis[base_node_to_move]

        bunch_to_move = get_bunch(bunch_radius, districts, base_node_to_move, part_from)

        if check_connected_without_bunch(districts, part_from, bunch_to_move)
            do_move(districts, part_to, part_from, bunch_to_move)
            return part_from, true
        end

    end
    return part_to, false
end

function get_bunch(bunch_radius, districts, base_node_to_move, part_from)
    radius = bunch_radius
    connected = false
    bunch_to_move = [] #Declare for access to local scope variable in loop.
    while connected == false
        bunch_to_move = Set(neighborhood(graph, base_node_to_move, radius))
        bunch_to_move = intersect(bunch_to_move, districts.dis_arr[part_from])
        subgraph, vm = induced_subgraph(graph, collect(bunch_to_move))
        if is_connected(subgraph)
            connected = true
        else
            radius -= 1 #Decrease radius until bunch_to_move is connected.
        end
    end
    return bunch_to_move
end

function check_connected_without_bunch(districts, part_from, bunch_to_move)
    part_nodes = setdiff(districts.dis_arr[part_from], bunch_to_move)
    subgraph, vm = induced_subgraph(graph, collect(part_nodes))
    return is_connected(subgraph)
end


function do_move(districts, part_to, part_from, bunch_to_move)
    pop_to_move = sum([demographic.pop[n] for n in bunch_to_move])
    dems_to_move = sum([demographic.dem[n] for n in bunch_to_move])
    reps_to_move = sum([demographic.rep[n] for n in bunch_to_move])

    districts.pop[part_to] += pop_to_move
    districts.pop[part_from] -= pop_to_move
    districts.dem[part_to] += dems_to_move
    districts.dem[part_from] -= dems_to_move
    districts.rep[part_to] += reps_to_move
    districts.rep[part_from] -= reps_to_move

    setdiff!(districts.dis_arr[part_from], bunch_to_move)
    union!(districts.dis_arr[part_to], bunch_to_move)

    for n in bunch_to_move
        districts.dis[n] = part_to
    end
end
