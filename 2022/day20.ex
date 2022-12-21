defmodule Day20 do

  def task_a() do
    sample = input()
    k = length(sample)
    seq = decrypt(sample, sample, k)
    j = Enum.find_index(seq, fn({_,d}) -> d == 0 end)
    n1 = Enum.at(seq, Integer.mod(j+1000,k))
    n2 = Enum.at(seq, Integer.mod(j+2000,k))    
    n3 = Enum.at(seq, Integer.mod(j+3000,k))
    {n1, n2, n3}
  end


  def task_b() do
    sample = input()
    k = length(sample)
    sample = Enum.map(sample, fn ({i,d}) -> {i, d*811589153} end)
    seq = Enum.reduce(1..10, sample, fn(_,smp) -> decrypt(sample, smp, k) end)
    j = Enum.find_index(seq, fn({_,d}) -> d == 0 end)
    {_,n1} = Enum.at(seq, Integer.mod(j+1000,k))
    {_,n2} = Enum.at(seq, Integer.mod(j+2000,k))    
    {_,n3} = Enum.at(seq, Integer.mod(j+3000,k))
    :io.format(" ~w \n", [{n1, n2, n3}])
    n1+n2+n3
  end




  def decrypt([], sample, _) do sample end
  def decrypt([{n,i}|rest], sample, k) do
    ## :io.format(" seq = ~w\n", [sample])
    shuffeld = fax(shuffel(sample, 0, {n,i}, k))
    decrypt(rest, shuffeld, k)
  end  

  def shuffel([{n,i}|rest], j, {n,i}, k) do
    d = dist(j, i, k)
    cond do
      d == 0 ->
	{:done, [{n,i}|rest]}
      d < 0 ->
	{:fix, d, {n,i}, rest}
      d > 0 ->
	{:done, frw(rest, d, {n,i})}
    end
  end
  def shuffel([pos|rest], j, itm, k) do
    fix(shuffel(rest, j+1, itm, k), pos)
  end

  def dist(j, i, k) do
    m = Integer.mod(j+i,k-1)   ##
    d = m - j
    ## :io.format(" j = ~w, m = ~w, d = ~w\n", [j, m, d])
    d
  end

  def fax({:done, seq}) do seq end
  def fax({:fix, 0, itm, seq}) do [itm|seq] end  
  
  def frw(rest, 0, itm) do [itm|rest] end 
  def frw([pos|rest], d, itm) do [pos| frw(rest, d-1, itm)] end 
  
  def fix({:done, done}, pos) do {:done, [pos|done]} end
  def fix({:fix, 0, itm, rest}, pos) do {:done, [pos, itm|rest]} end
  def fix({:fix, d, itm, rest}, pos) do {:fix, d+1, itm, [pos|rest]} end
  
  def input() do
    seq = File.stream!("day20.csv") |>
      Stream.map(fn(r) -> {nr,_} = Integer.parse(String.trim(r)); nr end) |>
      Enum.to_list()
    Enum.zip(0..(length(seq)-1), seq)
  end
  

  def sample() do
    [{0,1},{1,2},{2,-3},{3,3},{4,-2},{5,0},{6,4}]
  end
  

end
