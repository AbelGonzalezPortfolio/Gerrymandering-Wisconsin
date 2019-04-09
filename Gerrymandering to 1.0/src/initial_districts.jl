include("Gerrymandering.jl")

function get_state_boundary(pos::Array{Tuple{Float64, Float64}, 1})
    positions = reshape(collect(Iterators.flatten(pos)),
                       (2,nv(graph)))
    kdtree = KDTree(positions, reorder=false)
    hull = concave_hull(kdtree, 1)
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

function add_node!(districts, dis_array, node::Int64, part_to, nodes_taken)
    districts.dis[node] = part_to
    districts.dem[part_to] += demographic.dem[node]
    districts.rep[part_to] += demographic.rep[node]
    districts.pop[part_to] += demographic.pop[node]
    push!(dis_array[part_to], node)
    push!(nodes_taken, node)
end

function select_node(dis_array, nodes_taken, part_to)
    district_boundary = get_boundary(dis_array)
    setdiff!(district_boundary, nodes_taken)

    dem_share = Float64[]
    for i in district_boundary
        push!(dem_share, get_democratic_share(node))
    end
    sort!(dem_share)

    if part_to == 1
        return dem_share[1]
    else
        return dem_share[end]
    end
end


function initialize_districts(state_boundary::Array{Int64})
    # Initialize list of districts nodes and fill with random initial seeds
    dis = zeros(Int64, nv(graph))
    dem = zeros(Int64, num_parts)
    rep = zeros(Int64, num_parts)
    pop = zeros(Int64, num_parts)
    dis_array = [Int64[] for i in num_parts]
    districts = DistrictData(dis, dem, rep, pop)
    nodes_taken = Int64[]

    # Select initial seed
    state_boundary = setdiff(state_boundary, nodes_taken)
    initial_seed = rand(state_boundary)

    add_node!(districts, dis_array, initial_seed, 1, nodes_taken)
    for i in 1:num_parts
        node_to_move = select_node(dis, nodes_taken, i)
        add_node!(districts, dis_array, node_to_move, i, )
    end


    return districts
end

state_boundary = get_state_boundary(demographic.pos)
districts = initialize_districts(state_boundary)

draw_graph(graph, districts.dis, "initial_seeds")
