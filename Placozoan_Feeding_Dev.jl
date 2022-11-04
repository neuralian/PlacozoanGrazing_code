# Placozoan feeding (Contact map) demo

include("Placozoan.jl")


bodylayers = 12 # number of body cell layers
margin = 3  # number of layers in gut margin ("brain")
celldiameter = 10.0
skeleton_springconstant= 5.0e-2
cell_pressureconstant = 1.0e0
cell_surface_energy_density  = 5.0e1
dt = .001

param = trichoplaxparameters(   bodylayers,
                                margin,
                                skeleton_springconstant,
                                cell_pressureconstant,
                                cell_surface_energy_density,
                                celldiameter,
                                dt)

@time trichoplax = Trichoplax(param)
# trichoplax.param.k2[] = 5.0e-2    # cytoskeleton spring constant /2
# trichoplax.param.σ[]  = 5.0e1   # cell surface energy density
# trichoplax.param.ρ[]  = 1.0e0 #1.0e2    # cell turgor pressure energy per unit volume


# Draw
R = bodylayers*celldiameter    # approx radius of Trichoplax (for scene setting)
D = 3*R  # scene diameter
#limits=FRect(-D/2, -D/2, D, D)
fig = Figure(resolution = (800,800))

#, scale_plot = false,
#             show_axis = false, limits=limits)
ax = Axis(fig[1,1])

# scatter bacteria (point objects) over the scene
nbacteria = 50
#bactrect = FRect(20,20, 30, 30)
bacteria = growbacteria(nbacteria, [20,20, 30, 30])

# draw trichoplax cells
cell_handle = draw(trichoplax, RGB(.25, .25, .25), 1)

# colour the cells
potentialmap_handle = potentialmap(trichoplax)

display(fig)

restvolume = copy(trichoplax.state.volume)
i0 = 4
i1 = vcat(i0, trichoplax.anatomy.neighbourcell[i0,:])

record(fig, "trichoplaxdev.mp4", 1:25) do tick
#for tick in 1:25


   global trichoplax
  #  global fig
    if tick < 50
        which_bacteriahere = bacteriahere(bacteria, trichoplax)
        for j in 1:trichoplax.anatomy.nstomach
            for k in 1:length(which_bacteriahere[j])
                trichoplax.state.potential[j] = trichoplax.state.potential[j] -
                        1.0/(bacteria.deadticks[which_bacteriahere[j][k]] .+ 1)
                bacteria.deadticks[which_bacteriahere[j][k]] =
                      bacteria.deadticks[which_bacteriahere[j][k]] .+ 1
            end
        end
    end


    trichoplax = diffusepotential(trichoplax,600)

    trichoplax.state.volume[:] =
        restvolume.*(1.0 .-
        sign.(trichoplax.state.potential).*
        sqrt.(abs.(trichoplax.state.potential/4.0)))
    trichoplax = morph(trichoplax, .0001, 25)

    redraw(trichoplax,cell_handle)
    potential_remap(trichoplax, potentialmap_handle , 1)

    println(tick)
  #  display(fig)
    sleep(.005)

end


# end


# ch[12][:color] = [   RGB{Float64}(0.913603,0.0,0.0),
#                                 RGB{Float64}(0.,0.,1.0),
#                                 RGB{Float64}(0.913603,0.0,0.788739),
#                                 RGB{Float64}(0.913603,0.61886,0.788739),
#                                 RGB{Float64}(0.913603,0.61886,0.788739),
#                                 RGB{Float64}(0.913603,0.61886,0.788739),
#                                 RGB{Float64}(0.913603,0.61886,0.788739)]
