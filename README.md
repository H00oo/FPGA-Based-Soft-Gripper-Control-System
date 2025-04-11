# Soft-Gripper-Control-System
This repository showcases a complete engineering project integrating a soft robotic gripper with TurtleBot3, enabling a mobile robot to perform autonomous grasping tasks. Designed primarily for delicate object manipulation—such as fruit picking—this project combines soft robotics, embedded control, and ROS-based navigation into a unified system.

![image](https://github.com/user-attachments/assets/2164e7d1-6961-4523-b83b-b6e5aebaf934)

This diagram presents the working principle of the pneumatic soft gripper control system. A setpoint is sent to an FPGA that includes a PID controller. Based on this, the FPGA generates a PWM signal to drive a custom-designed power control PCB, which then powers the pumps and valves. These generate compressed air to actuate the soft gripper.

Meanwhile, an air pressure sensor continuously monitors the internal pressure inside the gripper. This feedback is sent back to the FPGA via an ADC interface, forming a closed-loop control system. This structure ensures that the pressure applied to the gripper is precisely adjusted in real-time to match the desired setpoint, allowing for soft and stable object handling.
![image](https://github.com/user-attachments/assets/1a2e9018-a8ba-419a-ba5f-ba7066ae8e32)

This flow chart illustrates how the soft gripper system is integrated into the full mobile robot platform based on TurtleBot3. High-level commands are handled by ROS code running on a PC, which communicates with the ROS Master. Commands are forwarded to the Raspberry Pi onboard the robot, which serves as the central controller.

The Raspberry Pi communicates with two systems: the OpenCR board (for robot motion control) and the BASYS3 FPGA board (for gripper control), using UART communication. The FPGA then controls the air pump and valve system via a dedicated PCB.

This system allows the mobile robot to identify targets, navigate autonomously, and execute pick-and-place tasks with adaptive soft gripping.

Dashed arrows in the diagram indicate control signal flow, and solid arrows represent data flow between system modules.
