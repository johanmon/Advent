defmodule Day7 do
  ## Day 7, fairly simple but I'm exploiting the fact that the
  ## traversal of the tree is regular depth first i.e. you enter a
  ## directory, do a "ls", explore all of its sub-directories and then
  ## return with "cd ..". This need not be the case but it worked.
  ##
  ## The parsing could of course be ignored but it makes it easier to
  ## do the size calculations. I thought the file extension would be
  ## important in the second task so this is why this is also
  ## extracted.

  def input() do
    File.stream!("day7.csv") |>
      Stream.map( fn (r) ->
	parse7(r)
      end) |>
      Enum.to_list()
  end
  
  def task_a() do
    seq = input()
    dir_sum(dir_sizes(seq), 0)
  end

  def task_b() do
    seq = input()
    [{"/", size} | sorted] = Enum.sort(dir_sizes(seq), fn ({_,x}, {_,y}) ->  x > y end)
    dir_delete(sorted, size, (size - 40_000_000))
  end

  def dir_delete([{_, size}| rest], _sofar, limit) when size >= limit do
    dir_delete(rest, size, limit)
  end
  def dir_delete(_, sofar, _) do sofar  end  

  
  def dir_sum([], sum) do sum end
  def dir_sum([{_, size}|rest], sum) when size <= 100000 do
    dir_sum(rest, sum+size)
  end  
  def dir_sum([_|rest], sum) do
    dir_sum(rest, sum)
  end    
  
  def dir_sizes([{:cd, "/"}, :ls | rest]) do
    {size, [], sizes} = dir_sizes(rest, 0, [])
    [{"/", size} | sizes]
  end

  def dir_sizes([], size, sizes) do {size, [], sizes} end
  def dir_sizes([{:cd, ".."} |rest], size, sizes) do  {size, rest, sizes} end

  def dir_sizes([{:file ,sz, _, _}|rest], size, sizes) do
    dir_sizes(rest, size + sz, sizes)
  end
  def dir_sizes([{:dir, _}|rest], size, sizes) do
    dir_sizes(rest, size, sizes)
  end  
  def dir_sizes([{:cd, dir}, :ls |rest], size, sizes) do
    {sz, rest, sizes} = dir_sizes(rest, 0, sizes)
    dir_sizes(rest, size+sz, [{dir, sz}|sizes])
  end  


  def parse7(<<?$, 32, ?l, ?s, _::binary>>) do :ls end
  def parse7(<<?$, 32, ?c, ?d, 32, dir::binary>>) do {:cd, String.trim(dir,"\n")} end
  def parse7(r) do
    case String.split(r, [" ", "."]) do
      ["dir", name] ->
	{:dir, String.trim(name)}
      [size, name] ->
	{size, _} = Integer.parse(size)
	{:file, size, String.trim(name, "\n"), ""}
      [size, name, ext] ->
	{size, _} = Integer.parse(size)
	{:file, size, name, String.trim(ext, "\n")}
    end
  end
end
