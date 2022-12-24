defmodule Day22b do



  ## Day22 second task ..... argh! So I thought it woudl be a small
  ## fix to change the original solution but how many errors can you
  ## do when you twist a cube?
  ##
  ## The original solution was to insert wrap instructions in the map
  ## of the cave and for the first task it was easy to calculate these
  ## instructions automatically. To solve the second task I dis a
  ## short cut and instead of calculating the wrap instructions I
  ## inserted them explicitly for the given map. ..... how many
  ## mistakes can you do?
  ##
  ##

  
  def task_a() do
    {r, c, cave, trail} = input()
    
    rows = connect_rows_a(r, c, cave)
    cols = connect_cols_a(r, c, cave)

    s = Enum.find_index(0..c, fn(i) -> Map.get(rows, {1,i}) != nil end) + 1

    #:io.format(" start at ~w\n", [{1,s}])
    #:io.format(" trail ~w\n", [trail])    
    {{r,c}, dir, _} = follow({1,s}, :right, trail, rows, cols, [{1,s}])
    1000*r + 4*c + facing(dir)
  end

  def task_b() do
    {_r, c, cave, trail} = input()
    
    rows = connect_rows_b(cave)
    cols = connect_cols_b(cave)

    s = Enum.find_index(0..c, fn(i) -> Map.get(rows, {1,i}) != nil end) + 1

    :io.format(" start at ~w\n", [{1,s}])
    ##:io.format(" trail ~w\n", [trail])    
    {{r,c}, dir, _} = follow({1,s}, :right, trail, rows, cols, [{1,s}])
    1000*r + 4*c + facing(dir)
  end
  
  def debug_b() do
    {r, c, cave, trail} = input()

    rows = connect_rows_b(cave)
    cols = connect_cols_b(cave)    
    s = Enum.find_index(0..c, fn(i) -> Map.get(rows, {1,i}) != nil end) + 1

    :io.format(" start at ~w\n", [{1,s}])
    ##:io.format(" trail ~w\n", [trail])    
    {_, _, path} = follow({1,s}, :right, trail, rows, cols, [{1,s}])

    path = Enum.reduce(path, cave, fn(pos, cave) ->
				       Map.put(cave, pos, :trail)
				   end)
    print_cave(r,c, path)  
    
    {rows, cols}
  end  

  def debug_a() do
    {r, c, cave, trail} = sample()

    rows = connect_rows_a(r, c, cave)
    cols = connect_cols_a(r, c, cave)    
    
    s = Enum.find_index(0..c, fn(i) -> Map.get(rows, {1,i}) != nil end) + 1

    {{1,s}, trail, rows, cols}
  end


  def print_pos(pos, cave) do
    case Map.get(cave, pos) do
      nil ->
	IO.write(" ")	  
	:free ->
	IO.write(".")
      :block ->
	IO.write("#")
      :trail ->
	IO.write("x")
      {:wr, :up, _} ->
	:io.format("u")
      {:wr, :down, _} ->
	:io.format("d")
      {:wr, :left, _} ->
	:io.format("l")	
      {:wr, :right, _} ->
	:io.format("r")	
    end
  end
  
  
  def print_cave(r, c, cave) do
    Enum.each(0..(r+1), fn(r) ->
      Enum.each(0..(c+1),  fn(c) ->
	 print_pos({r,c}, cave)
	 end)
      IO.write("\n")
    end)
  end

  

  
  
  ##   Sample structure
  #
  #      A
  #  B C D
  #      E F
  #
  #
  #
  #

  def connect_rows_sample(cave) do

    ## moving right
    
    #  A-east flip F-east
    from = Enum.zip(1..4, List.duplicate(13,4))
    to =  Enum.zip(12..9, List.duplicate(16,4))
    cave = Enum.reduce(Enum.zip(from, to), cave, fn({from, to}, rows) ->
      Map.put(rows, from, {:wr, :left, to})
    end)

    ## moving left    

    #  A-west flip C-north
    from = Enum.zip(1..4, List.duplicate(8,4))
    to =  Enum.zip(List.duplicate(5,4), 5..8)
    cave = Enum.reduce(Enum.zip(from, to), cave, fn({from, to}, rows) ->
      Map.put(rows, from, {:wr, :down, to})
    end)
						
    ## moving right    
    
    ##  D-east flip F-north
    from = Enum.zip(5..8, List.duplicate(13,4))
    to =  Enum.zip(List.duplicate(9,4), 16..13)
    cave = Enum.reduce(Enum.zip(from, to), cave, fn({from, to}, rows) ->
      Map.put(rows, from, {:wr, :down, to})
    end)
						
    ## moving left
    
    ## B-west flip F-south
    from = Enum.zip(5..8, List.duplicate(0,4))
    to =  Enum.zip(List.duplicate(13,4), 16..13)
    cave = Enum.reduce(Enum.zip(from, to), cave, fn({from, to}, rows) ->
      Map.put(rows, from, {:wr, :up, to})
    end)    

    ## moving right

    ## F-east flip A-east
    from = Enum.zip(9..12, List.duplicate(17,4))
    to =  Enum.zip(4..1, List.duplicate(12,4))
    cave = Enum.reduce(Enum.zip(from, to), cave, fn({from, to}, rows) ->
      Map.put(rows, from, {:wr, :left, to})
    end)

    ## moving left

    ## E-west flip C-south
    from = Enum.zip(9..12, List.duplicate(8,4))
    to =  Enum.zip(List.duplicate(0,4), 5..8)
    cave = Enum.reduce(Enum.zip(from, to), cave, fn({from, to}, rows) ->
      Map.put(rows, from, {:wr, :up, to})
    end)

    cave
  end


  ##
  #
  #      A
  #  B C D
  #      E F
  #
  #
  #
  #
  
  def connect_cols_sample(cave) do

    ## moving up

    ## B-north flip A-north
    from = Enum.zip(List.duplicate(4,4), 1..4)
    to =  Enum.zip(List.duplicate(1,4), 8..5)
    cave = Enum.reduce(Enum.zip(from, to), cave, fn({from, to}, rows) ->
      Map.put(rows, from, {:wr, :down, to})
    end)

    ## moving down

    ## B-south flip E-south
    from = Enum.zip(List.duplicate(9,4), 1..4)
    to =  Enum.zip(List.duplicate(12,4), 12..9)
    cave = Enum.reduce(Enum.zip(from, to), cave, fn({from, to}, rows) ->
      Map.put(rows, from, {:wr, :up, to})
    end)


    ## moving up

    ## C-north flip A-west
    from = Enum.zip(List.duplicate(4,4), 5..8)
    to =  Enum.zip(1..4, List.duplicate(9,4))
    cave = Enum.reduce(Enum.zip(from, to), cave, fn({from, to}, rows) ->
      Map.put(rows, from, {:wr, :right, to})
    end)

    ## moving down

    ## C-south flip E-west
    from = Enum.zip(List.duplicate(9,4), 5..8)
    to =  Enum.zip(List.duplicate(9,4), 12..9)
    cave = Enum.reduce(Enum.zip(from, to), cave, fn({from, to}, rows) ->
      Map.put(rows, from, {:wr, :up, to})
    end)


    ## moving up

    ## A-north flip B-north
    from = Enum.zip(List.duplicate(0,4), 9..12)
    to =  Enum.zip(List.duplicate(5,4), 4..1)
    cave = Enum.reduce(Enum.zip(from, to), cave, fn({from, to}, rows) ->
      Map.put(rows, from, {:wr, :down, to})
    end)

    ## moving down

    ## E-south flip B-south
    from = Enum.zip(List.duplicate(13,4), 9..12)
    to =  Enum.zip(List.duplicate(8,4), 4..1)
    cave = Enum.reduce(Enum.zip(from, to), cave, fn({from, to}, rows) ->
      Map.put(rows, from, {:wr, :up, to})
    end)
    

    ## moving up

    ## F-north flip D-east
    from = Enum.zip( List.duplicate(8,4), 13..16)
    to =  Enum.zip(List.duplicate(12,4), 12..9)
    cave = Enum.reduce(Enum.zip(from, to), cave, fn({from, to}, rows) ->
      Map.put(rows, from, {:wr, :left, to})
    end)

    ## moving down

    ## F-south flip B-west
    from = Enum.zip(List.duplicate(13,4), 13..16)
    to =  Enum.zip(8..5, List.duplicate(1,4))
    cave = Enum.reduce(Enum.zip(from, to), cave, fn({from, to}, rows) ->
      Map.put(rows, from, {:wr, :up, to})
    end)
    
    cave
    
  end

  ##
  #
  #   AB
  #   C 
  #  DE 
  #  F
  #
  #
  #

  def from_a_west() do Enum.zip(1..50,List.duplicate(50,50) ) end
  
  def from_b_east() do  Enum.zip(1..50,List.duplicate(151,50)) end

  def from_c_east() do Enum.zip(51..100,List.duplicate(101,50)) end

  def from_c_west() do Enum.zip(51..100,List.duplicate(50,50)) end  

  def from_e_east() do Enum.zip(101..150,List.duplicate(101,50) ) end

  def from_d_west() do Enum.zip(101..150,List.duplicate(0,50)) end 
  
  def from_f_east() do Enum.zip(151..200,List.duplicate(51,50) ) end

  def from_f_west() do Enum.zip(151..200,List.duplicate(0,50) ) end
  
  
  def to_a_west() do Enum.zip(50..1,List.duplicate(51,50) ) end  # flip

  def to_b_east() do Enum.zip(50..1, List.duplicate(150,50)) end    # flip

  def to_d_west() do Enum.zip(150..101,List.duplicate(1,50) ) end   # flip  

  def to_e_east() do Enum.zip(150..101,List.duplicate(100,50)) end    # flip 


  def to_a_north() do Enum.zip(List.duplicate(1,50), 51..100) end
  
  def to_b_south() do Enum.zip(List.duplicate(50,50), 101..150) end

  def to_d_north() do Enum.zip(List.duplicate(101,50), 1..50) end

  def to_e_south() do Enum.zip(List.duplicate(150,50), 51..100) end

  ##
  #
  #   AB
  #   C 
  #  DE 
  #  F
  #
  #
  #


  def from_a_north() do  Enum.zip(List.duplicate(0,50), 51..100)  end  

  def from_b_north() do Enum.zip(List.duplicate(0,50), 101..150) end

  def from_b_south() do Enum.zip(List.duplicate(51,50), 101..150) end  

  def from_d_north() do Enum.zip(List.duplicate(100,50), 1..50)  end

  def from_e_south() do Enum.zip(List.duplicate(151,50), 51..100) end

  def from_f_south() do Enum.zip(List.duplicate(201,50), 1..50) end

  
  def to_b_north() do Enum.zip(List.duplicate(1,50), 101..150) end
  def to_f_south() do Enum.zip(List.duplicate(200,50), 1..50) end
  

  def to_c_west() do Enum.zip(51..100,List.duplicate(51,50) ) end
  def to_c_east() do Enum.zip(51..100,List.duplicate(100,50) ) end

  def to_f_west() do Enum.zip(151..200,List.duplicate(1,50) ) end
  def to_f_east() do Enum.zip(151..200,List.duplicate(50,50) ) end


  def connect_rows_b(cave) do

    # right
    # B-east to E-east :left  flip
    from = from_b_east()
    to = to_e_east()
    cave = Enum.reduce(Enum.zip(from, to), cave, fn({from, to}, rows) ->
      Map.put(rows, from, {:wr, :left, to})
    end)
    
    # left
    # A-west to D-west  :right  flip
    from = from_a_west()
    to = to_d_west()
    cave = Enum.reduce(Enum.zip(from, to), cave, fn({from, to}, rows) ->
      Map.put(rows, from, {:wr, :right, to})
    end)
    
    # right
    # C-east to B-south :up   --
    from = from_c_east()
    to = to_b_south()
    cave = Enum.reduce(Enum.zip(from, to), cave, fn({from, to}, rows) ->
      Map.put(rows, from, {:wr, :up, to})
    end)    
    
    # left
    # C-west to D-north :down --
    from = from_c_west()
    to = to_d_north()
    cave = Enum.reduce(Enum.zip(from, to), cave, fn({from, to}, rows) ->
      Map.put(rows, from, {:wr, :down, to})
    end)
    
    # right
    # E-east to B-east :left  flip
    from = from_e_east()
    to = to_b_east()
    cave = Enum.reduce(Enum.zip(from, to), cave, fn({from, to}, rows) ->
      Map.put(rows, from, {:wr, :left, to})
    end)


    #   AB
    #   C 
    #  DE 
    #  F
    #

    
    # left
    # D-west to A-west  :right flip
    from = from_d_west() 
    to = to_a_west()
    cave = Enum.reduce(Enum.zip(from, to), cave, fn({from, to}, rows) ->
      Map.put(rows, from, {:wr, :right, to})
    end)
    
    # right
    # F-east to E-south :up --
    from = from_f_east() 
    to = to_e_south()
    cave = Enum.reduce(Enum.zip(from, to), cave, fn({from, to}, rows) ->
      Map.put(rows, from, {:wr, :up, to})
    end)    
    
    # left
    # F-west to A-north :down --
    from = from_f_west()
    to = to_a_north() 
    cave = Enum.reduce(Enum.zip(from, to), cave, fn({from, to}, rows) ->
      Map.put(rows, from, {:wr, :down, to})
    end)

    cave
  end

  ##
  #
  #   AB
  #   C 
  #  DE 
  #  F
  #
  #
  #


  ##
  #
  #   AB
  #   C 
  #  DE 
  #  F
  #
  #
  #

  
  def connect_cols_b(cave) do

    # down
    # F-south to B-north :down  ---
    from = from_f_south()
    to = to_b_north()
    cave = Enum.reduce(Enum.zip(from, to), cave, fn({from, to}, rows) ->
      Map.put(rows, from, {:wr, :down, to})
    end)
    
    # up
    # D-north to C-west :right ---
    from = from_d_north()
    to = to_c_west()
    cave = Enum.reduce(Enum.zip(from, to), cave, fn({from, to}, rows) ->
      Map.put(rows, from, {:wr, :right, to})
    end)
    
    # down
    # E-south to F-east :left  ---
    from = from_e_south()
    to = to_f_east()
    cave = Enum.reduce(Enum.zip(from, to), cave, fn({from, to}, rows) ->
      Map.put(rows, from, {:wr, :left, to})
    end)
    
    #   AB
    #   C 
    #  DE 
    #  F

    # up
    # A-north to F-west :right  --
    from = from_a_north()
    to = to_f_west()
    cave = Enum.reduce(Enum.zip(from, to), cave, fn({from, to}, rows) ->
      Map.put(rows, from, {:wr, :right, to})
    end)
    
    # down
    # B-south to C-east  :left  --
    from = from_b_south() 
    to = to_c_east()
    cave = Enum.reduce(Enum.zip(from, to), cave, fn({from, to}, rows) ->
      Map.put(rows, from, {:wr, :left, to})
    end)
    
    # up
    # B-north to F-south :up ---
    from = from_b_north()
    to = to_f_south()
    cave = Enum.reduce(Enum.zip(from, to), cave, fn({from, to}, rows) ->
      Map.put(rows, from, {:wr, :up, to})
    end)

    cave
  end  
  
    
    

						  
      
  

  
  def facing(:right) do 0 end
  def facing(:down) do 1 end  
  def facing(:left) do 2 end
  def facing(:up) do 3 end      

  def follow({r,c}, dir, [], _rows, _cols, path) do
    ##:io.format(" done \n")    
    {{r,c}, dir, Enum.reverse(path)}
  end
  def follow({r,c}, dir, [:left|rest], rows, cols, path) do  
    ##:io.format(" turning left\n")
    follow({r,c}, turn_left(dir), rest, rows, cols, path)
  end
  def follow({r,c}, dir, [:right|rest], rows, cols, path) do 
    ##:io.format(" turning right\n")
    follow({r,c}, turn_right(dir), rest, rows, cols, path)
  end
  def follow({r,c}, dir, [0|rest], rows, cols, path) do 
    ##:io.format("stoped ~w\n", [{r,c}])
    follow({r,c}, dir, rest, rows, cols, [{r,c}|path])
  end

  def follow({r,c}=pos, :right=dir, [n|rest], rows, cols, path) do
    case Map.get(rows, {r,c+1}) do
      :free ->
	##:io.format("moving right ~w\n", [{r,c+1}])
	follow({r,c+1}, dir, [n-1|rest], rows, cols, path)
      :block ->
	follow(pos, dir,  [0|rest], rows, cols, path)
      {:wr, new, to} ->
	case Map.get(rows, to) do
	  nil ->
	    ##:io.format("error : pos = ~w  moving right wrap to = ~w but nothing found\n", [pos, to])
	    throw(:error)
	  {:wr, _dir, _error} ->
	    ##:io.format("error : pos = ~w  moving right wrap to= ~w  but found ~w\n", [pos, to, {:wr, dir, error}])
	    throw(:error)
	  :free ->
	    ##:io.format("wrap to ~w moving ~w\n", [to, new])
	    follow(to, new, [n-1|rest], rows, cols, path)
	  :block ->
	    follow(pos, dir, [0|rest], rows, cols, path)
	end
    end
  end
  def follow({r,c}=pos, :left=dir, [n|rest], rows, cols, path) do
    case Map.get(rows, {r,c-1}) do
      :free ->
	##:io.format("moving left  ~w\n", [{r,c-1}])
	follow({r,c-1}, dir, [n-1|rest], rows, cols, path)
      :block ->
	follow(pos, dir, [0|rest], rows, cols, path)
      {:wr, new, to} ->
	case Map.get(rows, to) do
	  :free ->
	    ##:io.format("wrap to ~w moving ~w\n", [to, new])
	    follow(to, new, [n-1|rest], rows, cols, path)
	  :block ->
	    follow(pos, dir, [0|rest], rows, cols, path)
	end
    end
  end    
  def follow({r,c}=pos, :up=dir, [n|rest], rows, cols, path) do
    case Map.get(cols, {r-1,c}) do
      :free ->
	##:io.format("moving up ~w\n", [{r-1,c}])
	follow({r-1,c}, dir, [n-1|rest], rows, cols, path)
      :block ->
	follow(pos, dir, [0|rest], rows, cols, path)
      {:wr, new, to} ->
	case Map.get(cols, to) do
	  :free ->
	    ##:io.format("wrap to ~w moving ~w\n", [to, new])
	    follow(to, new, [n-1|rest], rows, cols, path)
	  :block ->
	    follow(pos, dir, [0|rest], rows, cols, path)
	end
    end
  end
  def follow({r,c}=pos, :down=dir, [n|rest], rows, cols, path) do
    case Map.get(cols, {r+1,c}) do
      nil ->
	##:io.format("error : pos = ~w  moving ~w  but nothing found\n", [pos, dir])
	throw(:error)
      :free ->
	##:io.format("moving down  ~w\n", [{r+1,c}])
	follow({r+1,c}, dir, [n-1|rest], rows, cols, path)
      :block ->
	follow(pos, dir, [0|rest], rows, cols, path)
      {:wr, new, to} ->
	case Map.get(cols, to) do
	  :free ->
	    ##:io.format("wrap to ~w moving ~w\n", [to, new])
	    follow(to, new, [n-1|rest], rows, cols, path)
	  :block ->
	    follow(pos, dir, [0|rest], rows, cols, path)
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
    {{r,c}, cave} = parse_cave(String.split(rows,"\n"))
    trail =  parse_trail(trail)
    {r, c, cave, trail}    
  end

  def sample() do
    {{r,c}, cave} = parse_cave(cave())
    trail = parse_trail(trail())
    {r, c, cave, trail}
  end
  

  def connect_rows_a(r, c, cave) do
    Enum.reduce(1..r, cave,  fn(r, rows) ->
      {c0, cn} = Enum.reduce(1..c, {:na, :na},  fn(c, {first, last}) ->

      case Map.get(cave, {r,c}) do
	nil ->
	  {first, last}
	_ ->
	  case first do
	    :na ->
	      {c, last}
	    _ ->
	      {first, c}
	  end
      end
      end)
      rows = Map.put(rows, {r, c0-1}, {:wr, :left, {r, cn}})
      Map.put(rows, {r, cn+1}, {:wr, :right, {r, c0}})    
    end)    
  end

  def connect_cols_a(r, c, cave) do  
    Enum.reduce(1..c, cave,  fn(c, cols) ->
      {r0, rn} = Enum.reduce(1..r, {:na, :na},  fn(r, {first, last}) ->

      case Map.get(cave, {r,c}) do
	nil ->
	  {first, last}
	_ ->
	  case first do
	    :na ->
	      {r, last}
	    _ ->
	      {first, r}
	  end
      end
      end)
      cols = Map.put(cols, {r0-1, c}, {:wr, :up, {rn, c}})
      Map.put(cols, {rn+1, c}, {:wr, :down, {r0, c}})    
    end)

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
	throw(:error)
    end
  end
  
  def parse_cave(rows) do
    cave = Map.new()
    {r, c, cave} = Enum.reduce(rows, {1, 0, cave}, fn(row, {r, cm, cave}) ->
      {c, cave} = Enum.reduce(String.to_charlist(row), {1, cave},  fn(char, {c, cave}) ->
      {c+1, encode(char, r, c, cave)}
      end)
      {r+1, max(c,cm), cave}
    end)

    {{(r-1), (c-1)}, cave}
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
  
  def encode(?\. , r, c, cave) do
    Map.put(cave, {r,c}, :free)
  end  
  def encode(?\# , r, c, cave) do
    Map.put(cave, {r,c}, :block)
  end  
  def encode(?\s, _r, _c, cave) do
    cave
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
