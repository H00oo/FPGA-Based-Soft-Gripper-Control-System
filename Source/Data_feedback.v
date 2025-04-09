`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/20/2025 11:23:59 PM
// Design Name: 
// Module Name: Data_feedback
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


module Data_feedback (
    input CLK,
    input RESET,
    input Start_signal,
    input [3:0] DEC0,
    input [3:0] DEC1,
    input [3:0] DEC2,
    input [3:0] DEC3,
    output Write_tick,
    output reg [7:0] data
    );
    
    reg [4:0] char_counter;
    reg [7:0] ASCII_DEC0;
    reg [7:0] ASCII_DEC1;
    reg [7:0] ASCII_DEC2;
    reg [7:0] ASCII_DEC3;
    wire Write_TRIG;

    // 0.01second counter
        Generic_counter # (
        .COUNTER_WIDTH(20),
        .COUNTER_MAX(999999)
        )
        HundredthsecondCounter(
        .CLK(CLK),
        .RESET(1'b0),
        .ENABLE(Start_signal),
        .TRIG_OUT(Write_TRIG),
        .COUNT()
    ); 
    
    always @(posedge Write_TRIG) begin
        ASCII_DEC0 <= DEC0 + 8'd48;
        ASCII_DEC1 <= DEC1 + 8'd48;
        ASCII_DEC2 <= DEC2 + 8'd48;
        ASCII_DEC3 <= DEC3 + 8'd48;
        if (Start_signal)begin
            char_counter <= (char_counter == 5'd25) ? 0 : char_counter + 1;
        end
        else begin
            char_counter <= 1'b0;
        end

        case(char_counter)
            5'd1: data <= 8'h43; // 'C'
            5'd2: data <= 8'h75; // 'u'
            5'd3: data <= 8'h72; // 'r'
            5'd4: data <= 8'h72; // 'r'
            5'd5: data <= 8'h5f; // '_'
            5'd6: data <= 8'h50; // 'P'
            5'd7: data <= 8'h72; // 'r'
            5'd8: data <= 8'h65; // 'e'
            5'd9: data <= 8'h73; // 's'
            5'd10: data <= 8'h73; // 's'
            5'd11: data <= 8'h75; // 'u'
            5'd12: data <= 8'h72; // 'r'
            5'd13: data <= 8'h65; // 'e'
            5'd14: data <= 8'h3a; // ':'
            5'd15: data <= 8'h20; // ' ' (space)
            5'd16: data <= ASCII_DEC3; // 'forth_sensor_value'
            5'd17: data <= ASCII_DEC2; // 'third_sensor_value'
            5'd18: data <= 8'h2E; // '.'
            5'd19: data <= ASCII_DEC1; // 'second_sensor_value'
            5'd20: data <= ASCII_DEC0; // 'first_sensor_value'
            5'd21: data <= 8'h70; // 'p'
            5'd22: data <= 8'h73; // 's'
            5'd23: data <= 8'h69; // 'i'
            5'd24: data <= 8'h0d; // 'enter'
            5'd25: data <= 8'h0a; // '\n'
        endcase
    end
    
    assign Write_tick = Write_TRIG;
    
endmodule
