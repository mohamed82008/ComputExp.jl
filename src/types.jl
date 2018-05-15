struct ComputExpDB{AT, PT, PFT, LVT, IT, ET, #=EPT, EIT,=# RT, IPT, IRT, RIRT, RIPT}
    algorithms_table::AT
    problems_table::PT
    problem_features_table::PFT
    language_versions_table::LVT
    implementations_table::IT
    experiments_table::ET
    #experiment_problem_table::EPT
    #experiment_implementation_table::EIT
    runs_table::RT
    implementation_parameters_table::IPT
    implementation_results_table::IRT
    run_implementation_result_table::RIRT
    run_implementation_parameter_table::RIPT
end

import Base: show, display
show(io::IO, db::ComputExpDB) = println("ComputExpDB")

function ComputExpDB()
    algorithms_table = table(@NT(ID = Int[], Name = String[], 
        Description = String[]), pkey=:ID)
    
    problems_table = table(@NT(ID = Int[], Description = String[]), 
        pkey=:ID)

    problem_features_table = table(@NT(ID = Int[], Problem_ID = Int[], 
        Feature_symbol = Symbol[], Feature_value = Any[]), pkey=:ID)

    language_versions_table = table(@NT(ID = Int[], Name = String[], 
        Version = String[], Commit = U(String)[]), pkey=:ID)
    
    implementations_table = table(@NT(ID = Int[], Algorithm_ID = Int[], 
        Language_ID = Int[], Repository = String[], Commit = U(String)[], 
        Script = String[], Function = Symbol[]), pkey = :ID)
    
    experiments_table = table(@NT(ID = Int[], Directory = String[], 
        Execute = Bool[]), pkey = :ID)

    #experiment_problem_table = table(@NT(ID = Int[], Experiment_ID = Int[],
    #    Problem_ID = Int[]), pkey = :ID)

    #experiment_implementation_table = table(@NT(ID = Int[], 
    #    Experiment_ID = Int[], Implementation_ID = Int[]), pkey = :ID)
    
    runs_table = table(@NT(ID = Int[], Experiment_ID = Int[], 
        Problem_ID = Int[], Implementation_ID = Int[], Executing = Bool[], 
        Executed = Bool[]), pkey = :ID)

    implementation_parameters_table = table(@NT(ID = Int[], 
        Implementation_ID = Int[], Parameter_symbol = Symbol[], 
        Parameter_description = String[]), pkey = :ID)
    
    implementation_results_table = table(@NT(ID = Int[], 
        Implementation_ID = Int[], Result_name = String[]), pkey = :ID)
    
    run_implementation_result_table = table(@NT(ID = Int[], 
        Implementation_result_ID = Int[], Run_ID = [], 
        Value = Any[]), pkey = :ID)
    
    run_implementation_parameter_table = table(@NT(ID = Int[],
        Implementation_parameter_ID = Int[], Run_ID = [], 
        Value = Any[]), pkey = :ID)
    
    return ComputExpDB(algorithms_table, problems_table, 
        problem_features_table, language_versions_table, 
        implementations_table, experiments_table#=, experiment_problem_table=#, 
        #=experiment_implementation_table,=# runs_table,
        implementation_parameters_table, implementation_results_table, 
        run_implementation_result_table, run_implementation_parameter_table)
end
