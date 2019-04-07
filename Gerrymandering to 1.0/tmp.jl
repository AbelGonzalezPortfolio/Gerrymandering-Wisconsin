function _fill!(new_dem, new_rep, dem, rep)
    dem_do = [1,1,1,1]
    rep_do = [1,1,1,1]

    new_dem = (dem + dem_do)
    new_rep = (rep+ rep_do)
end

function main()
    num_parts = 8
    new_dem = zeros(Int64, num_parts)
    new_rep = zeros(Int64, num_parts)
    dem = [1,1,1,1]
    rep = [1,1,1,1]

    _fill!(new_dem, new_rep, dem, rep)
    println(new_dem)
    println(new_rep)
end

main()
