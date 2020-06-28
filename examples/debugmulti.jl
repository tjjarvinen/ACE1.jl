
# --------------------------------------------------------------------------
# ACE.jl and SHIPs.jl: Julia implementation of the Atomic Cluster Expansion
# Copyright (c) 2019 Christoph Ortner <christophortner0@gmail.com>
# All rights reserved.
# --------------------------------------------------------------------------


using JuLIP, SHIPs, JuLIP.Potentials, LinearAlgebra
using JuLIP.Potentials: SZList, ZList



#---


#---

species = [:Al, :Fe]
Vref = ToyM.ToyModel(species)
train = trainset(Vref, 20_000)

for maxdeg in [6, 8, 10, 12]
   B = get_basis(species; N = 4, maxdeg = maxdeg, rcut = 7.0)
   lsq(train, B)
end
