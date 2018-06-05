# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "bento/ubuntu-18.04"
  config.vm.box_version = "201803.24.0"

  # config.vm.box = "geerlingguy/ubuntu1804"

  config.ssh.forward_agent = true

  # Ansible provisioner, but it may not work with Windows hosts.
  config.vm.provision "shell" do |s|
    s.path = "hardstone.sh"
    s.args = "'mySshPassphrase123'"
  end

  # Cache apt-get package downloads to speed things up
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
    config.cache.enable :generic, { :cache_dir => "/var/cache/pip" }
  end

end