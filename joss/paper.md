---
title: 'TEG-Gateway: A Lightweight and Reusable Gateway for Scientific Sensor Networks'
tags:
  - Gateway
  - Thingsboard
  - IoT
  - Python
  - ACROPOLIS
authors:
  - name: Lars Frölich
    orcid: 0009-0000-1579-7727
    equal-contrib: true
    corresponding: true
    affiliation: 1
  - name: Patrick Aigner
    orcid: 0000-0002-1530-415X
    equal-contrib: true
    corresponding: true
    affiliation: 1
affiliations:
    - name: Environmental Sensing and Modeling, Technical University of Munich (TUM), Munich, Germany
      index: 1
date: 06 February 2026
bibliography: paper.bib
---

# Summary

The TEG-Gateway is a lightweight, general-purpose open source software built for managing and monitoring networks of IoT 
devices. 
It is built to integrate with the ThingsBoard platform and was designed specifically for operating distributed 
sensor networks for scientific research.
Originally developed for and validated in the ACROPOLIS sensor network, it is network-agnostic and can be used with a 
wide range of IoT and sensor hardware.
The TEG-Gateway offers a stable and reusable architectural baseline for distributed sensor networks, enabling users to 
focus on application-specific logic while relying on a field-tested software solution for communication, data 
persistence, and remote management of sensor devices.
It is designed to be robust against network and power outages, crashes, and other failures, thus reducing the risk of 
data loss, system downtime, or the need for physical intervention.
Application-specific and hardware interfacing logic is delegated to a user-defined controller software which is managed 
and independently deployed by the TEG-Gateway, thus separating infrastructure and application logic.


~~- Introduce the TEG-Gateway as reusable research software
- Describe it as a lightweight gateway for scientific sensor networks ("The software must have an obvious research application.")
- Emphasize separation of infrastructure and application logic
- Highlight controller-agnostic design and reuse across projects
- Reference validation in a real-world scientific deployment~~

# Statement of need

Distributed sensor networks are a critical tool in scientific research and widely used across disciplines, enabling 
long-term, continuous sensor measurements. While they vary in the sensor hardware, data acquisition and processing 
protocols used, as well as in the number of deployed devices, such networks often face common infrastructure challenges:
Physical access to sensor devices is often limited or costly. This can be additionally exacerbated by challenges in 
scaling networks to large numbers of deployed sensors. Sensor networks often need to provide continuous
measurements while operating unattended for extended periods of time. At the same time, network connectivity and system 
power can be intermittent or unreliable.
Although these challenges vary across deployments, they translate into a common set of infrastructure requirements:

- Reliable bidirectional communication with a central platform
- Local buffering of data during network outages
- Remote configuration and maintenance capabilities
- Safe remotely initiated software updates without disrupting measurements
- Ability to recover from failures without physical intervention
- Seamless addition and removal of devices from the network

The TEG-gateway addresses these infrastructure requirements to significantly reduce the engineering overhead associated 
with deploying and maintaining sensor networks. This enables network operators to focus on application-specific logic 
while building on top of field-tested software. TEG-gateway leverages the ThingsBoard IoT platform, a robust open source
software, which was chosen for its maturity (10+yrs in development) and scalability, supporting large numbers of sensor 
devices.
The flexible design of the TEG gateway, combined with the ThingsBoard IoT platform, allows users to configure customized 
sensor networks or seamlessly integrate additional sensors into existing networks, as well as making it possible to reuse 
infrastructure across multiple research projects.


# State of the Field

Main difference to others. We integrate the gateway in the edge device. This allows to deploy single devices at different locations without the need of a on location mist/fog gateway.

Open Source:
Local Gateways:
- Thingsboard Edge (local gateway, on location server): https://github.com/thingsboard/thingsboard-edge
- Thin Edge (split edge gateway and light on device): https://thin-edge.io/

Similar architectures:
- (On Device, Java Virtual Machine) Eclipse Kura: https://www.eclipse.org/kura/
- Ivy: https://joss.theoj.org/papers/10.21105/joss.08862
- IoT Fledge (north, south stack, no OTA): https://github.com/fledge-iot/fledge

Commercial:
- AWS IoT Greengrass (full stack, closed source): https://aws.amazon.com/greengrass/
- Azure IoT Edge (gateway mist): https://azure.microsoft.com/en-us/services/iot-edge/

Alternatives to Thingsboard:
- Kube Edge (remote sw management): https://kubeedge.io/en/
- Belena (Device OS + backend stack): https://www.balena.io/
- Tenta: https://joss.theoj.org/papers/10.21105/joss.07311


# Software Architecture
The software is based on a three-component architecture:
- (1) TEG-Gateway (this software)
- (2) Controller Software (project-specific, user provided, we provide an example implementation)
- (3) ThingsBoard IoT Platform

This design strictly separates the infrastructure and application logic, and divides responsibilities between all three
components. Both the TEG-Gateway and the Controller Software are deployed on the same IoT sensor device, with the 
TEG-Gateway acting as intermediary between the controller software and the ThingsBoard platform. The Gateway (1) is 
designed to be lightweight and robust, performing only essential functions like forwarding telemetry to ThingsBoard and
managing the deployment of the controller software. It communicates with the ThingsBoard platform via a secure MQTT connection.
The Controller Software (2) is provided by the user and is responsible for handling application-specific logic such as 
controlling actuators and collecting and processing sensor data. It is deployed inside a virtualized container 
environment and communicates with the TEG-Gateway via an intermediary database. 
This isolates the controller software from the TEG-Gateway to provide better fault tolerance and support continuous gateway 
availability, regardless of the state of the controller software.
Finally, the ThingsBoard platform (3) is deployed remotely and acts as a centralized data storage and network 
management system. It is built to be highly scalable, both in the number of connected devices and in
the amount of data received and stored. It is also highly customizable, supporting arbitrary sensor data formats and
protocols.
This architecture was chosen specifically for maintaining remote control of sensor devices independently of 
application- or hardware-specific software. By decoupling the TEG-Gateway from the controller software, 
updates can be deployed independently without compromising the TEG-gateway's operation. 
In case a newly deployed controller software version fails to start or contains errors, the TEG-gateway remains operational
and continues to communicate with the ThingsBoard IoT platform. This design ensures that corrective actions, such as 
reverting to a stable software version or adjusting configurations, can be performed remotely without risking system 
connectivity or requiring on-site intervention.


~~This architecture gives the user the flexibility to modify and expand the application-specific controller software all
while 
TEG-Gateway ensures reliable communication with the ThingsBoard platform.~~

~~deploying and modifying sensor hardware allows the user to swap out the application-specific controller software independently of the TEG
This architecture positions the TEG-Gateway to continuously run and provide reliable communication with the ThingsBoard
platform, while allowing the~~
~~- architecture (teg gateway)
  - gateway handles controller deployment
  - gateway manages the sensor device itself (files, rpc commands..)
  - gateway is lightweight / guaranteed to run reliably
  - user gets simplified interface to thingsboard~~
  
~~In this architecture, the TEG-gateway abstracts away the complexity of managing the sensor device itself as well as
integrating with the ThingsBoard platform. For the user implementing the controller software, it provides a simple
interface and a relia~~
~~This 3-component architecture is designed to be robust against crashes, network outages, and other failures while
maintaining scalability and flexibility. It allows network operators to seemlessly add or remove sensor devices or 
integrate new sensors into their existing networks and to change and extend their application-specific controller 
software on the fly.~~


## Software Design and Implementation
The TEG-Gateway software is written in Python (version 3.12). It follows a modular design, encapsulating independent
functionality such as logging, database access, or communication via mqtt into separate software modules. During an 
initial setup phase, communication is established with the ThingsBoard platform using MQTT via TLS, and the device is 
provisioned in the ThingsBoard platform if needed. After that, the software enters a steady-state main loop which contains 
the remainder of the software's functionality. Each iteration of the main loop performs one task only. Higher priority
tasks, such as processing incoming MQTT messages, are executed first. This design ensures operational reliability and efficiency.
As part of the main loop, the TEG-Gateway provides the following three core features: (1) Remote procedure calls (RPC),
(2) over-the-air (OTA) updates of the controller software, and (3) remote file management and mirroring.
(1) Remote Procedure Calls enable users to invoke one of several predefined commands on the TEG-Gateway using the RPC 
mechanism built into the Thingsboard platform. This enables users to remotely reboot the sensor device, restart the controller 
software, or execute arbitrary scripts on the device. This mechanism is primarily intended for operational control, diagnostics, 
and maintenance tasks that must be executed on-demand without direct access to the device.
(2) The OTA update feature allows users to remotely deploy new versions of the controller software to the TEG-Gateway device, for
example to fix bugs or add new features. By the same mechanism, users can also easily downgrade the controller software
back to a previous version if needed. This feature leverages the Git version control system to manage the software
version history: Users can specify a specific commit hash or tag which is then matched against the repository by the
TAG-Gateway. The TAG-Gateway then checks out the corresponding source code and builds a docker image based on it.
The TEG-Gateway also provides a mechanism for directly accessing files on the sensor device's file system using the 
remote file management feature (3). This feature allows users to create, read, and write files on the device by defining 
shared device attributes using the Thingsboard platform. As Linux systems provide extensive access to operating system
functionality through files, this feature has a particularly wide range of applications. Typical use cases for this
feature are managing software configuration files for the controller software and configuring on-device drivers and 
system daemons such as cron jobs.
More technical details on the TEG-Gateway's functionality and implementation can be found in the TEG-Gateway documentation [^2].

Other:
- archive + reupload
- log-buffering
- graceful shutdown

****** FROM DOCS: https://tum-esm.github.io/teg-gateway/user-guide/ ******
(1) Remote Procedure Calls
The TEG gateway supports Remote Procedure Calls (RPC) via ThingsBoard’s built-in RPC mechanism. RPCs allow external 
applications, automation scripts, or ThingsBoard dashboards to invoke predefined commands on the TEG gateway and receive 
immediate feedback.

This mechanism is primarily intended for operational control, diagnostics, and maintenance tasks that must be executed 
on-demand without direct access to the device.

(2) Remote Software Update
The Remote Software Update feature allows deploying new versions of the TEG gateway controller software to devices using 
ThingsBoard’s OTA update mechanism. This enables the rollout of bug fixes, performance improvements, and new features without 
requiring physical access to deployed hardware.

OTA update packages reference git tags or commit hashes from the controller’s git repository. Once an OTA package is created 
and assigned to a device or device profile in ThingsBoard, TEG gateway devices automatically receive the update, download the 
corresponding source code using git, build a Docker image locally if required, and re-deploy the controller software Docker container.

The remote software update mechanism follows a controller-only update model. OTA updates apply exclusively to the TEG gateway 
controller software and never update or restart the TEG gateway runtime itself. This design ensures that connectivity, 
telemetry buffering, and management functions remain available throughout the update process.

(3) Remote File Management
The TEG gateway supports remote file management via ThingsBoard shared attributes. This mechanism allows configuration 
and system files on the gateway device to be created, updated, monitored, and synchronized in a controlled and traceable way. 
The approach is designed to be robust against intermittent connectivity and to support both read-only mirroring and file writing.

The remote file management mechanism follows a server-authoritative model. ThingsBoard shared attributes define the desired 
state of all managed files. The TEG gateway never propagates local file changes upstream, except for mirroring file content 
and reporting synchronization status.
*****


1. Check for incoming MQTT messages from ThingsBoard and process them accordingly (RPC commands, OTA software updates, etc.)
2. Check if the controller software's docker container is running and if not, restart it using an exponential backoff
3. Check if the MQTT connection has been lost and if so, exit the process with a 30s delay
4. Check if there are buffered logs to be sent to ThingsBoard, if so send them

- TEG-Gateway functionality:
  - MQTT-based communication with ThingsBoard
  - Tiered local buffering of telemetry, logs, and historical data
  - Server-authoritative remote file management and mirroring
  - Remote procedure calls for operational control
  - Controller-only over-the-air (OTA) updates using Git
  - Rollback to previous controller versions
  - Self-provisioning against ThingsBoard
  - Automated health monitoring and diagnostic telemetry
  - Graceful handling of network outages and controller failures

- Controller is managed as a Docker container

- Implemented in Python (version 3.12+)
- Modular code structure separating communication, persistence, and operational logic
- Tiered persistence using specialized SQLite databases for communication, archiving, and logging
- SQLite-based inter-process communication (IPC) for controller-gateway interaction
- Docker used for controller isolation
- Git used for versioned controller repository management and OTA updates
- Static type checking using mypy
- Documentation generated using Sphinx

# Research impact statement

- The TEG-Gateway has been validated in a real-world scientific deployment within the ICOS Cities framework. It has enabled reliable data collection from a network of environmental sensors in an urban setting @ACROPOLIS2026.
- Example implementation @ACROPOLIS-edge


# Citations

- ThingsBoard[^1] @ThingsBoard2026 
- Docker @merkel2014docker
- Python @Python
- SQLite @SQLite
- Mypy @mypy
- Sphinx @Sphinx
- Paho MQTT Client @paho

[^1]: https://thingsboard.io/
[^2]: https://tum-esm.github.io/teg-gateway/user-guide/

# Author contributions
PA, FL:
- Conceptual design of the TEG-gateway software architecture
- Implementation of the TEG-Gateway software
- Documentation and user guides
- Deployment and validation in a real-world sensor network
- Joint contribution to manuscript preparation

JC:
- Principal investigator of the ACROPOLIS sensor network 

All authors reviewed the manuscript.

# Acknowledgements

- ICOS Cities framework
- Funding bodies (to be added)

# AI usage disclosure

Generative AI tools were used to assist with language refinement, formatting, and editorial support during manuscript preparation, and to aid documentation of the codebase and online materials. All AI-assisted outputs were reviewed and approved by the authors to ensure accuracy, technical correctness, and integrity.
