using ArgParse
using Random
using Statistics

@enum EqualityCheck ASSOCIATIVITY=1 MULT_INV=2 MULT_INV_PI=3

function equality_test(equality_check::EqualityCheck, x, y, z, strict_equality::Bool)::Bool
    if equality_check == ASSOCIATIVITY
        if strict_equality
            return x + (y + z) == (x + y) + z
        else
            return x + (y + z) ≈ (x + y) + z # variation point: strict equality
        end
    elseif equality_check == MULT_INV
        if strict_equality
            return (x * z) / (y * z) == x / y
        else
            return (x * z) / (y * z) ≈ x / y
        end
    elseif equality_check == MULT_INV_PI
        if strict_equality
            return (x * z * π) / (y * z * π) == x / y
        else
            return (x * z * π) / (y * z * π) ≈ x / y
        end
    end
end

function proportion(number::Int, seed_val::Union{Int,Nothing}, equality_check::EqualityCheck, strict_equality::Bool)::Float64
    isnothing(seed_val) ? Random.seed!() : Random.seed!(seed_val)
    ok = 0
    for i in 1:number
        x = rand()
        y = rand()
        z = rand()
        ok += equality_test(equality_check, x, y, z, strict_equality)
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
        "--equality-check"
            arg_type = String
            required = true
            # choices = Enum.values(EqualityCheck) # not working
            help = "Type of equality check." # TODO: Choices are: " * join(Enum.values(EqualityCheck), ",")
        "--strict-equality"
            arg_type = Bool
            default = false
            help = "Strict equality. Default: ≈ (approximate)"
    end
    

    args = parse_args(parser)   

    # convert args.equality_check to EqualityCheck  
    en_found = strtoenum(EqualityCheck, args["equality-check"])
    if en_found == -1        
        println("Error: Invalid equality check type: $(args["equality-check"])")
        return
    end  

   
    println(string(proportion(args["number"], args["seed"], en_found, args["strict-equality"])) * "%")
end

main()