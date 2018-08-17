## base.jl base methods for NamedArray

## (c) 2013 David A. van Leeuwen

## This code is licensed under the MIT license
## See the file LICENSE.md in this distribution

# ## copy
# import Base: copy, copy!
# copy{T,N,AT,DT}(a::NamedArray{T,N,AT,DT}) = NamedArray{T,N,AT,DT}(copy(a.array), deepcopy(a.dicts), identity(a.dimnames))
#
# ## from array.jl
# function copy!{T}(dest::NamedArray{T}, dsto::Integer, src::ArrayOrNamed{T}, so::Integer, N::
# Integer)
#     if so+N-1 > length(src) || dsto+N-1 > length(dest) || dsto < 1 || so < 1
#         throw(BoundsError())
#     end
#     if isa(src, NamedArray)
#         unsafe_copy!(dest.array, dsto, src.array, so, N)
#     else
#         unsafe_copy!(dest.array, dsto, src, so, N)
#     end
# end

Base.size(a::NamedArray) = size(a.array)
# Base.size(a::NamedArray, d) = size(a.array, d)
# Base.ndims(a::NamedArray) = ndims(a.array)

Base.similar(n::NamedArray, t::Type) = NamedArray(similar(n.array, t), n.dicts, n.dimnames)

function Base.similar(n::NamedArray{T,N}, t::Type, dims::Base.Dims) where {T,N}
    nd = length(dims)
    dicts = Array{OrderedDict{Any,Int}}(nd)
    dimnames = Array{Any}(undef, nd)
    for d in 1:length(dims)
        if d ≤ ndims(n) && dims[d] == size(n, d)
            dicts[d] = n.dicts[d]
            dimnames[d] = n.dimnames[d]
        else
            dicts[d] = defaultnamesdict(dims[d])
            dimnames[d] = letter(d)
        end
    end
    tdicts = tuple(dicts...)
    array = similar(n.array, t, dims)
    return NamedArray{t,N,typeof(array),typeof(tdicts)}(array, tdicts, tuple(dimnames...))
end

## our own interpretation of ind2sub
Base.ind2sub(n::NamedArray, index::Integer) = tuple(map(x -> names(n, x[1])[x[2]], enumerate(ind2sub(size(n), index)))...)

## simplified text representation of namedarray
DelimitedFiles.writedlm(io, n::NamedVecOrMat) = writedlm(io, hcat(names(n, 1), n.array))

## Turn a NamedVector into a dict, #61
Base.Dict(n::NamedVector) = Dict(name => n[name] for name in names(n, 1))
