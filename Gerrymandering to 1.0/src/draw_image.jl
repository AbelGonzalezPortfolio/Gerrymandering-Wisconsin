"""
    draw_graph(graph, dis, name)

Draw an image of the network graph.
"""
function draw_graph(graph::SimpleGraph, dis::Array{Int64, 1}, name)
    color = distinguishable_colors(num_parts+1, [RGB(1,1,1)])
    node_labels = collect(vertices(graph))
    pos_x = [demographic.pos[v][1] for v in vertices(graph)]
    pos_y = [-demographic.pos[v][2] for v in vertices(graph)]
    nodefillc = [color[dis[v]+1] for v in vertices(graph)]
    draw(SVG(joinpath("images","graph_$name.svg")), gplot(graph, pos_x, pos_y, nodefillc=nodefillc))
end

"""
    draw_graph(graph, districts, name)

Draw and image of the districts using the shape objects.

Particularly creates an array of the same length as the graph, then fills
this array with the democratic share and district number of each
of the differents district.
Ex. [1: 32.00]
"""
function draw_shape(graph::PyObject, districts::DistrictData, name)
    dem_p = dem_percentages(districts)
    new_dis = String[]

    for i in 1:length(graph)
        push!(new_dis, "$(districts.dis[i]): $(round(dem_p[districts.dis[i]],digits=2))")
    end

    draw_shape(graph, new_dis, name)
end

"""
    draw_shape(graph, dis, name)

Draw image of shape using column districts as color
"""
function draw_shape(graph::PyObject, dis::Array{String, 1}, name)
    println("Drawing Shape")
    shapefile."districts"=dis
    fig, ax = plt.subplots(1, figsize=(10,8))
    ax.set_aspect("equal")
    shapefile.plot(ax=ax, column="districts", categorical=true, cmap="tab20", linewidth=0.8
                        , legend=true)
    ax.axis("off")
    ax.set_title("District's democratic share")
    plt.savefig(joinpath("images", "shape_$name.png"), dpi=400)
end

"""
    draw_shape_dem_share(dem_share_arr)

Draw a map with the democratic share by census tract
"""
function draw_shape_dem_share(dem_share_arr)
    shapefile."dem_share_arr"= pd.Series(dem_share_arr, index=shapefile.index)
    fig, ax = plt.subplots(1, figsize=(10,8))
    ax.set_aspect("equal")
    shapefile.plot(ax=ax, column="dem_share_arr", cmap="seismic", linewidth=0.8,
                        legend=true)
    ax.axis("off")
    ax.set_title("District's democratic share")
    plt.savefig(joinpath("images", "shape_dem_share.png"), dpi=400)
end

"""
    record_info(districts)

Record the information from DistrictData
"""
function record_info(districts::DistrictData)
    info = Dict()
    info["nv"] = nv(graph)
    compactness = measure_district_compactness(districts)
    info["compactness"] = [mean(compactness), minimum(compactness)]
    info["connected"] = all_connected(districts.dis_arr)
    info["parity"] = all_parity(districts.pop)
    info["dem_percent"] = dem_percentages(districts)
    info["mean_dem_percent"] = mean(percent_dem)
    info["safe_dem_seats"] = length([p for p in percent_dem if p >= safe_percentage])
    return info
end

"""
    print_info(info)

Print the information previously recorded
"""
function print_info(info::Dict)
    println("***********************************")
    println("Number of vertices = ", info["nv"])
    println("Connected? ", info["connected"])
    println("Parity? ", info["parity"])
    println("Dem percents = ", info["dem_percent"])
    println("Compactness : Avg = $(info["compactness"][1]), Min = $(info["compactness"][2])")
    println("Target = ", target)
    println("Mean dem percent = ", info["mean_dem_percent"])
    println("Safe dem seats = ", info["safe_dem_seats"])
end

"""
    draw_lowest_district(draw_array)

Draw the shape figure where only census tracts that correspond to lowest
district is shown
"""
function draw_lowest_district(draw_array::Array{Bool})
    to_drawdf = DataFrame(shapefile)
    to_draw = loc(to_drawdf)[draw_array]
    Pandas.plot(to_draw)
    plt.savefig("lowest_rep.png", dpi=400)
end
