`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/02/2023 03:46:50 PM
// Design Name: 
// Module Name: BIT
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


module BIT(
    input CLK,
    input RESET,
    input [15:0] Curr_Pressure_value,
    output [4:0] DecValue0,
    output [4:0] DecValue1,
    output [4:0] DecValue2,
    output [4:0] DecValue3,
    output [1:0] StrobeCount,
    output [15:0] decimal_sensor_value
    );
    
    wire Bit17TriggOut;
    wire [1:0] StrobeCount1;
    
    reg [3:0] DecCount0;
    reg [3:0] DecCount1;
    reg [3:0] DecCount2;
    reg [3:0] DecCount3;
    
    reg [16:0] Real_Value;
    reg [15:0] Normalized_Value;
    reg [3:0] dec3;
    reg [3:0] dec2;
    reg [3:0] dec1;
    reg [3:0] dec0;
    
    reg [15:0] Pressure_value = 0;
    
        //The 17 bit counter
    Generic_counter # (
        .COUNTER_WIDTH(17),
        .COUNTER_MAX(99999)
        )
        Bit17Counter(
        .CLK(CLK),
        .RESET(1'b0),
        .ENABLE(1'b1),
        .TRIG_OUT(Bit17TriggOut),
        .COUNT()
    );
        
    //The StrobeCount counter
    Generic_counter # (
        .COUNTER_WIDTH(2),
        .COUNTER_MAX(3)
        )
        Bit2Counter(
        .CLK(CLK),
        .RESET(1'b0),
        .ENABLE(Bit17TriggOut),
        .TRIG_OUT(),
        .COUNT(StrobeCount1)
    );
    
    //secen segment controller signals
    reg [32:0] count;
    localparam S_IDLE = 0;
    localparam S_FRAME_WAIT = 1;
    localparam S_CONVERSION = 2;
    reg [1:0] state = S_IDLE;
    reg [15:0] sseg_data;
    
    //binary to decimal converter signals
    reg b2d_start;
    reg [15:0] b2d_din;
    wire [15:0] b2d_dout;
    wire b2d_done;
    
    //binary to decimal conversion
    always @ (posedge(CLK)) begin
        case (state)
        S_IDLE: begin
            state <= S_FRAME_WAIT;
            count <= 'b0;
        end
        S_FRAME_WAIT: begin
            if (count >= 10000000) begin
                if (Curr_Pressure_value > 16'hFFD0) begin
                    sseg_data <= 16'h1000;
                    state <= S_IDLE;
                end else begin
                    b2d_start <= 1'b1;
                    b2d_din <= Curr_Pressure_value;
                    state <= S_CONVERSION;
                end
            end else
                count <= count + 1'b1;
        end
        S_CONVERSION: begin
            b2d_start <= 1'b0;
            if (b2d_done == 1'b1) begin
                sseg_data <= b2d_dout;
                state <= S_IDLE;
            end
        end
        endcase
    end
    
    bin2dec m_b2d (
        .CLK(CLK),
        .start(b2d_start),
        .din(b2d_din),
        .done(b2d_done),
        .dout(b2d_dout)
    );
    
    always @(posedge CLK) begin
        Real_Value <= sseg_data[3:0] + sseg_data[7:4] * 16'd10 + sseg_data[11:8] * 16'd100 + sseg_data[15:12] * 16'd1000;
        if (Real_Value <= 16'd500) begin
            Normalized_Value <= 0;
        end
        else begin
            Normalized_Value <= ((Real_Value - 16'd500) * 16'd15) / 16'd4;
        end
        dec3 <= Normalized_Value / 16'd1000; 
        dec2 <= (Normalized_Value / 16'd100) % 10;
        dec1 <= (Normalized_Value / 16'd10) % 10;
        dec0 <= Normalized_Value % 10;
    end
    
    assign DecValue0 = {1'b1, dec0};
    assign DecValue1 = {1'b1, dec1};
    assign DecValue2 = {1'b0, dec2};
    assign DecValue3 = {1'b1, dec3};
        
    assign StrobeCount = StrobeCount1;
    assign decimal_sensor_value = Normalized_Value;
    
endmodule
