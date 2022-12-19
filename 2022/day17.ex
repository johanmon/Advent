defmodule Day17 do

  def sample() do
    String.to_charlist(">>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>")
  end

  def input() do
    File.read!("day17.csv") |>
      String.trim() |>
      String.to_charlist()
  end

  def task_a(rocks) do
    wind = wind(input())
    cave = cave()    
    {n, floor, cave} = tetris(0, rocks, 0, 0, cave, wind)
    print(cave, n, floor)
    {n, floor}
  end

  def tetris(rocks, rocks, n, floor, cave, _) do
    {n, floor, cave}
  end
  def tetris(rks, rocks, n, floor, cave, wind) do
    ## :io.format(" rks = ~w  n = ~w\n", [rks,n])
    {n, cave, wind} = (rock(rks)).({n+4,3}, n, floor, cave, wind)
    {floor, cave} = trim(n, floor, cave)
    #:io.format(" n = ~w floor = ~w\n", [n, floor])
    #:io.format(" cave = ~w\n", [cave])
    tetris(rks+1, rocks, n, floor, cave, wind)
  end

  def print(cave, n, floor) do
    IO.write("\n")
    IO.write("\n")    
    for x <- n..(floor+1) do
      :io.format("~4.w  |", [x])
      for y <- 1..7 do
	if (free(cave, {x,y}) ) do
	  IO.write(".")
	else
	  IO.write("#")
	end
      end
      IO.write("\n")
    end
    IO.write("\n")
  end


  def trim(n, floor, cave) do
    res = Enum.reduce_while(n..(floor+1), cave, fn(i, cave) ->
      if ( marked(cave, {i,1})) do 
      case walk({i,1}, cave) do
	{:ok, k} ->
	  #:io.format(" found path at ~w, removing from ~w to ~w\n", [i, floor, k])
	  #print(cave, n, floor)
	  cave = remove(cave, floor+1, k)
	  #print(cave, n, floor)	  
	  {:halt, {k, cave}}
	{:no, _} ->
	  {:cont, cave}
      end
      else
	{:cont, cave}
      end
    end)
    case res do
      {floor, cave} -> {floor, cave}
      _ -> {floor, cave}
    end
  end

  def walk(pos, cave) do
    walk(pos, MapSet.new([pos]), cave)
  end

  def walk({x,7}, _path, _cave) do {:ok, x} end
  def walk({x,y}, path, cave) do
    res = Enum.reduce_while([{x+1,y},{x,y+1},{x-1,y},{x, y-1}], path, fn({x,y}, path) ->
      if (marked(cave, {x,y}) and !loop(path, {x,y})) do
	 path = MapSet.put(path, {x, y})
	 case walk({x,y}, path, cave) do
	   {:ok, k} ->
	     {:halt, {:ok, min(k,x)}}
	   {:no, path} ->
	     {:cont, path}
	 end
      else
	{:cont, path}
      end
    end)
    case res do
      {:ok, k} -> {:ok, k}
      path -> {:no, path}
    end
  end
  
  def bar({x,y}, n, floor, cave, wind) do
    ##  the shape 
    ##
    ##    x###
    ##
    {jet,wind} = jet(wind)
    {x,y} = case jet do
      ?> ->
	if ((y < 4) and free(cave,{x,y+4})) do
	  {x,y+1}
	else
	  {x,y}
	end
     ?< ->
	if ((y > 1) and free(cave,{x,y-1})) do
	  {x,y-1}
	else
	  {x,y}
	end
      end

    if ((x - 1 > floor) and free(cave, {x-1,y}) and free(cave, {x-1,y+1}) and free(cave, {x-1,y+2}) and free(cave, {x-1,y+3}) ) do
      bar({x-1, y}, n, floor, cave, wind)
    else
      cave = block(cave, {x,y})
      cave = block(cave, {x,y+1})      
      cave = block(cave, {x,y+2})
      cave = block(cave, {x,y+3})
      ## :io.format(" adding bar at ~w\n", [{x,y}])
      {max(n,x), cave, wind}
    end
  end


  def cross({x,y}, n, floor, cave, wind) do
    ##  the shape 
    ##
    ##     #
    ##    ###
    ##    .#

    {jet,wind} = jet(wind)
    {x,y} = case jet do
      ?> ->
	if ((y < 5) and free(cave,{x+2,y+2}) and free(cave,{x+1,y+3}) and free(cave,{x,y+2})) do
	  {x,y+1}
	else
	  {x,y}
	end
     ?< ->
	if ( (y > 1) and free(cave,{x+2,y}) and free(cave,{x+1,y-1}) and free(cave,{x,y}) ) do
	  {x,y-1}
	else
	  {x,y}
	end
      end

    if ((x-1 > floor) and free(cave, {x,y}) and free(cave, {x-1,y+1}) and free(cave, {x,y+2}) ) do
      cross({x-1, y}, n, floor, cave, wind)
    else

      cave = block(cave, {x+1,y})

      cave = block(cave, {x,y+1})      
      cave = block(cave, {x+1,y+1})
      cave = block(cave, {x+2,y+1})      

      cave = block(cave, {x+1,y+2})      
      ## :io.format(" adding cross at ~w\n", [{x,y}])
      {max(n,x+2), cave, wind}
    end
  end   


  def el({x,y}, n, floor, cave, wind) do
    ##  the shape 
    ##
    ##      #
    ##      #
    ##    x##
    
    {jet,wind} = jet(wind)
    {x,y} = case jet do
      ?> ->
	if ((y < 5) and free(cave,{x+2,y+3}) and free(cave,{x+1,y+3}) and free(cave,{x,y+3})) do
	  {x,y+1}
	else
	  {x,y}
	end
     ?< ->
	if ( (y > 1) and free(cave,{x+2,y+1}) and free(cave,{x+1,y+1}) and free(cave,{x,y-1}) ) do
	  {x,y-1}
	else
	  {x,y}
	end
      end

    if (((x-1) > floor) and free(cave, {x-1,y}) and free(cave, {x-1,y+1}) and free(cave, {x-1,y+2}) ) do
      el({x-1, y}, n, floor, cave, wind)
    else

      cave = block(cave, {x,y})
      cave = block(cave, {x,y+1})      
      cave = block(cave, {x,y+2})

      cave = block(cave, {x+1,y+2})
      cave = block(cave, {x+2,y+2})            
      ## :io.format(" adding el at ~w\n", [{x,y}])
      {max(n,x+2), cave, wind}
    end
  end   


  def rod({x,y}, n, floor, cave, wind) do
    ##  the shape 
    ##
    ##    #
    ##    #
    ##    #
    ##    x    

    ## :io.format(" rod at ~w ", [{x,y}])
    {jet,wind} = jet(wind)
    {x,y} = case jet do
      ?> ->
	if ((y < 7) and free(cave,{x,y+1}) and free(cave,{x+1,y+1}) and free(cave,{x+2,y+1}) and free(cave,{x+3,y+1})) do
	  ## :io.format(" right ~w ", [{x,y+1}])
	  {x,y+1}
	else
	  {x,y}
	end
     ?< ->
	if ( (y > 1) and free(cave,{x,y-1}) and free(cave,{x+1,y-1}) and free(cave,{x+2,y-1}) and free(cave,{x+3,y-1}) ) do
	  ## :io.format(" left ~w ", [{x,y-1}])
	  {x,y-1}
	else
	  {x,y}
	end
      end

    if (((x-1) > floor) and free(cave, {x-1,y}) ) do
      ## :io.format(" down\n", [])
      rod({x-1, y}, n, floor, cave, wind)
    else

      cave = block(cave, {x,y})
      cave = block(cave, {x+1,y})
      cave = block(cave, {x+2,y})
      cave = block(cave, {x+3,y})      
      ## :io.format(" adding rod at ~w\n", [{x,y}])
      {max(n,x+3), cave, wind}
    end
  end   

  def block({x,y}, n, floor, cave, wind) do
    ##  the shape 
    ##
    ##    ##
    ##    x#

    {jet,wind} = jet(wind)
    {x,y} = case jet do
      ?> ->
	if ((y < 6) and free(cave,{x,y+2}) and free(cave,{x+1,y+2}) )do
	  {x,y+1}
	else
	  {x,y}
	end
     ?< ->
	if ( (y > 1) and free(cave,{x,y-1}) and free(cave,{x+1,y-1}) ) do
	  {x,y-1}
	else
	  {x,y}
	end
      end

    if (((x-1) > floor) and free(cave, {x-1,y}) and free(cave, {x-1,y+1}) ) do
      block({x-1, y}, n, floor, cave, wind)
    else

      cave = block(cave, {x,y})
      cave = block(cave, {x,y+1})      
      cave = block(cave, {x+1,y})
      cave = block(cave, {x+1,y+1})      
      ## :io.format(" adding block at ~w\n", [{x,y}])
      {max(n,x+1), cave, wind}
    end
  end   

  def rock(i) do
    rocks = { &bar(&1,&2,&3,&4,&5),
	      &cross(&1,&2,&3,&4,&5),
	      &el(&1,&2,&3,&4,&5),
	      &rod(&1,&2,&3,&4,&5),
	      &block(&1,&2,&3,&4,&5) }
    ## :io.format("select ~w\n", [rem(i,5)])
    elem(rocks, rem(i,5))
  end

  def wind(wind) do
    {wind, wind}
  end
  
  def jet({[], wind}) do
    jet({wind, wind})
  end
  def jet({[jet|rest], wind}) do
    {jet, {rest, wind}}
  end

  def cave() do
    Map.new()
  end

  def marked(cave, {x,y}) do
    case Map.get(cave, x) do
      nil -> false
      row ->
	MapSet.member?(row,y)
    end
  end    
  
  def free(cave, {x,y}) do
    case Map.get(cave, x) do
      nil -> true
      row ->
	!(MapSet.member?(row,y))
    end
  end

  def remove(cave, frm, to) do
    Enum.reduce(frm..to, cave, fn(i, cave) -> Map.delete(cave, i) end)
  end
  
  
  def filled(cave, x) do
    case Map.get(cave, x) do
      nil ->
	false
      row ->
	MapSet.size(row) == 7
    end
  end

  def block(cave, {x,y}) do
    Map.update(cave, x,  MapSet.new([y]), fn(row) -> MapSet.put(row, y) end)
  end

  def loop(path, {x,y}) do
    MapSet.member?(path, {x,y})
  end
  
end
