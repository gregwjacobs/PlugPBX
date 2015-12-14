PlugPBX
=======

See http://www.plugpbx.org

PlugPBX is a pre-built image you can boot your SheevaPlug and have a full featured PBX phone system.

Based On:

 * Debian Linux
 * Asterisk
 * FreePBX
 * Webmin

The ansible playbook is intended as a build setup to task a stock Debian
booting SheevaPlug and setup/install/build a standard PlugPBX system automatically.
Its will a work in progress.

The ansible playbook is based on:
http://wiki.freepbx.org/display/HTGS/Installing+FreePBX+12+on+Ubuntu+Server+14.04+LTS

Look for tagged releases or branches later on, or feel free to pitch in.

Testing
=======

Vagrant file provided to automatically run the playbook for testing.
Just run `vagrant up` to run.

Should you make changes to the playbook and the VM is already running use:
`vagrant provision`.
