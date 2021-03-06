using InteractiveUtils
using DataStructures
using BenchmarkTools
using Statistics
input_1 = parse.(Int64, readlines("day1.txt"))
day1(input, window) = count(i->input[i+window] > input[i], 1:length(input)-window)
#day1(input_1, 1), day1(input_1, 3)
input_2 = split.(readlines("day2.txt"))
function day2(input)
    commands = Dict("forward"=>(i, v)->(v[1], i+v[2], v[3]+i*v[1]),
    "up"=>(i, v)->(v[1]-i, v[2], v[3]),
    "down"=>(i, v)->(v[1]+i, v[2], v[3]))
    state = (0,0,0)
    for input_v in input
        state .= commands[input_v[1]](parse(Int, input_v[2]), state)
    end
    return state[3]*state[2]
end
#@btime day2(input_2);
input_3 = readlines("day3.txt")
function day3(input_raw)
    input = permutedims(reshape(collect(Iterators.flatten(split.(input_raw, ""))), (length(input_raw[1]), :)))
    get_count(data, col) = count(i->i=="1", data[:,col])/size(data,1)
    eps = parse(Int, join(get_count(input, i) > 0.5 ? "1" : "0" for i in 1:size(input,2)), base=2)
    gam = 2^size(input,2) - 1 - eps
    function count_filter(subset, selector)
        for i in 1:size(input,2)
            subset = subset[subset[:,i] .== (selector(get_count(subset, i)) ? "1" : "0"), :]
            if size(subset,1) == 1
                return parse(Int, join(subset), base=2)
            end
        end
    end
    return (eps * gam, count_filter(input, x->x>=0.5) * count_filter(input, x->x<0.5))
end
#@btime day3(input_3);
#day3(input_3)

input_4 = readlines("day4.txt")
function day4(input, grid = 5)
    called_nums = parse.(Int, split(input[1],","))
    makeboard(board_in) = [parse.(Int, split(board_in[i])) for i in 1:grid]
    boards = [makeboard(input[i:i+grid-1]) for i in 3:grid+1:length(input)]
    complete(board) = any(all(board[i][j] == -1 for i in 1:grid) for j in 1:grid) || any(all(board[i][j] == -1 for j in 1:grid) for i in 1:grid)
    scores = []
    for num in called_nums
        for n in filter(i->!complete(boards[i]), 1:length(boards))
            boards[n] = [[boards[n][i][j] == num ? -1 : boards[n][i][j] for j in 1:grid] for i in 1:grid]
            if complete(boards[n])
                push!(scores, sum(filter(i->i>0, collect(Iterators.flatten(boards[n])))) * num)
            end
        end
    end
    return (scores[1], scores[end])
end
#day4(input_4)
#@btime day4(input_4)

input_5 = readlines("day5.txt")
function day5(input; diag=true)
    function process_line(line)
        a, b, c, d = parse.(Int, match(r"(\d+),(\d+) -> (\d+),(\d+)", line).captures)
        if a > c || (a == c && b > d) # For simplicity, a,b is on the bottom/left
            a, b, c, d = c, d, a, b
        end
        return a == c ? # Row
                [(c+1, a+1) for c in b:d] : # Lots of +1s since Julia is 1-indexed
            b == d ? # Col
                [(b+1, r+1) for r in a:c] :
            diag ? # Diagonal, and diagonals are enabled. Up or down depending on d>b
                [(b+1+i*(d>b ? 1 : -1), a+i+1) for i in 0:c-a] : []
    end
    return count(i->i[2]>1, counter(Iterators.flatten([process_line(l) for l in input])))
end
@assert(((day5(input_5, diag=false), day5(input_5, diag=true)) == (5306, 17787)))

input_6 = readlines("day6.txt")
function day6(input, time)
    timers = [counter(parse.(Int, split(input[1],",")))[i] for i in 0:8]
    for _ in 1:time
        timers = vcat(timers[2:end], timers[1])
        timers[7] += timers[end]
    end
    return sum(timers)
end
@assert((day6(input_6,80), day6(input_6, 256)) == (354564, 1609058859115))

input_7 = readlines("day7.txt")
function day7(input)
    vals = parse.(Int, split(input[1],","))
    (med_v, mean_v) = (median(vals), round(mean(vals)))
    return sum(abs(med_v-v) for v in vals), minimum(sum((abs(v-i)*abs(v-i)+1)/2 for v in vals) for i in mean_v-1:mean_v+1)
end
@assert(day7(input_7) == (328318.0, 8.9621123e7))
@btime day7(input_7)