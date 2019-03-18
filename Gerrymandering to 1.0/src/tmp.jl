function my_way(n)

end

function pr_way(n)
    bunch_to_move = Set(neighborhood(graph, n, 2))
    bunch_to_move = intersect(bunch_to_move, dist_dict[part_from].vtds)
    subgraph, vm = LG.induced_subgraph(mg, collect(bunch_to_move))
    if LG.is_connected(subgraph)
        return 1
end

@time my_way
@time pr_way
