`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/19/2025 07:39:23 PM
// Design Name: 
// Module Name: baud_rate_generator
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


module baud_rate_generator #(
    parameter N = 10,
    parameter COUNT = 651
)(
    input CLK,
    input RESET,
    output tick
);

    reg [N-1:0] count_value;
    wire [N-1:0] count_next;

    always @(posedge CLK or posedge RESET) begin
        if (RESET)
            count_value <= 0;
        else
            count_value <= count_next;
    end

    assign count_next = (count_value == (COUNT-1)) ? 0 : (count_value + 1);
    assign tick = (count_value == (COUNT-1)) ? 1'b1 : 1'b0;

endmodule
