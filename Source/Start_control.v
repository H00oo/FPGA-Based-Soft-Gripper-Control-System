`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/20/2025 04:45:13 PM
// Design Name: 
// Module Name: Start_control
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


module Start_control(
    input CLK,
    input RESET,
    input [7:0] rec_data,
    output reg Read_tick,
    output Start_signal
);

    reg [2:0] Curr_Start_state;
    reg [2:0] Next_Start_state;
    reg [2:0] Curr_Stop_state;
    reg [2:0] Next_Stop_state;
    
    reg Curr_control_signal = 1'b0;
    reg Next_control_signal = 1'b0;
    
    wire CLK_01;
    
    // 0.1second counter
    Generic_counter # (
        .COUNTER_WIDTH(24),
        .COUNTER_MAX(9999999)
        )
        tenthsecondCounter(
        .CLK(CLK),
        .RESET(1'b0),
        .ENABLE(1'b1),
        .TRIG_OUT(CLK_01),
        .COUNT()
    );
    
    always @(posedge CLK_01) begin
        if(rec_data > 8'h00)
            Read_tick <= 1'b1;
        else
            Read_tick <= 1'b0;
    end
    
    always @(posedge CLK) begin
        Curr_Start_state <= Next_Start_state;
        Curr_Stop_state <= Next_Stop_state;
        Curr_control_signal <= Next_control_signal;
    end
    
   always @(*) begin
        case (Curr_Start_state)
            3'd0: begin
                if (rec_data == 8'h53)
                    Next_Start_state = 3'd1;
                else
                    Next_Start_state = 3'd0;
            end
            
            3'd1: begin
                if (rec_data == 8'h54)                 
                    Next_Start_state = 3'd2;
                else if (rec_data == 8'h53)
                    Next_Start_state = Curr_Start_state;
                else
                    Next_Start_state = 3'd0;
            end
            
            3'd2: begin
                if (rec_data == 8'h41)
                    Next_Start_state = 3'd3;
                else if (rec_data == 8'h4f)
                    Next_Start_state = 3'd6;
                else if (rec_data == 8'h54)
                    Next_Start_state = Curr_Start_state;
                else
                    Next_Start_state = 3'd0;
            end
            
            3'd3: begin
                if (rec_data == 8'h52)
                    Next_Start_state = 3'd4;
                else if (rec_data == 8'h41)
                    Next_Start_state = Curr_Start_state;
                else
                    Next_Start_state = 3'd0;
            end
            
            3'd4: begin
                if (rec_data == 8'h54) begin
                    Next_control_signal = 1'b1;
                    Next_Start_state = 3'd5;
                end 
                else if (rec_data == 8'h52)
                    Next_Start_state = Curr_Start_state;
                else
                    Next_Start_state = 3'd0;
            end
            
            3'd5: begin
                Next_Start_state = 3'd0;
            end
            
            3'd6: begin
                if (rec_data == 8'h50)begin
                    Next_control_signal = 1'b0;
                    Next_Start_state = 3'd7;
                end
                else if (rec_data == 8'h4f)
                    Next_Start_state = Curr_Start_state;
                else
                    Next_Start_state = 3'd0;
            end
            
            3'd7: begin
                Next_Start_state = 3'd0;
            end
            
            default: begin
                Next_Start_state = 3'd0;
            end
        endcase
    end
    
    assign Start_signal = Curr_control_signal;

endmodule

