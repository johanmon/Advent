module Adv

function day1a()
    in = parse.(Int64, readlines("day1.csv"))
    count = function ((prev, sum), x) 
        if x > prev
            (x, sum+1)
        else
            (x, sum)
        end
    end
    foldl(count, in, init=(Inf, 0))
end

function day1b()
    in = parse.(Int64, readlines("day1.csv"))

    count = function((p1, p2, p3, sum), x)
        if x + p1 + p2 > p1+p2+p3
            (x,p1,p2, sum+1)
        else
            (x,p1,p2, sum)
        end
    end
    foldl(count, in, init=(Inf, Inf, Inf, 0))
end

#=========================================================================#

function day2a()
    in =  (x -> (x[1], parse(Int64, x[2]))).( split.(readlines("day2.csv"), " "))
    count = function((depth, dist), x)
        if cmp(x[1], "down") == 0 
            (depth+x[2], dist)
        elseif cmp(x[1], "up") == 0 
            (depth-x[2], dist)
        else
            (depth, dist+x[2])
        end
    end
    foldl(count, in, init=(0, 0))    
end

function day2b()
    in =  (x -> (x[1], parse(Int64, x[2]))).( split.(readlines("day2.csv"), " "))
    count = function((depth, dist, aim), x)
        if cmp(x[1], "down") == 0 
            (depth, dist, aim+x[2])
        elseif cmp(x[1], "up") == 0 
            (depth, dist, aim-x[2])
        else
            (depth+(aim*x[2]), dist+x[2], aim)
        end
    end
    foldl(count, in, init=(0, 0, 0))    
end

#=========================================================================# 


function day3a()
    in = (r -> (x -> parse(Int16, x)).(collect(r))).(readlines("test3.csv"))
    k = length(in[1])
    l = length(in)    
    ks = foldl((s,x) -> s + x, in, init=fill(0,k))
    gamma = rate(ks, l, <) 
    epsilon = rate(ks, l, >=)
    (bin_to_int(gamma), bin_to_int(epsilon))
end

# The rate is calculated given the vector ks consisting of the sum in
# each column. The sum is of course the number of ones. Knowing the k
# value of a column and the lenbth of the column we deterine the
# rate. The gamma and epsilon rate only differ in the comparisin operator.

function rate(ks, l, op)
    map( x -> if op.(x,(l-x)) 0 else  1  end, ks)
end

function bin_to_int(bin)
    foldl((a, x) -> a*2 + x , bin, init=0)
end


function day3b()
    in = (r -> (x -> parse(Int16, x)).(collect(r))).(readlines("day3.csv"))

    oxygen = rating(in, <)[1]
    scrubber = rating(in, >=)[1]

    (bin_to_int(oxygen), bin_to_int(scrubber))
end

# The rating is a bit more complicated, we need to recalculate the k
# value for a column in each interation. We implement it as a fold
# operation where the accumulated value are, a, are the remaining
# vectors. If the length is 1 we are done otherwise we calculate the k
# value and filter what we have. 

function rating(in, op)
    foldl((a,i) ->
        let l = length(a)
            if (l == 1)
                a
            else
                k = foldl( (s, x) -> x[i] + s, a, init=0);
                b = if op.(k, l-k) 0 else 1 end
                filter( r -> r[i] == b, a)                
            end
          end,
          1:length(in[1]), init=in)
end

# As a side note: a was thinking about doing this recursivly; in each
# recursion you would strip one column from the vectors. In the end I
# think this would just mean an overhead so I settled for the solution
# where you keep track of the index i.


#=========================================================================# 


function day4a()
    raw = readlines("day4.csv")
    seq = ( x -> parse(Int,x)).(split(raw[1], ","))
    brds = boards(raw[2:end], [])
    bingo(seq, brds)
end

# This is where things start to get complicated; how do we represent a
# board? This is my idea - instead of represneting the board as 5x5
# matrix we represent a board by five rows and five columns, each
# square is then counted twice. As numbers are called the numbers are
# removed from these vectors. Why? Well, no one really cares what the
# board looks like, i never access the board by row and column, the
# only thing that matters is to see if I win i.e. if a row or column
# is empty. Let's give it a try. 

function boards(in, all)
    if length(in) == 0
        all
    else
        brd = let 
            r1 = row(in[2])
            r2 = row(in[3])
            r3 = row(in[4])
            r4 = row(in[5])
            r5 = row(in[6])            
            [r1,r2,r3,r4,r5,
             column(1,r1,r2,r3,r4,r5),
             column(2,r1,r2,r3,r4,r5),
             column(3,r1,r2,r3,r4,r5),
             column(4,r1,r2,r3,r4,r5),            
             column(5,r1,r2,r3,r4,r5)]
        end
        # Ah, a recursive call where we jump forward six positions. I
        # use this since I'm used to languiages that have what is
        # caleld "tail recursion optimization". Whith this
        # optimization, this recursive call would not consume stack
        # space. Julia dows not provide this so do build on the
        # stack. We survive but if the input was larger we would have
        # to rewrite this in a for-loop.
        boards(in[7:end], push!(all, brd))
    end
end

function column(i, r1, r2, r3, r4,r5)
    [r1[i], r2[i], r3[i], r4[i], r5[i]]
end

function row(rw)
    # Had to use a regex since there could be one or two spaces between numbers.
    m =  match(r"(?<p1>\d+)[' ']+(?<p2>\d+)[' ']+(?<p3>\d+)[' ']+(?<p4>\d+)[' ']+(?<p5>\d+)",rw)
    parse.(Int,[ m[:p1],  m[:p2], m[:p3],  m[:p4], m[:p5]])
end

# A board is a wining board (Bingo!) if one of its rows or columns is empty. 

function bingo(brd)
    foldl( (a,x) -> (a || [] == x), brd, init=false)
end

# We have a winner if one of the boards is a winner

function winner(brds)
    for brd in brds 
        if bingo(brd)
            return Some(brd)
        end
    end
    return nothing
end

# The score is now simply the sum of what is left in the rows (don't
# count the columns as well since all squares occur twice).

function score(brd, nr)
    sum(sum.(brd[1:5])) * nr
end

# So, now it is time to play. Call a number and filter the boards that
# we have. If we have a winner we stop. 

function play(seq, brds)
    for nr in seq
        let
            brds = map( b -> map( r -> filter(x -> x != nr, r), b), brds)
            win = winner(brds)
            if win != nothing
                return score(something(win), nr)
            end
        end
    end
end


# In part two we should return the last borad to win. We can do this
# by changing the play function.

function day4b()
    raw = readlines("day4.csv")
    seq = ( x -> parse(Int,x)).(split(raw[1], ","))
    brds = boards(raw[2:end], [])
    plau(seq, brds)
end

# When finding a winner we simply returned the winner. This is now
# more complicated since we should continue the game. We could also
# have several "bingo" boards in each round. Let's return all "bingo"
# boards and the remaining boards?

function wanner(brds)

    foldl( ((w,r), b) ->
        if bingo(b)
            (push!(w,b), r)
           else
            (w, push!(r, b))
           end,
           brds,
           init = ([], []))
end

# The play sequence is almost as before but now we keep track of the
# last bingo board. If we have more than one bingo board we keep the higest score.

function plau(seq, brds)
    let 
        last = 0
        for nr in seq
            brds = map( b -> map( r -> filter(x -> x != nr, r), b), brds)
            (win, brds) = wanner(brds)
            if win != []
                last = sort(map( w -> score(w,nr), win), lt= >)[1]
            end
        end
        last
    end
end

                                                         
    



end
