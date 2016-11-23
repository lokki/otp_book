defmodule Coffee do

  ## Inbound events
  
  def tea,          do: send(__MODULE__, {:selection, :tea,         100})
  def espresso,     do: send(__MODULE__, {:selection, :espresso,    150})
  def americano,    do: send(__MODULE__, {:selection, :americane,   100})
  def cappuccino,   do: send(__MODULE__, {:selection, :cappuccino,  150})

  def cup_removed,  do: send(__MODULE__, :cup_removed)
  def pay(coin),    do: send(__MODULE__, {:pay, coin})
  def cancel,       do: send(__MODULE__, :cancel)
  
  ## Server API

  def start_link do
    pid = spawn_link(__MODULE__, :init, [])
    Process.register(pid, __MODULE__)
    {:ok, pid}
  end

  ## Callbacks

  def init do
    HW.reboot()
    home_screen()
    selection()
  end

  ## States

  defp selection do
    receive do
      {:selection, type, price} ->
        pay_screen(price)
        payment(type, price, 0)
      {:pay, coin} ->
        return_change(coin)
        selection()
      _ -> 
        selection()
    end
  end

  defp payment(type, price, paid) do
    receive do
      {:pay, coin} ->
        cond do
          coin + paid >= price ->
            return_change(coin + paid - price)
            prepare_drink(type)
            remove()
          true ->
            total_paid = paid + coin
            more_to_pay = price - total_paid
            pay_screen(more_to_pay)
            payment(type, price, total_paid)
        end
      :cancel ->
        home_screen()
        return_change(paid)
        selection()
      _ ->
        payment(type, price, paid)
    end
  end

  defp remove do
    receive do
      :cup_removed ->
        home_screen()
        selection()
      {:pay, coin} ->
        return_change(coin)
        remove()
      _ ->
        remove()
    end
  end

  ## Helpers

  defp home_screen, do: HW.display "Make Your Selection"

  defp pay_screen(price), do: HW.display "Please pay: #{price}"

  defp return_change(0), do: :ok
  defp return_change(c), do: HW.return_change(c)

  defp prepare_drink(type) do
    HW.display "Preparing your #{IO.inspect type}"
    HW.drop_cup()
    HW.prepare(type)
    HW.display "Remove drink"
  end

end
