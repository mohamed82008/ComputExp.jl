U(T) = Union{Missing, T}

function add_row!(t, named_tuple)
	push!(rows(t), named_tuple)
    table(t, pkey = t.pkey, copy = false)
    return 
end

macro check_not_missing(heading, args...)
    expr = Expr(:block)
    for arg in args
        push!(expr.args, :(!(($arg)[1] isa Missing) || (warn("$($heading) $(($arg)[2]) is missing and must be set."); return )))
    end
    esc(expr)
end

macro check_type(T, heading, args...)
    expr = Expr(:block)
    for arg in args
        push!(expr.args, :(($arg)[1] isa $T || (warn("$($heading) $(($arg)[2]) must be of type $($T)."); return )))
    end
    esc(expr)
end

newid(t) = reduce(max, t, select = :ID, 0) + 1

macro check_valid_id(t, field, id, heading)
    return esc(:($id ∈ columns($t).$field || (warn("$($heading) id does not exist."); return )))
end

function DIR(repository)
    d = Base.find_in_path(repository)
    gitdir = joinpath(d[1:search(d, "\\src\\").start-1], ".git")
    gitdir
end

function HEAD(repository)
    gitdir = DIR(repository)
    commit = strip(readstring(`git --git-dir $gitdir rev-parse HEAD`))
    commit
end

function STASH(repository)
    gitdir = DIR(repository)
    run(`git --git-dir $gitdir stash`)
    return 
end

function CHECKOUT(repository, commit)
    gitdir = DIR(repository)
    run(`git --git-dir $gitdir checkout $commit`)
    return 
end

function editvalue!(t, f, i, v)
    t.columns.columns[f][i] = v
    return
end