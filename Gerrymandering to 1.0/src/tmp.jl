include("Gerrymandering.jl")
include("draw_image.jl")

function draw_one_district(districts)
    dis_one = Float64[]
    for c in 1:nv(graph)
        d_share = -1(demographic.dem[c]/(demographic.dem[c]+demographic.rep[c]))
        push!(dis_one, d_share)
    end
    draw_shape_dem_share(dis_one)
end


function match_dis_arr_dem(districts)
    dem = 0
    rep = 0
    for i in districts.dis_arr[5]
        dem += demographic.dem[i]
        rep += demographic.rep[i]
    end
    return dem/(dem+rep)
end
match_dis_arr_dem(districts)

function get_lowest_district()
    dem_share_arr = Float64[]
    for i in 1:nv(graph)
        dem_share = get_democratic_share(i)
        push!(dem_share_arr, dem_share)
    end
    p = sortperm(dem_share_arr)
    n = collect(1:nv(graph))[p]
    println(n)
    pop = 0
    dem = 0
    rep = 0
    i = 1
    while pop < parity-1500
        pop += demographic.pop[n[i]]
        dem += demographic.dem[n[i]]
        rep += demographic.rep[n[i]]
        i += 1
    end
    return dem/(dem+rep), pop
end
parity
get_lowest_district()
check_result(districts)
districts
dem_percentages(districts)
