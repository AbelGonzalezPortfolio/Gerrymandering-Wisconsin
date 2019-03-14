"""
    dem_percentages(districts)

Create list of democratic percentages and returns sorted list.
"""
function dem_percentages(districts::DistrictData)
    dem_percentages = []
    for i in 1:num_parts
        push!(dem_percentages, 100*(districts.dem[i]/(districts.dem[i]+districts.pop[i])))
    end
    return sort(dem_percentages)
end
