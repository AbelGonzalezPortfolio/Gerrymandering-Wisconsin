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

function record_info(districts)
    info = Dict()
    info["connected"] = all_connected(districts.dis_arr)
    info["parity"] = all_parity(districts.pop)
    info["dem_percent"] = dem_percentages(districts)
    info["mean_dem_percent"] = mean(percent_dem)
    info["safe_dem_seats"] = length([p for p in percent_dem if p >= safe_percentage])
    return info
end

function print_info(info)
    println("***********************************")
    println("Number of vertices = ", nv(graph))
    println("Connected? ", info["connected"])
    println("Parity? ", info["parity"])
    println("Dem percents = ", info["dem_percent"])
    println("Target = ", target)
    println("Mean dem percent = ", info["mean_dem_percent"])
    println("Safe dem seats = ", info["safe_dem_seats"])
end
