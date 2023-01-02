defmodule Day24 do

  defstruct [:next]

  
  defimpl Enumerable do

    def count(_) do  {:error, __MODULE__}  end
    def member?(_, _) do {:error, __MODULE__}  end
    def slice(_) do {:error, __MODULE__} end

    def reduce(_,     {:halt, acc}, _fun),   do: {:halted, acc}
    def reduce(nums,  {:suspend, acc}, fun), do: {:suspended, acc, fn(cmd) -> reduce(nums, cmd, fun) end}
    def reduce(nums,  {:cont, acc}, fun) do
      case Day24.next(nums) do
	{n, next} ->
	  reduce(next, fun.(n,acc), fun)
	:done ->
	  {:done, acc}
      end
    end      

  end

  def nums(n) do
    %Day24{next: fn () -> nrs(n)  end}
  end
  
  def next(%Day24{next: f}) do 
    case f.() do 
      {n, f} ->
	{n, %Day24{next: f}}
      :done ->
	:done
    end
  end
  
  def nrs(0) do :done end
  def nrs(n) do
    {expand(14, n, []),  fn () -> nrs(n-1)  end}
  end  

  def expand(0, _, done) do done end
  def expand(k, 0, sofar) do expand(k-1, 0, [0|sofar]) end  
  def expand(k, n, sofar) do expand(k-1, div(n,10), [rem(n,10)|sofar]) end    

  def contract([], n) do n end
  def contract([d|t], n) do contract(t, n*10 + d) end  
    
  def crunch(n) do
    case Enum.find(nums(n), fn(nr) -> monad(nr) == 1 end) do
      nil -> :no
      nrs -> contract(nrs,0)
    end
  end
  
  def test() do
    seq = [1,3,5,7,9,2,4,6,8,9,9,9,9,9]
    monad(seq)
  end

  def eql(a,b) do if a == b do 1 else 0 end  end
  def nql(a,b) do if a != b do 1 else 0 end  end  
  
  def trans(z, i, k, j, l) do
    x = rem(z,26) + j      # 13, 11, 15, ,....
    z = div(z,k)           # 1  eller 26
    if x != i do
      :io.format("~w ~w not same \n", [i, x])
      z = (z*26) + i + l       # input + 3,12,9,12, ....
      :io.format("z = ~w \n", [z])
      z
    else
      :io.format("z = ~w \n", [z])
      z
    end
  end

  def monad([i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11,i12,i13,i14]) do
    z = trans( 0,  i1,   1,  13,  3)
    z = trans( z,  i2,   1,  11, 12)
    z = trans( z,  i3,   1,  15,  9)
    z = trans( z,  i4,  26,  -6, 12)
    z = trans( z,  i5,   1,  15,  2)
    z = trans( z,  i6,  26,  -8,  1)
    z = trans( z,  i7,  26,  -4,  1)
    z = trans( z,  i8,   1,  15, 13)
    z = trans( z,  i9,   1,  10,  1)
    z = trans( z, i10,   1,  11,  6)
    z = trans( z, i11,  26, -11,  0)
    z = trans( z, i12,  26,   0, 11)
    z = trans( z, i13,  26,  -8, 10)
    z = trans( z, i14,  26,  -7,  3)
    z
  end
  

end
