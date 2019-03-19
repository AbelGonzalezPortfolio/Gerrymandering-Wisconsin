function simulated_annealing(districts)
    bunch_radius = max_radius
    current_score = get_score(districts)
    println("Initial Score: ", current_score)
    T = 1.0
    steps_remaining = Int(round(temperature_steps))
    swaps = [max_swaps, 0]
    st = 0
    cont = 0
    while T > T_min
        i = 1
        while i <= swaps[1]
            new_districts = deepcopy(districts)
            new_districts, t = @timed shuffle_nodes(new_districts, bunch_radius)
            st += t
            cont += 1
            new_score = get_score(new_districts) - .1

            ap = acceptance_prob(current_score, new_score, T)
            if ap > rand()
                # if new_score < current_score
                #     println("Score: ", new_score)
                # end
                swaps[2] += 1
                districts = new_districts
                current_score = new_score
            end
            i += 1
        end
        steps_remaining -= 1
        bunch_radius = Int(floor(max_radius - (max_radius / temperature_steps) * (temperature_steps - steps_remaining)))
        dem_percents = sort!(dem_percentages(districts))
        T = T * alpha
        # println("-------------------------------------")
        # println("Steps Remaining: ", steps_remaining)
        # println("Bunch Radius: ", bunch_radius)
        # println("T = ", T)
        # println("Dem percents: ", sort(dem_percents))
        # println("Parity: ", [100.0*((p-parity)/parity) for p in sort(districts.pop)])
        # println("-------------------------------------")
    end
    return districts, st/cont
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
    num_moves = 2

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
