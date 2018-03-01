function split_not_empty(string, char)
    st = split(string, char)
    st = [x for x in st if x != ""]
    return st
end

function read_data(filename)
    n = 0
    m = 0
    a = Array{Int, 1}[]
    b = []
    c = []
    open(filename) do f
        s = readstring(f)
        s = replace(s, "\n", "")
        s = replace(s, "\r", "")
        s = split_not_empty(s, ";")
        for data in s
            data = split_not_empty(data, " = ")
            if length(data) == 1
                data = split_not_empty(data[1], "=")
            end
            if data[1] == "n"
                n = parse(Int, data[2])
            elseif data[1] == "m"
                m = parse(Int, data[2])
            elseif data[1] == "a"
                vect = data[2]
                vect = replace(vect, "[", "")
                vect = replace(vect, "]", "")
                vect = split_not_empty(vect, ",")
                for z in vect
                    push!(a,[parse(Int, y) for y in split_not_empty(z, " ")])
                end
                a = hcat(a...)
            elseif data[1] == "b"
                vect = data[2]
                vect = replace(vect, "[", "")
                vect = replace(vect, "]", "")
                vect = split_not_empty(vect, " ")
                b = [parse(Int, y) for y in vect]
            elseif data[1] == "c"
                vect = data[2]
                vect = replace(vect, "[", "")
                vect = replace(vect, "]", "")
                vect = split_not_empty(vect, ",")
                for z in vect
                    push!(c,[parse(Int, y) for y in split_not_empty(z, " ")])
                end
                c = hcat(c...)
            end
        end
    end
    return (n,m,a,b,c)
end

# get the order value
function get_affect(num, arr, order)
    max_val = maximum(arr)
    for k in 2:order
        arr[indmin(arr)] += max_val
    end
    return indmin(arr)
end

# Premier algorithme d'affectation, glouton
function glouton(n,m,a,b,c)
    priority = a.*c
    order = [i for i in 1:n]
    current_b = b
    affectations = Dict(i => m+1 for i in 1:n)
    for i in 1:n
        for k in 1:(m-1)
            index = get_affect(i, priority[i,:], k+1)
            if current_b[index] >= a[i,index]
                affectations[i] = index
                current_b[index] -= a[i,index]
                break
            end
        end
    end
    return affectations
end

# function reorder(order, i, new_pos):
#     new_order = [x for x in order[1: new_pos-1]]
#     push!(new_order, i)
#     append!(new_order, [x for x in order[new_pos:end] if x != i])
#     return new_order
#
# # Deuxième algorithme d'affectation, glouton, avec reaffectation
# function glouton2(n,m,a,b,c)
#     priority = a.*c
#     order = [i for i in 1:n]
#     current_b = b
#     affectations = Dict(i => 0 for i in 1:n)
#     last_affect = Dict(j => 0 for j in 1:m)
#     dic_tache = Dict(j => [] for j in 1:m)
#     while i <= n do
#         for k in 1:m
#             idx = order[i]
#             index = get_affect(idx, priority[idx,:], k)
#             if current_b[index] >= a[idx,index]
#                 affectations[i] = index
#                 current_b[index] -= a[idx,index]
#                 last_affect[index] = idx
#                 push!(dic_tache[index], idx)
#                 break
#             end
#         end
#         if (affectations[idx] == 0) && (i != 1)
#             new_pos = get_affect(idx, priority[idx,:], 1)
#             reorder(order, idx, new_pos)
#             recalculate_b()
#         end
#         i += 1
#     end
#     return affectations
# end

function add_virtual_machine(n,m,a,b,c)
    m2 = m + 1
    valb = sum(b)
    b2 = push!([x for x in b], valb)
    valc = sum(c)
    colc = [valc for i in 1:n]
    c2 = hcat(c, colc)
    cola = [0 for i in 1:n]
    a2 = hcat(a, cola)
    return n, m2, a2, b2, c2
end

function evaluate(affectation,c)
    cost = 0
    for tache in keys(affectation)
        cost += c[tache, affectation[tache]]
    end
    return cost
end

function calculate_b(b, a, affect)
    new_b = b
    for tache in keys(affect)
        new_b[affect[tache]] -= a[tache, affect[tache]]
    end
    return new_b
end

function level1_move!(affectation,current_b, n, m, a, b, c)
    modification = true
    while modification
        modification = false
        for k in keys(affectation)
            affect = affectation[k]
            for mach in 1:m
                if (affect != mach && a[k, mach] <= current_b[mach] && c[k, mach] < c[k, affect])
                    current_b[affect] += a[k, affect]
                    affectation[k] = mach
                    current_b[mach] -= a[k, mach]
                    modification = true
                    msg = string("    Replacement tache ", k, " de ", affect, " vers ", mach)
                    println(msg)
                    break # A verifier
                end
            end
        end
    end
    return modification
end

function level2_move!(affectation,current_b,n,m,a,b,c)
    modification = false
    change = true
    while change
        change = false
        for k1 in keys(affectation)
            for k2 in k1:n
                affect1 = affectation[k1]
                affect2 = affectation[k2]
                affect_weight = c[k1, affect1] + c[k2, affect2]
                if affect1 != affect2
                    potential_gain = affect_weight - c[k1, affect2] - c[k2, affect1]
                    if potential_gain > 0
                        possible1 = current_b[affect1] + a[k1, affect1] - a[k2, affect1]
                        possible2 = current_b[affect2] + a[k2, affect2] - a[k1, affect2]
                        if possible1 >= 0 && possible2 >= 0
                            current_b[affect1] = possible1
                            current_b[affect2] = possible2
                            affectation[k1] = affect2
                            affectation[k2] = affect1
                            modification = true
                            change = true
                            msg = string("    Echange taches ", k1, " et ", k2, " pour ", affect2, " et ", affect1)
                            println(msg)
                        end
                    end
                end
            end
        end
    end
    return modification
end

function level3_move!(affectation,current_b,n,m,a,b,c)
    modification = false
    change = true
    while change
        change = false
        for k1 in keys(affectation)
            for k2 in k1:n
                for k3 in k2:n
                    affect1 = affectation[k1]
                    affect2 = affectation[k2]
                    affect3 = affectation[k3]
                    affect_weight = c[k1, affect1] + c[k2, affect2] + c[k3, affect3]
                    if affect1 != affect2 && affect2 != affect3 && affect1 != affect3
                        alt1 = c[k1, affect2] + c[k2, affect3] + c[k3, affect1]
                        potential_gain1 = affect_weight - alt1
                        alt2 = c[k1, affect3] + c[k2, affect1] + c[k3, affect2]
                        potential_gain2 = affect_weight - alt2
                        if potential_gain1 > 0 && potential_gain1 >= potential_gain2
                            possible1 = current_b[affect1] + a[k1, affect1] - a[k3, affect1]
                            possible2 = current_b[affect2] + a[k2, affect2] - a[k1, affect2]
                            possible3 = current_b[affect3] + a[k3, affect3] - a[k2, affect3]
                            if possible1 >= 0 && possible2 >= 0 && possible3 >= 0
                                current_b[affect1] = possible1
                                current_b[affect2] = possible2
                                current_b[affect3] = possible3
                                affectation[k1] = affect2
                                affectation[k2] = affect3
                                affectation[k3] = affect1
                                modification = true
                                change = true
                                msg = string("    Rotations taches ", k1, ", ", k2, " et ", k3, " pour ", affect2, ", ", affect3, " et ", affect1)
                                println(msg)
                            end
                        elseif potential_gain2 > 0 && potential_gain2 >= potential_gain1
                            possible1 = current_b[affect1] + a[k1, affect1] - a[k2, affect1]
                            possible2 = current_b[affect2] + a[k2, affect2] - a[k3, affect2]
                            possible3 = current_b[affect3] + a[k3, affect3] - a[k1, affect3]
                            if possible1 >= 0 && possible2 >= 0 && possible3 >= 0
                                current_b[affect1] = possible1
                                current_b[affect2] = possible2
                                current_b[affect3] = possible3
                                affectation[k1] = affect3
                                affectation[k2] = affect1
                                affectation[k3] = affect2
                                modification = true
                                change = true
                                msg = string("    Rotations taches ", k1, ", ", k2, " et ", k3, " pour ", affect3, ", ", affect1, " et ", affect2)
                                println(msg)
                            end
                        end
                    end
                end
            end
        end
    end
    return modification
end

function LNS23opt(n_o, m_o, a_o, b_o, c_o; option="vide")
    # Initialisation, on affecte toutes les taches à une machine vituelle très couteuse
    n,m,a,b,c = add_virtual_machine(n_o,m_o,a_o,b_o,c_o)
    if option == "glouton"
        affectation = glouton(n,m,a,b,c)
        println(affectation)
        msg = string("Résultat glouton initial ", evaluate(affectation, c))
    else
        affectation = Dict(i => m for i in 1:n)
        println(affectation)
        msg = string("Résultat initial ", evaluate(affectation, c))
    end
    println(msg)
    current_b = calculate_b(b, a, affectation)
    current_level = 1
    arret = false
    while !arret
        if current_level == 1
            println("Optimisation voisinage 1")
            empty_space = level1_move!(affectation, current_b, n, m, a, b, c)
            current_level = 2
        end
        if current_level == 2
            println("Optimisation voisinage 2")
            echange = level2_move!(affectation, current_b, n, m, a, b, c)
            if echange
                current_level = 1
            else
                current_level = 3
            end
        end
        if current_level == 3
            println("Optimisation voisinage 3")
            tournee = level3_move!(affectation, current_b, n, m, a, b, c)
            if tournee
                current_level = 2
            else
                arret = true
            end
        end
        msg = string("Résultat courant ", evaluate(affectation, c))
        println(msg)
    end
    return affectation
end

n,m,a,b,c = read_data("GAP/GAP-a05100.dat")

res = LNS23opt(n, m, a, b, c, option="glouton")
println(res)
msg = string("Résultat final ", evaluate(res, c))
println(msg)

res = LNS23opt(n, m, a, b, c)
println(res)
msg = string("Résultat final ", evaluate(res, c))
println(msg)

function datafile_creation(n,m,a,b,c,res)
    open("test/test.dat", "w") do io
        # writing n
        write(io, "n = $n;\n")
        # writing m
        write(io, "m = $m;\n")
        # writing a
        write(io, "a = [\n")
        for i in 1:m
            write(io, "[ ")
            for j in a[:,i]
                write(io, "$j ")
            end
            if i == m
                write(io, "]\n")
            else
                write(io, "],\n")
            end
        end
        write(io, "];\n")
        # writing b
        write(io, "b = [ ")
        for i in b
            write(io, "$i ")
        end
        write(io, "];\n")
        # writing c
        write(io, "c = [\n")
        for i in 1:m
            write(io, "[ ")
            for j in c[:,i]
                write(io, "$j ")
            end
            if i == m
                write(io, "]\n")
            else
                write(io, "],\n")
            end
        end
        write(io, "];\n")
        # writing s (patterns)
        write(io, "Patterns = {\n")
        for i in 1:m
            num = i - 1
            write(io, "< ")
            write(io, "$num , $i, ")
            cost = 0
            for j in 1:n
                if res[j] == i
                    cost += c[j,i]
                end
            end
            write(io, "$cost, [ ")
            for j in 1:n
                bool = (res[j] == i)
                if bool
                    if j == n
                        write(io, "1 ")
                    else
                        write(io, "1, ")
                    end
                else
                    if j == n
                        write(io, "0 ")
                    else
                        write(io, "0, ")
                    end
                end
            end
            write(io, "] ")
            if i == m
                write(io, ">\n")
            else
                write(io, ">,\n")
            end
        end
        write(io, "};\n")
        # writing u
        write(io, "u = [ ")
        for i in 1:n
            write(io, "0.0 ")
        end
        write(io, "];\n")
        # writing v
        write(io, "v = [ ")
        for i in 1:m
            write(io, "0.0 ")
        end
        write(io, "];\n")
    end
end

datafile_creation(n,m,a,b,c,res)
