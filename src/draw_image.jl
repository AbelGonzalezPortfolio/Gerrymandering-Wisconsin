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
    draw_shape(districts, name)

Draw the shapes with sliders indicating democrtic share
"""
function draw_shape(districts::DistrictData, name)

    fig, ax = plt.subplots(1, figsize=(12,8))
    plt.subplots_adjust(left=-.15)

    new_shapefile = shapefile.to_crs(epsg = 3857)
    new_shapefile.plot(ax=ax, column = districts.dis, cmap="tab20", legend=true,
    categorical=true)

    for i in 1:num_parts
        axfreq = plt.axes([0.62, 0.872-0.0256*i, 0.12, 0.020], facecolor="red")
        sl = widgets.Slider(axfreq, "", 1, 100,
             valinit=100*get_democratic_share(districts.dem[i],districts.rep[i]))
    end

    ax.axis("off")
    println("Drawing Shape")
    plt.savefig(joinpath("images", "shape_$(name).png"), dpi=400)
    println("Done")
    plt.close(fig)
end


"""
    draw_shape_dem_share(dem_share_arr)

Draw a map with the democratic share by census tract
"""
function draw_dem_share()
    shares = Float64[]

    for i in 1:nv(graph)
        share = -1*demographic.dem[i]/(demographic.dem[i]+demographic.rep[i])
        push!(shares, share)
    end

    shapefile."to_draw" = pd.Series(shares,index=shapefile.index)

    shapefile.plot(column=shares, cmap="seismic")
    plt.savefig("dem_share_1", dpi=300)
end

"""
    record_info(districts)

Record the information from DistrictData
"""
function record_info(districts::DistrictData)
    info = Dict()
    info["nv"] = nv(graph)
    compactness = measure_district_compactness_shapes(districts)
    info["compactness"] = [mean(compactness), minimum(compactness)]
    info["connected"] = all_connected(districts.dis_arr)
    info["parity"] = all_parity(districts.pop)
    info["dem_percent"] = dem_percentages(districts)
    info["mean_dem_percent"] = 1
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
