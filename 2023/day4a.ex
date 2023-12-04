defmodule Day4a do


  def test() do
    String.split(sample(), "\n") |>
      Enum.map(fn(row) -> parse(row) end) |>
      Enum.map(fn({:card, _, winning, you}) -> points(winning, you) end) |>
      Enum.sum()
  end


  def task() do
    File.stream!("day4.csv") |>
      Stream.map(fn(row) -> parse(row) end) |>
      Stream.map(fn({:card, _, winning, you}) -> paints(winning, you) end) |>
      Enum.sum()
  end  
  

  ## Once the parsing is done this is quite simple. It makes a
  ## difference top sort the two sequences first. We turn an O(n²)
  ## algorithm into O(n*lg(n)). Not that n is very big but I think it
  ## pays off --  and then benchmarking shows that it does not :-(

  
  def points(winning, you) do
    winning = Enum.sort(winning, fn(x,y) -> x < y end)
    you = Enum.sort(you, fn(x,y) -> x < y end)
    points(winning, you, 0)
  end

  def points([], _, n) do n end
  def points(_, [], n) do n end
  def points([x|xr]=xxr, [y|yr]=yyr, n)  do
    cond do
      x == y ->
	points(xr, yr , inc(n))
      x < y ->
	points(xr, yyr , n)
      true ->
	points(xxr, yr , n)
    end
  end

  ## to benchmark.... turns out to be faster

  def paints(winning, you) do
    n = List.foldl(winning, 0,  fn(nr, acc) -> if ( Enum.any?(you, fn(x) -> (x == nr) end )) do acc+1 else acc end end)
    if n == 0 do 0 else trunc(:math.pow(2,(n-1))) end
  end
  

  
  def inc(0) do 1 end
  def inc(n) do 2*n end  


  ## The parsing os as always a bot of trial and horror but this time
  ## it was fairly easy. 
  
  
  def parse(row) do
    row = String.trim(row)
    [card, winning, you] =  String.split(row, [":", "|"])
    <<?C,?a,?r,?d, nr::binary>> = card
    {nr, _} = Integer.parse(String.trim(nr))
    winning = Enum.filter(String.split(winning, " "), fn(str) -> case str do
								   "" -> false
								   " " -> false
								   _ -> true
								 end
    end)

    you = Enum.filter(String.split(you, " "), fn(str) -> case str do
							   "" -> false
							   " " -> false
							   _ -> true
							 end
    end)    

    winning = Enum.map(winning, fn(nr) -> {nr, _} = Integer.parse(nr) ; nr   end)
    you = Enum.map(you, fn(nr) -> {nr,_} = Integer.parse(nr); nr end)
    
    {:card, nr, winning, you}
  end
  


  


  def sample() do
    "Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11"
  end
  


end

  
