defmodule Day16 do


  ## The first stubling block was to read the sample since "\" is the
  ## eascape character and tehre is of course no way of having the
  ## sample string in the code without the back slash being
  ## interpreted as an espace cahacter. In the end I patched the
  ## sample puzzle string :-)
  ##
  ## It was quite obvoius that we would have to traverse this map in
  ## all diections so it was natural to simply build a map structure
  ## to hold the mirrors. Since the energy in a tile is completely
  ## separated from the mirrors a second map was used to keep tracj of
  ## this.
  ##
  ## The important fact to realize is that we dont want to follow a
  ## beam to the end all the time. Since it does not matter how many
  ## beams have passed a tile one is as good as two. If we land on a
  ## tile going north but we have allready sent a beam going north
  ## through the tite then we don't have to do it again. Realizing
  ## this it is clear that we would have to store in what directions
  ## we had traversed a tile.
  ##
  ## The dubugging was mostly getting the reflections right and if I
  ## had taken the time to write some supporting function to start
  ## with that would have saved me some time :-)
  ##
  ## The second task was then but this was of course since I had
  ## done the right choices in the first solution.
  ##
  ## In the implementation I keep the unexplored beams in a list
  ## i.e. the last tile of all the current beams. Since we should
  ## follow them all to the end it does not matte rin which order they
  ## are processed. One could implement this differently and simply
  ## use the programing stack to keep track of unexplored
  ## branches. The implementation woudl then not be tail recursive but
  ## how long can the bemas be? ... hmmm, it would work for these
  ## exmaples but probably not on a 1000x1000 board.


  def test_a() do
    sample() |>
      parse() |>
      beam_a 
  end

  def task_a() do
    File.read!("day16.csv") |>
      parse() |>
      beam_a
  end

  def test_b() do
    sample() |>
      parse() |>
      beam_b
  end

  def task_b() do
    File.read!("day16.csv") |>
      parse() |>
      beam_b()
  end

  def beam_a({mirrors, r, c}) do
    beam([{:east, {1,1}}], r, c, mirrors, %{}) |>
      Map.to_list() |>
      length()
  end
  
  def beam_b({mirrors, r, c}) do
    Enum.reduce([{1..c, fn(k) -> {:south, {1,k}} end},
		 {1..c, fn(k) -> {:north, {r,k}} end},
   	         {1..r, fn(k) -> {:west,  {k,1}} end},
   	         {1..r, fn(k) -> {:east,  {k,c}} end}],
      0,
      fn({range, dir}, mx) ->
	Enum.reduce(range, mx, fn(k, mx) -> 
  	  energy = beam([dir.(k)], r, c, mirrors, %{}) |>
	    Map.to_list() |>
	    length()
	  max(energy, mx)
	end)
      end)
  end

  ## This is the work horse of the implementation. A list of all beam
  ## end points are explored. If a beam is found in the already
  ## explored beams then we go no further. 


  def beam([], _, _, _, beams) do beams end

  def beam([{dir, pos}|rest], r, c, mirrors, beams) do
    dirs =  Map.get(beams, pos, [])
    if Enum.member?(dirs, dir) do
      beam(rest, r, c, mirrors, beams)
    else
      beams = Map.put(beams, pos, [dir|dirs])
      next = enter(dir, pos, r, c, mirrors)
      beam(next ++ rest, r, c, mirrors, beams)
    end
  end

  ## The result of having a beam entering a tile in a direction. The
  ## mirrors will either let it pass through, reflect it in one
  ## direction or split it in two. The result is always a list of teh
  ## next directions.

  def enter(dir, pos, r, c, mirrors) do

    case Map.get(mirrors, pos) do

      ## pass through an empty tile

      :nil -> case dir do
		:north -> north(pos)
		:south -> south(pos, r)
		:west ->  west(pos)
		:east ->  east(pos, c)
	      end

      ## reflect in one direction 

      :back -> case dir do
		:north -> west(pos)
		:south -> east(pos, c)
		:west ->  north(pos)
		:east ->  south(pos, r)
	       end	

      :slash -> case dir do
		  :north -> east(pos, c)
		  :south -> west(pos)
		  :west ->  south(pos, r)
		  :east ->  north(pos)
		end

      ## split or pass through

      :hori ->  case dir do
		  :north -> west(pos) ++ east(pos, c)
		  :south -> west(pos) ++ east(pos, c)
		  :west ->  west(pos)
		  :east ->  east(pos, c)
		end
      :vert ->  case dir do
		  :north -> north(pos)
		  :south -> south(pos, r)
		  :west ->  north(pos) ++ south(pos, r)
		  :east ->  north(pos) ++ south(pos, r)
		end
    end
  end

  ## These functions will return a list of at most one direction. It
  ## will check if we areoutside the board and then return an empty
  ## list.
  
  def north({i,j}) when i > 1 do [{:north, {i-1, j}}] end
  def north(_)  do [] end  

  def south({i,j}, r) when i < r do [{:south, {i+1, j}}] end 
  def south(_, _)  do [] end
  
  def west({i,j}) when j > 1 do [{:west, {i, j-1}}] end
  def west(_) do [] end
  
  def east({i,j}, c) when j < c do [{:east, {i, j+1}}] end
  def east(_, _) do [] end


  ## Parsing will turn the input string into a map of mirrors. Also
  ## returns the number of rows and columns.

  def parse(rows) do
    rows = String.split(rows, "\n")
    Enum.reduce(rows, {%{}, 0, 0}, fn(row, {map,r,_}) ->
      r = r + 1
      Enum.reduce(String.to_charlist(row), {map, r, 0}, fn(char, {map, r, c}) ->
	c = c + 1
	case char do
	  ?.  -> {map, r, c}
	  ?/  -> {Map.put(map,{r,c}, :slash), r, c}
	  ?\\ -> {Map.put(map,{r,c}, :back),  r, c}
	  ?|  -> {Map.put(map,{r,c}, :vert),  r, c}
	  ?-  -> {Map.put(map,{r,c}, :hori),  r, c}
	end
      end)
    end)
  end
    

  ##  The sampe is adjusted so "/" is changed to "//" since ?/ is
  ##  treated as an escape character.

  def sample() do
".|...\\....
|.-.\\.....
.....|-...
........|.
..........
.........\\
..../.\\\\..
.-.-/..|..
.|....-|.\\
..//.|...."
  end
  


end
