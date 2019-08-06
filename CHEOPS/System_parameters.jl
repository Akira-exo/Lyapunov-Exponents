

#=

Function to call worker 'i' to perform the Task with # or ID 'i'

=#

@everywhere function perform_Task(m::Float64,W::Float64,Ly::Int64,jobID::Int64,dir_name::String)

	#-----------------------
	#SYSTEM PARAMETERS: 
        


	σ_x= [0 1;1 0]
	σ_y= [0 -1im; 1im 0 ]	
	σ_z =[1 0; 0 -1]

        #CHERN INSULATOR
	J_x = -(1im/2 )*( σ_x - 1im*σ_z)
	J_y = 1im/2 *( σ_y + 1im* σ_z)
	M = (2 - m) *σ_z

	ϵ = 0.0 #always probing at the middle of the gap
	
        p= 0 # PBC OFF:0, PBC ON:1

	Nx = 100*Ly;
	q=3;	
        


	𝐌= assign_M(M,J_y,Ly,p)
	𝐉,𝐕,𝚵,𝐖t=assign_J(J_x,Ly)

	calc_LyapunovList(𝐌,𝐕,𝚵,𝐖t,ϵ,Ly,Nx,W,dir_name,q,jobID)



end

