defmodule Day24 do

  ## Day 24 - not the best solution but it works. The winds are
  ## represented as Map with an entry for each position having a wind
  ## (which are most positions). Each entry hade a list of one up to
  ## four wind functions. A wind function would take aposition and
  ## return the next position in the direction of the wind - taht was ok.
  ##
  ## A better solution I think would be to represent a wind simply as
  ## a position {x,y}. Since the winds don't care about anythning
  ## their position would tehn simply be for example {x, mod(y+t,c)}
  ## where c is the length of a row. The table of wonds would then be
  ## static which would increase performance.
  ##
  ## Search was done breadth firts with out any problems. 
  

  def task_a(k) do
    {entry, out, bndr, wind} = parse(sample())
    :io.format(" entry = ~w\n", [entry])
    :io.format(" out = ~w\n", [out])    
    :io.format(" bndr = ~w\n", [bndr])
    #print(wind, bndr)
    {t, _} = search(k, [], [entry], entry, out, 0, bndr, wind)
    :io.format(" time = ~w\n", [t])    
  end

  def task_b(k) do
    {entry, out, bndr, wind} = parse(input())
    :io.format(" entry = ~w\n", [entry])
    :io.format(" out = ~w\n", [out])    
    {t, wind} = search(k, [], [entry], entry, out, 0, bndr, wind)
    :io.format(" at the exit after ~w min\n", [t])
    {t, wind} = search(k, [], [out], out, entry, t, bndr, wind)
    :io.format(" back at the entry after ~w min\n", [t])
    {t, _wind} = search(k, [], [entry], entry, out, t, bndr, wind)
    :io.format(" done after ~w min\n", [t])
    :ok
  end

  def search(0, _, _, _entry, _out, t, _bndr, wind) do
    {t, wind}
  end
  def search(k, [], next, entry, out, t, bndr, wind) do
    :io.format("\n\nt = ~w\n", [t+1])
    :io.format("positions under evaluation = ~w\n", [length(next)])    
    #:io.format("positions under evaluation = ~w\n", [next])
    wind = blow(wind)
    #:io.format("  next wind \n", [])
    #print(wind, bndr)
    case next do
      [] ->
	#print(wind, bndr)
	:io.format("deadlock ~w\n", [t+1])
	throw(:error)
      _ -> 
	search(k-1, next, [], entry, out, t+1, bndr, wind)
    end
  end
  def search(_, [out | _],  _, _, out, t, _, wind) do {t, wind} end
  def search(k, [pos | rest], next, entry, out, t, bndr, wind) do
    case possible(pos, entry, out, bndr, wind) do
      [^out] ->
	print(wind, bndr)
	:io.format("done ~w\n", [t])
	{t, wind}
      possible ->
	search(k, rest, insert(possible,next), entry, out, t, bndr, wind)
    end
  end
  
  def possible({-1,y}, {-1,y}, _, _, wind) do
    if (Map.get(wind, {0,y}) == nil ) do
      [{-1,y}, {0,y}]
    else
      [{-1,y}]
    end
  end

  def possible({r,y}, {r,y}, _, {r,_}, wind) do
    if (Map.get(wind, {r-1,y}) == nil ) do
      [{r,y}, {r-1,y}]
    else
      [{r,y}]
    end
  end
  
  
  def possible({x,y}, _, {xn,y}, _, _ ) when  xn == x+1 do
      :io.format("found lower exit\n")
      [{xn,y}]
  end
  def possible({x,y}, _, {xn,y}, _, _ ) when  xn == x-1 do
      :io.format("found upper exit\n")
      [{xn,y}]
  end
  
  def possible(pos, _, _, bndr, wind) do
    all =[]
    all = if (  Map.get(wind, pos) == nil ) do
       [ pos | all]
     else
       all
    end
    all = if ( possible_up(pos, bndr) and Map.get(wind, up(pos)) == nil ) do
       [up(pos) | all]
     else
       all
    end
    all = if ( possible_down(pos, bndr) and Map.get(wind, down(pos)) == nil ) do
      [down(pos) | all]
    else
      all
    end    
    all = if ( possible_left(pos, bndr) and Map.get(wind, left(pos)) == nil ) do
      [left(pos) | all]

    else
      all
    end        
    all = if ( possible_right(pos, bndr) and Map.get(wind, right(pos)) == nil ) do
      [right(pos) | all]
    else
      all
    end
    all
  end


  def insert(possible, next) do
    Enum.reduce(possible, next, fn(p,n) -> insert_possible(p, n) end)
  end
  

  def insert_possible(pos, []) do [pos] end
  def insert_possible(pos, [pos|_]=next) do next end
  def insert_possible(pos, [n|next]) do [n|insert_possible(pos,next)] end  
  
    

  
  def blow(wind) do
    Enum.reduce(wind, Map.new(), fn({pos, dirs}, wind) ->
      Enum.reduce(dirs, wind, fn(dir, wind) ->
	Map.update(wind, dir.(pos), [dir], fn(dirs) -> [dir|dirs] end)
      end)
    end)
  end
      

  def possible_up({x,_}, _) do x > 0 end
  def possible_down({x,_}, {r,_}) do x < r-1 end  

  def possible_left({_,y}, _) do y > 0 end
  def possible_right({_,y}, {_,c}) do y < c-1 end    

  def up({x,y}) do {x-1,y} end
  def down({x,y}) do {x+1,y} end  
  def left({x,y}) do {x,y-1} end
  def right({x,y}) do {x,y+1} end  


  def up({x,y}, {r,_}) do {Integer.mod(x-1,r), y} end    
  def down({x,y}, {r,_}) do {Integer.mod(x+1,r), y} end        

  def left({x,y}, {_,c}) do {x, Integer.mod(y-1,c)} end
  def right({x,y}, {_,c}) do {x, Integer.mod(y+1,c)} end



    
  
  def parse(rows) do
    #
    # positions are  {0..r, 0..c}
    #
    first = String.to_charlist(hd(Enum.take(rows, 1)))
    last =  String.to_charlist(hd(Enum.take(rows,-1)))

    rows = Enum.drop(Enum.drop(rows, -1), 1)

    ## the bndr will me used to calculate wind positons mod r and mod c

    r = length(rows)
    c = length(first)-2
    bndr = {r,c}
    
    entry =  Enum.find_index(first, fn(char) -> char == ?\.  end) - 1
    out =  Enum.find_index(last, fn(char) -> char == ?\.  end) - 1

    wind = Map.new()
    wind = parse_rows(rows, 0, bndr, wind)
    {{-1, entry}, {r, out}, bndr, wind}
  end

  def parse_rows([], _, _,  wind) do wind end

  def parse_rows([row|rest], r, bndr, wind) do
    {_, wind} = Enum.reduce(String.to_charlist(row), {0, wind}, fn(char, {c, wind}) ->
      case char do
	?\# ->
	  {c, wind}
	?\. ->
	  {c+1, wind}
	?\> ->
	  {c+1, Map.put(wind, {r,c}, [fn(pos) -> right(pos, bndr) end])}
	?\< ->
	  {c+1, Map.put(wind, {r,c}, [fn(pos) -> left(pos, bndr) end])}
	?v ->
	  {c+1, Map.put(wind, {r,c}, [fn(pos) -> down(pos, bndr) end])}
	?\^ ->
	  {c+1, Map.put(wind, {r,c}, [fn(pos) -> up(pos, bndr) end])}
      end
    end)
    parse_rows(rest, r+1, bndr, wind)
  end

  def print(wind, {r,c}) do
    Enum.each(0..(r-1), fn(r) ->
      Enum.each(0..(c-1), fn(c) ->
	case Map.get(wind,{r,c}) do
	  nil ->
	    IO.write(".")
	  [_] ->
	    IO.write("x")
	  [_,_] ->
	    IO.write("2")	    
	  [_,_,_] ->
	    IO.write("3")	    
	  [_,_,_,_] ->
	    IO.write("4")
	end
      end)
      IO.write("\n")
    end)      
  end
    
  
  def input() do
    File.stream!("day24.csv") |>
      Enum.map( fn(row) -> String.trim(row) end)
  end

  def small() do
    [
      "#.#####",
      "#.....#",
      "#.>...#",
      "#.....#",
      "#.....#",
      "#...v.#",
      "#####.#"
    ]
  end

  def sample() do
    [
      "#.######",
      "#>>.<^<#",
      "#.<..<<#",
      "#>v.><>#",
      "#<^v^^>#",
      "######.#"
    ]
  end
  

end


