defmodule Phoenix.Plugs.Builder do
  alias Phoenix.Controller.Connection

  @moduledoc """
  Provides Plug.Builder wrapper that injects local `:scoped` plug to conditionally
  execute plugs based on Controller action of Conn

  ## Examples

      plug :assign_layout, "print"
      plug :scoped, {:authenticate, only: [:create, update]}
      plug :action
      plug :scoped, {:render, except: [:edit]}

  """
  defmacro __using__(_) do
    quote do
      use Plug.Builder
      import unquote(__MODULE__)
      @before_compile unquote(__MODULE__)
    end
  end

  @doc """
  Returns the AST for def invoke_plug/3 to invoke any public or private function plug
  or Module plugs

  ## Examples

      defp invoke_plug(:my_private_function, conn, opts) do
        my_private_function(conn, opts)
      end

  """
  def definvoke_plug(plug, :module) do
    quote do
      defp invoke_plug(mod = unquote(plug), conn, opts) do
        mod.call(conn, opts)
      end
    end
  end
  def definvoke_plug(plug, :function) do
    quote do
      defp invoke_plug(unquote(plug), conn, opts) do
        unquote(plug)(conn, opts)
      end
    end
  end

  defmacro __before_compile__(env) do
    invoke_plugs_ast = for plug <- Module.get_attribute(env.module, :plugs) do
      case plug do
        {:scoped, {func, _}}    -> definvoke_plug(func, plug_type(func))
        {:scoped, {func, _, _}} -> definvoke_plug(func, plug_type(func))
        _ -> nil
      end
    end

    quote do
      unquote(invoke_plugs_ast)
      defp invoke_plug(plug, conn, opts), do: :noop
      defp scoped(conn, {plug, actions}), do: scoped(conn, {plug, [], actions})
      defp scoped(conn, {plug, opts, only: actions}) when is_list actions do
        if Connection.action_name(conn) in actions do
          invoke_plug(plug, conn, opts)
        else
          conn
        end
      end
      defp scoped(conn, {plug, opts, except: actions}) when is_list actions do
        if not(Connection.action_name(conn) in actions) do
          invoke_plug(plug, conn, opts)
        else
          conn
        end
      end
      defp scoped(_conn, {_plug, _opts, _}) do
        raise "Expected scoped plug to define `:only` or `:except` actions list"
      end
    end
  end

  @doc """
  Returns the Atom Plug type

  ## Examples

      iex> Builder.plug_type Authenticate
      :module

      iex> Builder.plug_type :authenticate
      :function

  """
  def plug_type(plug) do
    if match?('Elixir.' ++ _rest, Atom.to_char_list(plug)) do
      :module
    else
      :function
    end
  end
end
