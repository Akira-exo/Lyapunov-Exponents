

@everywhere function get_SystemParameters()
	
	σ_x= [0 1;1 0]
	σ_y= [0 -1im; 1im 0 ]	
	σ_z =[1 0; 0 -1]

        #CHERN INSULATOR
	J_x = -(1im/2 )*( σ_x - 1im*σ_z)
	J_y = 1im/2 *( σ_y + 1im* σ_z)
	M = (2 - m) *σ_z
	
	ϵ = 0.0    #always probing at the middle of the gap
	p= 0  # PBC OFF:0, PBC ON:1
	scale=100    #Nx = scale*Ly;
	q=3;
	
	return(J_x,J_y,M,ϵ,p,scale,q)
	
end
