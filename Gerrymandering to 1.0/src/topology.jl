"""
    all_connected(dis_array)

Check that all districts are connected returns true or false
"""

function all_connected(dis_arr::Array{Array{Int64}})
    connected = true
    for part in 1:num_parts
        subgraph, vm = induced_subgraph(graph, dis_arr[part])
        if !is_connected(subgraph)
            connected = false
            break
        end
    end
    return connected
end


function get_boundary(nodes)
    boundary = Set()
    for v in nodes
        union!(boundary, neighbors(graph, v))
    end
    return setdiff(boundary, nodes)
end
