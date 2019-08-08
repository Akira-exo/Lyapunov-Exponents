#----------------------------------------INTRODUCTION--------------------------------------------------------------------
# main.jl takes no arguments from the terminal
#ARGS is the array that stores the arguments passed to the julia program (as STRINGs, hence they need to be parsed as Int)
# (TIP: REMEMBER TO ADD LIBRARIES WHICH ARE BEING IMPORTED IN THE PROGRAM TO A NEW ENVIRONMENT AND GET THE PROJECT.TOML FILE !!!)
#-------------------------------------------------------------------------------------------------------------


#----------------------------------------IMPORT LIBRARIES REQUIRED BY MASTER----------------------------------------------------------------


using Distributed, ClusterManagers,DelimitedFiles,LinearAlgebra


#-----------------------------------------DEFINE MASTER FUNCTIONS--------------------------------------------------------------------------------------

#=
Function to map each job information to its respective machine.
=#

function map_jobs(nprocs,m_list,W_list)

      map= zeros(nprocs,4)
	
          count=1
          for m in m_list
             for W in W_list
                 map[count,1]= count+1 #id of the worker
	     	 map[count,2]= fetch(@spawnat count+1  getpid())
	     	 map[count,3]= m # corresponding m
	     	 map[count,4]= W # corresponding W
	      	 count+=1
              end
          end
          
          filename=string(pwd(),"/TaskID(#,pid,m,W).txt")
          writedlm(filename,map)
          
    return(map)

end




#-------------------------------------------READING INPUTS------------------------------------------------------------------------

dir_name= string(pwd())  #I/O directory= current working directory


println(string("THE INPUT/OUTPUT directory is ",dir_name))

m_list = readdlm(string(dir_name,"/m_list.txt"),' ')
W_list = readdlm(string(dir_name,"/W_list.txt"),' ')
Ly_list = readdlm(string(dir_name,"/Ly_list.txt"),' ')



#------------------------------------- START WORKERS and DISTRIBUTE JOBS TO THEM--------------------------------------------------

nprocs= length(m_list)*length(W_list) # one (m,W) per worker

println("starting ", nprocs, " processes...")
println("one (m,W) per worker")
println("on CHEOPS CLUSTER :o !!")

addprocs(SlurmManager(nprocs)) #SlurmManager works for CHEOPS

println("Started ",nworkers()," workers\n")
println("Done.\n")



#----------------------------------------- MAP JOBS TO WORKERS ----------------------------------------------------------------------


map= map_jobs(nprocs,m_list,W_list)


#---------------------------------IMPORT FUNCTIONALITY REQUIRED @everywhere-----------------------------------------------------------------

@everywhere pushfirst!(Base.DEPOT_PATH, "/tmp/test.cache") #important!
@everywhere using Dates    
@everywhere using LinearAlgebra
@everywhere using DelimitedFiles
@everywhere using Statistics
@everywhere using Distributions

include("FindLyapunov.jl") #from the project directory where main.jl is
include("perform_job.jl")#from the project directory where main.jl is
#include("System_parameters.jl")  #from the project directory where main.jl is
include(string(dir_name,"/System_parameters.jl")) # from the I/O directory



#--------------------------------------DO JOBS!!!!!!------------------------------------------------------------------------------

#creating directories for outputs
mkdir(string(dir_name,"/λ_list"))
mkdir(string(dir_name,"/Q_prev"))


@sync for i in workers() 
      
      #host, pid = fetch(@spawnat i (gethostname(), getpid()))
      #println("I'm worker $i running on host $host with pid $pid at time $(now())")
      m=map[i-1,3]
      W=map[i-1,4]
      # println("My (m,W) is (",m,", ",W,")")

      @async @spawnat i perform_job(m,W,Ly_list,i,dir_name) 

end
println("JOB COMPLETE! Congratulations!!")



#--------------------------remove workers-------------------------
for i in workers()
        rmprocs(i)
end

#------------------------------------------------------------------
#-----------------------------END----------------------------------
