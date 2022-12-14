defmodule Day14 do


  def input() do
    File.stream!("day14.csv") |>
      Enum.map(fn(row) -> String.split(String.trim(row), [" -> "]) end) |>
      Enum.map(fn(row) ->
	out = Enum.map(row, fn(r) ->
	            [x,y] = String.split(r,[","])
	            {x,_} = Integer.parse(x)
	            {y,_} = Integer.parse(y)
	            {x,y}
               end)
	out
      end)
  end


  def graph() do
    set = MapSet.new()
    Enum.reduce(input(), set, fn([pos|line], set) ->
      {_, set} = Enum.reduce(line, {pos, set}, fn({x1,y1}, {{x0,y0}, set}) ->
	set = if (x0 == x1) do
 	  Enum.reduce((y0)..(y1), set, fn(i, set) ->
	    MapSet.put(set, {x0,i})
	  end)
	else
	  Enum.reduce((x0)..(x1), set, fn(i, set) ->
	    MapSet.put(set, {i, y0})
	  end)
	end
	{{x1,y1}, set}
      end)
      set
    end)
  end


  def task_a() do
    set = graph()
    max = Enum.reduce(set, 0, fn({_,y},a) -> max(y,a) end) + 1
    fill(0, max, set)
  end

  def task_b() do
    set = graph()
    max = Enum.reduce(set, 0, fn({_,y},a) -> max(y,a) end) + 1
    floor(0, max, set)
  end  

  def floor(n, max, set) do
    case floor(500, 0, max, set) do
      :done -> n + 1
      set -> floor(n+1, max, set)
    end
  end

  def floor(x, max, max, set) do
    MapSet.put(set, {x,max})
  end
  def floor(x, y, max, set) do
    if ( MapSet.member?(set, {x,y+1}) ) do
      if ( MapSet.member?(set, {x-1, y+1}) ) do
	if ( MapSet.member?(set, {x+1,y+1}) ) do
	  if ({x,y} == {500,0} ) do
	    :done
	  else
	    MapSet.put(set, {x,y})
	  end
	else
	  floor(x+1, y+1, max, set)
	end	
      else
	floor(x-1, y+1, max, set)
      end
    else
      floor(x, y+1, max, set)
    end
  end
  
    
    
  
  def fill(n, max, set) do
    case fill(500, 0, max, set) do
      :done -> n
      set -> fill(n+1, max, set)
    end
  end

  def fill(_x, max, max, _set) do :done  end
  def fill(x, y, max, set) do
    if ( MapSet.member?(set, {x,y+1}) ) do
      if ( MapSet.member?(set, {x-1, y+1}) ) do
	if ( MapSet.member?(set, {x+1,y+1}) ) do
	  MapSet.put(set, {x,y})
	else
	  fill(x+1, y+1, max, set)
	end	
      else
	fill(x-1, y+1, max, set)
      end
    else
      fill(x, y+1, max, set)
    end
  end
  

end
