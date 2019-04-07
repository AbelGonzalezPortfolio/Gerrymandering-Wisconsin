mutable struct DistrictData
    dis::Array{Int64,1}
    dis_arr::Array{Array{Int64,1},1}
    dem::Array{Int64,1}
    rep::Array{Int64,1}
    pop::Array{Int64,1}
end

function get_state_boundary()
    positions = reshape(collect(Iterators.flatten(demographic.pos)),
                       (2,nv(graph)))
    kdtree = KDTree(positions, reorder=false)
    hull = concave_hull(kdtree, 10)
    state_boundary = Int[]
    hull_pos = Tuple{Float64, Float64}[]

    for j in 1:length(hull.vertices)
        push!(hull_pos, (hull.vertices[j][1],hull.vertices[j][2]))
    end

    for i in 1:nv(graph)
        if demographic.pos[i] in hull_pos
            push!(state_boundary, i)
        end
    end
    return state_boundary
end

function get_score(dem::Array{Int64,1}, rep::Array{Int64,1})
    percentages = sort([(dem[i]/(dem[i]+rep[i]))*100 for i in 1:num_parts])
    return norm(percentages-target)
end

function try_move(dem, rep, dis_arr, d, no_moves, nodes_taken)
    new_dem = Array{Int64}(undef, num_parts)
    new_rep = Array{Int64}(undef, num_parts)
    dummy_array_dem = zeros(Int64, num_parts)
    dummy_array_rep = zeros(Int64, num_parts)

    boundary = get_boundary(dis_arr[d])
    boundary = setdiff!(boundary, nodes_taken)
    if length(boundary) == 0
        no_moves += 1
        return new_dem, new_rep, 0, false, no_moves
    end
    dem_shares = Float64[]
    for i in boundary
        share = demographic.dem[i]/(demographic.dem[i]+demographic.rep[i])
        push!(dem_shares, share)
    end
    p = sortperm(dem_shares)
    if d == 1
        node_to_move = collect(boundary)[p][1]
    else
        node_to_move = collect(boundary)[p][end]
    end

    dummy_array_dem[d] += demographic.dem[node_to_move]
    dummy_array_rep[d] += demographic.rep[node_to_move]

    new_dem = dem + dummy_array_dem
    new_rep = rep + dummy_array_rep
    return new_dem, new_rep, node_to_move, true, no_moves
end

function initialize_districts(state_boundary::Array{Int64})
    # Initialize list of districts nodes and fill with random initial seeds
    dis = Array{Int64}(undef, nv(graph))
    dis_arr = Array{Int64}(undef, num_parts)
    state_boundary = StatsBase.self_avoid_sample!(state_boundary, dis_arr)

    dem = Array{Int64}(undef, num_parts)
    rep = Array{Int64}(undef, num_parts)
    pop = Array{Int64}(undef, num_parts)
    for i in 1:num_parts
        dem[i] = demographic.dem[dis_arr[i][1]]
        rep[i] = demographic.rep[dis_arr[i][1]]
        pop[i] = demographic.pop[dis_arr[i][1]]
    end

    nodes_leftover = [i for i in 1:nv(graph) if !(i in dis_arr)]
    nodes_taken = Set(dis_arr)
    dis_arr = [[i] for i in dis_arr]

    districts_under_parity = [i for i in 1:num_parts]
    current_score = get_score(dem, rep)
    println(current_score)
    no_moves = 0

    while length(nodes_leftover) > 0
        for d in districts_under_parity
            #println("d",d)

            #for t in 1:max_tries
            new_dem, new_rep, node_to_move, success, no_moves =
                try_move(dem, rep, dis_arr, d, no_moves, nodes_taken)

            if !success
                println("not_working")
                deleteat!(districts_under_parity, findfirst(x->x==d,districts_under_parity))
                continue
            end
            #println(dis_arr)
            #print(no_moves)
            score = get_score(new_dem, new_rep)
            #ap = acceptance_prob(current_score, score, 10)
            #if score < current_score
            dem = new_dem
            rep = new_rep
            pop[d] += demographic.pop[node_to_move]
            push!(dis_arr[d], node_to_move)
            # Remove node from pool
            push!(nodes_taken, node_to_move)
            deleteat!(nodes_leftover, findfirst(x->x==node_to_move, nodes_leftover))
            println(score)

            current_score = score
            if pop[d] > parity
                deleteat!(districts_under_parity, findfirst(x->x==d,districts_under_parity))
            end
        end
        if length(districts_under_parity) == 0
            districts_under_parity = [i for i in 1:num_parts]
        end
    end
    for i in 1:length(dis_arr)
        for j in dis_arr[i]
            dis[j] = i
        end
    end
    districts = DistrictData(dis, dis_arr, dem, rep, pop)
    return districts
end
