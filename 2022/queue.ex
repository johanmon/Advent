defmodule Queue do


  def new() do
    {[],[]}
  end

  def new(init) do
    {init,[]}
  end  

  def add({first,rest}, itm) do
    {first, [itm|rest]}
  end


  def remove({[],[]}) do
    :empty
  end
  def remove({[],rest}) do
    remove({Enum.reverse(rest), []})
  end    
  def remove({[itm|first],rest}) do
    {itm, {first, rest}}
  end  

  
end
