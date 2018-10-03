include("../utils.jl")
include("utils.jl")
include("varconstr.jl")
include("variables.jl")
include("constraints.jl")
include("solution.jl")
include("mastercolumn.jl")
include("problem.jl")
include("node.jl")
include("algsetupnode.jl")
include("algpreprocessnode.jl")
include("algevalnode.jl")

function unit_tests()
    @testset "varconstr.jl" begin
        varconstr_unit_tests()
    end
    @testset "variables.jl" begin
        variables_unit_tests()
    end
    @testset "constraints.jl" begin
        constraints_unit_tests()
    end
    @testset "solution.jl" begin
        solution_unit_tests()
    end
    @testset "mastercolumn.jl" begin
        mastercolumn_unit_tests()
    end
    @testset "problem.jl" begin
        problem_unit_tests()
    end
    @testset "node.jl" begin
        node_unit_tests()
    end
    @testset "algsetupnode.jl" begin
        algsetupnode_unit_tests()
    end
    @testset "algpreprocessnode.jl" begin
        alg_preprocess_node_unit_tests()
    end
    @testset "algevalnode.jl" begin
        alg_eval_node_unit_tests()
    end
end

