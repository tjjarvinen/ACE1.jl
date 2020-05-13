
# --------------------------------------------------------------------------
# ACE.jl and SHIPs.jl: Julia implementation of the Atomic Cluster Expansion
# Copyright (c) 2019 Christoph Ortner <christophortner0@gmail.com>
# All rights reserved.
# --------------------------------------------------------------------------



module RPI

include("../extimports.jl")

include("../shipimports.jl")


import SHIPs.SphericalHarmonics: SHBasis, index_y

export RPIBasis, SparsePSHDegree, BasicPSH1pBasis

# specify the `Rotations3D` submodule for CLebsch-Gordan and related
include("rotations3d.jl")
using SHIPs.RPI.Rotations3D

# some basic degree types useful for RPI type constructions
# (this file also specifies the PSH1pBasisFcn
include("rpi_degrees.jl")

# the basic RPI type 1-particle basis
include("rpi_basic1pbasis.jl")

# RPI basis and RPI potential
# (the RPI potential is specified through the combine function in this file)
include("rpi_basis.jl")

# include("rpi_regularise.jl")

end
