# Cookbook Name:: chef-php-extra
# Provider:: composer
#
# Copyright 2012, Marcello Duarte, Alistair Stead
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

action :install_composer do
  if !node['php']['composer']['as_bin'] && !::File.directory?(new_resource.project_path)
    raise "#{new_resource.project_path} is not a directory"
  end

  remote_file "#{new_resource.project_path}/composer.phar" do
    source "http://getcomposer.org/composer.phar"
    mode "0774"
    not_if do
      new_resource.project_path.nil? ||
        node['php']['composer']['as_bin'] ||
	::File.exists?("#{new_resource.project_path}/composer.phar")
    end
  end
  
  remote_file "#{node['php']['prefix_dir']}/bin/composer" do
    source "http://getcomposer.org/composer.phar"
    mode "0775"
    not_if do
      ::File.exists?("#{node['php']['prefix_dir']}/bin/composer")
    end
    only_if { node['php']['composer']['as_bin'] }
  end
  new_resource.updated_by_last_action(true)
end

action :install_packages do

  cmd = if ::File.exists?("#{new_resource.project_path}/composer.phar")
    "php composer.phar"
  else
    "composer"
  end

  execute "install dependencies with composer #{new_resource.name}" do
    cwd new_resource.project_path
    user "root"
    command "#{cmd} install"
    only_if do
      ::File.exists?("#{new_resource.project_path}/composer.json")
    end
  end
  new_resource.updated_by_last_action(true)
end

action :create_project do

  cmd = if ::File.exists?("#{new_resource.project_path}/composer.phar")
    "php composer.phar"
  else
    "composer"
  end

  execute "create project with composer #{new_resource.name}" do
    cwd new_resource.project_path
    user "root"
    command "#{cmd} create-project #{new_resource.project} -s #{new_resource.stability} ."
  end
  new_resource.updated_by_last_action(true)
end
