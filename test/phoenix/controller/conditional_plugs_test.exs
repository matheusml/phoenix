defmodule Phoenix.Controller.ConditionalPlugsTest do
  use ExUnit.Case
  use PlugHelper

  defmodule ModulePlug do
    def init(opts), do: opts
    def call(conn, _), do: Plug.Conn.assign(conn, :module_plug, true)
  end

  defmodule OnlyController do
    use Phoenix.Controller

    plug :scoped, {:pub_func_plug, [],     only: [:index]}
    plug :scoped, {:pub_func_plug_no_opts, only: [:index]}
    plug :scoped, {:priv_func_plug, [],    only: [:index]}
    plug :scoped, {ModulePlug,             only: [:index]}
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

    plug :scoped, {:pub_func_plug, [],     except: [:index]}
    plug :scoped, {:pub_func_plug_no_opts, except: [:index]}
    plug :scoped, {:priv_func_plug, [],    except: [:index]}
    plug :scoped, {ModulePlug,             except: [:index]}
    plug :action

    def index(conn, _) do
      conn
    end

    def show(conn, _) do
      conn
    end

    def missing(conn, _) do
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

  defmodule MalformedScopedController do
    use Phoenix.Controller

    plug :scoped, {:assign_layout, "print", foo: [:index]}
    plug :action

    def index(conn, _) do
      conn
    end
  end


  defmodule Router do
    use Phoenix.Router
    get "/only/only_with_public_func", OnlyController, :index
    get "/only/no_conditionals", OnlyController, :show

    get "/except/index", ExceptController, :index
    get "/except/show", ExceptController, :show
    get "/malformed/index", MalformedScopedController, :index

  end

  test "scoped/2 `only:` allows function plug to be scoped to specific actions" do
    conn = simulate_request(Router, :get, "/only/only_with_public_func")
    assert conn.assigns[:pub_func_plug]
    assert conn.assigns[:priv_func_plug]
    assert conn.assigns[:module_plug]

    conn = simulate_request(Router, :get, "/only/no_conditionals")
    refute conn.assigns[:pub_func_plug]
    refute conn.assigns[:priv_func_plug]
    refute conn.assigns[:module_plug]
  end

  test "scoped/2 `only:` without options allows function plug to be scoped to specific actions" do
    conn = simulate_request(Router, :get, "/only/only_with_public_func")
    assert conn.assigns[:pub_func_plug_no_opts]
    assert conn.assigns[:module_plug]

    conn = simulate_request(Router, :get, "/only/no_conditionals")
    refute conn.assigns[:pub_func_plug_no_opts]
    refute conn.assigns[:module_plug]
  end

  test "scoped/2 `except:` allows function plug to be excluded from actions" do
    conn = simulate_request(Router, :get, "/except/index")
    refute conn.assigns[:pub_func_plug]
    refute conn.assigns[:priv_func_plug]
    refute conn.assigns[:module_plug]

    conn = simulate_request(Router, :get, "/except/show")
    assert conn.assigns[:pub_func_plug]
    assert conn.assigns[:priv_func_plug]
    assert conn.assigns[:module_plug]
  end

  test "scoped/2 `except:` without options allows function plug to be excluded from actions" do
    conn = simulate_request(Router, :get, "/except/index")
    refute conn.assigns[:pub_func_plug_no_opts]

    conn = simulate_request(Router, :get, "/except/show")
    assert conn.assigns[:pub_func_plug_no_opts]
  end

  test "scoped/2 raises an error with only or except key is missing" do
    conn = simulate_request(Router, :get, "/malformed/index")
    assert conn.status == 500
  end
end
