abstract type AbstractMembersContainer end

mutable struct MembersVector{I,K,T} <: AbstractMembersContainer
    elements::Dict{I, K} # holds a reference towards the container of elements (sorted by ID) to which we associate records
    records::Dict{I, T} # holds the records associated to elements that are identified by their ID
end

MembersVector{I,K,T}(elems::Dict{I,K}) where {I,K,T} = MembersVector(elems, Dict{I,T}())

Base.eltype(vec::MembersVector{I,K,T}) where {I,K,T} = T
Base.ndims(vec::MembersVector) = 1

function Base.setindex!(vec::MembersVector{I,K,T}, val, id::I) where {I,K,T}
    vec.records[id] = val
end

function Base.get(vec::MembersVector{I,K,T}, id::I, default) where {I,K,T}
    Base.get(vec.records, id, default)
end

function Base.getindex(vec::MembersVector{I,K,T}, id::I) where {I,K,T}
    vec.records[id]
end

function Base.getindex(vec::MembersVector{I,K,T}, id::I) where {I,K,T<:Number}
    Base.get(vec, id, zero(T))
end

Base.getindex(vec::MembersVector, ::Colon) = vec

function Base.merge(op, vec1::MembersVector{I,K,T}, vec2::MembersVector{I,K,U}) where {I,K,T,U}
    (vec1.elements === vec2.elements) || error("elements are not the same.") # too much restrictive ?
    MembersVector(vec1.elements, Base.merge(op, vec1.records, vec2.records))
end

function Base.reduce(op, vec::MembersVector)
    Base.mapreduce(e -> e[2], op, vec.records)
end

function Base.:(==)(vec1::MembersVector, vec2::MembersVector)
    vec1.records == vec2.records
end

function Base.:(==)(vec1::Dict, vec2::MembersVector)
    vec1 == vec2.records
end

function Base.:(==)(vec1::MembersVector, vec2::Dict)
    vec1.records == vec2
end

function Base.:(!=)(vec1::MembersVector, vec2::MembersVector)
    vec1.records != vec2.records
end

function Base.haskey(vec::MembersVector{I,K,T}, id::I) where {I,K,T}
    Base.haskey(vec.records, id)
end

function Base.filter(f::Function, vec::MembersVector)
    MembersVector(vec.elements, Base.filter(e -> f(vec.elements[e[1]]), vec.records))
end

iterate(d::MembersVector) = iterate(d.records)
iterate(d::MembersVector, state) = iterate(d.records, state)
length(d::MembersVector) = length(d.records)
lastindex(d::MembersVector) = lastindex(d.records)

# =================================================================

struct MembersMatrix{I,K,J,L,T} <: AbstractMembersContainer
    cols::MembersVector{I,K,MembersVector{J,L,T}}
    rows::MembersVector{J,L,MembersVector{I,K,T}}
end

function MembersMatrix{I,K,J,L,T}(col_elems::Dict{I,K}, row_elems::Dict{J,L}) where {I,K,J,L,T}
    cols = MembersVector{I,K,MembersVector{J,L,T}}(col_elems)
    rows = MembersVector{J,L,MembersVector{I,K,T}}(row_elems)
    MembersMatrix(cols, rows)
end

function MembersMatrix{I,K,J,L,T}() where {I,K,J,L,T}
    MembersMatrix(MembersVector{I,K,MembersVector{J,L,T}}(), MembersVector{J,L,MembersVector{I,K,T}}())
end

function _getmembersvector!(dict::MembersVector{I,K,MembersVector{J,L,T}}, key::I, elems::Dict{J,L}) where {I,K,J,L,T}
    if !haskey(dict, key)
        membersvec = MembersVector{J,L,T}(elems)
        dict[key] = membersvec
        return membersvec
    end
    dict[key]
end

function Base.setindex!(m::MembersMatrix, val, col_id, row_id)
    col = _getmembersvector!(m.cols, col_id, m.rows.elements)
    col[row_id] = val
    row = _getmembersvector!(m.rows, row_id, m.cols.elements)
    row[col_id] = val
    m
end

function Base.getindex(m::MembersMatrix, col_id, row_id)
    if length(m.cols) < length(m.rows) # improve ?
        return m.cols[col_id][row_id]
    else
        return m.rows[row_id][col_id]
    end
end

function Base.getindex(m::MembersMatrix, ::Colon, row_id)
    _getmembersvector!(m.rows, row_id, m.cols.elements)
end

function Base.getindex(m::MembersMatrix, col_id, ::Colon)
    _getmembersvector!(m.cols, col_id, m.rows.elements)
end

function setcolumn!(m::MembersMatrix, col_id, new_col::Dict)
    col = MembersVector(m.rows.elements, deepcopy(new_col))
    m.cols[col_id] = col
    for (row_id, val) in col
        row = _getmembersvector!(m.rows, row_id, m.cols.elements)
        row[col_id] = val
    end
    m
end

function setrow!(m::MembersMatrix, row_id, new_row::Dict)
    row = MembersVector(m.col.elements, deepcopy(new_row))
    m.rows[row_id] = row
    for (col_id, val) in row
        col = _getmembersvector!(m.cols, col_id, m.rows.elements)
        col[row_id] = val
    end
    m
end

function columns(m::MembersMatrix)
    return m.cols
end

function rows(m::MembersMatrix)
    return m.rows
end

# =================================================================
const VarDict = Dict{VarId,Variable}
const ConstrDict = Dict{ConstrId,Constraint}
const MembMatrix = MembersMatrix{VarId,Variable,ConstrId,Constraint,Float64}

struct FormulationManager
    vars::VarDict
    constrs::ConstrDict
    coefficients::MembMatrix # rows = constraints, cols = variables
    partial_sols::MembMatrix # rows = variables, cols = solutions
    expressions::MembMatrix  # rows = expressions, cols = variables
end

FormulationManager() = FormulationManager(VarDict(),
                                          ConstrDict(),
                                          MembMatrix(),
                                          MembMatrix(),
                                          MembMatrix())
                                          
                                          


function add_var!(m::FormulationManager, var::Variable)
    haskey(vars, id) && error(string("Variable of id ", id, " exists"))
    vars[id] = v
    return
end

function add_constr!(m::FormulationManager, constr::Constraint)
    haskey(constrs, id) && error(string("Constraint of id ", id, " exists"))
    constrs[id] = constr
    return
end

get_var(m::FormulationManager, id::VarId) = vars[id]

get_constr(m::FormulationManager, id::ConstrId) = constrs[id]

get_vars(m::FormulationManager) = vars

get_constrs(m::FormulationManager) = constrs

get_coefficient_matrix(m::FormulationManager) = coefficients


# =================================================================
