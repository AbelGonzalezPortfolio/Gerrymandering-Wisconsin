"""
    get_score(districts)

Calculate score of districts
"""
function get_score(districts::DistrictData)
    percentages = sort([districts.dem[i]/(districts.dem[i]+districts.rep[i]) for i in 1:num_parts])
    pops = sort(districts.pop)
    dist_to_parity = 100*(maximum(append!([par_thresh], [par_thresh * ((p-parity)/(parity * par_thresh))^2 for p in pops])))
    return norm(percentages-target) + dist_to_parity
end
