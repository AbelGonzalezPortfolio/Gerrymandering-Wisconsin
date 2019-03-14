"""
    all_parity(pop)

Check whther all of the district's populations are under the parity threshold
returns true or false
"""
function all_parity(pop::Array{Int64})
    parity_bool = true
    for i in 1:num_parts
        if !(abs(pop[i] - parity)/parity < par_thresh)
            parity_bool = false
            break
        end
    end
    return parity_bool
end
