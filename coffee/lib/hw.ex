defmodule HW do

  def display(str), do: IO.puts "Display: #{str}."

  def return_change(payment), do: IO.puts "Machine: Returned #{payment} in change."

  def drop_cup, do: IO.puts "Machine: Dropped Cup."

  def prepare(type), do: IO.puts "Machine: Preparing #{type}..."

  def reboot, do: IO.puts "Machine: Rebooted Hardware."

  def stop, do: IO.puts "Machine: Shutting down..."

end