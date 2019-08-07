
#-----------------------------------------DEFINE @everywhere FUNCTIONS--------------------------------------------------------------------------------------
#=
Function to call worker 'i' to perform the job with jobID 'i' each job = one (m,W)
=#

@everywhere function perform_job(m::Float64,W::Float64,Ly_list::Array{Int64},jobID::Int64,dir_name::String)

        #NOTE: WORKER'S ID = myid()

        println("starting my job $(jobID) at $(gethostname()) on time $(now()) ")

        #SYSTEM PARAMETERS: 
        J_x,J_y,M,ϵ,p,scale,q = get_SystemParameters(m)
        for Ly in Ly_list
  		𝐌= assign_M(M,J_y,Ly,p)
		 𝐉,𝐕,𝚵,𝐖t=assign_J(J_x,Ly)
        	 Nx=scale*Ly
	      	 λ_list,Q_prev=get_LyapunovList(𝐌,𝐕,𝚵,𝐖t,ϵ,Ly,Nx,W,q)
	         filename = string(dir_name,"/λ_list/λ(m,W,Ly)=(",jobID,", ",Ly,")" )
           	 writedlm(filename,λ_list, ", ")
          	 filename = string(dir_name,"/Q_prev/Q(m,W,Ly)=(",jobID,", ",Ly,")" )
          	 writedlm(filename,Q_prev, ", ")
	end
        println("finishing my job $(jobID) at $(gethostname()) on time $(now()) ")


end

