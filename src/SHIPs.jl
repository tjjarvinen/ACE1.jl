
# --------------------------------------------------------------------------
# ACE.jl and SHIPs.jl: Julia implementation of the Atomic Cluster Expansion
# Copyright (c) 2019 Christoph Ortner <christophortner0@gmail.com>
# All rights reserved.
# --------------------------------------------------------------------------

module SHIPs

using Reexport
@reexport using JuLIP

include("auxiliary.jl")
include("prototypes.jl")
include("jacobi.jl")
include("sphericalharmonics.jl")
include("transforms.jl")
include("degrees.jl")
include("basis.jl")
include("fast.jl")
include("pair.jl")

end # module
