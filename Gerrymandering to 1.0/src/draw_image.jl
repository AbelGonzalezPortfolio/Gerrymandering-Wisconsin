function draw_graph(graph::SimpleGraph, dis::Array{Int64, 1}, name)
    color = distinguishable_colors(num_parts+1, [RGB(1,1,1)])
    node_labels = collect(vertices(graph))
    pos_x = [demographic.pos[v][1] for v in vertices(graph)]
    pos_y = [-demographic.pos[v][2] for v in vertices(graph)]
    nodefillc = [color[dis[v]+1] for v in vertices(graph)]
    draw(SVG(joinpath("images","graph_$name.svg")), gplot(graph, pos_x, pos_y, nodefillc=nodefillc))
end

function draw_graph(graph::PyObject, districts::DistrictData, name)
    dem_p = dem_percentages(districts)
    new_dis = String[]

    for i in 1:length(graph)
        push!(new_dis, "$(districts.dis[i]): $(round(dem_p[districts.dis[i]],digits=2))")
    end
    draw_graph(graph, new_dis, name)
end

function draw_graph(graph::PyObject, dis::Array{String, 1}, name)
    println("Drawing Shape")
    shapefile."districts"=dis
    fig, ax = plt.subplots(1, figsize=(10,8))
    ax.set_aspect("equal")
    shapefile.plot(ax=ax, column="districts", categorical=true, cmap="tab20", linewidth=0.8
                        , legend=true)
    ax.axis("off")
    #ax.legend(labels=["27","27","27","27","27","27","27","27"], loc=0)
    ax.set_title("District's democratic share")
    plt.savefig(joinpath("images", "shape_$name.png"), dpi=400)
end

function draw_shape_dem_share(dem_share_arr)
    # dem_share_arr = Float64[]
    # for i in 1:nv(graph)
    #     dem_share = demographic.rep[i]/(demographic.dem[i]+demographic.rep[i])
    #     push!(dem_share_arr, dem_share)
    # end
    shapefile."dem_share_arr"= pd.Series(dem_share_arr, index=shapefile.index)
    fig, ax = plt.subplots(1, figsize=(10,8))
    ax.set_aspect("equal")
    shapefile.plot(ax=ax, column="dem_share_arr", cmap="seismic", linewidth=0.8,
                        legend=true)
    ax.axis("off")
    ax.set_title("District's democratic share")
    plt.savefig(joinpath("images", "shape_dem_share.png"), dpi=400)
end


function record_info(districts)
    info = Dict()
    info["nv"] = nv(graph)
    info["connected"] = all_connected(districts.dis_arr)
    info["parity"] = all_parity(districts.pop)
    info["dem_percent"] = dem_percentages(districts)
    info["mean_dem_percent"] = mean(percent_dem)
    info["safe_dem_seats"] = length([p for p in percent_dem if p >= safe_percentage])
    return info
end

function print_info(info)
    println("***********************************")
    println("Number of vertices = ", info["nv"])
    println("Connected? ", info["connected"])
    println("Parity? ", info["parity"])
    println("Dem percents = ", info["dem_percent"])
    println("Target = ", target)
    println("Mean dem percent = ", info["mean_dem_percent"])
    println("Safe dem seats = ", info["safe_dem_seats"])
end
