defmodule Day18a do

  ## Stealing candy from a kid ... almost. This is teh quick and dirty
  ## solution. The only problem is filling the pool i.e. identify all
  ## squares that are inside the pool. The chosen solution is to flood
  ## the internal positions and the problem then is ofcourse to find
  ## one position that is inside the rim ... and hope that this is
  ## enough.
  ##
  
  def test() do
    sample() |>
      String.split("\n") |>
      Enum.map(&parse/1) |>
      dig() |>
      fill() |>
      Map.to_list() |>
      length()
  end

  def task() do
    File.read!("day18.csv") |>
      String.split("\n") |>
      Enum.map(&parse/1) |>
      dig() |>
      fill() |>
      Map.to_list() |>
      length()
  end

  ## To fill the pool we identify a row that, looking from the left,
  ## has two paths with some room in-between. This in-between needs to
  ## be inside the pool and we can therefore flood it with water. 
  
  def fill({_, map}) do
    keys = Map.keys(map)
    sorted = Enum.sort(keys)
    [{r,_}|_] = sorted
    fill(r, sorted, map)
  end

  def fill(_, [], _map) do 
    ## strange
    map
  end
  
  def fill(r, [{r,c1}, {r,c2}| _], map) when c1 != (c2-1) do
    ## If the two first holes are separated from each other we have
    ## found a position that is inside the pool,
    flood([{r,c1+1}], map)
  end
  def fill(r, [{r,_}| rest], map) do
    ## ... otherwise we skip this row,
    fill(r, rest, map)
  end
  def fill(r, keys, map) do 
    ## ... and try the next.
    fill(r+1, keys, map)
  end

  ## Flooding position an empty position will simply flood all
  ## neighbours. If the position is already filled we ignore i (part
  ## of the rim or already flooded).
  ##
  ## This does not work if the rim is touching it self i.e. creating
  ## separated islands. It works here but that is only luck.
  
  def flood([], map) do map end
  def flood([pos|rest], map) do
    case Map.get(map, pos) do
      :nil ->
	map = Map.put(map, pos, {:rgb, 0, 0, 0})
	flood([move(pos,:left,1), move(pos,:right,1), move(pos,:up,1), move(pos,:down,1) | rest], map)
      _ ->
	flood(rest, map)
    end
  end  


  ## Digging accoring to the plan will add all positions with the
  ## right color to the map.

  def dig(plan) do
    Enum.reduce(plan, {{0,0},%{}}, fn(d, {pos, map}) -> dig(d, pos, map) end)
  end
    
  def dig({:dig, dir, meters, color}, pos, map) do
    map = Enum.reduce(1..meters, map, fn(m,map) ->
      Map.put(map, move(pos, dir, m), color)
    end)
    {move(pos,dir,meters), map}
  end

  def move({i,j}, dir, m) do
    case dir do
      :up -> {i-m, j}
      :down -> {i+m, j}
      :right -> {i, j+m}
      :left -> {i, j-m}
    end
  end

  def parse(row) do
    [dir, nr, code] = String.split(row," ")
    dir = case dir do
	    "D" -> :down
	    "L" -> :left
	    "R" -> :right
	    "U" -> :up
	  end
    <<?(,?\#,r::binary-size(2),g::binary-size(2),b::binary-size(2) ,?)>> = code
    {nr,_} = Integer.parse(nr)
    [r,g,b] = Enum.map([r,g,b], fn(str) -> {nr, _} = Integer.parse(str, 16) ; nr end)
    {:dig, dir, nr, {:rgb, r, g, b}}
  end



  def sample() do 
"R 6 (#70c710)
D 5 (#0dc571)
L 2 (#5713f0)
D 2 (#d2c081)
R 2 (#59c680)
D 2 (#411b91)
L 5 (#8ceee2)
U 2 (#caa173)
L 1 (#1b58a2)
U 2 (#caa171)
R 2 (#7807d2)
U 3 (#a77fa3)
L 2 (#015232)
U 2 (#7a21e3)"
  end
  

  
end

