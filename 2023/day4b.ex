defmodule Day4b do


  def test() do
    String.split(sample(), "\n") |>
      Enum.map(fn(row) -> parse(row) end) |>
      scan(0)
  end


  def task() do
    File.stream!("day4.csv") |>
      Stream.map(fn(row) -> parse(row) end) |>
      Enum.to_list() |>
      scan(0)
  end  

  ## Turns pout to be quite simple since we have all cards ordered in
  ## the list. We do not have to search for them but take for granted
  ## that they follow immediately. We only win cards that are forward
  ## in the list and since we only modify the head of the list the
  ## operation becomes quite efficient. 
  
  def scan([], n) do n end
  def scan([{:card, _, k, winning, you}|rest], n) do
    p = points(winning, you)
    scan(update(p, k, rest), n+k)
  end

  def update(0, _, cards) do cards end
  def update(n, k, [{:card, nr, i, winning, you}|rest]) do
    [{:card, nr, i+k, winning, you}| update(n-1,k,rest)]
  end  

  ## Only change the way oints are calculated. 
  
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

  def inc(n) do n+1 end  


  ## The difference is now that we keep a counter on each card that
  ## descriobes how many duplicates we have.
  
  
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
    
    {:card, nr, 1, winning, you}
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

  
