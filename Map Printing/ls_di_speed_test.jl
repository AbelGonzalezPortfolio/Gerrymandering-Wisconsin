using LightGraphs, MetaGraphs

function list_index(list, in)
    return list[in]
end

function list_loop(list)
    for i in list
        i
    end
    return 0
end

function dict_index(dict, in)
    return dict[in]
end

function dict_loop(dict)
    for i in dict
        i
    end
    return 0
end

function graph_index(mgraph, in)
    return get_prop(mgraph, in, :pop)
end

function graph_loop(mgraph)
    for i in vertices(mgraph)
        get_prop(mgraph, i, :pop)
    end
    return 0
end

function main()
    list = 1:100000
    dict = Dict(i => i for i=1:100000)
    graph = Graph(100000)
    mgraph = MetaGraph(graph)

    for i in vertices(mgraph)
        set_prop!(mgraph, i, :pop, i)
    end

    t_l_index = 0
    t_d_index = 0
    t_g_index = 0
    t_l_loop = 0
    t_d_loop = 0
    t_g_loop = 0
    for i in 1:100
        t_l_index += @elapsed list_index(list, 10000)
        t_d_index += @elapsed dict_index(dict ,10000)
        t_g_index += @elapsed graph_index(mgraph, 10000)
        t_l_loop += @elapsed list_loop(list)
        t_d_loop += @elapsed dict_loop(dict)
        t_g_loop += @elapsed graph_loop(mgraph)

    end
    println("Avg index list: ", t_l_index/100)
    println("Avg index dict: ", t_d_index/100)
    println("Avg index grap: ", t_g_index/100)
    println("Avg loop list : ", t_l_loop/100)
    println("Avg loop dict : ", t_d_loop/100)
    println("Avg loop grap : ", t_g_loop/100)
    println("-----------------------------")
end

main()
