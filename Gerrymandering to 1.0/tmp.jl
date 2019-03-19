function doub(lis)
    x = sum(lis)
    return x
end


function sum_all(lis)
    result = 0
    ti = 0
    ti2 = 0
    for i in lis
        result, t = @timed doub(lis)
        ti += t
        ti2 += @elapsed result = doub(lis)
    end
    println("-*-*-*-*-*-*-*-*-*-*-*")
    return ti/100000, ti2/100000
end

lis = rand(100000)
println(sum_all(lis))
