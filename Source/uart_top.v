`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/19/2025 08:17:41 PM
// Design Name: 
// Module Name: uart_top
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


module uart_top #(
    parameter DATA_BITS = 8,
    parameter STOP_TICK = 16,
    parameter BR_COUNT  = 651,
    parameter BR_BITS   = 10,
    parameter FIFO_EXP  = 12
)(
    input CLK,
    input RESET, 
    input read_uart, 
    input write_uart,         
    input rx_data_in,                    
    input [DATA_BITS-1:0] write_data,    
    
    output rx_full, 
    output rx_empty, 
    output tx_full,   
    output tx_data_out,                  
    output [DATA_BITS-1:0] read_data     
);
    
    // Interconnect Wires
    wire tick;
    wire rx_done, tx_done;
    wire tx_fifo_empty, tx_fifo_not_empty;
    wire [DATA_BITS-1:0] tx_fifo_out, rx_fifo_in;
    
    // Baud Rate Generator
    baud_rate_generator #(
        .N(BR_BITS), 
        .COUNT(BR_COUNT)
    ) 
    baud_rate_gen_module (
        .CLK(CLK), 
        .RESET(RESET), 
        .tick(tick)
    );
    
    // UART Transmitter
    uart_transmitter #(
        .DATA_BITS(DATA_BITS), 
        .STOP_TICK(STOP_TICK)
    ) 
    uart_tx_module (
        .CLK(CLK), 
        .RESET(RESET), 
        .tx_start(tx_fifo_not_empty), 
        .sample_tick(tick), 
        .data_in(tx_fifo_out), 
        .tx_done(tx_done), 
        .tx_data(tx_data_out)
    );
                          
    // UART Receiver
    uart_receiver #(
        .DATA_BITS(DATA_BITS), 
        .STOP_TICK(STOP_TICK)
    ) 
    uart_rx_module (
        .CLK(CLK), 
        .RESET(RESET), 
        .rx_data(rx_data_in), 
        .sample_tick(tick), 
        .data_out(rx_fifo_in), 
        .data_ready(rx_done)
    );
                          
    // Transmit FIFO
    fifo #(
        .DATA_SIZE(DATA_BITS), 
        .ADDR_SIZE_EXP(FIFO_EXP)
    ) 
    fifo_tx_module (
        .CLK(CLK), 
        .RESET(RESET), 
        .rd_from_fifo(tx_done), 
        .wr_to_fifo(write_uart),
        .wr_data_in(write_data), 
        .rd_data_out(tx_fifo_out), 
        .empty(tx_fifo_empty), 
        .full(tx_full)
    );
        
    // Receive FIFO
    fifo #(
        .DATA_SIZE(DATA_BITS), 
        .ADDR_SIZE_EXP(FIFO_EXP)
    ) 
    fifo_rx_module (
        .CLK(CLK), 
        .RESET(RESET), 
        .rd_from_fifo(read_uart), 
        .wr_to_fifo(rx_done),
        .wr_data_in(rx_fifo_in), 
        .rd_data_out(read_data), 
        .empty(rx_empty), 
        .full(rx_full)
    );
        
    // Additional Logic
    assign tx_fifo_not_empty = ~tx_fifo_empty;
    
endmodule

