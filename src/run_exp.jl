macro run_exps(db)
    #addprocs(1)
    #n = procs()[end]
    #db = fetch(@spawnat n $(quote
    _results = gensym()
    all_implementations = gensym()
    functions = gensym()
    parameters = gensym()
    results = gensym()
    current_dir = gensym()
    esc(quote
        using JuliaDB
        using Query
        
        # Extract the implementations
        $all_implementations = Int[]
        x = @from i in db.runs_table begin
            @from j in db.experiments_table
            @where j.Execute && i.Experiment_ID == j.ID && !i.Executed && !i.Executing
            @select i.Implementation_ID
            @collect 
        end
        $all_implementations = unique(x)

        # Extract the functions, parameters and results
        $functions = Dict{Int, Symbol}()
        $parameters = Dict{Int, Vector{Tuple{Symbol, Int}}}()
        $results = Dict{Int, Vector{Int}}()
        for implementation in $all_implementations
            $parameters[implementation] = Tuple{Symbol,Int}[]
            $results[implementation] = Int[]

            i = db.implementations_table[implementation]
            $functions[implementation] = i.Function
            if i.Commit != ComputExp.HEAD(i.Repository)
                ComputExp.STASH(i.Repository)
                ComputExp.CHECKOUT(i.Repository, i.Commit)
            end
            eval(parse("using $(i.Repository)"))
            include(i.Script)

            params = @from j in db.implementation_parameters_table begin
                @where j.Implementation_ID == implementation
                @select {j.Parameter_symbol, j.ID}
                @collect 
            end
            for j in params
                push!($parameters[implementation], (j.Parameter_symbol, j.ID))
            end

            # Retrieves the results of the implementation, order is assumed the same order returned by the function
            $results[implementation] = @from j in db.implementation_results_table begin
                @where j.Implementation_ID == implementation
                @select j.ID
                @collect 
            end
        end

        $current_dir = pwd()

        # Run the experiments
        for exper in db.experiments_table
            if exper.Execute
                # Get the run ids of the experiment
                exper_runs = @from i in db.runs_table begin
                    @where i.Experiment_ID == exper.ID
                    @select i.ID
                    @collect 
                end
                
                # Change the directory
                cd(exper.Directory)
                
                # Run the run
                for rn in exper_runs
                    r = db.runs_table[rn]
                    if !r.Executed && !r.Executing
                        column(db.runs_table, :Executing)[rn] = true
                        problem_features = Dict(@from i in db.problem_features_table begin
                            @where i.Problem_ID == r.Problem_ID
                            @select {i.Feature_symbol, i.Feature_value}
                            @collect
                        end)

                        run_parameters = Dict(@from i in db.run_implementation_parameter_table begin
                            @from j in db.implementation_parameters_table
                            @where i.Run_ID == r.ID && i.Implementation_parameter_ID == j.ID
                            @select {j.Parameter_symbol, i.Value}
                            @collect
                        end)
                        
                        func = db.implementations_table[r.Implementation_ID].Function
                        $_results = eval(func)(; problem = problem_features, parameters = run_parameters)

                        column(db.runs_table, :Executed)[rn] = true
                        column(db.runs_table, :Executing)[rn] = false
                        
                        for (rid, rv) in zip($results[r.Implementation_ID], $_results)
                            resultid = ComputExp.newid(db.run_implementation_result_table)
                            ComputExp.add_row!(db.run_implementation_result_table, @NT(ID = resultid, Implementation_result_ID = rid, Run_ID = r.ID, Value = rv))
                        end
                    end
                end
                #column(db.experiments_table, :Execute)[exper.ID] = false
            end
        end
        cd($current_dir)
    #end))
    #rmprocs(n)
    end)
end
