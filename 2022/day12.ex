defmodule Day12 do

  ## Day 12 a first algorithm that was a bit more than list
  ## traversal. Recognized as a graph problem the easiest way was to
  ## transform the input into a map using the {row,col} as the key and
  ## the height as the value. One could of course sweep through all
  ## positions and determine the allowed edges but since we will only
  ## use it once this is of little purpose.
  ##
  ## So given a graph we also need a queue to do breath first
  ## search. A vanilla queue works fine even though I suspected that
  ## there would be need for a priority queue in the second part
  ## (which it was not). 
  ##
  ## Searching from S to E is straight forward and as soon as we find
  ## E in the head of the queue we are done. The queue items will
  ## always hold the distance to the node so the final distance is
  ## there. The failure in the beginning was not reading the
  ## description properly and having a solution where one could also
  ## walk diagonally :-(
  ##
  ## The second part was only turning the search around and search
  ## from E to all nodes with the height 'a. We now had to collect the
  ## distances and then pick the shortest.


  def input() do
    File.stream!("day12.csv") |>
      Enum.map(fn(r) -> String.to_charlist(String.trim(r)) end)
  end

  def test() do
    ['Sabqponm',
     'abcryxxl',
     'accszExk',
     'acctuvwj',
     'abdefghi']
  end

  def graph() do
    {graph, _} = input() |>
      Enum.to_list() |>
      Enum.reduce({%{}, 1}, fn (seq, {graph, row}) ->
	{graph, _} = Enum.reduce(seq, {graph, 1}, fn (h, {graph, col}) ->
	{Map.put(graph, {row,col}, h), col+1} end)
	{graph, row+1}
      end)
    {s, _} = List.keyfind(Map.to_list(graph), ?S, 1)    
    {e, _} = List.keyfind(Map.to_list(graph), ?E, 1)
    graph = Map.put(graph, s, ?a)
    graph = Map.put(graph, e, ?z)
    {graph, s, e}
  end

  def task_a() do
    {graph, s, e} = graph()
    queue = Queue.new()
    queue = Queue.add(queue, {s,0})
    found = %{}
    path(queue, e, found, graph)
  end

  def path(queue, e, found, graph) do
    case Queue.remove(queue) do
      {{nxt,d}, queue} ->
	cond do
	  (nxt == e) -> 
            {:distance, d}
	  :nil == Map.get(found, nxt) ->
	    found = Map.put(found, nxt, d)
	    queue = Enum.reduce(path(nxt, graph), queue, fn(nxt, queue) -> Queue.add(queue, {nxt, d+1}) end)
	    path(queue, e, found, graph)
	  true ->
	    path(queue, e, found, graph)
	end
      :empty ->
	:failed
    end
  end


  def task_b() do
    {graph, _, e} = graph()
    queue = Queue.new()
    queue = Queue.add(queue, {e,0})
    found = %{}
    List.foldl(trails(queue, ?a, found, graph), :inf, fn(d, a) -> if d < a do d else a end end)
  end

  def trails(queue, a, found, graph) do
    case Queue.remove(queue) do
      {{nxt,d}, queue} ->
	cond  do
	  a == Map.get(graph, nxt) ->
            [d | trails(queue, a, found, graph)]
	  :nil == Map.get(found, nxt) ->
	    found = Map.put(found, nxt, d)
	    queue = Enum.reduce(trail(nxt, graph), queue, fn(nxt, queue) -> Queue.add(queue, {nxt, d+1}) end)
	    trails(queue, a, found, graph)
	  true ->
	    trails(queue, a, found, graph)
	end
      :empty ->
	[]
    end
  end

  def path({r,c} = pos, graph) do
    h = Map.get(graph, pos)
    Enum.reduce([{r-1,c}, {r,c-1}, {r,c+1}, {r+1,c}],
      [],
      fn(nxt, all) ->
	case Map.get(graph, nxt) do
	  :nil -> all
	  hn -> if hn <= h+1 do
			    [nxt|all]
			   else
			     all
		end
	end
      end)
  end

  def trail({r,c} = pos, graph) do
    h = Map.get(graph, pos)
    Enum.reduce([{r-1,c}, {r, c-1}, {r,c+1}, {r+1,c}],
      [],
      fn(nxt, all) ->
	case Map.get(graph, nxt) do
	  :nil -> all
	  hn -> if hn >= h-1 do
			    [nxt|all]
			   else
			     all
		end
	end
      end)
  end
  

end
