VA SCAN 2014 Puppet Demo
========================

### Pre-reqs

To run vagrant or terraform you'll need an AWS account, with
your keys stored in the `AWS_ACCESS_KEY` and `AWS_SECRET_KEY` environment
variables.

You'll also need the SSH keypair you plan on using stored in `AWS_KEYPAIR_NAME`.

Running the example in AWS will incur some cost. It should be fairly easy to
convert everything so that it runs entirely in Vagrant + VirtualBox.

### Puppet Master

The puppet master used in the demo is the experimental puppet server.

To run it you'll need [vagrant](http://vagrantup.com) and
[vagrant-aws](https://github.com/mitchellh/vagrant-aws).

### Puppet nodes

The nodes are created and spun up using [terraform](http://terraform.io)
(v0.2 at the time).

### base-puppet

The base-puppet folder is a simple set of puppet manifests and modules
that define the nodes using the roles and profiles design.

Basic spec tests are included.
