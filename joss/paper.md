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
Other existing solutions already cover a variety of the features provided by the combination of TEG-gateway and ThingsBoard,
though there are different tradeoffs and limitations to consider with each approach:
Some solutions implement a semi-distributed architecture, where in addition to a central backend server, an on-site 
central gateway server collects data from multiple connected sensor devices. Examples include thin-edge.io and ThingsBoard's
own product Thingsboard Edge. These architectures benefit from sensor network layouts where many sensor devices share a local
network, such as in large factory or office buildings, but face limitations when sensors are deployed individually in
remote locations and don't form local networks. Furthermore, since the gateway servers are not designed to be co-deployed
on the sensor devices themselves, they lack software update (OTA) or remote management capabilities.
Some subset of our features can be covered with commercial solutions: For example, Amazon's AWS IoT and Microsoft Azure's
Azure IoT Edge products are IoT cloud-platforms similar to ThingsBoard, and Balena's device OS offers reliable device 
management and software updates of IoT device fleets similar to TEG-Gateway's OTA and RPC functionality. However, projects
building on top of such products are dependent on future pricing and availability of these products, and require
continuous funding (which is often not possible in scientific research projects).
Finally, a combination of open source solutions can offer a similar feature set: Examples are the Eclipse Foundation's Kura 
and Kapua projects, as well as the linux foundation's fledge and kube edge projects. In both cases, these unfortunately lack
in some aspects we consider important, such as data visualization dashboards and software maturity. Finally, the @IvyProject
only covers basic data forwarding via an MQTT client instead of natively integrating with a fleet management software. 
Furthermore, it lacks separation between application and infrastructure logic, making OTA updates brittle. For example, 
any crashes not covered by the test suite may result in permanent downtime requiring on-site fixes.

# Software Architecture

![Overview of the software architecture for on-device (TEG-Gateway, controller) and off premise (ThingsBoard, Git Repository) components. Arrows indicate the flow of data and actions between components. Dashed boxes show local files that are used for configuration, management and data persistence. \label{fig:architecture}](figures/figure1.png)

The software is based on a three-component architecture (see Figure \autoref{fig:architecture}):
- (1) TEG-Gateway (this software)
- (2) Controller Software (project-specific, user provided, we provide an example implementation)
- (3) ThingsBoard IoT Platform

Both the TEG-Gateway (1) and the Controller Software (2) are deployed on the same IoT sensor device, with the TEG-Gateway 
acting as intermediary between the controller software and the ThingsBoard platform which runs on a remote server. 
This design strictly separates the infrastructure and application logic, and divides responsibilities between all three components:
The TEG-Gateway (1) is designed to be lightweight and robust, performing only essential functions like forwarding telemetry 
to ThingsBoard and managing the deployment of the controller software. It communicates with the ThingsBoard platform via 
a secure MQTT connection.
The Controller Software (2) is provided by the user and is responsible for handling application-specific logic such as 
controlling actuators and collecting and processing sensor data. It is deployed inside a Docker @merkel2014docker container 
environment and communicates with the TEG-Gateway via an intermediary database. 
This isolates the controller software from the TEG-Gateway to provide better fault tolerance.
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


## Software Design and Implementation
The TEG-Gateway software is written in Python (version 3.12). It follows a modular design, encapsulating independent
functionality such as logging, database access, or communication via MQTT into separate software modules. During an 
initial setup phase, communication is established with the ThingsBoard platform using MQTT via TLS, and the device is 
provisioned in the ThingsBoard platform if needed. The software subsequently enters a steady-state main loop which contains 
the remainder of the software's functionality. Each iteration of the main loop performs one task only. Higher priority
tasks, such as processing incoming MQTT messages, are executed first. This design ensures operational reliability and efficiency.
The TEG-Gateway receives telemetry data from the controller software via a local sqlite database, which is used to
buffer messages between the two software components for additional fault tolerance. The TEG-gateway then forwards the 
telemetry data to the ThingsBoard platform via MQTT, and stores a copy of the data in a local database for additional 
redundancy (for example to backfill data gaps on-demand).
The TEG-Gateway also manages the deployment of the controller software by directly interacting with the host system's
Docker daemon: If the controller software's docker container is not running or has not provided a recent heartbeat, 
the TEG-Gateway attempts to start it using an exponential backoff strategy.
Besides managing the controller software and forwarding telemetry data, the TEG-Gateway provides the following three 
core features: (1) Remote procedure calls (RPC), (2) over-the-air (OTA) updates of the controller software, and (3) 
remote file management.
Remote Procedure Calls (1) enable users to invoke one of several predefined commands on the TEG-Gateway using the RPC 
mechanism built into the Thingsboard platform. This enables users to remotely reboot the sensor device, restart the controller 
software, or execute arbitrary scripts on the device. This mechanism is primarily intended for operational control, diagnostics, 
and maintenance tasks that must be executed on-demand without direct access to the device.
The OTA update feature (2) allows users to remotely deploy new versions of the controller software to the TEG-Gateway device, for
example to fix bugs or add new features. By the same mechanism, users can also easily downgrade the controller software
back to a previous version if needed. This feature leverages the Git version control system to manage the software
version history: Users can specify a specific commit hash or tag. The TEG-Gateway then builds a docker image based on the 
corresponding source code.
The TEG-Gateway also provides a mechanism for directly accessing files on the sensor device's file system using the 
remote file management feature (3). This feature allows users to create, read, and write files on the device by defining 
shared device attributes using the Thingsboard platform. As Linux systems provide extensive access to operating system
functionality through files, this feature has a particularly wide range of applications. Typical use cases for this
feature are managing software configuration files for the controller software and configuring on-device drivers and 
system daemons such as cron jobs.
More technical details on the TEG-Gateway's functionality and implementation can be found in the TEG-Gateway documentation [^2],
which is built on Sphinx @Sphinx.

To make the TEG-Gateway's source code more robust against potential errors, the TEG-gateway codebase is statically typed.
Developers can perform local type checks using mypy, which is also deployed as a continuous integration (CI) pipeline using
GitHub actions.
To enable integration testing of the system as a whole, a demo application is provided which enables developers to
quickly deploy a fresh ThingsBoard server instance, the current version of the TEG-Gateway as well as an example 
implementation of the controller software. This example implementation of the controller software also serves as a 
starting point for developers to copy and modify for their own projects.


# Research impact statement

The TEG-Gateway has been validated in a real-world scientific deployment within the ICOS Cities framework. It has 
enabled reliable data collection from a network of 20 environmental sensors in an urban setting @ACROPOLIS2026. As part
of this project, @ACROPOLIS-edge serves an example of a successful implementation of the TEG-Gateway in a real world use case.


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
LF, PA:
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
