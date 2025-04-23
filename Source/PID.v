`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/10/2024 02:12:32 PM
// Design Name: 
// Module Name: PID
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


module PID(
    input CLK,
    input PID_Sample_Frequency,
    input RESET,
    input [15:0] Curr_Pressure_value,
    output reg signed [15:0] PID_out
    );
    
    parameter [15:0] Desired_value = 16'd950;
    parameter signed [15:0] Kp = 16'sd160; 
    parameter signed [15:0] Ki = 16'sd25; 
    parameter signed [15:0] Kd = 16'sd60; 
    parameter SCALE_FACTOR = 100;
    
    reg signed [15:0] error;
    reg signed [15:0] integral;
    reg signed [15:0] derivative;
    reg signed [15:0] prev_error;
    
    parameter signed [15:0] INTEGRAL_MAX = 16'sh7FFF;
    parameter signed [15:0] INTEGRAL_MIN = 16'sh8000;
    
    parameter signed [15:0] PID_MAX = 16'sh7FFF;
    parameter signed [15:0] PID_MIN = 16'sh8000;

always @(posedge PID_Sample_Frequency or posedge RESET) begin
        if (RESET) begin
            error <= 16'sd0;
            integral <= 16'sd0;
            derivative <= 16'sd0;
            prev_error <= 16'sd0;
        end else begin
        
            error <= Desired_value - Curr_Pressure_value;           
            
            if ( (integral + (Ki * error/SCALE_FACTOR)) > INTEGRAL_MAX ) begin
                integral <= INTEGRAL_MAX;
            end 
            else if ( (integral + (Ki * error/SCALE_FACTOR)) < INTEGRAL_MIN ) begin
                integral <= INTEGRAL_MIN;
            end 
            else begin
                integral <= integral + (Ki * error/SCALE_FACTOR);
            end

            derivative <= error - prev_error;

            prev_error <= error;
            
            if ( ((Kp * error/SCALE_FACTOR) + (integral) + (Kd * derivative/SCALE_FACTOR)) > PID_MAX )begin
                PID_out <= PID_MAX;
            end
            else if ( ((Kp * error/SCALE_FACTOR) + (integral) + (Kd * derivative/SCALE_FACTOR)) < PID_MIN )begin
                PID_out <= PID_MIN;
            end
            else begin
                PID_out <= (Kp * error/SCALE_FACTOR) + (integral) + (Kd * derivative/SCALE_FACTOR);
            end
        end
    end

endmodule
