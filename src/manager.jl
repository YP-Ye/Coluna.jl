const VarDict = Dict{VarId,Variable}
const ConstrDict = Dict{ConstrId,Constraint}
const VarConstrDict = Union{VarDict,ConstrDict}
const VarMembership = MembersVector{VarId,Variable,Float64}
const ConstrMembership = MembersVector{ConstrId,Constraint,Float64}
const MembMatrix = MembersMatrix{VarId,Variable,ConstrId,Constraint,Float64}
const VarMatrix = MembersMatrix{VarId,Variable,VarId,Variable,Float64}

struct FormulationManager
    vars::VarDict
    constrs::ConstrDict
    coefficients::MembMatrix # rows = constraints, cols = variables
    partial_sols::VarMatrix # rows = variables, cols = solutions
    expressions::VarMatrix  # rows = expressions, cols = variables
end

function FormulationManager()
    vars = VarDict()
    constrs = ConstrDict()
    
    return FormulationManager(vars,
                              constrs,
                              MembersMatrix{Float64}(vars,constrs),
                              MembersMatrix{Float64}(vars,vars),
                              MembersMatrix{Float64}(vars,vars))
end

haskey(m::FormulationManager, id::Id{Variable}) = haskey(m.vars, id)
haskey(m::FormulationManager, id::Id{Constraint}) = haskey(m.constrs, id)

function addvar!(m::FormulationManager, var::Variable)
    haskey(m.vars, var.id) && error(string("Variable of id ", var.id, " exists"))
    m.vars[var.id] = var
    return var
end

function addpartialsol!(m::FormulationManager, var::Variable)
     ### check if partialsol exists should take place heren along the coeff update
    return var
end

function addconstr!(m::FormulationManager, constr::Constraint)
    haskey(m.constrs, constr.id) && error(string("Constraint of id ", constr.id, " exists"))
    m.constrs[constr.id] = constr
    return constr
end

getvar(m::FormulationManager, id::VarId) = m.vars[id]

getconstr(m::FormulationManager, id::ConstrId) = m.constrs[id]

getvars(m::FormulationManager) = m.vars

getconstrs(m::FormulationManager) = m.constrs

getcoefmatrix(m::FormulationManager) = m.coefficients

getpartialsolmatrix(m::FormulationManager) = m.partial_sols

function Base.show(io::IO, m::FormulationManager)
    println(io, "FormulationManager :")
    println(io, "> variables : ")
    for (id, var) in m.vars
        println(io, "  ", id, " => ", var)
    end
    println(io, "> constraints : ")
    for (id, constr) in m.constrs
        println(io, " ", id, " => ", constr)
    end
    return
end


# =================================================================

