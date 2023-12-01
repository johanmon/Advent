defmodule Day14 do


  ## Day 14 - of course also today most time was spent paring the
  ## input. In the end it is so obvious but at breakfast you do a lot
  ## of small mistakes and what coudl have been five minutes turns out
  ## to be half an hour of debugging :-(
  ##
  ## The problem did at first look more complicated than it was. Once
  ## the maps was set up, implemented as a MapSet of posistions, the
  ## algorithm was not that complicated. I chose to let one grain of
  ## sand drop down and come to rest before droping the next grain
  ## from the top. 
  ##
  ## A max limit was used already in the first task so changing the
  ## behaviour of the algorithm was fairly simple.
  ##
  ## An intersting question is if one could do a recursive solution
  ## where you don't start from the top each time. After all the next
  ## grain will follow exactly the same path apart from the last step
  ## so one should be able to continue from a position one step before
  ## a grain comes to rest. This would save us a lot of computations
  ## even though the complexity woudld probably be the same.
  ##
  ## Update - take a look at hmm/2. Here we continue with the next
  ## grain of sand as soon as a grain comes to rest. The execution
  ## time is cut in two :-)
  
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

  def test() do 
     [[{498,4},{498,6},{496,6}], 
      [{503,4},{502,4},{502,9}, {494,9}]]
  end
    

  def graph(input) do
    set = MapSet.new()
    Enum.reduce(input, set, fn([pos|line], set) ->
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
    set = graph(input())
    max = Enum.reduce(set, 0, fn({_,y},a) -> max(y,a) end) + 1
    fill(0, max, set)
  end

  def task_aa() do
    set = graph(input())
    max = Enum.reduce(set, 0, fn({_,y},a) -> max(y,a) end) + 1
    hmm(max, set)
  end  

  def task_b() do
    set = graph(input())
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

  def hmm(max, set) do
     hmm(500, 0, 0, max, set) 
  end

  def hmm(_x, max, n, max, _set) do 
    {:done, n}
  end
  def hmm(x, y, n, max, set) do
    if ( MapSet.member?(set, {x,y+1}) ) do
      if ( MapSet.member?(set, {x-1, y+1}) ) do
	if ( MapSet.member?(set, {x+1,y+1}) ) do
	  {MapSet.put(set, {x,y}), n}
	else
	  case hmm(x+1, y+1, n, max, set) do
	    {:done, n} -> {:done, n}
	    {set,n} -> hmm(x, y, n+1, max, set)
	  end
	end	
      else
	case hmm(x-1, y+1, n, max, set) do
	  {:done, n} -> {:done, n}
	  {set, n} -> hmm(x, y, n+1, max, set)
	end
      end
    else
      case hmm(x, y+1, n, max, set) do
	{:done, n} -> {:done, n}
	{set, n} -> hmm(x, y, n+1, max, set)
      end	
    end
  end
  
  

end
