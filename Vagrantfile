# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  config.vm.box = "debian/jessie64"

  config.vbguest.auto_update = false
  config.vbguest.no_remote = true

  config.vm.provision :ansible do |ansible|
    ansible.playbook = "playbook.yml"
    # The following line is needed for SSH agent forwarding to be usable from within playbooks
    # (i.e. for automatically doing git checkouts with your SSH key)
    ansible.raw_ssh_args = ['-o UserKnownHostsFile=/dev/null']
  end

  config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
    vb.memory = "2048"
    vb.customize ["modifyvm", :id, "--cpus", "2"]
  end
  config.ssh.forward_agent = true
  # Forward for connecting to webmin
  config.vm.network "forwarded_port", guest: 10000, host: 10000

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   sudo apt-get update
  #   sudo apt-get install -y apache2
  # SHELL
end
