mutable struct MyType{T<:AbstractFloat}
           a::T
       end

func(m::MyType) = m.a+1
code_llvm(func, Tuple{MyType{Float64}})
code_llvm(func, Tuple{MyType{AbstractFloat}})
