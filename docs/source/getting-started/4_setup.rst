.. _setup:
Setup
=====

How to set up TEGAT on an IoT device once it has been installed.

Docker
------

Create a Docker daemon configuration file:

.. code-block:: bash

    sudo nano /etc/docker/daemon.json
    # Add:
    {
        "dns": ["8.8.8.8", "1.1.1.1", "8.8.4.4"],
        "log-driver": "json-file",
        "log-opts": { "max-size": "100m", "max-file": "3" }
    }

This config sets up DNS servers as well as log rotation.

Add the current user to the Docker group and reboot:

.. code-block:: bash
    
    sudo usermod -aG docker $USER
    sudo reboot

This is needed to avoid permission errors when the gateway tries to run Docker commands.

.. _setup_env_vars:
Environment variables
---------------------

Edit the `.env.example` file to configure the application's basic settings.
Use the descriptions in `.env.example` for guidance on which environment variables to set and which values to use.

.. code-block:: bash

    mv .env.example .env
    sudo nano .env  # edit environment variables as needed

Note
  All environment variables are documented in `.env.example`. To avoid duplication and drift,
  this guide intentionally does not repeat them here.

Prerequisites
-------------

- Set up a ThingsBoard Server (see official docs: https://thingsboard.io/docs/user-guide/install/installation-options/)
- Create appropriate Device Profiles in ThingsBoard: https://thingsboard.io/docs/user-guide/device-profiles/
- For the gateway device profile, configure:

    - Name
    - Transport Type: MQTT
    - Provisioning Strategy: Secret Provisioning (enable “Allow to create new devices”)

- Put the provisioning credentials into your `.env` file (see `.env.example`).
- Optionally, set the desired hostname in your OS configuration


Build the TEGAT runner Docker image:
--------------------------------------------------
.. code-block:: bash

    cd scripts
    ./build_gateway_runner_docker_image.sh # builds the TEGAT-runner docker image


Run TEGAT using Docker daemon:
--------------------------------------
.. code-block:: bash

    cd scripts
    ./run_dockerized_gateway.sh # also registers device with ThingsBoard and creates tb_access_token
    docker logs --tail 50 -f tegat # see live logs


.. _setup_device_provisioning:
Device Provisioning
-------------------

- On first start, the gateway will self-provision if no access token file exists.
- By default, the device name will match the host OS hostname (unless overridden via environment variable).

