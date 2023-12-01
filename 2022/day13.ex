defmodule Day13 do

  ## Day 13 - I'm not parsing something that is almost perfect to
  ## start with. A quick Emacs keyboard-macro does the trick in
  ## no-time.
  ##
  ## The task was rather simple, the order/2 function was almost
  ## correct from the beginning and would have been perfect if I only
  ## read the instructions :-)
  ##
  ## In the second task I simply ordered the sequences but this is not
  ## necessary. One could simply sweep through all packets and count
  ## how many packages are smaller then the two dividers. Sorting is
  ## though very efficient and it is surprising how fast it is even
  ## when comparing complex data structures.
  ##
  ## The task_c/0 function shows the alternative and it is indeed
  ## three times faster.

  ## ok, I wrote input/0 function that parses the .csv file using the
  ## Erlang parser.

  def input() do
    File.stream!("day13.csv") |>
      Stream.chunk_every(3) |>
      Enum.map(fn([left, right | _]) -> {parse(left), parse(right)} end)  |>
      Enum.reverse()
  end

  def parse(str) do
    {:ok,tokens,_} = :erl_scan.string(String.to_charlist(String.trim(str)) ++ [?.])
    {:ok, abstract} = :erl_parse.parse_exprs(tokens)
    {:value, value, []} = :erl_eval.exprs(abstract, :erl_eval.new_bindings())
    value
  end

  def test() do
  [{[1,1,3,1,1],   [1,1,5,1,1]},

   {[[1],[2,3,4]], [[1],4]},

   {[9],   [[8,7,6]]},

   {[[4,4],4,4],   [[4,4],4,4,4]},

   {[7,7,7,7],   [7,7,7]},

   {[],   [3]},

   {[[[]]], [[]]},

   {[1,[2,[3,[4,[5,6,7]]]],8,9],
    [1,[2,[3,[4,[5,6,0]]]],8,9]}

   ]
  end
  
  def task_a() do
    Enum.reduce(input(), {1,0} , fn({l,r}, {i, sum}) ->
      case order(l,r) do
	true -> {i+1, sum+i}
	false -> {i+1, sum}
	## :eq -> true
      end
    end)
  end

  def task_b() do
    all = List.foldr([{[[2]],[[6]]} | input()], [], fn({l,r}, acc) -> [l,r|acc] end)
    sorted = Enum.sort(all, fn(x,y) -> order(x,y) end)
    i = 1 + Enum.find_index(sorted, fn(x) -> x == [[2]] end)
    j = 1 + Enum.find_index(sorted, fn(x) -> x == [[6]] end)
    {i,j,i*j}
  end

  def task_c() do
    all = List.foldr(input(), [], fn({l,r}, acc) -> [l,r|acc] end)
    i = Enum.reduce(all, 1, fn(x, a) -> if order(x,[[2]]) do a + 1 else a end end)
    j = Enum.reduce(all, 2, fn(x, a) -> if order(x,[[6]]) do a + 1 else a end end)
    {i,j,i*j}
  end
  

  def order([],[]) do :eq end
  def order([],[_|_]) do true end  
  def order([_|_],[]) do false end  
  def order([l|lt], [r|rt]) do
    case order(l,r) do
      :eq -> order(lt,rt)
      res -> res
    end
  end
  def order(left, right) when is_list(left) and is_number(right) do
    order(left, [right])
  end
  def order(left, right) when is_number(left) and is_list(right) do
    order([left], right)
  end  
  def order(left, right) when  is_number(left) and is_number(right) do
    cond do
      left < right -> true
      left > right -> false
      true -> :eq
    end
  end

  
end

