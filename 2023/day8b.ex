defmodule Day8b do

  ## Solving this puzzle by simply running all thread simultaneous was
  ## of course a dead end - or more precisely a computation that would
  ## take a very long time.
  ##
  ## The insight is of course that the different threads will
  ## inevitably end up in a loop since we only have a finite set of
  ## nodes in the graph. The solution is then to figure out the length
  ## of each loop and then come up with the lowest possible common
  ## path length.
  ##
  ## The solution below - happens to - work bu it is in fact only
  ## luck.
  ##
  ## For each thread, start in the original position and iterate the
  ## sequence of directions until a terminal state is found. Then
  ## iterate the sequence again until we land in a terminal state
  ## again (we assume that this is the same terminal state which it
  ## might not be).
  ##
  ## Now we have two number: the number of iterations to reach the
  ## terminal state and the size of the loop. The result for the
  ## different threads were as follows:
  ##
  ##    [{59, 59}, {73, 73}, {47, 47}, {53, 53}, {79, 79}, {71, 71}]
  ##
  ## This is strange, in all threads we first go from the original
  ## state to the first terminal state in the same number of steps
  ## that the loop is (same for sample). This does not have to be the
  ## case ...!
  ##
  ## We are also lucky that all loops are prime numbers so finding the
  ## lowest common length is simply multiplying the numbers. This is
  ## of course something that dis not have to be so we're doing a
  ## short cut for this particular problem.
  ##
  ## Now a general solution would have to take several things into
  ## account. First of all we could have two terminal nodes in a loop.
  ##
  ##     start - 1 ->  t1 -> 3 -> t2 -> 2 -> t1 -> ....
  ##
  ## The "loop" has the same length for both (5 in the example) but we
  ## reach these states more often:
  ##
  ##   start - 1 -> t1 - 5 -> t1 - 5 -> t1
  ##   start - 4 -> t2 - 5 -> t3 - 5 -> t2
  ##
  ## This could of course be extended to any number of terminal states.
  ##
  ## The general solution must also be open to the fact that the
  ## initial path to reach the first terminal position need not be the
  ## same as the length of the loop. As in the example above we could
  ## have one step to reach the first terminal state. The common
  ## length should then not be a multiple of the loop but initial path
  ## plus a multiple of the loop.
  ##
  ## Since we also have two terminal states in the loop we have the
  ## following two sequences to consider:
  ##
  ##   1 + k*5  i.e. 1, 6, 11, 16, ....
  ##   4 + k*5  i.e. 4, 9, 14, 19, ....
  ##
  ## This is not handled in the "solution" below.
  
  def test() do
    {:puzzle, dir, nodes} = parse(sample())
    starting = Enum.map(Enum.filter(nodes, fn({_, {type, _, _}}) -> (type == :starting) end), fn({node, _}) -> node end)
    nodes = Map.new(nodes)
    loops = Enum.map(starting,  fn(start) -> loop1(start, dir, nodes, 0) end)
    ##  Assert that the initial path is the same length as the loop and that there are no terminal stats inside the loop.
    List.foldl(loops, 1, fn({l, {l, []}}, a) -> l*a end) * length(dir)
  end

  def task() do
    {:puzzle, dir, nodes} = parse(String.trim(File.read!("day8.csv")))
    starting = Enum.map(Enum.filter(nodes, fn({_, {type, _, _}}) -> (type == :starting) end), fn({node, _}) -> node end)
    nodes = Map.new(nodes)
    loops = Enum.map(starting,  fn(start) -> loop1(start, dir, nodes, 0) end)
    ##  Assert that the initial path is the same length as the loop and that there are no terminal stats inside the loop.
    List.foldl(loops, 1, fn({l, {l, []}}, a) -> l*a end) * length(dir)
  end  
  

  def loop1(pos, dir, nodes,n) do
    case nodes[pos] do
      {:terminal, _,_} ->
	{n, loop2(search(dir, pos, nodes), pos, [], dir, nodes, 1)}
      _ ->
	loop1(search(dir, pos, nodes), dir, nodes, n+1)
    end
  end

  def loop2(pos, term, all, dir, nodes, n) do
      if (pos == term)  do
	{n, all}
      else
	case nodes[pos] do
	  {:terminal, _,_} ->	  
	    loop2(search(dir, pos, nodes), term, [n|all], dir, nodes, n+1)
	  _ ->
	    loop2(search(dir, pos, nodes), term, all, dir, nodes, n+1)
	end
    end
  end
	
  
  

  def search(pos, dir, nodes, n) do
     #:io.format("search ~w: ~w~n", [n, pos])
     if ( Enum.all?(pos, fn(node) -> case nodes[node] do
				 {:terminal, _, _} -> true
				 _ -> false
			       end
	 end)) do
       n
     else
       search(Enum.map(pos, fn(node) -> search(dir, node, nodes) end), dir, nodes, n+1)
     end
  end

  
  def search([], pos, _) do pos end
  def search([d|rest], pos, nodes) do
    {_, left,right} = nodes[pos]
    case d do
      :left -> search(rest, left, nodes)
      :right -> search(rest, right, nodes)
    end
  end


  

  def parse(input) do
    [dir, _ | rows] =  String.split(input, "\n")
    dir = Enum.map(String.to_charlist(dir), fn(char) -> case char do
						          ?L -> :left
						          ?R -> :right
					                end
    end)
    rows = Enum.map(rows, fn(row) ->
      <<org::binary-size(3), " ", "=", " ", "(", left::binary-size(3), ","," ", right::binary-size(3), ")">> = row
      case org do
	<<_,_,?A>> ->
	  {String.to_atom(org),  {:starting, String.to_atom(left), String.to_atom(right)}}
	<<_,_,?Z>> ->
	  {String.to_atom(org),  {:terminal, String.to_atom(left), String.to_atom(right)}}
	_ ->
	  {String.to_atom(org),  {:regular, String.to_atom(left), String.to_atom(right)}}
      end
    end)
    {:puzzle, dir, rows}
  end
  
      
    
      


  def sample() do
"LR

11A = (11B, XXX)
11B = (XXX, 11Z)
11Z = (11B, XXX)
22A = (22B, XXX)
22B = (22C, 22C)
22C = (22Z, 22Z)
22Z = (22B, 22B)
XXX = (XXX, XXX)"
  end
  
end
