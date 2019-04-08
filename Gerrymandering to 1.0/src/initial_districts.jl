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

function fill_district!(districts, district_to_fill, dis_array)
    while pop[district_to_fill] < parity
        select_nodes!
    end
end

function initialize_districts(state_boundary::Array{Int64})
    # Initialize list of districts nodes and fill with random initial seeds
    dis = zeros(Int64, nv(graph))
    dem = zeros(Int64, num_parts)
    rep = zeros(Int64, num_parts)
    pop = zeros(Int64, num_parts)
    dis_array = Array{Array{Int64}}(undef, num_parts)
    districts = DistrictData(dis, dem, rep, pop)
    nodes_taken = Int64[]

    while length(nodes_taken) < nv(graph)
        state_boundary = setdiff(state_boundary, nodes_taken)
        district_to_fill = rand(state_boundary)
        fill_district!(districts, district_to_fill, dis_array)
    end
    return districts
end

state_boundary = get_state_boundary(demographic.pos)
districts = initialize_districts(state_boundary)

draw_graph(graph, districts.dis, "initial_seeds")
