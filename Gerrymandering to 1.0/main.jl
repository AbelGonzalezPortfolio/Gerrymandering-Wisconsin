push!(LOAD_PATH, "$(pwd())")
using GraphData
using timing
dis = districts.dis

# Run the time comparison funciton
timing.get_time()

println(demographics.pop[20])
println(dis[20])

println(districts.pop[1])
println(districts.pop[dis[20]])
