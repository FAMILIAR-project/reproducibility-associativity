using ArgParse
using Random
using Statistics

@enum EqualityCheck ASSOCIATIVITY=1 MULT_INV=2 MULT_INV_PI=3

function equality_test(equality_check::EqualityCheck, x, y, z)::Bool
    if equality_check == ASSOCIATIVITY
        return x + (y + z) ≈ (x + y) + z # variation point: strict equality
    elseif equality_check == MULT_INV
        return (x * z) / (y * z) ≈ x / y
    elseif equality_check == MULT_INV_PI
        return (x * z * π) / (y * z * π) ≈ x / y
    end
end

function proportion(number::Int, seed_val::Union{Int,Nothing}, equality_check::EqualityCheck)::Float64
    isnothing(seed_val) ? Random.seed!() : Random.seed!(seed_val)
    ok = 0
    for i in 1:number
        x = rand()
        y = rand()
        z = rand()
        ok += equality_test(equality_check, x, y, z)
    end
    return ok*100/number
end

function strtoenum(enumgrp::Type{<:Enum{T}}, str::String) where {T<:Integer}
    srch = Symbol(str)
    found = -1
    for val in instances(enumgrp)
        if srch == Symbol(val)
            found = val
            break
        end
    end
    return found
end

function main()
    # older code using ArgParse.jl with ChatGPT (older version!)
    # parser = ArgParseSettings(description="Equality test with seed.")
    # add_argument!(parser, "--seed", type=int, default=nothing, help="Seed value.")
    # add_argument!(parser, "--number", type=int, default=10000, help="Number of tests")
    # add_argument!(parser, "--equality-check", type=EqualityCheck, required=true, choices=Enumerate.values(EqualityCheck), help="Type of equality check")
    # args = parse_args(parser)
    parser = ArgParseSettings("Equality test with seed",
                     version = "1.0",
                     add_version = true)

    @add_arg_table! parser begin
        "--seed"
            arg_type = Int
            help = "Seed value."
        "--number"
            arg_type = Int
            default = 10000
            help = "Number of tests."
        "--echeck"
            arg_type = String
            required = true
            # choices = Enum.values(EqualityCheck) # not working
            help = "Type of equality check." # TODO: Choices are: " * join(Enum.values(EqualityCheck), ",")
    end
    

    args = parse_args(parser)
    println("Parsed args:")
    for (key,val) in args
        println("  $key  =>  $(repr(val))")
    end

    # convert args.equality_check to EqualityCheck
    # equality_check = strtoenum(EqualityCheck, args.echeck)

    
    en_found = strtoenum(EqualityCheck, args["echeck"])
    if en_found == -1        
        println("Error: Invalid equality check type: $(args["echeck"])")
        return
    end  

   
    println(string(proportion(args["number"], args["seed"], en_found)) * "%")
end

main()