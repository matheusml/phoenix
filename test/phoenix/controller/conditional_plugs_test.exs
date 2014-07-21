defmodule Phoenix.Controller.ConditionalPlugsTest do
  use ExUnit.Case
  use PlugHelper


  defmodule OnlyController do
    use Phoenix.Controller

    plug :only, {:pub_func_plug, [],     [:index]}
    plug :only, {:pub_func_plug_no_opts, [:index]}
    plug :only, {:priv_func_plug, [],    [:index]}
    plug :action

    def index(conn, _) do
      conn
    end

    def show(conn, _) do
      conn
    end

    def pub_func_plug(conn, _) do
      assign(conn, :pub_func_plug, true)
    end

    def pub_func_plug_no_opts(conn, _) do
      assign(conn, :pub_func_plug_no_opts, true)
    end

    def priv_func_plug(conn, _) do
      assign(conn, :priv_func_plug, true)
    end
  end

  defmodule ExceptController do
    use Phoenix.Controller

    plug :except, {:pub_func_plug, [],     [:index]}
    plug :except, {:pub_func_plug_no_opts, [:index]}
    plug :except, {:priv_func_plug, [],    [:index]}
    plug :action

    def index(conn, _) do
      conn
    end

    def show(conn, _) do
      conn
    end

    def pub_func_plug(conn, _) do
      assign(conn, :pub_func_plug, true)
    end

    def pub_func_plug_no_opts(conn, _) do
      assign(conn, :pub_func_plug_no_opts, true)
    end

    def priv_func_plug(conn, _) do
      assign(conn, :priv_func_plug, true)
    end
  end

  defmodule Router do
    use Phoenix.Router
    get "/only/only_with_public_func", OnlyController, :index
    get "/only/no_conditionals", OnlyController, :show

    get "/except/index", ExceptController, :index
    get "/except/show", ExceptController, :show

  end

  test "only/2 with options allows function plug to be scoped to specific actions" do
    conn = simulate_request(Router, :get, "/only/only_with_public_func")
    assert conn.assigns[:pub_func_plug]
    assert conn.assigns[:priv_func_plug]

    conn = simulate_request(Router, :get, "/only/no_conditionals")
    refute conn.assigns[:pub_func_plug]
    refute conn.assigns[:priv_func_plug]
  end

  test "only/2 without options allows function plug to be scoped to specific actions" do
    conn = simulate_request(Router, :get, "/only/only_with_public_func")
    assert conn.assigns[:pub_func_plug_no_opts]

    conn = simulate_request(Router, :get, "/only/no_conditionals")
    refute conn.assigns[:pub_func_plug_no_opts]
  end

  test "except/2 with options allows function plug to be excluded from actions" do
    conn = simulate_request(Router, :get, "/except/index")
    refute conn.assigns[:pub_func_plug]
    refute conn.assigns[:priv_func_plug]

    conn = simulate_request(Router, :get, "/except/show")
    assert conn.assigns[:pub_func_plug]
    assert conn.assigns[:priv_func_plug]
  end

  test "except/2 without options allows function plug to be excluded from actions" do
    conn = simulate_request(Router, :get, "/except/index")
    refute conn.assigns[:pub_func_plug_no_opts]

    conn = simulate_request(Router, :get, "/except/show")
    assert conn.assigns[:pub_func_plug_no_opts]
  end

end
