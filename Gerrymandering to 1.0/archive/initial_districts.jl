include("Gerrymandering.jl")

mutable struct DistrictData{T<:Array{Int64,1}}
    dis::T
    dem::T
    rep::T
    pop::T
end

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
function get_state_boundary()
    positions = reshape(collect(Iterators.flatten(demographic.pos)),
                       (2,nv(graph)))
    kdtree = KDTree(positions, reorder=false)
    hull = concave_hull(kdtree, 1)
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

function initialize_districts(state_boundary::Array{Int64})
    # Initialize list of districts nodes and fill with random initial seeds
    dis = zeros(Int64, nv(graph))
    dis_arr = Array{Int64}(undef, num_parts)
    StatsBase.self_avoid_sample!(state_boundary, dis_arr)
    println(state_boundary)
    println(dis_arr)

    dem = Array{Int64}(undef, num_parts)
    rep = Array{Int64}(undef, num_parts)
    pop = Array{Int64}(undef, num_parts)
    for i in 1:num_parts
        dem[i] = demographic.dem[dis_arr[i][1]]
        rep[i] = demographic.rep[dis_arr[i][1]]
        pop[i] = demographic.pop[dis_arr[i][1]]
    end

    nodes_leftover = [i for i in 1:nv(graph) if !(i in dis_arr)]

    dis_arr = [[i] for i in dis_arr]
    for i in 1:length(dis_arr)
        dis[dis_arr[i][1]] = i
    end
    districts = DistrictData(dis, dis_arr, dem, rep, pop)
    return districts
end

state_boundary = get_state_boundary(demographic.pos)
districts = initialize_districts(state_boundary)

draw_graph(graph, districts.dis, "initial_seeds")
