"""
    get_state_boundary(pos)

Find the nodes that are in the boundary of the state
"""
function get_state_boundary(pos::Array{Tuple{Float64, Float64}, 1})
    positions = reshape(collect(Iterators.flatten(pos)),
                       (2,nv(graph)))
    kdtree = KDTree(positions, reorder=false)
    hull = concave_hull(kdtree, 100)
    state_boundary = Int[]
    hull_pos = Tuple{Float64, Float64}[]

    for j in 1:length(hull.vertices)
        push!(hull_pos, (hull.vertices[j][1],hull.vertices[j][2]))
    end

    for i in 1:nv(graph)
        if pos[i] in hull_pos
            push!(state_boundary, i)
        end
    end
    return state_boundary
end


"""
    add_node!(districts, node, part_to, nodes_taken)

Add node to the part_to district
"""
function add_node!(districts, node::Int64, part_to, nodes_taken)
    districts.dis[node] = part_to
    districts.dem[part_to] += demographic.dem[node]
    districts.rep[part_to] += demographic.rep[node]
    districts.pop[part_to] += demographic.pop[node]
    push!(districts.dis_arr[part_to], node)
    push!(nodes_taken, node)
end
"""
    add_node!(districts, node, part_to, nodes_taken)

Add node to the part_to district without need of nodes_taken
"""
function add_node!(districts, node::Int64, part_to)
    districts.dis[node] = part_to
    districts.dem[part_to] += demographic.dem[node]
    districts.rep[part_to] += demographic.rep[node]
    districts.pop[part_to] += demographic.pop[node]
    push!(districts.dis_arr[part_to], node)
end


"""
    get_score_no_full(districts)

Calculate a score based on dstance to target only on throw away districts
"""
function get_score_no_full(districts)
    dem_share_arr = dem_percentages(districts)[1:non_safe_seats]
    target_dem_share_arr = [throw_away_target for i in 1:non_safe_seats]
    return norm(target_dem_share_arr-dem_share_arr)
end


"""
    add_node!(districts, node, part_to, nodes_taken)

Add an array of nodes to the part_to districts
"""
function add_node!(districts, nodes::Set{Int64}, part_to, nodes_taken)
    for i in nodes
        add_node!(districts, districts.dis_arr, i, part_to, nodes_taken)
    end
end

function get_democratic_share(node)
    return demographic.dem[node]/(demographic.dem[node]+demographic.rep[node])
end


"""
    select_node(dis_arr, nodes_taken, part_to)

Select node or list of nodes to be moved to initial districts
"""
function select_node(dis_arr, nodes_taken, part_to)
    district_boundary = get_boundary(dis_arr)
    setdiff!(district_boundary, nodes_taken)
    if length(district_boundary) == 0
        return false
    end

    dem_share = Float64[]
    for i in district_boundary
        push!(dem_share, get_democratic_share(i))
    end
    p = sortperm(dem_share)
    boundary_by_dem = collect(district_boundary)[p]

    if part_to in 1:non_safe_seats
        return boundary_by_dem[1]
    else
        return boundary
    end
end


"""
    get_initial_districts(state_boundary)

Generate DistrictsData object with initialized districts in
"""
function get_initial_districts(state_boundary::Array{Int64})
    # Initialize list of districts nodes and fill with random initial seeds
    dis = zeros(Int64, nv(graph))
    dem = zeros(Int64, num_parts)
    rep = zeros(Int64, num_parts)
    pop = zeros(Int64, num_parts)
    dis_arr = [Int64[] for i in 1:num_parts]
    districts = DistrictData(dis, dem, rep, pop, dis_arr)
    nodes_taken = Int64[]
    vm = Int64[]


    # Select initial seed
    for d in 1:non_safe_seats
        #state_boundary = setdiff(1:nv(graph), nodes_taken)
        state_boundary = setdiff(state_boundary, nodes_taken)
        initial_seed = rand(state_boundary)
        add_node!(districts, initial_seed, d, nodes_taken)
        while districts.pop[d] < (parity-1500)
            node_to_move = select_node(districts.dis_arr[d], nodes_taken, d)
            if node_to_move == false
                break
            end
            add_node!(districts, node_to_move, d, nodes_taken)
        end

        # Rest of the nodes
        nodes_leftover = setdiff(collect(1:nv(graph)), nodes_taken)
        leftover_graph, vm = induced_subgraph(graph, nodes_leftover)
        components = connected_components(leftover_graph)
        sort!(components, by=length, rev=true)
        for i in 2:length(components)
            for node_to_move in components[i]
                add_node!(districts, vm[node_to_move], d, nodes_taken)
            end
        end
        nodes_leftover = setdiff(collect(1:nv(graph)), nodes_taken)
        leftover_graph, vm = induced_subgraph(graph, nodes_leftover)
    end
    return districts, vm
end



"""
    get_lowest_init(state_boundary)

Run get_initial_districts 50 times in order to get best initial layout
"""
function get_lowest_init(state_boundary)
    districts, vm = get_initial_districts(state_boundary)
    new_districts = deepcopy(districts)
    new_vm = Int64[]
    old_score = get_score_no_full(districts)
    for i in 1:50
        districts, vm = get_initial_districts(state_boundary)
        new_score = get_score_no_full(districts)
        if new_score < old_score
            new_districts, new_vm = deepcopy(districts), deepcopy(vm)
        end
    end
    return new_districts, new_vm
end


"""
    partition_rest!(districts, vm)

Takes initial partition object and fill the rest with a metis partition
"""
function partition_rest!(districts, vm)
    # Clean networkx graph

    # for i in vm
    #     graph_nx.remove_node(i)
    # end
    index_python_vm = [vm[i]-1 for i in 1:length(vm)]
    subgraph_nx = graph_nx.subgraph(index_python_vm)
    println(length(subgraph_nx))
    targets = convert(Array{Any,1},[1/safe_seats for i in 1:safe_seats])
    edgecuts, parts = metis.part_graph(
        subgraph_nx, safe_seats, contig=true, tpwgts=targets, ufactor = 1)
    for i in 1:length(parts)
        parts[i] += (non_safe_seats+1)
    end
    for i in 1:length(parts)
        add_node!(districts, vm[i], parts[i])
    end
    return districts
end


"""
    initialize_districts()

Run functions necessary to initialize the districts layout

First the boundary of the whole state is found using concave hull package.
Then try to find lowest possible democratic share districts. Fills the rest
with a metis partition returns the district object.
"""
function initialize_districts()
    state_boundary = get_state_boundary(demographic.pos)
    districts, vm = get_lowest_init(state_boundary)
    partition_rest!(districts, vm)
    return districts
end
