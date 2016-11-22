defmodule Frequency do
  ## Client API

  def start, do: Server.start(__MODULE__, [])

  def stop, do: Server.stop(__MODULE__)

  def allocate, do: Server.call(__MODULE__, :allocate)

  def deallocate(frequency), do: Server.call(__MODULE__, {:deallocate, frequency})

  ## Callbacks

  def init(_), do: {get_frequencies, []}

  def terminate(_), do: :ok

  def handle(:allocate, from, frequencies), do: allocate(frequencies, from)
  def handle({:deallocate, freq}, _from, frequencies), do: {deallocate(frequencies, freq), :ok}

  ## Helpers

  defp get_frequencies, do: [10, 11, 12, 13, 14, 15]

  defp allocate({[], _} = state, _), do: {state, {:error, :no_frequency}}
  defp allocate({[freq | rest], allocated}, pid), do: {{rest, [{freq, pid} | allocated]}, {:ok, freq}}

  defp deallocate({available, allocated}, freq) do
    new_allocated = :lists.keydelete(freq, 1, allocated)
    {[freq | available], new_allocated}
  end 

end
