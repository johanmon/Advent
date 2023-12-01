defmodule Day10 do

  ## Day 10, this task was surprisibly simple to code but harder to
  ## understand what was going on. The first part was fine all though
  ## it was strange how the register was updated after the second
  ## clock cycle. The second part was ... hello, what is going on...?
  ## It did turn out to be a very simple transformation.

  ## The solution points to the downside of representing things as
  ## lists. Both sultions would benefit from representing the sequence
  ## of register values in an array.
  ##
  ## If the task includes reading a file it does not really matter in
  ## this small example but as the benchmark show the second task can
  ## be improved with a factor ten when changing to a tuple
  ## representation. The improvement will only grow as the data set
  ## becomes larger since we are changing the algorithm from O(n²)
  ## to  O(n). 
  ##
  ## An alternative is to only work with the list and keep track of
  ## the row and column. This might even be faster... hmm?
  ##
  ## Take a look at the crt_hmm_l/1 benchmark. It outperforms the tuple
  ## benchmark.  
  ##
  ## To avoid doing the reverse operations we can use a List.foldr/3
  ## function (stack is only 240 deep) and now we can do it even
  ## faster :-)

  def input() do
    File.stream!("day10.csv") |>
      Enum.map(fn (r) ->
	case String.split(r, [" "]) do
	  [cmd, n] ->
	    {n, _} = Integer.parse(n)
	    {String.to_atom(cmd), n}
	  [cmd] ->
	    String.to_atom(String.trim(cmd))
	end
      end)
  end

  def run(seq) do
    Enum.reduce(seq, [1], fn(cmd, [n|rest]) ->
      case cmd do
	{:addx, x} -> [n+x,n,n|rest]
	:noop -> [n,n|rest]
      end
    end) |>
      Enum.drop(1) |>
      Enum.reverse()
    
  end
  
  def task_a() do
    seq = run(input())
    for i <- 0..5 do Enum.at(seq, 19+(i*40)) * (20+(i*40)) end
  end

  def task_b() do
    seq = run(input())
    for r <- 0..5 do
      for c <- 0..39 do
	pos = Enum.at(seq, r*40 + c)
	if (pos == c-1 or pos == c or pos == c+1) do
	  ?\#
	else
	  ?\ 
	end
      end
    end
  end

  def bench() do
    lst = run(input())
    {t1, _} = :timer.tc(fn() -> crt_lists(lst) end)
    {t2, _} = :timer.tc(fn() -> crt_tuple(List.to_tuple(lst)) end)
    {t3, _} = :timer.tc(fn() -> crt_hmm_l(lst) end)
    {t4, _} = :timer.tc(fn() -> crt_hmm_r(lst) end)  
    {t1,t2,t3,t4}
  end

  def crt_lists(seq) do
    for r <- 0..5 do
      for c <- 0..39 do
	p = Enum.at(seq, r*40 + c)
	if (c == p-1  or c == p  or c == p+1) do
	  ?\#
	else
	  ?\ 
	end
      end
    end
  end

  def crt_tuple(seq) do
    for r <- 0..5 do
      for c <- 0..39 do
	p = elem(seq, r*40 + c)
	if (c == p-1  or c == p  or c == p+1) do
	  ?\#
	else
	  ?\ 
	end
      end
    end
  end

  def crt_hmm_l(seq) do
    {_, rows, _} = List.foldl(seq, {[],[],0}, fn (p,{row,rows,c}) ->
      mrk = if (c == p-1  or c == p  or c == p+1) do
	  ?\#
	else
	  ?\ 
	end
      if (c == 39) do
	  {[],[Enum.reverse([mrk|row])|rows], 0}
      else
	{[mrk |row],rows, c+1}
      end
    end)
    Enum.reverse(rows)
  end

  def crt_hmm_r(seq) do
    {_, rows, _} = List.foldr(seq, {[],[],39}, fn (p,{row,rows,c}) ->
      mrk =  if (c == p-1  or c == p  or c == p+1) do
	  ?\#
	else
	  ?\ 
	end
      if (c == 0) do
	  {[],[[mrk|row]|rows], 39}
      else
	{[mrk |row],rows, c-1}
      end
    end)
    rows
  end  

  
  
	
  def test() do
    [{:addx, 15},
     {:addx, -11},
     {:addx, 6},
     {:addx, -3},
     {:addx, 5},
     {:addx, -1},
     {:addx, -8},
     {:addx, 13},
     {:addx, 4},
     :noop,
     {:addx, -1},
     {:addx, 5},
     {:addx, -1},
     {:addx, 5},
     {:addx, -1},
     {:addx, 5},
     {:addx, -1},
     {:addx, 5},
     {:addx, -1},
     {:addx, -35},
     {:addx, 1},
     {:addx, 24},
     {:addx, -19},
     {:addx, 1},
     {:addx, 16},
     {:addx, -11},
     :noop,
     :noop,
     {:addx, 21},
     {:addx, -15},
     :noop,
     :noop,
     {:addx, -3},
     {:addx, 9},
     {:addx, 1},
     {:addx, -3},
     {:addx, 8},
     {:addx, 1},
     {:addx, 5},
     :noop,
     :noop,
     :noop,
     :noop,
     :noop,
     {:addx, -36},
     :noop,
     {:addx, 1},
     {:addx, 7},
     :noop,
     :noop,
     :noop,
     {:addx, 2},
     {:addx, 6},
     :noop,
     :noop,
     :noop,
     :noop,
     :noop,
     {:addx, 1},
     :noop,
     :noop,
     {:addx, 7},
     {:addx, 1},
     :noop,
     {:addx, -13},
     {:addx, 13},
     {:addx, 7},
     :noop,
     {:addx, 1},
     {:addx, -33},
     :noop,
     :noop,
     :noop,
     {:addx, 2},
     :noop,
     :noop,
     :noop,
     {:addx, 8},
     :noop,
     {:addx, -1},
     {:addx, 2},
     {:addx, 1},
     :noop,
     {:addx, 17},
     {:addx, -9},
     {:addx, 1},
     {:addx, 1},
     {:addx, -3},
     {:addx, 11},
     :noop,
     :noop,
     {:addx, 1},
     :noop,
     {:addx, 1},
     :noop,
     :noop,
     {:addx, -13},
     {:addx, -19},
     {:addx, 1},
     {:addx, 3},
     {:addx, 26},
     {:addx, -30},
     {:addx, 12},
     {:addx, -1},
     {:addx, 3},
     {:addx, 1},
     :noop,
     :noop,
     :noop,
     {:addx, -9},
     {:addx, 18},
     {:addx, 1},
     {:addx, 2},
     :noop,
     :noop,
     {:addx, 9},
     :noop,
     :noop,
     :noop,
     {:addx, -1},
     {:addx, 2},
     {:addx, -37},
     {:addx, 1},
     {:addx, 3},
     :noop,
     {:addx, 15},
     {:addx, -21},
     {:addx, 22},
     {:addx, -6},
     {:addx, 1},
     :noop,
     {:addx, 2},
     {:addx, 1},
     :noop,
     {:addx, -10},
     :noop,
     :noop,
     {:addx, 20},
     {:addx, 1},
     {:addx, 2},
     {:addx, 2},
     {:addx, -6},
     {:addx, -11},
     :noop,
     :noop,
     :noop]
  end

end
