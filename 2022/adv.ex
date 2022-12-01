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

end
