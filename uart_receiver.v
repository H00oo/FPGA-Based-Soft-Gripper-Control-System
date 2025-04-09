`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/19/2025 08:10:12 PM
// Design Name: 
// Module Name: uart_receiver
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


module uart_receiver #(
    parameter DATA_BITS = 8,
    parameter STOP_TICK = 16 // STOP_TICK=16 for 1 stop bit, 32 for 2 stop bits
)(
    input CLK,
    input RESET,
    input rx_data,
    input sample_tick,
    output [DATA_BITS-1:0] data_out,
    output reg data_ready
);

    // State Definitions
    localparam [1:0] IDLE  = 2'b00,
                     START = 2'b01,
                     DATA  = 2'b10,
                     STOP  = 2'b11;

    // Register Definitions
    reg [1:0] state, state_next;
    reg [3:0] tick_reg, tick_next;
    reg [2:0] nbits_reg, nbits_next;
    reg [DATA_BITS-1:0] data_reg, data_next;

    // Sequential Logic
    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            state     <= IDLE;
            tick_reg  <= 0;
            nbits_reg <= 0;
            data_reg  <= 0;
        end
        else begin
            state     <= state_next;
            tick_reg  <= tick_next;
            nbits_reg <= nbits_next;
            data_reg  <= data_next;
        end
    end

    // Combinational Logic
    always @(*) begin
        // Default Assignments
        state_next = state;
        tick_next  = tick_reg;
        nbits_next = nbits_reg;
        data_next  = data_reg;
        data_ready = 1'b0;

        case (state)
            IDLE: begin
                if (rx_data == 1'b0) begin // Start condition detected
                    state_next = START;
                    tick_next  = 0;
                end
            end

            START: begin
                if (sample_tick) begin
                    if (tick_reg == 4'd7) begin // Middle of start bit
                        state_next = DATA;
                        tick_next  = 0;
                        nbits_next = 0;
                    end
                    else begin
                        tick_next = tick_reg + 1;
                    end
                end
            end

            DATA: begin
                if (sample_tick) begin
                    if (tick_reg == 4'd15) begin // Middle of data bit
                        tick_next  = 0;
                        data_next  = {rx_data, data_reg[DATA_BITS-1:1]}; // Shift in received bit
                        if (nbits_reg == (DATA_BITS-1)) begin
                            state_next = STOP;
                        end
                        else begin
                            nbits_next = nbits_reg + 1;
                        end
                    end
                    else begin
                        tick_next = tick_reg + 1;
                    end
                end
            end

            STOP: begin
                if (sample_tick) begin
                    if (tick_reg == (STOP_TICK-1)) begin // End of stop bit
                        state_next = IDLE;
                        data_ready = 1'b1;
                    end
                    else begin
                        tick_next = tick_reg + 1;
                    end
                end
            end

            default: begin
                state_next = IDLE;
                tick_next  = 0;
                nbits_next = 0;
                data_next  = 0;
                data_ready = 1'b0;
            end
        endcase
    end

    // Output Assignment
    assign data_out = data_reg;

endmodule

