defmodule Adv do

  ## Day 1 A simple task to sum sequences. The solution below is not
  ## ideal since it does not keep track of which elf has the most
  ## calories. Nor is it very efficient since it sorts the whole list
  ## when we are actually only interested in the top three elfs. We
  ## could instead scan the sequence or in the general case build a
  ## heap.

  def day1() do
    File.stream!("day1.csv") |>
      Stream.map( fn (r) ->
	case Integer.parse(r) do
	  :error -> 0
	  {cal, _} -> cal
	end
      end) |>
      Enum.reduce([0], fn (x, [c|t]=cs) ->
	if x == 0 do
	  [0|cs]
	else
	  [x+c|t]
	end
      end) |>
      Enum.sort( fn (x,y) -> x > y end)
  end

  def day1a() do
    [e1 | _ ] = day1()
    e1
  end
  
  def day1b() do
    [e1, e2, e3 | _ ] = day1()
    e1 + e2 + e3
  end

  ## Day 2 Fairly simple and the only tricky part is kepping track of
  ## if A is rock or scissors. I simply started with cretaing a
  ## sequence of tuples {:A, :Y} etc instead of representing them as
  ## {:rock, :scissors}, which would have made life easier. 
  ## Writing uo the rules was fine once the pattern is clear.


  def day2() do
    File.stream!("day2.csv") |>
      Stream.map( fn (r) ->
	[one, two] = String.split(r)
	{String.to_atom(one), String.to_atom(two)}
      end)
  end

  def day2a() do
    day2() |>
      Enum.reduce(0, fn (turn, n) -> playa(turn) + n end)
  end

  def day2b() do
    day2() |>
      Enum.reduce(0, fn (turn, n) -> playb(turn) + n end)
  end  

  def playa(turn) do
    case turn do
      {:A, :X} ->
	1 + 3
      {:A, :Y} ->
	2 + 6
      {:A, :Z} ->
	3 + 0

      {:B, :X} ->
	1 + 0
      {:B, :Y} ->
	2 + 3
      {:B, :Z} ->
	3 + 6

      {:C, :X} ->
	1 + 6 
      {:C, :Y} ->
	2 + 0
      {:C, :Z} ->
	3 + 3
    end
  end

  def playb(turn) do
    case turn do
      {:A, :X} ->
	3 + 0
      {:A, :Y} ->
	1 + 3
      {:A, :Z} ->
	2 + 6

      {:B, :X} ->
	1 + 0
      {:B, :Y} ->
	2 + 3
      {:B, :Z} ->
	3 + 6

      {:C, :X} ->
	2 + 0 
      {:C, :Y} ->
	3 + 3
      {:C, :Z} ->
	1 + 6
    end
  end


  def day3a() do
    File.stream!("day3.csv") |>
      Stream.map( fn (r) -> String.to_charlist(r) end) |>
      Stream.map(fn (r) -> Enum.drop(r, -1) end) |>
      Stream.map(fn(r) -> Enum.split(r, div(length(r),2)) end) |>
      Stream.map(fn({l,r}) -> {Enum.sort(l), Enum.sort(r)} end) |>
      Enum.reduce([], fn({l,r}, a) -> [duplicate(l,r)|a] end) |>
      Enum.reduce(0, fn(c, a) -> cond do
	  c <= 90 -> a + c - 65 + 27
	  c >= 97 -> a +  c - 97 + 1
	end
      end)
  end

  def day3b() do
    File.stream!("day3.csv") |>
      Stream.map( fn (r) -> String.to_charlist(r) end) |>
      Stream.map(fn (r) -> Enum.drop(r, -1) end) |>
      Enum.reduce([], fn(r, a) ->
	case a do
	  {2, t, a} -> [[r|t]| a]
	  {1, t, a} -> {2, [r|t], a}
	  a -> {1, [r], a}
	end
      end) |>
      Stream.map(fn([l,r,q]) -> {Enum.sort(l), Enum.sort(r), Enum.sort(q)} end) |>
      Enum.reduce([], fn({l,r,q}, a) -> [triplet(l,r,q)|a] end) |>
      Enum.reduce(0, fn(c, a) ->
	cond do
	  c <= 90 -> a + c - 65 + 27
	  c >= 97 -> a +  c - 97 + 1
	end
      end)




  end
  
  def duplicate([a|_],[a|_]) do a end
  def duplicate([a|l],[b|_]=r) when a < b do duplicate(l,r) end
  def duplicate(l,[_|r])  do duplicate(l,r) end

  def triplet([a|_],[a|_],[a|_]) do a end
  def triplet([a|l],[b|_]=r,[c|_]=q) when a <= b and a <= c do triplet(l,r,q) end
  def triplet([a|_]=l,[b|r],[c|_]=q) when b <= a and b <= c do triplet(l,r,q) end
  def triplet(l,r,[_|q]) do triplet(l,r,q) end  

  ## Day 4, no problem. One could write it even more compact by
  ## stransforming the list of strings from the splot oepration to a
  ## list of integers using a map operation.

  def day4() do
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

  def day4a() do
    day4() |>
      Stream.filter(fn({a1,a2,b1,b2}) ->
	(a1 <= b1 and a2 >= b2) or (a1 >= b1 and a2 <= b2)
      end) |>
      Enum.reduce(0, fn(_,a) -> a + 1 end)
  end

  def day4b() do
    day4() |>
      Stream.filter(fn({a1,a2,b1,b2}) ->
	(a1 <= b1 and a2 >= b1) or
	(a1 <= b2 and a2 >= b2) or
	(a1 >= b1 and a2 <= b2)
      end) |>
      Enum.reduce(0, fn(_,a) -> a + 1 end)
  end

  
end
