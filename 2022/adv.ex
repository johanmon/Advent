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
  
end
