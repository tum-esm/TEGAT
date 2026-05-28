Controller Repository
=====================

The controller git repository contains the software for interfacing with device-side hardware and is managed by TEGAT.
It is designed to be a standalone, versioned component that is built and deployed independently from TEGAT.


Architecture Overview
---------------------

The controller repository:

- is a dedicated Git repository (not part of the gateway)
- has its own versioning and release cycle
- is fetched and built by the gateway via the ThingsBoard OTA update mechanisms and git remote repository
- is executed inside an isolated Docker container
- communicates with the gateway exclusively via a local SQLite database

TEGAT is responsible for:

- building the controller Docker image
- starting and supervising the controller Docker container
- monitoring controller health
- restarting the controller Docker container in case of failure

The controller is responsible for:

- Implementing device-specific logic (sensors, actuators, control flows).
- Writing outbound messages to the local SQLite message queue (measurements, logs).
- Providing a periodic health check heartbeat message.

Repository Structure
--------------------

A minimal controller repository must contain:

- ``Dockerfile`` (in repository root)
- controller source code
- TGE-communication implementation via SQLite
- dependency definition (e.g. ``requirements.txt``)

A typical structure:

::

    controller-repo/
    ├── Dockerfile
    ├── requirements.txt
    ├── main.py
    ├── db.py
    ├── config/
    └── modules/


The gateway automatically builds the Docker image from the root ``Dockerfile`` unless a different file is specified
via environment variables.

Linking the Controller Repository
----------------------------------

The controller repository is linked to the gateway using the environment variable:

::

    TEG_CONTROLLER_GIT_PATH

This variable must point to the controller Git repository and must have a git remote configured / authenticated for the
OTA software update feature to function.

Setup details are described in: :ref:`setup_env_vars`

SQLite Communication Interface
------------------------------

The controller and gateway communicate via a shared SQLite database.

The controller must:

1. Enqueue outbound messages into the ``messages`` table.
2. Periodically update the ``health_check`` table.

Database schema definitions are documented in: :ref:`header-database-schemas` 

A reference implementation is available in:

``demo/example_controller/db.py``

Outbound Message Queue
^^^^^^^^^^^^^^^^^^^^^^^

Messages must be inserted into the ``messages`` table with:

- ``type`` (telemetry, attributes, rpc, etc.)
- ``message`` (JSON payload)

The gateway consumes and forwards these messages to ThingsBoard via MQTT.

Health Check Mechanism
^^^^^^^^^^^^^^^^^^^^^^^

The controller must periodically write a timestamp (milliseconds since epoch) to:

``health_check(id=1, timestamp_ms=<now>)``

TEGAT monitors this timestamp to detect stalled or crashed controllers.

Failure Handling
----------------

Controllers must fail fast and exit the main process if an unrecoverable error occurs.

TEGAT will automatically restart the container using an exponential backoff.

Controllers must not:

- Attempt self-restarts
- Implement their own process supervision
- Modify the database schema

Main Loop Requirements
----------------------

A typical controller main loop should:

1. Initialize configuration.
2. Connect to the SQLite database.
3. Initialize sensors/actuators.
4. Enter execution loop.
5. Perform periodic tasks.
6. Write health check in every iteration.

Example pattern:

::

    while True:
        read_sensors()
        process_logic()
        enqueue_messages()
        write_health_check()
        sleep(interval)


Optional Components
-------------------

Base Classes
^^^^^^^^^^^^

Reusable base classes for sensors and actuators are recommended to:

- Standardize device interfaces
- Reduce boilerplate
- Improve testability

Example implementations are provided in:

``demo/example_controller/sensor`` and ``demo/example_controller/actuator``

Remote Configuration
^^^^^^^^^^^^^^^^^^^^

Controllers can use the gateway Remote File Management to receive configuration files (e.g. ``config.json``).

Typical workflow:

- File is managed via ThingsBoard UI using shared attributes (see :ref:`remote-file-management` ).
- Gateway syncs file to controller data folder (mounted to controller docker container filesystem).
- Controller reads configuration at startup.
- Configurable: Configuration changes trigger controller restart.

Example Controller
------------------

A minimal working controller is available at:

``demo/example_controller/``

It includes:

- SQLite communication module
- Example sensor and actuator base classes
- Minimal main loop
- Dockerfile
- Requirements file

You may use this as a starting template for new implementations.
