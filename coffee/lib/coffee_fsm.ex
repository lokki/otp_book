defmodule CoffeeFSM do

  @timeout 10000

  ## Raw gen_fsm

  ## Inbound events
  
  def tea,          do: :gen_fsm.send_event(__MODULE__, {:selection, :tea,         100})
  def espresso,     do: :gen_fsm.send_event(__MODULE__, {:selection, :espresso,    150})
  def americano,    do: :gen_fsm.send_event(__MODULE__, {:selection, :americano,   100})
  def cappuccino,   do: :gen_fsm.send_event(__MODULE__, {:selection, :cappuccino,  150})

  def cup_removed,  do: :gen_fsm.send_event(__MODULE__, :cup_removed)
  def pay(coin),    do: :gen_fsm.send_event(__MODULE__, {:pay, coin})
  def cancel,       do: :gen_fsm.send_event(__MODULE__, :cancel)
  
  ## Server API

  def start_link do
    :gen_fsm.start_link({:local, __MODULE__}, __MODULE__, [], [])
  end

  ## Callbacks

  def init(_) do
    HW.reboot()
    home_screen()
    Process.flag(:trap_exit, true)
    {:ok, :selection, :none}
  end

  ## States

  def selection({:selection, type, price}, _) do
    pay_screen(price)
    {:next_state, :payment, {type, price, 0}, @timeout}
  end

  def selection({:pay, coin}, _) do
    return_change(coin)
    {:next_state, :selection, :none}
  end

  def selection(_, _), do: 
    {:next_state, :selection, :none}

  def payment({:pay, coin}, {type, price, paid}) when coin + paid >= price do
    return_change(coin + paid - price)
    prepare_drink(type)
    {:next_state, :remove, :none}
  end

  def payment({:pay, coin}, {type, price, paid}) when coin + paid < price do
    total_paid = paid + coin
    more_to_pay = price - total_paid
    pay_screen(more_to_pay)
    {:next_state, :payment, {type, price, total_paid}, @timeout}
  end

  def payment(:cancel, {_, _, paid}) do
    home_screen()
    return_change(paid)
    {:next_state, :selection, :none}
  end

  def payment(:timeout, {_, _, paid}) do
    home_screen()
    return_change(paid)
    {:next_state, :selection, :none}
  end

  def payment(_, state), do: 
    {:next_state, :payment, state}

  def remove(:cup_removed, _) do
    home_screen()
    {:next_state, :selection, :none}
  end

  def remove({:pay, coin}, _) do
    return_change(coin)
    {:next_state, :remove, :none}
  end

  def remove(_, _) do
    {:next_state, :remove, :none}
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
