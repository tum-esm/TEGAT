Main Loop
=========

This page explains how TEGAT operates once it is running,
from startup through normal operation and shutdown.

Overview
--------

After startup, TEGAT runs continuously and coordinates all interaction
between the local controller, ThingsBoard, and local persistence components.

The main loop is responsible for:

- Maintaining a persistent MQTT connection to ThingsBoard
- Forwarding telemetry, logs, and status information
- Receiving and dispatching remote commands
- Supervising the controller Docker container
- Ensuring local data durability during network interruptions and/or system outages

The loop is designed to run continuously and autonomously without user
interaction.

Startup Phase
-------------

Before entering the steady-state main loop, TEGAT performs a short
initialization phase:

- Command-line arguments are parsed
- Device identity and credentials are verified or provisioned
- Local sqlite databases used for buffering and archiving are opened
- The MQTT connection to ThingsBoard is established

Once initialization completes successfully, the gateway proceeds to endlessly loop through a sequential list of actions.

Steady-State Operation (Loop)
----------------------------------

During normal operation, the main loop continuously performs the following tasks:

- Receives shared attribute updates and RPC commands from ThingsBoard
- Builds and starts the controller software Docker container if needed
- Publishes telemetry and log messages received from the controller
- Triggers remote file synchronization and OTA updates when requested
- Monitors the health of the controller Docker container
- Buffers outgoing and incoming messages in sqlite

All of these activities are coordinated within the main loop to ensure predictable
and deterministic behavior.

See a detailed description here: :ref:`architecture`

Failure Handling and Resilience
-------------------------------

The main loop is designed to be resilient to common failure scenarios:

- Temporary network outages
- Controller restarts or crashes
- Short-lived local I/O errors

If connectivity to ThingsBoard is lost, telemetry and log messages are buffered
locally and transmitted once the connection is restored.

If the controller becomes unresponsive or exits unexpectedly, the gateway
supervises its restart without terminating the main loop itself.

Shutdown Behavior
-----------------

TEGAT responds gracefully to shutdown signals:

- Active connections are closed cleanly
- Local databases are flushed and closed

A forced shutdown is only triggered if graceful termination fails within a defined
timeout.


Operational Notes
-----------------

- The main loop runs continuously as long as the TEGAT process is active.
- Most user-facing features (RPCs, file management, OTA updates) are coordinated
  through this loop.