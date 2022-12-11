defmodule Day11 do

  ## Day 11, ok some Sunday fun where it did require some
  ## thinking. Firts of all I sciped parsing the text input and
  ## instead used some Emacs keyboard macros to turn the monkies into
  ## some sensible structured data. I encoded the increment of the
  ## worry level as a function but left the test and which monkey to
  ## throw at as separate values. These could of course had been
  ## encoded in the function as well but it then felt like an ok idea
  ## since I didn't know how to actualy use the data.

  ## The first task in teh end quite simple. The tricky part was
  ## understanding what was going on i.e. the item itself had a
  ## chainging worrying level but your worry level did not increas
  ## etc. Ok, after things were straightened out and realizing that
  ## there were no obvious clever way maps came to resque. The monkeys
  ## items were collected in one map and the Map.get_and_update/3
  ## funktion was used to update it. Anoter map was used to hold the
  ## parameters of each monkey but these could better be stored in a
  ## tuple since we never change the content and the monkeys are
  ## called 0..k.
  ##
  ## I first implemented a version that only printed out the itens of
  ## each monkey after each round so that I knew things workd
  ## ok. After that it was only a small addition to kepp track of the
  ## number of items considered by each monkey.
  ##
  ## The second task was at first puzzeling ... how do I invent a way
  ## to keep my worries under control? Realizing that one could do
  ## multiplication mod some number that stil kept all tests happy was
  ## of course the soultion and why not multiply the primes that we
  ## used. 
  ##
  ## I realize that I'm still old-school since I often implement
  ## functions like run/6 and roudns/6 using explicit recursion
  ## instead of a reduce expression.
  
  def input() do 
    [{0, [89, 84, 88, 78, 70],             fn(old) -> old * 5 end,   7,  6,  7},
     {1, [76, 62, 61, 54, 69, 60, 85],     fn(old) -> old + 1 end,  17,  0,  6},
     {2, [83, 89, 53],                     fn(old) -> old + 8 end,  11,  5,  3},
     {3, [95, 94, 85, 57],                 fn(old) -> old + 4 end,  13,  0,  1},
     {4, [82, 98],                         fn(old) -> old + 7 end,  19,  5,  2},
     {5, [69],                             fn(old) -> old + 2 end,   2,  1,  3},
     {6, [82, 70, 58, 87, 59, 99, 92, 65], fn(old) -> old * 11 end,  5,  7,  4},
     {7, [91, 53, 96, 98, 68, 82],         fn(old) -> old * old end, 3,  4,  2}]
  end


  def test() do
    [{0, [79, 98],         fn(old) -> old * 19 end,  23, 2, 3},
     {1, [54, 65, 75, 74], fn(old) -> old + 6 end,   19, 2, 0},
     {2, [79, 60, 97],     fn(old) -> old * old end, 13, 1, 3},
     {3, [74],             fn(old) -> old + 3 end,   17, 0, 1}]
  end
  
  def task(rounds) do
    input = input()
    k = length(input)
    items = input |>
      Enum.map(fn({i, itms, _f, _d, _m1, _m2}) -> {i, itms} end) |>
      Map.new()
    table = input |>
      Enum.map(fn({i, _itms, f, d, m1, m2}) -> {i, {f, d, m1, m2}} end) |>
      Map.new()
    mod = input |>
      Enum.reduce(1, fn({_i, _itms, _f, d, _m1, _m2}, m) -> m* d end)
    inpect = Map.new(for i <- 0..(k-1) do {i, 0} end)
    run(rounds, k, mod, items, table, inpect)
  end

  def run(0, _, _, _, _, inspect) do inspect end
  def run(rounds, k, mod, items, table, inspect) do
    {items, inspect} = round(0, k, mod, items, table, inspect)
    ## pp(items, rounds, k)
    run(rounds-1, k, mod, items, table, inspect)
  end

  def round(k, k, _mod, items, _table, inspect) do {items, inspect} end
  def round(i, k, mod, items, table, inspect) do 
    {items, inspect} = turn(i, mod, items, table, inspect)
    round(i+1, k, mod, items, table, inspect) 
  end
  
  def pp(items, n, k) do
    :io.format("== Round ~w\n", [n])
    for i <- 0..k-1 do
      :io.format("Monkey ~w: ~w\n", [i, items[i]])
    end
    :io.format("\n\n")
  end
  
    def turn(monkey, mod, items, table, inspect) do
    {itm, items} = Map.get_and_update(items, monkey, fn(pack) -> {pack, []} end)
    {_, inspect} = Map.get_and_update(inspect, monkey, fn(insp) -> {insp, insp + length(itm)} end)
    items = List.foldl(itm, items,
      fn(itm, items) ->
	{to, itm}  = monkey(itm, mod, table[monkey])
        {_, items} = Map.get_and_update(items, to, fn(pack) -> {pack, pack ++ [itm]} end)
        items
      end)
    {items, inspect}
  end

  def monkey(itm, mod, {f,d,m1,m2}) do
    ##itm = div(f.(itm),3)
    ##itm = f.(itm)
    itm = rem(f.(itm), mod)
    if rem(itm,d) == 0 do
      {m1, itm}
    else
      {m2, itm}
    end
  end

  
end




