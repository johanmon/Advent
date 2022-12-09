defmodule Day3 do

  ## Day 3. I here decided to sort the content of the two pockets
  ## already in the first task. This reduces the complexity of
  ## searching from O(n^2) to O(n) and the sorting is only
  ## O(n*lg(n)). The list of items is not very large so it might not
  ## matter but the coding is simpler.
  ##
  ## Breaking the backpacks into groups of three was done in a clever
  ## (?) reduce operation. Sorting and searching was alsmost the same.

  def task_a() do
    File.stream!("day3.csv") |>
      Stream.map(fn (r) -> String.to_charlist(r) end) |>
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

  def task_b() do
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
  
  
end
