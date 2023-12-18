defmodule Day12 do

  ##  Dynamic programming to our rescue :-)
  ##
  ##  The first task was rather simple since I took a search approach
  ##  and simply tested all possible scenarios. We read the
  ##  specification spring by spring and if we see:
  ##
  ##      a working spring proceed 
  ##
  ##      a damaged spring, make sure we have a sequence of damaged
  ##      springs followed by a operational and then proceed
  ##
  ##      a unknown spring, try two scenarios; either the spring is
  ##      damaged and then do as above or it is operational.
  ##
  ##   This search prcedure also worked fine for the real task.
  ##
  ##  The second task was of course five times larger and since teh
  ##  search approach is O(2^n) it was doomed. To our recue comes
  ##  dynamic programming and it worked right out of the box (clocked
  ##  in as solver 2214 :-) 
  ##
  ##  One thing worried me and this was the size of the keys since I
  ##  used the rest of the specification as the key. This did not
  ##  cause and problems.

  
  def test_a() do
    String.split(sample(), "\n") |>
      Enum.map(fn(row) -> parse(row) end) |>
      Enum.map(fn(spec) -> solve(spec) end) |>
      Enum.sum()
  end

  def task_a() do
    File.stream!("day12.csv") |>
      Enum.map(fn(row) -> parse(row) end) |>
      Enum.map(fn(spec) -> solve(spec) end) |>
      Enum.sum()
  end  

  def test_b() do
    String.split(sample(), "\n") |>
      Enum.map(fn(row) -> parse(row) end) |>
      Enum.map(fn(spec) -> expand(spec) end) |>
      Enum.map(fn(spec) -> dynamic(spec) end) |>
      Enum.sum()    
  end

  def task_b() do
    File.stream!("day12.csv") |>
      Enum.map(fn(row) -> parse(row) end) |>
      Enum.map(fn(spec) -> expand(spec) end) |>
      Enum.map(fn(spec) -> dynamic(spec) end) |>
      Enum.sum()
  end  

 
  def expand({:spec, springs, seq}) do
    {:spec,
     springs ++ [:unk] ++ springs ++ [:unk] ++ springs ++ [:unk] ++ springs ++ [:unk] ++ springs,
     seq ++ seq ++ seq ++ seq ++ seq}
  end

  def dynamic({:spec, springs, seq}) do
    {n, _} = dynamic(springs, seq, %{})
    n
  end

  def solve({:spec, springs, seq}) do
    solve(springs, seq)
  end
    

  ## The dynamic solver.
  
  def dynamic(springs, seq, mem) do
    case Map.get(mem, {:spec, springs, seq}) do
      :nil ->
	{n, mem} = solve(springs, seq, mem)
	{n, Map.put(mem, {:spec, springs, seq}, n)}
      n ->
	{n, mem}
    end
  end

  ## This is the solver with the added memory and recurive call to
  ## dynamic.
  
  def solve([], [], mem) do {1, mem} end
  def solve([:dam|springs], [ok|seq], mem) do
    case damaged(springs, ok-1) do
      {:ok, springs} ->
	dynamic(springs, seq, mem)
      :no ->
	{0, mem}
    end
  end
  def solve([:opr|springs], seq, mem) do
    dynamic(springs, seq, mem)
  end
  def solve([:unk|springs], [ok|rest]=seq, mem) do
    {n,mem} = dynamic(springs, seq, mem)
    case damaged(springs, ok-1) do
      {:ok, springs} ->
	{alt, mem} = dynamic(springs, rest, mem)
	{alt+n, mem}
      :no ->
	{n,mem}
    end
  end
  def solve([:unk|springs], [], mem) do
    dynamic(springs, [], mem)
  end
  def solve(_, _, mem) do {0, mem} end


  ## This is the solver for the first task
  
  def solve([], []) do 1 end
  def solve([:dam|springs], [ok|seq]) do
    case damaged(springs, ok-1) do
      {:ok, springs} ->
	solve(springs, seq)
      :no ->
	0
    end
  end
  def solve([:opr|springs], seq) do
    solve(springs, seq)
  end
  def solve([:unk|springs], [ok|rest]=seq) do
    n = solve(springs, seq)
    case damaged(springs, ok-1) do
      {:ok, springs} ->
	solve(springs, rest) + n
      :no ->
	n
    end
  end
  def solve([:unk|springs], []) do
    solve(springs, [])
  end
  def solve(_, _) do 0 end

  ## Make sure that we have n number of damaged springs - followed by
  ## a spring that is operational!  This means that we might turn an
  ## unknown pring to operational before returning the rest of the
  ## springs.

  def damaged([], 0) do {:ok, []} end
  def damaged([:opr|_]=springs, 0) do {:ok, springs} end
  def damaged([:unk|rest], 0) do {:ok, [:opr|rest]} end  
  def damaged([:unk|rest], n) when n > 0 do
    damaged(rest, n-1)
  end
  def damaged([:dam|rest], n) when n > 0 do
    damaged(rest, n-1)
  end
  
  def damaged(_, _) do :no end


  ## Simply turn rows into lists of symbols and integers. 
  
  def parse(row) do
    [springs, seq] = String.split(row, " ")
    springs = Enum.map(String.to_charlist(springs), fn(char) ->
      case char do
	?. -> :opr
	?# -> :dam
	?? -> :unk
      end
    end)
    seq = Enum.map(String.split(seq, ","), fn(nr) ->
      elem(Integer.parse(nr),0)
    end)
    {:spec, springs, seq}
  end
  
  



  def sample() do
"???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1"
  end
  
    

end
