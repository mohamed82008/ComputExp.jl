# ComputExp

## ComputExpDB

```julia

struct ComputExpDB{AT, PT, PFT, LVT, IT, ET, RT, IPT, IRT, RIRT, RIPT}
    algorithms_table::AT
    problems_table::PT
    problem_features_table::PFT
    language_versions_table::LVT
    implementations_table::IT
    experiments_table::ET
    runs_table::RT
    implementation_parameters_table::IPT
    implementation_results_table::IRT
    run_implementation_result_table::RIRT
    run_implementation_parameter_table::RIPT
end
```

## Relational schema

![alt tag](https://github.com/mohamed82008/ComputExp.jl/blob/master/RelationsDiagram.png)

## Example

See the [notebook](https://github.com/mohamed82008/ComputExp.jl/blob/master/test/TestComputationalExperiments.ipynb).
