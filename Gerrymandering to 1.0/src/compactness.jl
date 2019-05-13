"""
    measure_district_compactness(dis_arr)

Calculate compactness of a district returns values from 0 (more) to 1 (less)
"""
function measure_district_compactness(dis_arr::Array{Int64})
    positions = [demographic.pos[i] for i in dis_arr]
    positions = reshape(collect(Iterators.flatten(positions)), (2,length(dis_arr)))
    kdtree = KDTree(positions, reorder=false)

    #println(positions)
    ccave_hull = concave_hull(kdtree, 20)
    cvex_hull = concave_hull(kdtree, 10000)

    #plot!(ccave_hull, color = cl)
    #plot!(cvex_hull, color = cl)

    compactness = area(ccave_hull)/area(cvex_hull)
    return compactness
end

"""
    measure_district_compactness(districts)

Iterate through each district and return compactness values of each.
"""
function measure_district_compactness(districts::DistrictData)
    #colors = distinguishable_colors(num_parts+1, [RGB(1,1,1)])
    compactness = Float64[]
    for i in 1:length(districts.dis_arr)
        push!(compactness, measure_district_compactness(districts.dis_arr[i]))
    end
    #savefig("ccave_hull_initial_part")
    return compactness
end


"""
    measure_district_compactness_shapes(districts)

Measure compactness levels using the shapefile
"""
function measure_district_compactness_shapes(districts)
    d_shapes = gpd.GeoDataFrame(shapefile."geometry")
    d_shapes = d_shapes.dissolve(by=districts.dis)
    convex_hull = d_shapes.convex_hull

    d_shapes_area = d_shapes.area
    cvex_hull_area = convex_hull.area

    area_difference = d_shapes_area/cvex_hull_area
    return area_difference
end
