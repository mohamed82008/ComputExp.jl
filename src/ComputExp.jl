module ComputExp

using JuliaDB
using Missings
using Query
using NamedTuples

include("utils.jl")
include("types.jl")
include("api.jl")
include("run_exp.jl")

export  ComputExpDB, 
        New!, 
        Language, 
        Algorithm, 
        Implementation, 
        Problem, 
        Experiment, 
        Run,
        @run_exps

end # module
