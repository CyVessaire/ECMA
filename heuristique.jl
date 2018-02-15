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
        s = split_not_empty(s, ";")
        for data in s
            data = split_not_empty(data, r" = ")
            # println(data)
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
    affectations = Dict(i => 0 for i in 1:n)
    for i in 1:n
        for k in 1:m
            index = get_affect(i, priority[i,:], k)
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
#         if (affectations[idx] == 0) and (i != 1)
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

n,m,a,b,c = read_data("GAP/GAP-a05100.dat")
res = glouton(n,m,a,b,c)
n2,m2,a2,b2,c2 = add_virtual_machine(n,m,a,b,c)
println("n")
println(n)
println(n2)

println("m")
println(m)
println(m2)

println("a")
println(a)
println(a2)

println("b")
println(b)
println(b2)

println("c")
println(c)
println(c2)

function calculate_b(b, a, affect)
    new_b = b
    for tache in keys(affect)
        new_b[tache] -= a[tache, affect[tache]]
    end
    return new_b
end

function level1_move!(affectation,current_b,n,m,a,b,c)
    modification= false
    for k in keys(affectation)
        affect = affectation[k]
        for mach in range(m)
            if (affect != mach
                and a[k, mach] <= current_b[mach]
                and c[k, mach] < c[k, affect])
                current_b[affect] += a[k, affect]
                affectation[k] = mach
                current_b[mach] -= a[k, mach]
                modification = true
                break # A verifier
            end
        end
    end
    return modification
end

function level2_move!(affectation,current_b,n,m,a,b,c)
    continue
end

function level3_move!(affectation,current_b,n,m,a,b,c)
    continue
end

function LNS23opt(n_o,m_o,a_o,b_o,c_o)
    # Initialisation, on affecte toutes les taches à une machine vituelle très couteuse
    n,m,a,b,c = add_virtual_machine(n_o,m_o,a_o,b_o,c_o)
    first_affect = glouton(n,m,a,b,c)
    current_b = calculate_b(b, a, first_affect)
    current_level = 2
    arret = false
    while !arret do
        if current_level == 1
            empty_space = level1_move!(affectation,current_b,n,m,a,b,c)
            current_level = 2
        end
        if current_level == 2
            echange = level2_move(affectation)
            if echange
                current_level = 1
            else
                current_level = 3
            end
        end
        if current_level == 3
            tournee = level3_move(affectation)
            if tournee
                current_level = 2
            else
                arret = true
            end
        end
    end
end
