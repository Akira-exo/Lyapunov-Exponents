
#----------------------------------------INTRODUCTION----------------------------------------------------------------
# main.jl takes no arguments from the terminal

#-------------------------------------------------------------------------------------------------------------


#----------------------------------------IMPORT REQUIRED LIBRARIES----------------------------------------------------------------
# (TIP: REMEMBER TO ADD ALL THESE LIBRARIES WHICH ARE BEING IMPORTED TO A NEW ENVIRONMENT AND GET THE PROJECT.TOML FILE !!!)

using Distributed, ClusterManagers,DelimitedFiles,LinearAlgebra


#system_scale = parse(Int, ARGS[1])
#ARGS is the array that stores the arguments passed to the julia program (as STRINGs, hence they need to be parsed as Int)


#-------------------------------------------READING INPUTS------------------------------------------------------------------------
dir_name= string(pwd())  #I/O directory= current working directory


println(string("Currently working in and reading (m,W,L) inputs from ",dir_name))

m_list = readdlm(string(dir_name,"/m_list.txt"),' ')
W_list = readdlm(string(dir_name,"/W_list.txt"),' ')
Ly_list = readdlm(string(dir_name,"/Ly_list.txt"),' ')

nprocs= length(m_list)*length(W_list)*length(Ly_list)  #number of tasks in total= number of workers required

#--------------------------------------- SET UP WORKERS/PROCESSES-------------------------------------------



println("starting ", nprocs, " processes...")
println("on THP CLUSTER :O!!")




#------------------------------------------distribute processes over the computers------------------------------------


function distribute_jobs(nprocs, machines)
j=1
for i in 1:nprocs
   if(j>length(machines)) 
     j=1
    end
   params = (exename=`nice -19 /vol/thp/share/julia-1.0.0-x86_64/bin/julia `, dir= dir_name )
   addprocs([(machines[j], 1)]; params...)
   j=j+1
 end

end

machines=readdlm("/home/anegi/complist/available_complist.txt",' ') #list of available computers on the THP NETWORK by running cinit.sh

distribute_jobs(nprocs, machines)
println("Started ",nworkers()," workers\n")

println("Done.\n")

#SSH Manager is automatically called when you call addprocs() with an array




#--------------------------------------MAP tasks to workers-----------------------------------------------------------------------



function map_jobs(nprocs,m_list,W_list,Ly_list)

map= zeros(nprocs,5)
count=1
for m in m_list
   for W in W_list
       for Ly in Ly_list
	      map[count,1]= count+1 #pid of the worker
	      map[count,2]= fetch(@spawnat count+1  getpid())
	      map[count,3]= m # corresponding m
	      map[count,4]= W # corresponding W
              map[count,5]= Ly # corresponding Ly
	      count+=1
        end
   end
end

filename=string(pwd(),"/TaskID(#,pid,m,W,Ly).txt")
writedlm(filename,map)
  
return(map)
end


map= map_jobs(nprocs,m_list,W_list,Ly_list)


#-------------------------------------------------------------------------IMPORT REQUIRED FUNCTIONALITY-----------------------------------------------------------------

include("FindLyapunov.jl") #from the project directory where main.jl is
#include("System_parameters.jl")  #from the project directory where main.jl is
include(string(dir_name,"/System_parameters.jl")) # from the I/O directory

@everywhere pushfirst!(Base.DEPOT_PATH, "/tmp/test.cache") #important!
@everywhere using Dates    
@everywhere using LinearAlgebra
@everywhere using DelimitedFiles
@everywhere using Statistics
@everywhere using Distributions
mkdir(string(dir_name,"/λ_list"))
mkdir(string(dir_name,"/Q_prev"))


#-----------------------------------------------------------------------------------------------------------------------------------------------------

#--------------------------------------DO TASK!!!!!!------------------------------------------------------------------------------






@sync for i in workers()
      
     # host, pid = fetch(@spawnat i (gethostname(), getpid()))
     
      #println("I'm worker $i running on host $host with pid $pid at time $(now())")
      m=map[i-1,3]
      W=map[i-1,4]
      Ly=Int.(map[i-1,5])
     # println("My (m,W,Ly) is (",m,", ",W,", ",Ly,")")

      @async @spawnat i perform_Task(m,W,Ly,i,dir_name) #@sync synchronises the output 

end
println("JOB COMPLETE! Congratulations!!")


#--------------------------remove workers-------------------------
for i in workers()
        rmprocs(i)
end

#------------------------------------------------------------------
