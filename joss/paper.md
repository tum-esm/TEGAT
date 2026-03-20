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
Hardware interfacing logic is delegated to a user-defined controller software which interacts with the TEG-Gateway via 
a message queue, separating infrastructure and application logic.


~~- Introduce the TEG-Gateway as reusable research software
- Describe it as a lightweight gateway for scientific sensor networks ("The software must have an obvious research application.")
- Emphasize separation of infrastructure and application logic
- Highlight controller-agnostic design and reuse across projects
- Reference validation in a real-world scientific deployment~~

# Statement of need

Distributed sensor networks are a critical tool in scientific research and widely used across disciplines, enabling 
long-term, continuous sensor measurements. While they vary in the sensor hardware, data acquisition and processing 
protocols used, as well as in the number of deployed devices, such networks often face common infrastructure challenges:
Physical access to sensor devices is often limited or costly, either due to inaccessible deployment locations or due to 
challenges in scaling networks to large numbers of deployed sensors. Sensor networks often need to provide continuous
measurements while operating unattended for extended periods of time. At the same time, network connectivity and system 
power can be intermittent or unreliable.
Although these challenges vary across deployments, they translate into a common set of infrastructure requirements:
- Reliable bidirectional communication with a central platform
- Local buffering of data during network outages
- Remote configuration and maintenance capabilities
- Safe remotely initiated software updates without disrupting measurements
- Ability to recover from failures without physical intervention

A single reusable software that addresses these infrastructure requirements while staying network-agnostic can 
significantly reduce the engineering overhead associated with deploying and maintaining new sensor networks. 
Network operators can focus on application-specific logic while building on top of a field-tested software solution. 
Furthermore, subsequent deployments of new sensor networks can reuse the same infrastructure, further reducing overall
cost and operational complexity while ensuring architectural consistency across scientific studies.



~~- nr supported devices
- nr geographic locations
- nr deployed devices (spatial resolution)~~

~~To achieve sufficient spatial and temporal resolution, large numbers of sensors are usually deployed~~ 
~~To achieve both large geographic coverage and sufficient spatial resolution of resulting data, sensor networks require 
increasingly large numbers of independently deployed devices, increasing the operational complexity of managing and 
monitoring the network.~~
- Scientific sensor networks are widely used across disciplines
- Typical use cases include long-term, continuous measurements
- Deployments often operate unattended for months or years
- Physical access to devices is limited or costly
- Network connectivity can be intermittent or unreliable~~

~~- Sensor networks differ mainly in:
  - sensor hardware
  - acquisition protocols
  - domain-specific processing~~
~~- Infrastructure needs are largely identical across projects
  - Reliable bidirectional communication with a central platform
  - Local buffering of data during network outages
  - Remote configuration and maintenance capabilities
  - Safe software updates without disrupting measurements
  - Ability to recover from failures without physical intervention~~
~~- A reusable architectural baseline reduces duplicated engineering effort~~

~~- Research projects can:
  - Start from a proven gateway design
  - Implement only controller logic specific to their hardware
  - Reduce engineering overhead at project start
  - Deploy new sensor networks more rapidly~~

~~- The ThingsBoard Edge Gateway provides:
  - A stable and reusable gateway architecture
  - (Clear separation between infrastructure and application logic)
  - (Persistent connectivity, buffering, and remote management)
  - (Supervision of an external, application-specific controller)~~

~~- Broader impact:
  - Architectural consistency across scientific projects (setup thingsboard once, deploy many times)
  - Reuse beyond a single study or funding cycle~~

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


# Software Design

- Two-component architecture:
  - Edge Gateway (this software)
  - Controller Software (project-specific, we provide an example implementation)
- Good Scaling properties (ThingsBoard):
  - Controllers can be added or removed from the network as needed
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
- Controller responsibilities:
  - Sensor/Actuator hardware interaction
  - Data acquisition and processing
- Controller is managed as a Docker container
- Architecture supports continuous gateway availability, regardless of the state of the controller software
- Architecture is designed to be robust against crashes, network outages, and other failures

## Implementation

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
