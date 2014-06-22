defmodule Phoenix.View.AutoCreator do

  defmacro __after_compile__(env, bytecode) do
    base_module = env.module
    base_dir    = Path.dirname(env.file)

    for {submod, path} <- implicit_subview_modules(base_module, base_dir) do
      Code.eval_quoted(quote do
        defmodule unquote(submod) do
          @path Path.join([unquote(path), "./"])
          use unquote(base_module)
        end
      end)
    end

    bytecode
  end

  def implicit_subview_modules(base_module, dir) do
    Path.wildcard(Path.join([dir, "**/*"]))
    |> Enum.filter(&subview?(&1))
    |> Enum.filter(&!subview_defined?(&1))
    |> Enum.map fn dir ->
      {Module.concat([base_module, Path.basename(dir)]), dir}
    end
  end

  def subview?(dir) do
    File.dir?(dir) && !String.starts_with?(Path.basename(dir), "_")
  end

  def subview_defined?(dir) do
    module_name = Path.basename(dir)
    ex_file     = Path.join([dir, "#{module_name}.ex"])
    exs_file    = Path.join([dir, "#{module_name}.exs"])

    File.exists?(ex_file) || File.exists?(exs_file)
  end
end
