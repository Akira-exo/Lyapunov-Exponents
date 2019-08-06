using LinearAlgebra
using DelimitedFiles

min_W,max_W,W_steps= parse(Float64,ARGS[1]),parse(Float64, ARGS[2]), parse(Int,ARGS[3])
list_W= LinRange(min_W,max_W,W_steps)
filename=string(pwd(),"/W_list.txt")
writedlm(filename,list_W)


    
