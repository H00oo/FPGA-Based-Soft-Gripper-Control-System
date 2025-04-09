`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/19/2025 08:06:14 PM
// Design Name: 
// Module Name: fifo
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


module fifo #(
    parameter DATA_SIZE = 8,
    parameter ADDR_SIZE_EXP = 12
)(
    input  CLK,
    input  RESET,
    input  rd_from_fifo,
    input  wr_to_fifo,
    input  [DATA_SIZE-1:0] wr_data_in,
    output [DATA_SIZE-1:0] rd_data_out,
    output empty,
    output full
);
    
    reg [DATA_SIZE-1:0] mem [2**ADDR_SIZE_EXP-1:0];
    
    reg [ADDR_SIZE_EXP-1:0] curr_wr_addr, curr_wr_addr_buff, next_wr_addr;
    reg [ADDR_SIZE_EXP-1:0] curr_rd_addr, curr_rd_addr_buff, next_rd_addr;
    reg fifo_full, fifo_empty, full_buff, empty_buff;
    wire write_en;
    
    assign write_en = wr_to_fifo & (~fifo_full);
    
    // Memory Write
    always @(posedge CLK) begin
        if(write_en)
            mem[curr_wr_addr] <= wr_data_in;
    end
    
    // Memory Read
    assign rd_data_out = mem[curr_rd_addr];   
    
    // Update Addresses and Flags
    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            curr_wr_addr <= 0;
            curr_rd_addr <= 0;
            fifo_full    <= 1'b0;
            fifo_empty   <= 1'b1;
        end
        else begin
            curr_wr_addr <= curr_wr_addr_buff;
            curr_rd_addr <= curr_rd_addr_buff;
            fifo_full    <= full_buff; 
            fifo_empty   <= empty_buff;
        end
    end
    
    // Next State Logic
    always @ (*) begin
        next_wr_addr = curr_wr_addr + 1;
        next_rd_addr = curr_rd_addr + 1;
        
        // Default assignments
        curr_wr_addr_buff = curr_wr_addr;
        curr_rd_addr_buff = curr_rd_addr;
        full_buff  = fifo_full;
        empty_buff = fifo_empty;
        
        // Condition on Write-Read enable 
        case({wr_to_fifo, rd_from_fifo})
            2'b01: begin // Read enabled
                if(~fifo_empty) begin
                    curr_rd_addr_buff = next_rd_addr;
                    full_buff = 1'b0;
                    if(next_rd_addr == curr_wr_addr)
                        empty_buff = 1'b1; 
                end
            end
            2'b10: begin // Write enabled
                if(~fifo_full) begin
                    curr_wr_addr_buff = next_wr_addr;
                    empty_buff = 1'b0;
                    if(next_wr_addr == curr_rd_addr)
                        full_buff = 1'b1; 
                end
            end
            2'b11: begin // Both Write and Read enabled
                curr_wr_addr_buff = next_wr_addr;
                curr_rd_addr_buff = next_rd_addr;
                // No change to fifo_full and fifo_empty as write and read balance each other
            end
            default: ; // 2'b00: No operation
        endcase
    end
    
    // Output Assignments
    assign full  = fifo_full;
    assign empty = fifo_empty;
    
endmodule

