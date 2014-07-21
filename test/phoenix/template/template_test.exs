defmodule Phoenix.Template.TemplateTest do
  use ExUnit.Case
  alias Phoenix.Template


  test "#func_name_from_path/2 returns the function name from the full path" do
    file_path = "/var/www/templates/admin/users/show.html.eex"
    template_root = "/var/www/templates"
    assert Template.func_name_from_path(file_path, template_root) ==
      "admin/users/show.html"

    file_path = "/var/www/templates/users/show.html.eex"
    template_root = "/var/www/templates"
    assert Template.func_name_from_path(file_path, template_root) ==
      "users/show.html"

    file_path = "/var/www/templates/home.html.eex"
    template_root = "/var/www/templates"
    assert Template.func_name_from_path(file_path, template_root) ==
      "home.html"

    file_path = "/var/www/templates/home.html.haml"
    template_root = "/var/www/templates"
    assert Template.func_name_from_path(file_path, template_root) ==
      "home.html"
  end

  test "#find_all_from_root/1 returns wildcard of all contained templates" do
    root = Path.join([__DIR__], "../../fixtures/templates")
    templates = Template.find_all_from_root(root)
    assert File.exists?(templates |> Enum.at(0))
  end
end

