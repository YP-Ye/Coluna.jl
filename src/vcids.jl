struct Id{VcInfo <: AbstractVarConstrInfo} #<: AbstractVarConstrId
    uid::Int
    info::VcInfo
end

idtype(::Type{<: Variable}) = Id{VarInfo}
idtype(::Type{<: Constraint}) = Id{ConstrInfo}

#Id(T::Type{<: AbstractVarConstr}, i::Int) = Id{T}(i, infotype(T)())

# Id{T <: AbstractVarConstr} = Id{T, infotype(T)} # Default constructor should be enough

Id(id::Id{T}) where {T} = Id{T}(id.uid, id.info)

# Id(uid::Int) = Id(uid, nothing)

Base.hash(a::Id, h::UInt) = hash(a.uid, h)

Base.isequal(a::Id, b::Id) = Base.isequal(a.uid, b.uid)

Base.isless(a::Id, b::Id) = Base.isless(a.uid, b.uid)

getuid(id::Id) = id.uid

getinfo(id::Id) = id.info

function Base.show(io::IO, id::Id{T}) where {T}
    print(io, "Id(", getuid(id), ")")
end

