`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/25/2024 06:19:39 PM
// Design Name: 
// Module Name: XADC
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


module ADC(
    input CLK,
    input RESET,
    input vauxp6,
    input vauxn6,
    output reg [15:0] ADC_data
);

    wire enable;  
    wire [15:0] data;

    xadc_wiz_0  XLXI_7 (     
         .daddr_in(8'h16),        
         .dclk_in(CLK),        
         .den_in(enable),           
         .di_in(),               
         .dwe_in(),     
         .reset_in(RESET),            
         .vauxp6(vauxp6),            
         .vauxn6(vauxn6),
         .busy_out(),            
         .channel_out(),        
         .do_out(data),             
         .drdy_out(),            
         .eoc_out(enable),            
         .eos_out(),           
         .ot_out(),             
         .vccaux_alarm_out(),  
         .vccint_alarm_out(),  
         .user_temp_alarm_out(), 
         .alarm_out(),         
         .vp_in(),             
         .vn_in()
    );
    
    always @(posedge CLK) begin
        if (RESET) begin
            ADC_data <= 16'b0; 
        end 
        else begin
            ADC_data <= data;
        end
    end
  
endmodule
