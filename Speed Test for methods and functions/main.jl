function add(x,y)
    for i in 1:y
        result = x^4
    end
end

function add_meth(x::Int64,y::Int64)
    for i in 1:y
        result = x^4
    end
end

function add_meth_nu(x::Number, y::Number)
    for i in 1:y
        result = x^4
    end
end

function main()
    t_add = 0
    t_add_meth = 0
    t_add_meth_nu = 0
    for i in 1:100000
        t_add += @elapsed add(10,10000000)
        t_add_meth += @elapsed add_meth(10,10000000)
        t_add_meth_nu += @elapsed add_meth_nu(10,10000000)
    end
    println(t_add/100000)
    println(t_add_meth/100000)
    println(t_add_meth_nu/100000)
    println("------")
end

main()
