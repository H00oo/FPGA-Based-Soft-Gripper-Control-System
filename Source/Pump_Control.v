`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/10/2024 12:38:57 PM
// Design Name: 
// Module Name: Pump_Control
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Pump_Control(
    input CLK,
    input RESET,
    input Start,
    input signed [15:0] PID_in,
    input PWM_Frequency,
    output reg Pump_Outer_Control_Signal,
    output reg Pump_Inner_Control_Signal,
    output reg Value_Outer_Control_Signal,
    output reg Valve_Inner_Control_Signal   
    );

    reg [15:0] PO_counter; 
    reg [15:0] PI_counter; 
    reg [15:0] PO_Curr_Duty_cycle;
    reg [15:0] PO_Next_Duty_cycle;
    reg [15:0] PI_Curr_Duty_cycle;
    reg [15:0] PI_Next_Duty_cycle;
    parameter signed PO_MAX_DUTY = 16'd1000;
    parameter signed PI_MAX_DUTY = 16'd1000;
    
    always @(posedge CLK) begin
        if (PID_in > PO_MAX_DUTY) begin
            PO_Next_Duty_cycle = PO_MAX_DUTY;  
        end 
        else if (PID_in < 16'sd0) begin
            PO_Next_Duty_cycle = 16'd0;
        end 
        else begin
            PO_Next_Duty_cycle = PID_in;
        end
    end
    
    always @(posedge CLK) begin
        if (PID_in > PI_MAX_DUTY) begin
            PI_Next_Duty_cycle = PI_MAX_DUTY;  
        end 
        else if (PID_in < 16'sd0) begin
            PI_Next_Duty_cycle = 16'd0;  
        end 
        else begin
            PI_Next_Duty_cycle = PID_in;
        end
    end
    
    always @(posedge CLK) begin
        if (Start) begin
            Value_Outer_Control_Signal <= 0;
            Valve_Inner_Control_Signal <= 0;
        end
        else begin
            Value_Outer_Control_Signal <= 1;
            Valve_Inner_Control_Signal <= 1;
        end
    end
    
    always @(posedge CLK) begin
        if (RESET) begin
            PO_counter <= 0;
            Pump_Outer_Control_Signal <= 0; 
        end 
        else begin
            if (PWM_Frequency) begin
                if (PO_counter < PO_MAX_DUTY) begin
                    if (PO_counter < PO_Curr_Duty_cycle && Start) begin
                        Pump_Outer_Control_Signal <= 1; 
                    end
                    
                    else begin
                        Pump_Outer_Control_Signal <= 0; 
                    end
                    PO_counter <= PO_counter + 1;
                end 
                else begin
                    PO_counter <= 0;
                    PO_Curr_Duty_cycle <= PO_Next_Duty_cycle;
                end          
            end
        end
    end
    
    always @(posedge CLK) begin
        if (RESET) begin
            PI_counter <= 0;
            Pump_Inner_Control_Signal <= 0; 
        end 
        else begin
            if (PWM_Frequency) begin
                if (PI_counter < PI_MAX_DUTY) begin
                    if (PI_counter < PI_Curr_Duty_cycle && Start) begin
                        Pump_Inner_Control_Signal <= 1;  
                    end
                    
                    else begin
                        Pump_Inner_Control_Signal <= 0; 
                    end
                    PI_counter <= PI_counter + 1;
                end 
                else begin
                    PI_counter <= 0;
                    PI_Curr_Duty_cycle <= PI_Next_Duty_cycle;
                end          
            end
        end
    end
    
endmodule
