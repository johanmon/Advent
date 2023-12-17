defmodule Day17 do

  ##  Arghhh, Sunday!
  ##
  ##  So we're of course implementing Dijkstra but there is a
  ##  catch. We explore the shortest paths as usual but ... if we find
  ##  a node as the first node in the queue it does imply that that we
  ##  have found the shortest path to the node but ... it does not
  ##  imply that we can stop if we encounter this node again. The
  ##  reason is that the last time we entered the node we might have
  ##  entered from south but we now enter it from the west. When we
  ##  entered from the south we explored only the paths leading east
  ##  and west but now we inter from the west we should explore the
  ##  paths leading north and south
  ##
  ##  The restriction on the number of steps in a straight line one
  ##  could take have several solutions. The approach that I used was
  ##  to add three nodes to the queue, one for each possible step. A
  ##  entry in the queue thus encoded: the node ({i,j}) from which
  ##  direction we came and the length of the path.
  ##
  ##  When we dequeue an entry from the queue we as usual check if we
  ##  have already been to this node but now also which directions we
  ##  have explored. If only the vertical or horizontal directions
  ##  have been explored we might continue depending on the direction
  ##  of the current path.
  ##
  ##  Note that the "path" is not actually available when we are
  ##  done. The only thing we know is that smallest heat loss. The
  ##  reason that we loose the path is that we in each node record
  ##  only the lowest heat loss. The actual path is tricky to
  ##  reconstruct. If we would encode the path in each queue entry it
  ##  would work.
  ##
  ##  An alternative way to encode the unexplored paths would be to
  ##  use a tuple: {dir, n, sofar} where n is the number of steps that
  ##  we could continue in that directions. When we now dequeue an
  ##  entry we would add tow or three more entries for: forward (if n
  ##  > 0), left and right. 
  ## 
  ##  The priority queue is a leftist heap implemented in another
  ##  project.

  require Leftist

  def test_a() do
    sample() |>
      parse() |>
      search({1,3}) |>
      print()
  end

  def task_a() do
    File.read!("day17.csv") |>
      parse() |>
      search({1,3}) |>
      elem(0)
  end  

  def test_b() do
    sample() |>
      parse() |>
      search({4,10}) |>
      print()
  end

  def task_b() do
    File.read!("day17.csv") |>
      parse() |>
      search({4,10}) |>
      elem(0)
  end  

  ## Some print out helps the debugging process :-)

  def print({heat, {r,c}, done}) do
    :io.format(" lowest heat loss: ~w~n", [heat]) 
    Enum.map(1..r, fn(i) ->
      Enum.map(1..c, fn(j) ->
	case Map.get(done, {i,j}) do
	  :nil ->
	    :io.format(" . ")
	  {heat, _} ->
	    :io.format(" ~2w", [heat])
	end
      end)
      IO.write("\n")
    end)
    :ok
  end

  def search({map, r,c}, range) do
    pos = {1,1}
    done = %{}
    ## The two starting directions
    Leftist.new(&</2) |>
      Leftist.enqueue(0, {:east, pos}) |>
      Leftist.enqueue(0, {:south, pos}) |>
      dijkstra(done, map, {r,c}, range)
  end


  def dijkstra(queue, done, map, to, range) do
    case Leftist.dequeue(queue) do
      {sofar, {_, ^to}, _} ->
	done = Map.put(done, to, {sofar, :done})
	{sofar, to, done}
      {sofar, {dr, pos}, queue} ->
	ori = orientation(dr)
	case Map.get(done, pos) do
	  :nil ->
	    ## first visit, continue 
	    done = Map.put(done, pos, {sofar, ori})
	    explore(sofar, dr, pos, queue, done, map, to, range)
	  {_sofar, :done} ->
	    ## both orientations explored, do nothing 
	    dijkstra(queue, done, map, to, range)
	  {_sofar, ^ori} ->
	    ## this orientation explored, do nothing 
	    dijkstra(queue, done, map, to, range)
	  {_sofar, _} ->
	    ## the other orientation explored, continue, note that we
	    ## ignore the shortest path found since we will now
	    ## explore comming from another direction.
	    done = Map.put(done, pos, {sofar, :done})
	    explore(sofar, dr, pos, queue, done, map, to, range)
	end
    end
  end

  def explore(sofar, dr, pos, queue, done, map, to, range)  do
    ## Generating the next poosible steps is now parameterized with a
    ## range ({1,3} or {4,10}). 
    rgt = forward(right(dr), pos, map, range)
    lft = forward(left(dr), pos, map, range)
    ## Next is a list of all possible next steps, add them to the queue.
    next = rgt ++ lft
    queue = Enum.reduce(next, queue, fn({dir, heat}, acc) ->  Leftist.enqueue(acc, heat+sofar, dir)  end)
    dijkstra(queue, done, map, to, range)
  end
  

  ## Generat a list of possible new entries. If we are at a position
  ## and facing a direction we can turn either left or right and
  ## proceed first to last steps. These are now the positions where we
  ## would have to do another turn. Each entry incodes the direction,
  ## position and the heat loss so far (starting from zero).
  ##
  
  def forward(dir, pos, map, {first, last}) do
    ## We generate the entries 1 to last in order to add up the heat
    ## loss as we go. If we do not find a position in the map it means
    ## that it is outside of the map and should be ignored. 

    Enum.map(1..last, fn(i) -> step(dir, pos, i) end) |>
      Enum.reduce({[],0}, fn(nxt, {all, sofar}) ->
	case Map.get(map, nxt) do
	  :nil ->
	    {all, sofar}
	  heat ->
	    {[{{dir, nxt}, sofar+heat} | all], sofar+heat}
	end
      end) |>
      elem(0) |>
      ## Ignore all entries that are before first. The entries are
      ## recoreded in the reveres order so we drop the last entries.
      Enum.drop(-(first-1))
  end

  ## The low level operations.
  
  def step(:east,  {i,j}, s) do {i, j+s} end  
  def step(:west,  {i,j}, s) do {i, j-s} end  
  def step(:north, {i,j}, s) do {i-s, j} end
  def step(:south, {i,j}, s) do {i+s, j} end

  def right(:east)  do :south end
  def right(:west)  do :north end
  def right(:north) do :east  end  
  def right(:south) do :west  end    

  def left(:east)   do :north end
  def left(:west)   do :south end
  def left(:north)  do :west  end  
  def left(:south)  do :east  end      

  def orientation(:north) do :horz end
  def orientation(:south) do :horz end
  def orientation(:east)  do :vert end  
  def orientation(:west)  do :vert end  

  ## The parser, simply collect all heat losses in a map.
    
  def parse(rows) do
    rows = String.split(rows, "\n")
    Enum.reduce(rows, {%{}, 0, 0}, fn(row, {map,r,_}) ->
      r = r + 1
      Enum.reduce(String.to_charlist(row), {map, r, 0}, fn(char, {map, r, c}) ->
	c = c + 1
	{Map.put(map,{r,c}, (char-?0)), r, c}
      end)
    end)
  end


  ## Some sample maps to use for debugging.
  
  def small() do
"24134323113
32154535356
32552456542"
end
  

  def another() do
"111111111111
999999999991
999999999991
999999999991
999999999991"
  end
  

  def sample() do
"2413432311323
3215453535623
3255245654254
3446585845452
4546657867536
1438598798454
4457876987766
3637877979653
4654967986887
4564679986453
1224686865563
2546548887735
4322674655533"
  end
  



end
