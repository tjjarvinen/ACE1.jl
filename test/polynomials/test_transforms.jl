
# --------------------------------------------------------------------------
# ACE1.jl: Julia implementation of the Atomic Cluster Expansion
# Copyright (c) 2019 Christoph Ortner <christophortner0@gmail.com>
# Licensed under ASL - see ASL.md for terms and conditions.
# --------------------------------------------------------------------------


##
using ACE1, Printf, Test, LinearAlgebra, JuLIP, JuLIP.Testing
using JuLIP: evaluate, evaluate_d
import ACE1.Testing: println_slim

verbose = false
maxdeg = 10

@info("Testing Transforms and TransformedPolys")
for p in 2:4
   local h, trans 
   @info("p = $p, random transform")
   trans = PolyTransform(1+rand(), 1+rand())
   @info("      test (de-)dictionisation")
   println(@test read_dict(write_dict(trans)) == trans)
   B1 = transformed_jacobi(maxdeg, trans, 3.0; pcut = p)
   B2 = transformed_jacobi(maxdeg, trans, 3.0, 0.5, pin = p, pcut = p)
   for B in [B1, B2]
      B == B1 && @info("basis = 1s")
      B == B2 && @info("basis = 2s")
      for r in [3 * rand(10); [3.0]]
         P = evaluate(B, r)
         dP = evaluate_d(B, r)
         errs = []
         verbose && @printf("     h    |     error  \n")
         for p = 2:10
            h = 0.1^p
            dPh = (evaluate(B, r+h) - P) / h
            push!(errs, norm(dPh - dP, Inf))
            verbose && @printf(" %.2e | %2e \n", h, errs[end])
         end
         print_tf(@test (/(extrema(errs)...) < 1e-3) || (minimum(errs) < 1e-10) )
      end
      println()
   end
end

##
@info("Testing PolyTransforms")
for p = 2:4
   r0 = 1+rand()
   trans = PolyTransform(p, r0)
   ACE1.Testing.test_transform(trans, [r0/2, 3*r0])
end
println()

##
@info("Testing Morse Transform")
for lam = 1.0:3.0
   r0 = 1+rand()
   trans = ACE1.Transforms.MorseTransform(lam, r0)
   ACE1.Testing.test_transform(trans, [r0/2, 3*r0])
end
println()

##

@info("Testing Agnesi Transform")
for p = 2:4
   r0 = 1+rand()
   trans = ACE1.Transforms.AgnesiTransform(r0, p)
   ACE1.Testing.test_transform(trans, [r0/2, 3*r0])
end
println()

##

@info("Testing AnalyticTransform")
trans = ACE1.Transforms.AnalyticTransform("r -> exp(-r)", "x -> - log(x)")
ACE1.Testing.test_transform(trans, [0.3, 3.0])
println()
println_slim(@test all(JuLIP.Testing.test_fio(trans)))

# log x = - 1.234 * r^2 
# sqrt(- log x / 1.234) = r 
trans = ACE1.Transforms.AnalyticTransform(
            "r -> exp(- 1.234 * r^2)", "x -> sqrt(- log(x) / 1.234)")
ACE1.Testing.test_transform(trans, [0.1, 2.345])
println()
println_slim(@test all(JuLIP.Testing.test_fio(trans)))

##

@info("Testing Generalized Agnesi Transform")
import ACE1.Transforms: transform_d 
r0 = 2.712
trans = agnesi_transform(r0, 3, 4)
rr = range(0.0, 6.0, length=1_000)
td_rr = transform_d.(Ref(trans), rr)
td_r0 = transform_d(trans, r0)
println_slim(@test all(abs(td_r0) .>= abs.(td_rr)))
println_slim(@test all(test_fio(trans)))


##

@info("Testing Agnesi(3,3)")

trans = agnesi_transform(r0, 3, 3)
ACE1.Testing.test_transform(trans, [0.1, 5.0])
println()
println_slim(@test all(JuLIP.Testing.test_fio(trans)))

##

@info("Testing Agnesi(2,4)")

trans = agnesi_transform(r0, 2, 4)
ACE1.Testing.test_transform(trans, [0.1, 5.0])
println()
println_slim(@test all(JuLIP.Testing.test_fio(trans)))


# ##
#
# using Plots
# r0 = 1.0
# rr = range(0.0, 3*r0, length=200)
# plot(; size = (500, 300))
# for p = 2:4
#    tpoly = PolyTransform(p, r0)
#    tagnesi = ACE1.Transforms.AgnesiTransform(r0, p)
#    plot!(rr, tagnesi.(rr), lw=2, c=p-1, label = "p = $p")
#    plot!(rr, tpoly.(rr), lw=2, c=p-1, ls = :dash, label = "")
# end
# xlabel!("r")
# ylabel!("x")
# title!("solid = Agnesi, dashed = Poly")
# vline!([1.0], lw=2, c=:black, label = "r0")
# ylims!(0.0, 2.0)
# ##
#
# function visualize_transform(T, rrange; nrays = 50, c = 1,
#                              inverse = false, straightr0 = false)
#    rnn = T.r0
#    xnn = T(rnn)
#    r0, r1 = extrema(rrange)
#    x0, x1 = T(r0), T(r1)
#    # plot r -> x
#    if !inverse
#       rr = range(r0, r1, length=nrays)
#       xx = T.(rr)
#    else
#       xx = range(x0, x1, length=nrays)
#       rr = ACE1.Transforms.inv_transform.(Ref(T), xx)
#    end
#    rnn = (rnn - rr[1]) / (rr[end] - rr[1])
#    xnn = (xnn - xx[1]) / (xx[end] - xx[1])
#    rr = (rr .- rr[1]) / (rr[end] - rr[1])
#    xx = (xx .- xx[1]) / (xx[end] - xx[1])
#    if straightr0
#       rr = rr .- rnn; rnn = 0.0
#       xx = xx .- xnn; xnn = 0.0
#    end
#    plot(; size = (500, 200), ylims = (-1, 2), xticks = [])
#    for (r, x) in zip(rr, xx)
#       plot!([r, x], [0, 1], lw=1, label = "", c = c, )
#    end
#    plot!([rnn, xnn], [0, 1], lw=3, c = :red, label = "")
#    plot!([rr[1], rr[end]], [0, 0], lw=3, label = "", c = :black)
#    plot!([xx[1], xx[end]], [1, 1], lw=3, label = "", c = :black)
#    yticks!([0, 1], ["r", "x"])
# end
#
#
#
# tagnesi = AgnesiTransform(1.0, 3)
# P1 = visualize_transform(tagnesi, (0.3*r0, 3*r0), straightr0=true)
# title!(P1, "Agnesi-3")
#
# tagnesi4 = AgnesiTransform(1.0, 4)
# P3 = visualize_transform(tagnesi4, (0.3*r0, 3*r0), straightr0=true)
# title!(P3, "Agnesi-4")
#
# tpoly = PolyTransform(2, 1.0)
# P2 = visualize_transform(tpoly, (0.3*r0, 3*r0), straightr0=true)
# title!(P2, "Poly-2")
# plot(P2, P1, P3, layout = (3,1), size = (500, 600))
#


##

