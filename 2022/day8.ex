defmodule Day8 do

  ## Day 8 ohh how a I hate matrix operations in Elixir. You simply
  ## don't want to kepp track of i and j indexes and make sure that
  ## you don't fall off a boundry. The solution is not very beautiful
  ## and a lot of unnecessary computations are done.  The row/5 and
  ## column/5 functions are of course so similar that they should be
  ## able to express in one function. I'm happy though that I manged
  ## to use them for both visibility and counting trees visible. 

  
  def input() do
    List.to_tuple(File.stream!("day8.csv") |>
      Enum.map(fn(r) -> List.to_tuple(Enum.map(String.to_charlist(String.trim(r,"\n")),fn(c) -> c-48 end)) end) |>
      Enum.to_list())
  end

  def test() do
    {{3,0,3,7,3},
     {2,5,5,1,2},
     {6,5,3,3,2},
     {3,3,5,4,9},
     {3,5,3,9,0}}
  end
  
  def day8a() do
    array = input()
    n = tuple_size(array) -1 
    m = tuple_size(elem(array,1)) -1
    visible = for i <- 0..n do
      for j <- 0..m do
	visible(i,j, array, n, m)
      end
    end
    ## visible 
    Enum.reduce(visible, 0, fn(r,a) -> Enum.reduce(r, 0, fn(v,a) -> if v, do: a+1, else: a end) + a end)
  end


  ## Is position (i,j) in the array (of size n, m) visible from either edge?
  
  def visible(i,j,array, n, m) do
    ## {row(i, j, array, m, 1, 0) == (m-j), row(i, j, array, 0, -1, 0) == j, column(i, j, array, n, 1, 0) == (n-i), column(i, j, array, 0, -1, 0) == i}
    if row(i, j, array, m, 1, 0) == (m-j) do
      true
    else
      if row(i, j, array, 0, -1, 0) == j do
     	true
      else
     	if column(i, j, array, n, 1, 0) == (n-i) do
     	  true
     	else
     	  column(i, j, array, 0, -1, 0) == i
     	end
      end
    end
  end

  def day8b() do
    array = input()
    n = tuple_size(array) -1 
    m = tuple_size(elem(array,1)) -1
    scores = for i <- 0..n do
      for j <- 0..m do
	score(i,j, array, n, m)
      end
    end
    ## scores
    Enum.reduce(scores, 0, fn(r,a) -> Enum.reduce(r, a, fn(v,a) -> if v > a, do: v, else: a end) end)
  end

  def score(i,j,array, n, m) do
    ## {row(i, j, array, m, 1, 1), row(i, j, array, 0, -1, 1), column(i, j, array, n, 1, 1), column(i, j, array, 0, -1, 1)}
    row(i, j, array, m, 1, 1) * row(i, j, array, 0, -1, 1) * column(i, j, array, n, 1, 1) *  column(i, j, array, 0, -1, 1)
  end



  ## row(i, j, array, m, k, x) : number of trees that are
  ## lower than the tree at (i,j) from row j to the edge. The
  ## direction is given by k (1 or -1) and the edge column is given by
  ## m (0 or length).  The x value determines if we should count the
  ## tree that is blocking the sight (used by the second task).

  def row(_,m, _, m, _, _) do 0 end   ## at the edge
  def row(i,j, array, m, k, x) do
    row(i,j+k, get(array, i, j), array, m+k, k, x)
  end
  
  def row(_, m, _, _, m, _, _) do  0 end
  def row(i, j, height, array, m, k, x) do
    if get(array, i,j) < height do
      row(i, j+k, height, array, m, k, x) + 1
    else
      x
    end
  end

  ## column(i, j, array, m, k, x) : same thing but now column wise.

  def column(n,_, _, n, _, _) do 0 end
  def column(i, j, array, m, k, x) do
    column(i+k, j, get(array, i, j), array, m+k, k, x)
  end
  
  def column(n, _, _, _, n, _, _) do  0 end
  def column(i, j, height, array, m, k, x) do
    if get(array, i,j) < height do
      column(i+k, j, height, array, m, k, x) + 1
    else
      x
    end
  end
  
  def get(array, i, j) do elem(elem(array,i),j) end
    
  
end
