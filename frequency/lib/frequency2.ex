defmodule Frequency2 do
  use GenServer

  ## Client API

  def start, do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  def stop, do: GenServer.cast(__MODULE__, :stop)

  def allocate, do: GenServer.call(__MODULE__, :allocate)

  def deallocate(frequency), do: GenServer.cast(__MODULE__, {:deallocate, frequency})

  ## Callbacks

  def init(_), do: {ok, {get_frequencies, []}}

  def terminate(_, _), do: :ok

  def handle_call(:allocate, {from, _ref}, state) do
    {new_state, response} = allocate(frequencies, from)
    {:reply, response, new_state}
  end

  def handle_cast({:deallocate, freq}, frequencies) do
    new_state = deallocate(frequencies, freq)
    {:noreply, new_state}
  end
  def handle_cast(:stop, frequencies), do: {:stop, :normal, frequencies}

  ## Helpers

  defp get_frequencies, do: [10, 11, 12, 13, 14, 15]

  defp allocate({[], _} = state, _), do: {state, {:error, :no_frequency}}
  defp allocate({[freq | rest], allocated}, pid), do: {{rest, [{freq, pid} | allocated]}, {:ok, freq}}

  defp deallocate({available, allocated}, freq) do
    new_allocated = :lists.keydelete(freq, 1, allocated)
    {[freq | available], new_allocated}
  end 

end
