defmodule Day5 do

  ## Day 5, a lot of parsing. Most of todays puzzle was about parsing
  ## the input. Turning the description of the original setting was
  ## the crux and that took some time. As soon as the input was parsed
  ## properly the moving of crates was simple. A lucky shot was that I
  ## had not tried to make special case of how to move more than one
  ## crate so the second assignment turned out to be a no-brainer. 

  def input() do
    {:ok, input} = File.read("day5.csv")
    [cargo, moves] = String.split(input, ["\n\n"])
    {piles, nrs} = cargo(cargo)
    moves = moves(moves)
    {piles, nrs, moves}
  end


  def task_a() do
    {piles, _, moves} = input()
    piles = Enum.reduce(moves, piles, fn(mv, pls) ->  move_a(mv, pls) end)
    Enum.map(piles, fn(p) -> hd(p) end)
  end

  def task_b() do
    {piles, _, moves} = input()
    piles = Enum.reduce(moves, piles, fn(mv, pls) ->  move_b(mv, pls) end)
    Enum.map(piles, fn(p) -> hd(p) end)
  end

  def move_a({0,_,_}, piles) do piles end
  def move_a({n,f,t}, piles) do
    {c, piles} = from(f, piles)
    move_a({n-1, f, t}, to(t, c, piles))
  end

  def move_b({0,_,_}, piles) do piles end
  def move_b({n,f,t}, piles) do
    {c, piles} = from(f, piles)
    to(t, c, move_b({n-1, f, t}, piles))
  end
  
  def from(1, [[c|pile]|piles]) do  {c, [pile|piles]} end
  def from(n, [pile|piles]) do
    {c, piles} = from(n-1, piles)
    {c, [pile|piles]}
  end

  def to(1, c, [pile|piles]) do [[c|pile]|piles] end
  def to(n, c, [pile|piles]) do
    [pile|to(n-1, c, piles)]
  end  
    
  
  def cargo(input) do
    rows = String.split(input, ["\n"])
    {rows, [last]} = Enum.split(rows, -1)
    last = String.split(last, [" "])
    nrs = stacks(last)
    piles = piles(rows, Enum.map(nrs, fn(_) -> [] end))
    {piles, nrs}
  end

  def moves(input) do
    Enum.map(String.split(input, ["\n"]), fn(r) ->
      case String.split(r,[" "]) do
	[_, n, _, f, _, t] ->
	  {n,_} = Integer.parse(n)
	  {f, _} = Integer.parse(f)
	  {t,_} =  Integer.parse(t)
	  {n, f, t}
	_ -> {0,0,0}
      end
    end)
  end
  
  def stacks(input) do 
    Enum.flat_map(input, fn(s) ->
      case Integer.parse(s) do
	{n, _} -> [n]
	:error -> []
      end
    end)
  end

  def piles([], piles) do
    piles
  end
  def piles([row|rest], piles) do
    pile(scan(row), piles(rest, piles))
  end

  def pile([],[]) do [] end
  def pile([:nil|rest], [p|piles]) do
    [p|pile(rest, piles)]
  end
  def pile([c|rest], [p|piles]) do
    [[c|p]|pile(rest, piles)]
  end  

  
  # "[T]     [J] [Z] [M] [N] [F]     [L]" 

  def scan(<<>>) do [] end
  def scan(<<?[,c,?], 32, rest::binary>>) do
     [c| scan(rest)]   ## String.to_atom(<<c>>)
  end
  def scan(<<?[,c,?], rest::binary>>) do
     [c| scan(rest)]   ## String.to_atom(<<c>>)
  end
  def scan(<<32,32,32,32, rest::binary>>) do
    [:nil|scan(rest)]
  end  



end
