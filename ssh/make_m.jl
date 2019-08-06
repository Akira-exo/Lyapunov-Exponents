using LinearAlgebra
using DelimitedFiles

min_m,max_m,m_steps= parse(Float64,ARGS[1]),parse(Float64, ARGS[2]), parse(Int,ARGS[3])
list_m= LinRange(min_m,max_m,m_steps)
filename=string(pwd(),"/m_list.txt")
writedlm(filename,list_m)