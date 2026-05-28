Setup from Image
================

This section describes how to create an image after the system setup to flash it on multiple systems. This allows to avoid repeating the setup steps on each system. 

Follow installation and setup instructions for a single system first. Skip the provisioning step as this needs to be done for each system individually after flashing the image.

An image can be created from the prepared system and then flashed onto other systems. The new systems can then be renamed and provisioned individually.

(Once) Create Backup Image
-------------------

-> Prepare system and install necessary software as described in :ref:`tegat_installation` and :ref:`setup`
-> Do not provision the device as this needs to be done for each system individually after flashing the image.
-> Insert fresh SD Card

.. code-block:: bash

    diskutil list
    # replace [*] with the correct disk number of the SD Card (e.g. disk2)
    # diskutil umountDisk /dev/disk[*]
    # dd status=progress bs=4M  if=/dev/disk[*] | gzip > //Users/.../tegat-image.gz


Flash image onto card
-------------------

 -> Insert fresh SD Card.

.. code-block:: bash

    diskutil list
    # replace [*] with the correct disk number of the SD Card (e.g. disk2)
    #diskutil umountDisk /dev/disk[*]
    #gzip -dc //Users/.../tegat-image.gz | sudo dd of=/dev/disk[*] bs=4M status=progress


-> Remove SD Card and
-> Insert into RaspberryPi/edge-device.

(Optional) Change Hostname (Raspberry Pi):
------------------------------------
.. code-block:: bash
    
    sudo raspi-config
    # Navigate to: System Options → Change Hostname
    sudo reboot


Provision Device
----------------

The device self-provisions upon its initial MQTT connection with ThingsBoard. See :ref:`setup_device_provisioning`