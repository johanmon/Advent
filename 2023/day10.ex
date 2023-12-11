defmodule Day10 do

  ## Day10 a Sunday :-) The first part was too easy. The first idea
  ## was of course - yes Dijkstra - but on a second thought it was
  ## trivial sine there were not any forking pipes i.e. the only thing
  ## one had to do was to follow the pipe.
  ## 
  ## Yes, of course there was some thinking on how to represent the
  ## tiles, what was important and what could be ignored. The firts
  ## solution was to have each tile, keyed {x,y}, held the properties:
  ##
  ##    :dot
  ##    {:pipe, a, b}
  ##
  ## The start tile had the key :start and value {x,y} so it was
  ## easily found. The two tiles that connect to the start tile are
  ## also easily identified (and it is only two but it's a bot unclear
  ## if this has to be so).  The location furthest way is simply the
  ## length of the loop deivided by two. .... this is... and was too
  ## simple.
  ##
  ## The second task was more puzzling. How do you identify the tiles
  ## that are surounded by the loop. I solved the problem by walking
  ## along the loop and marking adjecent tiles as being to the right
  ## or left of the path (should not be any ambiguities once you
  ## decide the direction). After some ... you know what I mean
  ## ... all tiles were marked as either part of the loop, right or
  ## left. You still do not know if right is inside or if left is
  ## inside but if you print it out its quite obvious. One could add
  ## another row to the map and this row would then either be all
  ## right or all left so it's easy to solve.
  ## 
  ## 
  

  def test_a() do
    String.split(sample(), "\n") |>
      Enum.map(fn(row) -> parse(row) end) |>
      build() |>
      loop() |>
      then(fn({:loop, _, _, loop}) ->
	trunc (length(loop))/2
      end)
  end

  def task_a() do
    File.stream!("day10.csv") |>
      Enum.map(fn(row) -> parse(String.trim(row)) end) |>
      build() |>
      loop() |>
      then(fn({:loop, _, _, loop}) ->
	trunc (length(loop))/2
      end)
  end  

  def test_b() do
    String.split(another(), "\n") |>
      Enum.map(fn(row) -> parse(row) end) |>
      build() |>
      loop() |>
      color() 
  end

  def task_b() do
    File.stream!("day10.csv") |>
      Enum.map(fn(row) -> parse(String.trim(row)) end) |>
      build() |>
      loop() |>
      color()
  end

  ## Why do I call it color ... don't know. 

  def color({:loop, n, m, loop}) do
    :io.format("n = ~w, m = ~w, loop = ~w~n", [n,m, length(loop)])
    ## set all tiles as unknown
    map = Enum.reduce(1..n, %{}, fn(x, map) -> Enum.reduce(1..m, map, fn(y, map) -> Map.put(map, {x,y}, :unknown) end) end)

    ## mark the tiels of the loop
    map = Enum.reduce(loop, map, fn({pos,_,_}, map) -> Map.put(map, pos, :loop) end)

    ## now the tricky part
    map = Enum.reduce(loop, map, fn(nxt, map) -> next(nxt, map) end)

    ## We should be done.
    print(n, m, map)

    ## Count the colors
    Enum.reduce(Map.values(map), {0,0,0,0}, fn(val, {loop, left, right, unk}) ->
      case val do
	:left    -> {loop, left+1, right, unk}
	:right   -> {loop, left, right+1, unk}
	:loop    -> {loop+1, left, right, unk}
	:unknown -> {loop, left, right, unk+1}
      end
      end)
  end

  def print(n,m, map) do
    Enum.map(1..m, fn(y) -> Enum.map(1..n, fn(x) ->
                                  case Map.get(map, {x,y}) do
				    :left ->  IO.write("l")
				    :right -> IO.write("r")
				    :loop -> IO.write(".")
				  end
                                           end)
                            IO.puts("")
    end)
  end

  ## ok, if you'r in pos and came from fd and will leav to td then you
  ## know the left and right. 
  
  def next({pos, fd, td}, map) do
    case td do
      :e ->
	case fd do 
	  :n ->
	    map = fill(map, west(pos), :right)
	    fill(map, south(pos), :right)
	  :w ->
	    map = fill(map, north(pos), :left)
	    fill(map, south(pos), :right)
	  :s ->
	    map = fill(map, west(pos), :left)
	    fill(map, north(pos), :left)
	end
      :w ->
	case fd do
	  :n ->
	    map = fill(map, south(pos), :left)		
	    fill(map, east(pos), :left)
	  :e ->
	    map = fill(map, south(pos), :left)		
	    fill(map, north(pos), :right)	    
	  :s ->
	    map = fill(map, east(pos), :right)		
	    fill(map, north(pos), :right)
	end
      :s ->
	case fd do 
	  :n ->
	    map = fill(map, east(pos), :left)
	    fill(map, west(pos), :right)
	  :e ->
	    map = fill(map, north(pos), :right)
	    fill(map, west(pos), :right)
	  :w ->
	    map = fill(map, east(pos), :left)
	    fill(map, north(pos), :left)
	end
      :n ->
	case fd do
	  :e ->
	    map = fill(map, west(pos), :left)
	    fill(map, south(pos), :left)
	  :w ->
	    map = fill(map, south(pos), :right)
	    fill(map, east(pos), :right)
	  :s ->
	    map = fill(map, west(pos), :left)
	    fill(map, east(pos), :right)
	end
      :nil ->
	map
    end
  end

  ## Let the :left or :right value spread. 

  def fill(map, pos, val) do
    case Map.get(map, pos) do
      :unknown ->
	map = Map.put(map, pos, val)
	Enum.reduce([north(pos), south(pos), east(pos), west(pos)], map, fn(pos, map) -> fill(map, pos, val) end)

      ## Checking that the value actually is :loop or the value or outside the map. Anything else should crash.
      :loop ->
	map
      ^val ->
	map
      :nil ->
	map
    end
  end

  ## This is the solution to the first part i.e. finding the loop.
  
  def loop({:map, n, m, map}) do
    start = Map.get(map, :start)
    {fd, td, from} = start(map)
    {:loop, n, m, [{start, fd, td} | loop(from, start, start, map)]}
  end

  def loop(to, _prv, to, _) do [] end
  def loop(from, prv, to, map) do
    case Map.get(map, from) do
      {:pipe, fd, td, ^prv, nxt} ->
	[{from, fd, td} | loop(nxt, from, to, map)]
      {:pipe, td, fd, nxt, ^prv} ->
	[{from, fd, td} | loop(nxt, from, to, map)]
    end
  end


  ## Find the start and first tile to go to, also return the
  ## directions entering and leaving the start tile.
  
  def start(map) do
    pos = Map.get(map, :start)
    ## :io.format(" east: ~w, west ~w, north: ~w, south: ~w~n", [east(pos), west(pos), north(pos), south(pos)])
    case {connection(east(pos), pos, map), connection(west(pos), pos, map), connection(north(pos), pos, map), connection(south(pos), pos, map)} do
      #east  west  north  south
      {true, true, false, false} -> {:w, :e, east(pos)}
      {true, false, true, false} -> {:n, :e, east(pos)}
      {true, false, false, true} -> {:s, :e, east(pos)}
      {false, true, true, false} -> {:n, :w, west(pos)}
      {false, true, false, true} -> {:s, :w, west(pos)}
      {false, false, true, true} -> {:s, :n, north(pos)}
    end
  end

  def connection(a, b, map) do
    case Map.get(map, a) do
      :nil ->
	false
      {:pipe, _, _, ^b, _} ->
	true
      {:pipe, _, _, _, ^b} ->
	true
      _ ->
	false
    end
  end

  ##  This is where we build the map given the parsed input.
  
  def build(rows) do
    {map, x, y} = Enum.reduce(rows, {%{}, 0, 1}, fn(row, {map, _, y}) ->
      {map, {m,_}} = build(row, map, {1, y})
      {map, m, y+1}
    end)
    {:map, x-1, y-1, map}
  end
  
  def build(row, map, pos) do
    Enum.reduce(row, {map, pos}, fn(pipe, {map, pos}) ->
      map = if (pipe == :start)  do
              Map.put(map, :start, pos)
	else
	      val = case pipe do
		      :ns -> {:pipe, :n, :s, north(pos), south(pos)}
		      :we -> {:pipe, :w, :e, west(pos),  east(pos) }
		      :ne -> {:pipe, :n, :e, north(pos), east(pos) }
		      :nw -> {:pipe, :n, :w, north(pos), west(pos) }
		      :sw -> {:pipe, :s, :w, south(pos), west(pos) }
		      :se -> {:pipe, :s, :e, south(pos), east(pos) }
		      :dot -> :dot
		    end
	      ## :io.format("pos = ~w,  val = ~w~n", [pos, val])
	      Map.put(map, pos, val)
	end
      {map, east(pos)}
    end)
  end
      

  def north({x,y}) do {x, y-1} end	
  def south({x,y}) do {x, y+1} end	
  def east({x,y}) do {x+1, y} end
  def west({x,y}) do {x-1, y} end	  


  ## Turn the pipe characters into symbols.
  
  def parse(<<>>) do [] end
  def parse(<<char, rest::binary>>) do
    pipe = case char do
	     ?| -> :ns
	     ?- -> :we
	     ?L -> :ne
	     ?J -> :nw
	     ?7 -> :sw
	     ?F -> :se
	     ?. -> :dot
	     ?S -> :start
	   end
    [pipe | parse(rest)]
  end


  ## Smaller and larger examples.


  def sample() do
"7-F7-
.FJ|7
SJLL7
|F--J
LJ.LJ"
  end

  def larger() do
".F----7F7F7F7F-7....
.|F--7||||||||FJ....
.||.FJ||||||||L7....
FJL7L7LJLJ||LJ.L-7..
L--J.L7...LJS7F-7L7.
....F-J..F7FJ|L7L7L7
....L7.F7||L7|.L7L7|
.....|FJLJ|FJ|F7|.LJ
....FJL-7.||.||||...
....L---J.LJ.LJLJ..."
  end
  

  def another() do
"FF7FSF7F7F7F7F7F---7
L|LJ||||||||||||F--J
FL-7LJLJ||||||LJL-77
F--JF--7||LJLJ7F7FJ-
L---JF-JLJ.||-FJLJJ7
|F|F-JF---7F7-L7L|7|
|FFJF7L7F-JF7|JL---7
7-L-JL7||F7|L7F-7F7|
L.L7LFJ|||||FJL7||LJ
L7JLJL-JLJLJL--JLJ.L"
  end
  
  

end
