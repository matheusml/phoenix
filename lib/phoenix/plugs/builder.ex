defmodule Phoenix.Plugs.Builder do
  alias Phoenix.Controller.Connection

  @moduledoc """
  Provides Plug.Builder wrapper that injects local functions to conditionally
  execute plugs based on Controller action of Conn

  ## Examples

      plug :assign_layout, "print"
      plug :only,   {:authenticate, [:create, update]}
      plug :action
      plug :except, {:render, [:edit]}

  """
  defmacro __using__(_) do
    quote do
      use Plug.Builder
      import unquote(__MODULE__)

      def except(conn, {plug, actions}), do: except(conn, {plug, [], actions})
      def except(conn, {plug, opts, actions}) do
        if not(Connection.action_name(conn) in actions) do
          if module_plug?(plug) do
            apply(plug, :call, [conn, opts])
          else
            apply(__MODULE__, plug, [conn, opts])
          end
        else
          conn
        end
      end

      def only(conn, {plug, actions}), do: only(conn, {plug, [], actions})
      def only(conn, {plug, opts, actions}) do
        if Connection.action_name(conn) in actions do
          if module_plug?(plug) do
            apply(plug, :call, [conn, opts])
          else
            apply(__MODULE__, plug, [conn, opts])
          end
        else
          conn
        end
      end
    end
  end

  @doc """
  Returns true if provided atom Plug is a Module

  ## Examples

      iex> Builder.module_plug? Authenticate
      true

      iex> Builder.module_plug? :authenticate
      false

  """
  def module_plug?(plug) do
    match?('Elixir.' ++ _rest, Atom.to_char_list(plug))
  end
end
