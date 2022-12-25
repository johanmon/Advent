defmodule Day23 do



  ## Day 23 was fairly simple. A simple set of elf positions was kept
  ## to keep track of where thery were. Having a set of elfs is
  ## probably better than haveing a set of positions in that the elfs
  ## are far fewer than the positions on the board.
  ##
  ## Each roudn was implememnted with a propse phase where poposals
  ## were collected in a set (and removed if present, this works since
  ## at most two elfs can propose the same position). 

  
  def task_a() do
    rows = input()
    elfs = elfs(rows)
    checks = [&check1/6,&check2/6,&check3/6,&check4/6]
    {elfs,_} = rounds(10, 1, elfs, checks)
    size = size(elfs)
    size - MapSet.size(elfs)
  end

  
  def task_b() do
    rows = input()
    elfs = elfs(rows)
    checks = [&check1/6,&check2/6,&check3/6,&check4/6]
    {_, k} = rounds(-1, 1, elfs, checks)
    k
  end
  

  def debug_a() do
    rows = larger()
    elfs = elfs(rows)
    checks = [&check1/6,&check2/6,&check3/6,&check4/6]
    {elfs,_} = rounds(10, 0, elfs, checks)
    size = size(elfs)
    size - MapSet.size(elfs)
  end


  def size(elfs) do
    {_,c1} = Enum.min(elfs, fn({_,c1},{_,c2}) -> c1 < c2 end)
    {_,cn} = Enum.max(elfs, fn({_,c1},{_,c2}) -> c1 > c2 end)
    {r1,_} = Enum.min(elfs, fn({r1,_},{r2,_}) -> r1 < r2 end)
    {rn,_} = Enum.max(elfs, fn({r1,_},{r2,_}) -> r1 > r2 end)
    (rn-r1+1) * (cn-c1+1)
  end

  
  def rounds(0, k, elfs, _) do
    print(12,14,elfs)
    {elfs, k}
  end
  def rounds(n, k, elfs, [check|checks]) do
    ## print(12,14,elfs)
    case propose(elfs, check) do
      {props, true} ->
	elfs = move(props, elfs)
	rounds(n-1, k+1, elfs, checks ++ [check])
      {_, false} ->
	{elfs, k}
    end
  end


  def print(r, c, elfs) do
    IO.write("\n\n")
    Enum.each(1..r, fn(r) ->
      Enum.each(1..c, fn(c) ->
	if (MapSet.member?(elfs, {r,c})) do
	  IO.write("#")
        else
          IO.write(".")	      
	end
      end)
      IO.puts("")
    end)
  end
  
  def propose(elfs, check) do
    props = Map.new()
    Enum.reduce(elfs, {props, false}, fn(elf, {props, need}) ->
      scan(elf, elfs, props, check, need)
    end)
  end

  def move(props, elfs) do
    Enum.reduce(props, elfs, fn({to, from}, elfs) ->
      MapSet.put(MapSet.delete(elfs, from), to)
    end)
  end
  
  def scan(elf, elfs, props, check, need) do
    nw = MapSet.member?(elfs, nw(elf))
    nn = MapSet.member?(elfs, nn(elf))    
    ne = MapSet.member?(elfs, ne(elf))    

    ee = MapSet.member?(elfs, ee(elf))
    ww = MapSet.member?(elfs, ww(elf))    

    sw = MapSet.member?(elfs, sw(elf))
    ss = MapSet.member?(elfs, ss(elf))    
    se = MapSet.member?(elfs, se(elf))

    north = (!nw) and (!nn) and (!ne)
    south = (!sw) and (!ss) and (!se)

    if (north and !(ee) and !(ww) and south) do
      {props, need}
    else
      west = (!nw) and (!ww) and (!sw)
      east = (!ne) and (!ee) and (!se)
      {check.(elf, props, north, south, west, east), true}
    end
  end

  def check1(elf, props, north, south, west, east) do 
    cond do 
      north ->
	case Map.get(props, nn(elf)) do
	  nil ->
	    Map.put(props, nn(elf), elf)
	  _another ->
	    Map.delete(props, nn(elf))
	  end
	south ->
	  case Map.get(props, ss(elf)) do
	    nil ->
	      Map.put(props, ss(elf), elf)
	    _another ->
	      Map.delete(props, ss(elf))
	  end
	west ->
	  case Map.get(props, ww(elf)) do
	    nil ->
	      Map.put(props, ww(elf), elf)
	    _another ->
	      Map.delete(props, ww(elf))
	  end
	east ->  
	  case Map.get(props, ee(elf)) do
	    nil ->
	      Map.put(props, ee(elf), elf)
	    _another ->
	      Map.delete(props, ee(elf))
	  end
	true ->
	  props
      end
  end


  def check2(elf, props, north, south, west, east) do 
      cond do 
	south ->
	  case Map.get(props, ss(elf)) do
	    nil ->
	      Map.put(props, ss(elf), elf)
	    _another ->
	      Map.delete(props, ss(elf))
	  end
	west ->
	  case Map.get(props, ww(elf)) do
	    nil ->
	      Map.put(props, ww(elf), elf)
	    _another ->
	      Map.delete(props, ww(elf))
	  end
	east ->  
	  case Map.get(props, ee(elf)) do
	    nil ->
	      Map.put(props, ee(elf), elf)
	    _another ->
	      Map.delete(props, ee(elf))
	  end
	north ->
	  case Map.get(props, nn(elf)) do
	    nil ->
	      Map.put(props, nn(elf), elf)
	    _another ->
	      Map.delete(props, nn(elf))
	  end
	true ->
	  props
      end
  end

  def check3(elf, props, north, south, west, east) do 
      cond do 
	west ->
	  case Map.get(props, ww(elf)) do
	    nil ->
	      Map.put(props, ww(elf), elf)
	    _another ->
	      Map.delete(props, ww(elf))
	  end
	east ->  
	  case Map.get(props, ee(elf)) do
	    nil ->
	      Map.put(props, ee(elf), elf)
	    _another ->
	      Map.delete(props, ee(elf))
	  end
	north ->
	  case Map.get(props, nn(elf)) do
	    nil ->
	      Map.put(props, nn(elf), elf)
	    _another ->
	      Map.delete(props, nn(elf))
	  end
	south ->
	  case Map.get(props, ss(elf)) do
	    nil ->
	      Map.put(props, ss(elf), elf)
	    _another ->
	      Map.delete(props, ss(elf))
	  end
	true ->
	  props
      end
  end

  def check4(elf, props, north, south, west, east) do 
      cond do 
	east ->  
	  case Map.get(props, ee(elf)) do
	    nil ->
	      Map.put(props, ee(elf), elf)
	    _another ->
	      Map.delete(props, ee(elf))
	  end
	north ->
	  case Map.get(props, nn(elf)) do
	    nil ->
	      Map.put(props, nn(elf), elf)
	    _another ->
	      Map.delete(props, nn(elf))
	  end
	south ->
	  case Map.get(props, ss(elf)) do
	    nil ->
	      Map.put(props, ss(elf), elf)
	    _another ->
	      Map.delete(props, ss(elf))
	  end
	west ->
	  case Map.get(props, ww(elf)) do
	    nil ->
	      Map.put(props, ww(elf), elf)
	    _another ->
	      Map.delete(props, ww(elf))
	  end
	true ->
	  props
      end
  end
  
  
  def nw({x,y}), do: {x-1,y-1}
  def nn({x,y}), do: {x-1,y}
  def ne({x,y}), do: {x-1,y+1}

  def ee({x,y}), do: {x,y+1}
  def ww({x,y}), do: {x,y-1}
  
  def sw({x,y}), do: {x+1,y-1}
  def ss({x,y}), do: {x+1,y}
  def se({x,y}), do: {x+1,y+1}  
  
  def elfs(rows) do
    elfs = MapSet.new()
    {_,elfs} = Enum.reduce(rows, {1,elfs}, fn(row,{r,elfs}) ->
      {_,elfs} =  Enum.reduce(String.to_charlist(String.trim(row)), {1,elfs}, fn(char, {c,elfs}) ->
        case char do
	  ?\. ->
	    {c+1, elfs}
	  ?\# ->
	    {c+1, MapSet.put(elfs,{r,c})}
	end
    end)
      {r+1, elfs}
    end)
    elfs
  end

  def input() do
    File.stream!("day23.csv")
  end


  def sample() do
    [".....",
     "..##.",
     "..#..",
     ".....",
     "..##.",
     "....."]
  end

  def larger() do
    [
      "..............",
      "..............",
      ".......#......",
      ".....###.#....",
      "...#...#.#....",
      "....#...##....",
      "...#.###......",
      "...##.#.##....",
      "....#..#......",
      "..............",
      "..............",
      ".............."]
  end
  

end
