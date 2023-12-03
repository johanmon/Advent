defmodule Day3a do

  ## This took too long and an hour was spent on an extra \n that I
  ## dod not trim from the line +-/ 

  def test() do
    rows = Enum.map( String.split(sample(), "\n"),  fn(row) -> parse(row) end)
    [one,two] = Enum.take(rows, 2)
    dummy = List.duplicate(:dot, length(one))
    scanned = scan(dummy, one, two, dummy, Stream.drop(rows, 2))
    List.foldl(scanned, 0, fn (r,acc) -> Enum.sum(r) + acc end)
    
  end

  def task() do
    rows = Enum.map(File.stream!("day3.csv"),  fn(row) -> parse(String.trim(row)) end)
    [one,two] = Enum.take(rows, 2)
    dummy = List.duplicate(:dot, length(one))
    scanned = scan(dummy, one, two, dummy, Stream.drop(rows, 2))
    List.foldl(scanned, 0, fn (r,acc) -> Enum.sum(r) + acc end)
    
  end

  ## We want to scan three rows at a time looking at the middle
  ## one. In order to scan the first and last rows we use a dummy row.
  
  
  def scan(one, two, three, dummy, rest) do
    case Enum.take(rest, 1) do
      [] ->
	[scan(one, two, three), scan(two, three, dummy)]
      [four] ->
	[scan(one, two, three) | scan(two, three, four, dummy, Stream.drop(rest,1))]
    end
  end

  ## We are scanning three rows, looking at the middle one. If we find
  ## a number or a sumbol we move in to the collect or potential state. 
  
  def scan([],[],[]) do [] end

  def scan([a1|ar], [{:nr,i}|br], [c1|cr]) do
    if ( (a1 == :symbol) or (c1 == :symbol))  do 
      collect(ar, br, cr, i)
    else
      potential(ar,br,cr, i)
    end
  end

  ##   dot or symbol 
  def scan([a1|ar], [b1|br], [c1|cr]) do  
    if ( (a1 == :symbol) or (b1 == :symbol) or (c1 == :symbol))  do 
      collect(ar,br,cr, 0)
    else
      potential(ar,br,cr, 0)
    end
  end

  
  ## We have started on a potential number or will move in to the
  ## collect state of we seea symbol.

  def potential([],[],[], _) do [] end

  def potential([a1|ar], [{:nr,i}|br], [c1|cr], nr) do
    if ( (a1 == :symbol) or (c1 == :symbol))  do 
      collect(ar,br,cr, nr*10+i )
    else
      potential(ar,br,cr, nr*10+i)
    end
  end

  def potential([a1|ar], [b1|br], [c1|cr], nr ) do  
    if ( (a1 == :symbol) or (b1 == :symbol) or (c1 == :symbol))  do 
      [nr | collect(ar, br, cr, 0)]
    else
      scan(ar, br, cr)
    end
  end

  ##  collect the number as far as possible
  
  def collect([], [], [], nr) do [nr] end

  def collect([_|ar],[{:nr,i}|br], [_|cr], nr) do
    collect(ar,br,cr, (nr*10 + i))
  end
  
  def collect(ar, br, cr, nr) do
    [ nr | scan(ar,br,cr)]
  end


  ## The parser will return a list of tokens: :dot, :symbol, {:nr, nr}
  
  def parse(<<>>) do  []  end
  def parse(<<char, rest::binary>>) do
      cond do
	char == ?. ->
	  [:dot | parse(rest)]
	(char >= ?0) && (char <=?9) ->
	  [{:nr, char - ?0} | parse(rest)]
	true ->
	  [:symbol | parse(rest)]
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
