import Cairo
using LightGraphs
using GraphPlot
using Combinatorics
using Compose
using Colors

function brute_force_part(graph, no_districts)
    possible_partitions = []
    for p in partitions(1:length(vertices(graph)), no_districts)
        add = 1
        for d in p
            small_graph, vlist = induced_subgraph(graph, d)
            if is_connected(small_graph) == false
                add = 0
                break
            end
        end
        if add == 1
            push!(possible_partitions, p)
        end
    end
    return possible_partitions
end

function draw_images(graph, possible_partitions, no_districts)
    colors_d = distinguishable_colors(no_districts, colorant"red")
    nodefillc = [colors_d[1] for i in 1:length(vertices(graph))]
    nodelabel = 1:length(vertices(graph))

    i = 1
    for p in possible_partitions
         for d in range(1,no_districts)
            color = colors_d[d]
            #println(typeof(color))
            for v in p[d]
                nodefillc[v] = color
            end
        end
        draw(PNG("graph.pdf"), gplot(graph, layout=spectral_layout, nodefillc=nodefillc, nodelabel=nodelabel))
        i+= 1
    end
end

function main()
    graph = Grid([2,2])
    no_districts = 2

    @time possible_partitions = brute_force_part(graph, no_districts)
    print(length(possible_partitions))
    draw_images(graph, possible_partitions, no_districts)
end

main()
