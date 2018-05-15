struct Language end
struct Algorithm end
struct Implementation end
struct Problem end
struct Experiment end
struct Run end

function New!(db, ::Type{Language}; name = missing, version = missing, commit = "")
    @check_not_missing "Language" (name, "name") (version, "version")
    @check_type String "Language" (name, "name") (version, "version") (commit, "commit")
    id = newid(db.language_versions_table)
    add_row!(db.language_versions_table, @NT(ID = id, Name = name, Version = version, Commit = commit))
    
    return 
end

function New!(db, ::Type{Algorithm}; name = missing, description = "")    
    @check_not_missing "Algorithm" (name, "name")
    @check_type String "Algorithm" (name, "name")
    id = newid(db.algorithms_table)
    add_row!(db.algorithms_table, @NT(ID = id, Name = name, Description = description))
    return
end

function New!(db, ::Type{Implementation}; algorithm = missing, language = missing, repository = missing, commit = missing, script = missing, func = missing, parameters = (), parameter_descriptions = (), results = missing)
    @check_not_missing "Implementation's" (algorithm, "algorithm") (language, "programming language") (repository, "repository") (script, "script") (func, "function") (results, "results")
    @check_type String "Implementation's" (repository, "repository") (script, "script") 
    @check_type U(String) "Implementation's" (commit, "commit")
    @check_type Symbol "Implementation's" (func, "function") 
    @check_type Tuple "Implementation's" (results, "results") (parameters, "parameters")
    length(results) == 0 || eltype(results) <: String || (warn("Results names should be of type String."); return )
    length(parameters) > 0 || eltype(parameters) <: Symbol || (warn("Parameters should be of type Symbol."); return )
    @check_valid_id db.language_versions_table ID language "Language"
    @check_valid_id db.algorithms_table ID algorithm "Algorithm"

    if commit isa Missing
        commit = HEAD(repository)
    end
    impl_id = newid(db.implementations_table)
    add_row!(db.implementations_table, @NT(ID = impl_id, Algorithm_ID = algorithm, Language_ID = language, Repository = repository, Commit = commit, Script = script, Function = func))

    for (i,p) in enumerate(parameters)
        param_id = newid(db.implementation_parameters_table)
        add_row!(db.implementation_parameters_table, @NT(ID = param_id, Implementation_ID = impl_id, Parameter_symbol = p, Parameter_description = parameter_descriptions == () ? "" : parameter_descriptions[i]))
    end

    for r in results
        result_id = newid(db.implementation_results_table)
        add_row!(db.implementation_results_table, @NT(ID = result_id, Implementation_ID = impl_id, Result_name = r))
    end

    return 
end

function New!(db, ::Type{Problem}; description = "", kwargs...)
    problemid = newid(db.problems_table)
    add_row!(db.problems_table, @NT(ID = problemid, Description = description))
    for (k, v) in kwargs
        featureid = newid(db.problem_features_table)
        add_row!(db.problem_features_table, @NT(ID = featureid, Problem_ID = problemid, Feature_symbol = k, Feature_value = v))
    end
    return 
end

function New!(db, ::Type{Experiment}; directory = pwd(), execute = true)
    id = newid(db.experiments_table)
    if !ispath(directory)
        mkdir(directory)
    end
    add_row!(db.experiments_table, @NT(ID = id, Directory = directory, Execute = execute))
    return 
end

function New!(db, ::Type{Run}; experiment = missing, implementation = missing, parameters = missing, problems = missing)
    @check_not_missing "Run's" (experiment, "experiment") (implementation, "implementation") (parameters, "parameters")
    @check_type Union{NamedTuples.NamedTuple, Vector{<: NamedTuples.NamedTuple}} "Run's" (parameters, "parameters")
    @check_valid_id db.experiments_table ID experiment "Experiment"
    @check_valid_id db.implementations_table ID implementation "Implementation"

    if parameters isa Array
        param = parameters[1]
    else
        param = parameters
    end
    param_ids = Dict{Symbol, Int}()
    t = db.implementation_parameters_table
    for k in keys(param)
        x = @from i in t begin
            @where i.Implementation_ID == implementation && i.Parameter_symbol == k
            @select i.ID
            @collect 
        end
        param_ids[k] = x[1]
    end
    if problems isa Missing
        all_problem_ids = columns(db.problems_table, :ID)
    else
        all_problem_ids = problems
    end
    for problem in all_problem_ids
        if typeof(parameters) <: AbstractVector
            for param in parameters
                runid = newid(db.runs_table)
                add_row!(db.runs_table, @NT(ID = runid, Experiment_ID = experiment, Problem_ID = problem, Implementation_ID = implementation, Executing = false, Executed = false))
                for (k,v) in zip(keys(param), values(param))
                    valueid = newid(db.run_implementation_parameter_table)
                    add_row!(db.run_implementation_parameter_table, @NT(ID = valueid, Implementation_parameter_ID = param_ids[k], Run_ID = runid, Value = v))
                end
            end
        else
            runid = newid(db.runs_table)
            add_row!(db.runs_table, @NT(ID = runid, Experiment_ID = experiment, Problem_ID = problem, Implementation_ID = implementation, Executing = false, Executed = false))
            for (k,v) in zip(keys(parameters), values(parameters))
                valueid = newid(db.run_implementation_parameter_table)
                add_row!(db.run_implementation_parameter_table, @NT(ID = valueid, Implementation_parameter_ID = param_ids[k], Run_ID = runid, Value = v))
            end
        end
    end

    return     
end
