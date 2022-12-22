defmodule Day22 do


  def task_a() do
    {start, trail, rows, cols} = input()
    {{r,c}, dir, _} = follow(start, :right, trail, rows, cols, [start])
    1000*r + 4*c + facing(dir)
  end

  def facing(:right) do 0 end
  def facing(:down) do 1 end  
  def facing(:left) do 2 end
  def facing(:up) do 3 end      

  def follow({r,c}, dir, [], _rows, _cols, path) do  {{r,c}, dir, Enum.reverse(path)}  end
  def follow({r,c}, dir, [:left|rest], rows, cols, path) do  follow({r,c}, turn_left(dir), rest, rows, cols, path) end
  def follow({r,c}, dir, [:right|rest], rows, cols, path) do  follow({r,c}, turn_right(dir), rest, rows, cols, path) end
  def follow({r,c}, dir, [0|rest], rows, cols, path) do  follow({r,c}, dir, rest, rows, cols, [{r,c}|path]) end

  def follow({r,c}, :right=dir, [n|rest], rows, cols, path) do
    case Map.get(rows, {r,c+1}) do
      :free ->
	:io.format("moving right ~w\n", [{r,c+1}])
	follow({r,c+1}, dir, [n-1|rest], rows, cols, path)
      :block ->
	follow({r,c}, dir,  [0|rest], rows, cols, path)
      {:wr, x, y} ->
	case Map.get(rows, {x,y}) do
	  :free ->
	    :io.format("wrap moving right  ~w\n", [{x,y}])
	    follow({x,y}, dir, [n-1|rest], rows, cols, path)
	  :block ->
	    follow({r,c}, dir, [0|rest], rows, cols, path)
	end
    end
  end
  def follow({r,c}, :left=dir, [n|rest], rows, cols, path) do
    case Map.get(rows, {r,c-1}) do
      :free ->
	:io.format("moving left  ~w\n", [{r,c-1}])
	follow({r,c-1}, dir, [n-1|rest], rows, cols, path)
      :block ->
	follow({r,c}, dir, [0|rest], rows, cols, path)
      {:wr, x, y} ->
	case Map.get(rows, {x,y}) do
	  :free ->
	    :io.format("wrap moving left  ~w\n", [{x,y}])
	    follow({x,y}, dir, [n-1|rest], rows, cols, path)
	  :block ->
	    follow({r,c}, dir, [0|rest], rows, cols, path)
	end
    end
  end    
  def follow({r,c}, :up=dir, [n|rest], rows, cols, path) do
    case Map.get(cols, {c,r-1}) do
      :free ->
	:io.format("moving up ~w\n", [{r-1,c}])
	follow({r-1,c}, dir, [n-1|rest], rows, cols, path)
      :block ->
	follow({r,c}, dir, [0|rest], rows, cols, path)
      {:wr, y, x} ->
	case Map.get(cols, {y,x}) do
	  :free ->
	    :io.format("wrap moving up  ~w\n", [{x,y}])
	    follow({x,y}, dir, [n-1|rest], rows, cols, path)
	  :block ->
	    follow({r,c}, dir, [0|rest], rows, cols, path)
	end
    end
  end
  def follow({r,c}, :down=dir, [n|rest], rows, cols, path) do
    case Map.get(cols, {c,r+1}) do
      :free ->
	:io.format("moving down  ~w\n", [{r+1,c}])
	follow({r+1,c}, dir, [n-1|rest], rows, cols, path)
      :block ->
	follow({r,c}, dir, [0|rest], rows, cols, path)
      {:wr, y, x} ->
	case Map.get(cols, {y,x}) do
	  :free ->
	    :io.format("wrap moving down  ~w\n", [{x,y}])
	    follow({x,y}, dir, [n-1|rest], rows, cols, path)
	  :block ->
	    follow({r,c}, dir, [0|rest], rows, cols, path)
	end
    end
  end    


  def turn_left(:right) do :up end
  def turn_left(:up) do :left end  
  def turn_left(:left) do :down end  
  def turn_left(:down) do :right end

  def turn_right(:right) do :down end
  def turn_right(:up) do :right end  
  def turn_right(:left) do :up end  
  def turn_right(:down) do :left end  
  
  def input() do
    [rows, trail] = String.split(File.read!("day22.csv"), "\n\n")
    {{_r,c}, cave_rows, cave_cols} = parse_cave(String.split(rows,"\n"))
    s = Enum.find_index(0..c, fn(i) -> Map.get(cave_rows, {1,i}) != nil end) + 1
    trail =  parse_trail(trail)
    {{1,s}, trail, cave_rows, cave_cols}    
  end

  def debug() do
    {{_r,c}, cave_rows, cave_cols} = parse_cave(cave())
    s = Enum.find_index(0..c, fn(i) -> Map.get(cave_rows, {1,i}) != nil end) + 1
    trail =  parse_trail(trail())
    {{1,s}, trail, cave_rows, cave_cols}
  end
  
  def parse_trail("") do [] end
  def parse_trail("\n") do [] end  
  def parse_trail(<<?L, rest::binary>>) do [:left|parse_trail(rest)] end
  def parse_trail(<<?R, rest::binary>>) do [:right|parse_trail(rest)] end
  def parse_trail(str) do
    case Integer.parse(str) do
      {nr, rest} ->
	[nr | parse_trail(rest)]
      :error ->
	:io.format(" error ~w\n", [str])
	:error
    end
  end
  
  def parse_cave(rows) do
    cave_rows = Map.new()
    {r, c, cave_rows} = Enum.reduce(rows, {1, 0, cave_rows}, fn(row, {r, cm, cave}) ->
      {c, wr, cave} = Enum.reduce(String.to_charlist(row), {1, nil, cave}, fn(char, {c, wr, cave}) ->
               encode(char, r, c, wr, cave)
               end)
      cave = loop(r, c, wr, cave)
      {r+1, max(c,cm), cave}
    end)

    cave_cols = Map.new()
    cave_cols =  Enum.reduce(1..(c-1), cave_cols,  fn(c, cave) ->
      {r, wr, cave} = Enum.reduce(1..(r-1), {:na, nil, cave},  fn(r, {_, wr, cave}) ->
      encode(decode(Map.get(cave_rows, {r,c})), c, r, wr, cave)
    end)
      loop(c, r, wr, cave)
    end)
    {{(r-1), (c-1)}, cave_rows, cave_cols}
  end


  def encode(?.) do :free end
  def encode(?\#) do :block end  
  def encode(?\s) do nil end  

  def decode(:free) do ?\. end  
  def decode(:block) do ?\# end
  def decode({:wr,_,_}) do ?\s  end
  def decode(nil) do ?\s end

  def print(:free) do ?\. end  
  def print(:block) do ?\# end
  def print({:wr,_,_}) do ?w  end
  def print(nil) do ?\s end
  
  def loop(_, _, nil, cave) do
    cave
  end
  def loop(r, c, {:wr, x, y}, cave) do
    cave = Map.put(cave, {x, y-1}, {:wr, r, c-1})
    cave = Map.put(cave, {r, c}, {:wr, x, y})    
    cave
  end  

  
  def encode(?\. , r, c, nil, cave) do
    cave = Map.put(cave, {r,c}, :free)
    {c+1, {:wr, r, c}, cave}
  end  
  def encode(?\. , r, c, wr, cave) do
    cave = Map.put(cave, {r, c}, :free)
    {c+1, wr, cave}
  end

  def encode(?\# , r, c, nil, cave) do
    cave = Map.put(cave, {r,c}, :block)
    {c+1, {:wr, r, c}, cave}
  end  
  def encode(?\#, r, c, wp, cave) do
    cave = Map.put(cave, {r,c}, :block)
    {c+1, wp, cave}
  end  
  def encode(?\s, r, c, {:wr, x, y}, cave) do
    :io.format("  looping ~w and ~w \n", [{r,c}, {x,y}])
    cave = Map.put(cave, {x, y-1}, {:wr, r, c-1})
    cave = Map.put(cave, {r, c}, {:wr, x, y})    
    {c+1, nil, cave}
  end      
  def encode(?\s, _r, c, wp, cave) do
    {c+1, wp, cave}
  end

  def cave() do
    [
      "        ...#",
      "        .#..",
      "        #...",
      "        ....",
      "...#.......#",
      "........#...",
      "..#....#....",
      "..........#.",
      "        ...#....",
      "        .....#..",
      "        .#......",
      "        ......#."]
  end

  def trail() do "10R5L5R10L4R5L5" end

end
