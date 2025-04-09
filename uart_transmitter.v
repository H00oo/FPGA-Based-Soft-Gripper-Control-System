`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/19/2025 08:17:11 PM
// Design Name: 
// Module Name: uart_transmitter
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


module uart_transmitter #(
    parameter DATA_BITS = 8,
    parameter STOP_TICK = 16
)(
    input CLK,
    input RESET,
    input tx_start,
    input sample_tick,
    input [DATA_BITS-1:0] data_in,
    output reg tx_done,
    output tx_data
);

    localparam [1:0] IDLE  = 2'b00,
                     START = 2'b01,
                     DATA  = 2'b10,
                     STOP  = 2'b11;

    reg [1:0] state, state_next;
    reg [4:0] tick_reg, tick_next;
    reg [2:0] nbits_reg, nbits_next;
    reg [DATA_BITS-1:0] data_reg, data_next;
    reg tx_reg, tx_next;

    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            state     <= IDLE;
            tick_reg  <= 0;
            nbits_reg <= 0;
            data_reg  <= 0;
            tx_reg    <= 1'b1;
        end
        else begin
            state     <= state_next;
            tick_reg  <= tick_next;
            nbits_reg <= nbits_next;
            data_reg  <= data_next;
            tx_reg    <= tx_next;
        end
    end

    always @(*) begin
        state_next  = state;
        tick_next   = tick_reg;
        nbits_next  = nbits_reg;
        data_next   = data_reg;
        tx_next     = tx_reg;
        tx_done     = 1'b0;

        case (state)
            IDLE: begin
                tx_next = 1'b1;
                if(tx_start) begin
                    state_next = START;
                    tick_next  = 0;
                    data_next  = data_in;
                end
            end

            START: begin
                tx_next = 1'b0;
                if(sample_tick) begin
                    if(tick_reg == 15) begin
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
                tx_next = data_reg[0];
                if(sample_tick) begin
                    if(tick_reg == 15) begin
                        tick_next = 0;
                        data_next = data_reg >> 1;
                        if(nbits_reg == (DATA_BITS-1))
                            state_next = STOP;
                        else
                            nbits_next = nbits_reg + 1;
                    end
                    else begin
                        tick_next = tick_reg + 1;
                    end
                end
            end

            STOP: begin
                tx_next = 1'b1;
                if(sample_tick) begin
                    if(tick_reg == (STOP_TICK-1)) begin
                        state_next = IDLE;
                        tx_done    = 1'b1;
                    end
                    else begin
                        tick_next = tick_reg + 1;
                    end
                end
            end
        endcase
    end

    assign tx_data = tx_reg;

endmodule

