defmodule Day3b do

  ## This is closer to the solution one should have tried from the
  ## beginning. The implemenation is rather simple once you realize
  ## that you cabn search for any adjacent nr to a muktiplication in
  ## one sweep. 

  def test() do
    rows = Enum.map( String.split(sample(), "\n"),  fn(row) -> parse(String.trim(row)) end)
    [one,two] = Enum.take(rows, 2)
    scanned = scan({[],[]}, one, two,  Stream.drop(rows, 2))
    Enum.sum(List.flatten(scanned))
  end

  def task() do
    rows = Enum.map(File.stream!("day3.csv"),  fn(row) -> parse(String.trim(row)) end)
    [one,two] = Enum.take(rows, 2)
    scanned = scan({[],[]}, one, two,  Stream.drop(rows, 2))
    Enum.sum(List.flatten(scanned))
  end
  
  def scan( one, two, three, rest) do
    case Enum.take(rest, 1) do
      [] ->
	[scan(one, two, three), scan(two, three, {[],[]})]
      [four] ->
	[scan(one, two, three) | scan(two, three, four,  Stream.drop(rest, 1) )]
    end
  end

  ##  Scanning is noq almost trivial sin ce we can search all three
  ##  lines in one go, 

  def scan({_, one}, {mul, two}, {_, three}) do
    adj(mul, one ++ two ++ three)
  end


  ## Filter and look for exactly two adjacent numbers.

  def adj([], _) do [] end
  def adj([{:mul, k}|mr], nrs) do
    case filter(nrs, k) do
      [{:nr, i, _, _}, {:nr, j, _, _}] ->
	[i*j | adj(mr, nrs)]
      _ ->
	adj(mr, nrs)
    end
  end


  def filter(ar,k) do
    Enum.filter(ar, fn(x) -> case x do
				    {:nr, _, k1, k2} when  (k1-1) <= k and k <= (k2+1) ->
				      true
				    _ ->
				      false
				  end
    end)
  end


  ##  The parser now returns a list of {:nr, nr, first, last} with the
  ##  position of the number on the line or {:mul, pos}. It then
  ##  becomes easier ti search for adjacent numbers. 
  
  def parse(str) do parse(str, 0, [], []) end

  def parse(<<>>, _, mul, nrs) do  {mul, nrs}  end
  def parse(<<char, rest::binary>>, k, mul, nrs) do
    cond do
      (char >= ?0) && (char <=?9) ->
	collect(rest, {char - ?0, k, k}, mul, nrs)
      char == ?* ->
	parse(rest, k+1, [{:mul, k}|mul], nrs)
      true ->
	parse(rest, k+1, mul, nrs)
    end
  end
					   

  def collect(<<>>, {nr,k1,k2}, mul, nrs) do {mul, [{:nr, nr, k1,k2}|nrs]} end
  def collect(<<char, rest::binary>>, {nr, k1, k2}, mul, nrs) do
    cond do
      (char >= ?0) && (char <=?9) ->
	collect(rest, {nr*10 + (char - ?0), k1, k2+1}, mul, nrs)
      char == ?* ->
	parse(rest, k2+2, [{:mul, k2+1}|mul], [{:nr, nr, k1, k2}|nrs])
      true ->
	parse(rest, k2+2, mul, [{:nr, nr, k1, k2}|nrs])
    end
  end


  def sample() do
"467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598.."
  end

  
    
  

end
