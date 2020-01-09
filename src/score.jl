"""
    get_score(districts)

Calculate score of districts
"""
function get_score(districts::DistrictData)
    #compactness = measure_district_compactness(districts)
    percentages = sort([(districts.dem[i]/(districts.dem[i]+districts.rep[i]))*100 for i in 1:num_parts])
    pops = sort(districts.pop)
    dist_to = append!([par_thresh], [par_thresh * ((p-parity)/(parity * par_thresh))^2 for p in pops])
    dist_to_parity = 100*(maximum(dist_to))
    #println(dist_to_parity)
    score = norm(percentages-target) + dist_to_parity
    return score
end
