include("Gerrymandering.jl")

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


function get_score(dem::Array{Int64,1}, rep::Array{Int64,1})
    percentages = sort([(dem[i]/(dem[i]+rep[i]))*100 for i in 1:num_parts])
    return norm(percentages-target)
end

function add_node!(districts, node::Int64, part_to, nodes_taken)
    districts.dis[node] = part_to
    districts.dem[part_to] += demographic.dem[node]
    districts.rep[part_to] += demographic.rep[node]
    districts.pop[part_to] += demographic.pop[node]
    push!(districts.dis_array[part_to], node)
    push!(nodes_taken, node)
end

function add_node!(districts, nodes::Set{Int64}, part_to, nodes_taken)
    for i in nodes
        add_node!(districts, districts.dis_array, i, part_to, nodes_taken)
    end
end

function get_democratic_share(node)
    return demographic.dem[node]/(demographic.dem[node]+demographic.rep[node])
end

function select_node(dis_array, nodes_taken, part_to)
    district_boundary = get_boundary(dis_array)
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

    if part_to == 1
        return boundary_by_dem[1]
    else
        return boundary
    end
end


function initialize_districts(state_boundary::Array{Int64})
    # Initialize list of districts nodes and fill with random initial seeds
    dis = zeros(Int64, nv(graph))
    dem = zeros(Int64, num_parts)
    rep = zeros(Int64, num_parts)
    pop = zeros(Int64, num_parts)
    dis_array = [Int64[] for i in 1:num_parts]
    districts = DistrictData(dis, dem, rep, pop, dis_array)
    nodes_taken = Int64[]


    # Select initial seed
    state_boundary = setdiff(state_boundary, nodes_taken)
    initial_seed = rand(state_boundary)
    add_node!(districts, initial_seed, 1, nodes_taken)
    while districts.pop[1] < (parity-1500)
        node_to_move = select_node(districts.dis_array[1], nodes_taken, 1)
        if node_to_move == false
            break
        end
        add_node!(districts, node_to_move, 1, nodes_taken)
    end

    # Rest of the nodes
    nodes_leftover = setdiff(collect(1:nv(graph)), nodes_taken)
    leftover_graph, vm = induced_subgraph(graph, nodes_leftover)
    components = sort(connected_components(leftover_graph), by=length, rev=true)
    for i in 2:length(components)
        for node_to_move in components[i]
            add_node!(districts, vm[node_to_move], 1, nodes_taken)
        end
    end
    return districts
end


function get_lowest_init()
    current_dem_share = 100
    for i in 1:50
        districts = initialize_districts(state_boundary)
        dem_share = dem_percentages(districts)[1]
        if dem_share < current_dem_share
            global new_districts = deepcopy(districts) # need gloabl to work
            println(dem_share)
            current_dem_share = dem_share
        end
    end
    return new_districts
end

function partition_rest(districts)
    # Clean networkx graph
    graph_nx_copy = deepcopy(graph_nx)
    for i in districts.dis_array[1]
        graph_nx_copy.remove_node(i)
    end
    targets = convert(Array{Any,1},[1/(num_parts-1) for i in 1:(num_parts-1)])

    edgecuts, parts = metis[:part_graph](
        graph_nx_copy, num_parts-1, contig=true, tpwgts=targets, ufactor = 1)

    for i in 1:length(parts)
        parts[i] += 1
    end

    println(parts)

end
state_boundary = get_state_boundary(demographic.pos)
@time districts = get_lowest_init()
partition_rest(districts)
println(dem_percentages(districts))
