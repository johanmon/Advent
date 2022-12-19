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
    wind = sample()
    cave = MapSet.new([{0,1},{0,2},{0,3},{0,4},{0,5},{0,6},{0,7}])
    tetris(0, rocks, 0, cave, {wind, wind})
  end

  def tetris(rocks, rocks, n, _cave, _) do
    n
  end
  def tetris(rks, rocks, n, cave, wind) do
    ## :io.format(" rks = ~w  n = ~w\n", [rks,n])
    {n, cave, wind} = (rock(rks)).({n+4,3}, n, cave, wind)
    ## print(cave, n)
    tetris(rks+1, rocks, n, cave, wind)
  end

  def print(cave, n) do
    IO.write("\n")
    IO.write("\n")    
    for x <- n..1 do
      :io.format("~2.w  ", [x])
      for y <- 1..7 do
	if (free(cave, {x,y}) ) do
	  IO.write(" ")
	else
	  IO.write("#")
	end
      end
      IO.write("\n")
    end
    IO.write("\n")
  end
  

  

  def bar({x,y}, n, cave, wind) do
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

    if (x > 1 and free(cave, {x-1,y}) and free(cave, {x-1,y+1}) and free(cave, {x-1,y+2}) and free(cave, {x-1,y+3}) ) do
      bar({x-1, y}, n, cave, wind)
    else

      cave = block(cave, {x,y})
      cave = block(cave, {x,y+1})      
      cave = block(cave, {x,y+2})
      cave = block(cave, {x,y+3})
      ## :io.format(" adding bar at ~w\n", [{x,y}])
      {max(n,x), cave, wind}
    end
  end


  def cross({x,y}, n, cave, wind) do
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

    if (x > 1 and free(cave, {x,y}) and free(cave, {x-1,y+1}) and free(cave, {x,y+2}) ) do
      cross({x-1, y}, n, cave, wind)
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


  def el({x,y}, n, cave, wind) do
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

    if (x > 1 and free(cave, {x-1,y}) and free(cave, {x-1,y+1}) and free(cave, {x-1,y+2}) ) do
      el({x-1, y}, n, cave, wind)
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


  def rod({x,y}, n, cave, wind) do
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

    if (x > 1 and free(cave, {x-1,y}) ) do
      ## :io.format(" down\n", [])
      rod({x-1, y}, n, cave, wind)
    else

      cave = block(cave, {x,y})
      cave = block(cave, {x+1,y})
      cave = block(cave, {x+2,y})
      cave = block(cave, {x+3,y})      
      ## :io.format(" adding rod at ~w\n", [{x,y}])
      {max(n,x+3), cave, wind}
    end
  end   

  def block({x,y}, n, cave, wind) do
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

    if (x > 1 and free(cave, {x-1,y}) and free(cave, {x-1,y+1}) ) do
      block({x-1, y}, n, cave, wind)
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
    rocks = { &bar(&1,&2,&3,&4),
	      &cross(&1,&2,&3,&4),
	      &el(&1,&2,&3,&4),
	      &rod(&1,&2,&3,&4),
	      &block(&1,&2,&3,&4) }
    ## :io.format("select ~w\n", [rem(i,5)])
    elem(rocks, rem(i,5))
  end
  
  def jet({[], wind}) do
    jet({wind, wind})
  end
  def jet({[jet|rest], wind}) do
    {jet, {rest, wind}}
  end

  def free(cave, {x,y}) do
    !(MapSet.member?(cave,{x,y}))
  end

  def block(cave, {x,y}) do
    MapSet.put(cave, {x,y})
  end
  
    
  
end
