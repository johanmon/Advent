defmodule Day4 do

  ## Day 4, no problem. One could write it even more compact by
  ## stransforming the list of strings from the splot oepration to a
  ## list of integers using a map operation.

  def input() do
    File.stream!("day4.csv") |>    
      Stream.map( fn (r) ->
	[a1, a2, b1, b2] = String.split(r, [",","-"])
	{a1,_} = Integer.parse(a1)
	{a2,_} = Integer.parse(a2)	
	{b1,_} = Integer.parse(b1)
	{b2,_} = Integer.parse(b2)	
	{a1, a2, b1, b2}
      end)
  end    

  def task_a() do
    input() |>
      Stream.filter(fn({a1,a2,b1,b2}) ->
	(a1 <= b1 and a2 >= b2) or (a1 >= b1 and a2 <= b2)
      end) |>
      Enum.reduce(0, fn(_,a) -> a + 1 end)
  end

  def task_b() do
    input() |>
      Stream.filter(fn({a1,a2,b1,b2}) ->
	(a1 <= b1 and a2 >= b1) or
	(a1 <= b2 and a2 >= b2) or
	(a1 >= b1 and a2 <= b2)
      end) |>
      Enum.reduce(0, fn(_,a) -> a + 1 end)
  end

  
end
