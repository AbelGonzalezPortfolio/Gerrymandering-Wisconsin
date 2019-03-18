function draw_graph(graph::SimpleGraph, dis::Array{Int64, 1}, name)
    color = distinguishable_colors(num_parts+1, [RGB(1,1,1)])
    node_labels = collect(vertices(graph))
    pos_x = [demographic.pos[v][1] for v in vertices(graph)]
    pos_y = [-demographic.pos[v][2] for v in vertices(graph)]
    nodefillc = [color[districts.dis[v]+1] for v in vertices(graph)]
    draw(SVG("./images/graph_$name.svg"), gplot(graph, pos_x, pos_y, nodefillc=nodefillc))
end

function draw_graph(graph::PyObject, dis::Array{Int64, 1}, name)
    shapefile["districts"] = dis
    shapefile[:plot](column="districts", cmap="Set1")
    plt[:savefig]("./images/shape_$name.png")
end
