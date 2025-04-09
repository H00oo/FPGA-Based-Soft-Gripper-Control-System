`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/10/2024 12:19:59 PM
// Design Name: 
// Module Name: TOP
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


module TOP#(
    parameter DATA_BITS = 8,
    parameter STOP_TICK = 16,
    parameter BR_COUNT  = 651,
    parameter BR_BITS   = 10,
    parameter FIFO_EXP  = 4
)
    (
    input CLK,
    input RESET,
    input vauxp6,
    input vauxn6,
    input resetn,
    input rx,
    output tx,
    output [3:0] SEG_SELECT_OUT,
    output [7:0] HEX_OUT,
    output Pump_Outer_Control_LED,
    output Pump_Inner_Control_LED,
    output Value_Outer_Control_LED,
    output Valve_Inner_Control_LED,
    output Pump_Outer_Control,
    output Pump_Inner_Control,
    output Value_Outer_Control,
    output Valve_Inner_Control,
    output Full_state,
    output Empty_state
    );
    
    // UART Connection Signals
    wire rx_full, rx_empty;
    wire [7:0] rec_data;
    
    // UART Control Signals
    wire Start_signal;
    wire Read_tick;
    wire Write_tick;
    wire [7:0] data;
        
    // Define the wire for PID and Controll output
    wire signed [15:0] PID_out;
    wire Pump_Outer_Control_Signal;
    wire Pump_Inner_Control_Signal;
    wire Value_Outer_Control_Signal;
    wire Valve_Inner_Control_Signal;
    
    // Define the wire for counters
    wire [1:0] StrobeCount;
    // Define the wire for dec count number   
    wire [4:0] DEC0;
    wire [4:0] DEC1;
    wire [4:0] DEC2;
    wire [4:0] DEC3;
    // Define the wire for multiplexer output
    wire [4:0] MuxOut;
    
    // Define the wire for ADC output
    wire [15:0] ADC_data;
    wire [15:0] decimal_sensor_value;
    // Define the wire for PWM_Frequency
    wire PWM_Frequency;
    
    // Define the wire for PID_Sample_Frequency
    wire PID_Sample_Frequency;
    
    // 10 MHz counter
    Generic_counter # (
        .COUNTER_WIDTH(4),
        .COUNTER_MAX(9)
        )
        TenMHzCounter(
        .CLK(CLK),
        .RESET(1'b0),
        .ENABLE(1'b1),
        .TRIG_OUT(PWM_Frequency),
        .COUNT()
    );
    
    // 100 KHz counter
    Generic_counter # (
        .COUNTER_WIDTH(10),
        .COUNTER_MAX(999)
        )
        HundredKHzCounter(
        .CLK(CLK),
        .RESET(1'b0),
        .ENABLE(1'b1),
        .TRIG_OUT(PID_Sample_Frequency),
        .COUNT()
    );     
    
    // Call the UART top mudule
     uart_top UART(
       .CLK(CLK), 
       .RESET(RESET), 
       .read_uart(Read_tick), 
       .write_uart(Write_tick),         
       .rx_data_in(rx),                    
       .write_data(data),    
      
       .rx_full(rx_full), 
       .rx_empty(rx_empty),
       .tx_data_out(tx),                  
       .read_data(rec_data)
   );       
    
    // Call the module for Start_signal for pump
    Start_control start(
        .CLK(CLK),
        .RESET(RESET),
        .rec_data(rec_data),
        .Read_tick(Read_tick),
        .Start_signal(Start_signal)
    );
    
    // Call the module for Feedback to terminal
    Data_feedback feedback(
        .CLK(CLK),
        .RESET(RESET),
        .Start_signal(Start_signal),
        .DEC0(DEC0[3:0]),
        .DEC1(DEC1[3:0]),
        .DEC2(DEC2[3:0]),
        .DEC3(DEC3[3:0]),
        .Write_tick(Write_tick),
        .data(data)
    );
    
    // Call the module for PID controll
    PID PID(
        .CLK(CLK),
        .PID_Sample_Frequency(PID_Sample_Frequency),
        .RESET(RESET),
        .Curr_Pressure_value(decimal_sensor_value),
        .PID_out(PID_out)
    );
    
    // Call the module for Pump control    
    Pump_Control Pump(
        .CLK(CLK),
        .RESET(RESET),
        .Start(Start_signal),
        .PID_in(PID_out),
        .PWM_Frequency(PWM_Frequency),
        .Pump_Outer_Control_Signal(Pump_Outer_Control_Signal),
        .Pump_Inner_Control_Signal(Pump_Inner_Control_Signal),
        .Value_Outer_Control_Signal(Value_Outer_Control_Signal),
        .Valve_Inner_Control_Signal(Valve_Inner_Control_Signal)
    );
    
    // Call the module for ADC reading
    ADC ADC(
        .CLK(CLK),
        .RESET(RESET),
        .vauxp6(vauxp6),
        .vauxn6(vauxn6),
        .ADC_data(ADC_data)
    );
    
    // Call the module for presenting pressure value
    BIT control(
        .CLK(CLK),
        .RESET(RESET),
        .Curr_Pressure_value(ADC_data),
        .DecValue0(DEC0),
        .DecValue1(DEC1),
        .DecValue2(DEC2),
        .DecValue3(DEC3),
        .StrobeCount(StrobeCount),
        .decimal_sensor_value(decimal_sensor_value)   
    );
    
    //Call the module for 4 way multiplexer
    Multiplexer_4way Mux4(
        .CONTROL(StrobeCount),
        .IN0(DEC0),
        .IN1(DEC1),
        .IN2(DEC2),
        .IN3(DEC3),
        .OUT(MuxOut)
    );
    
    //Call the module for 7 seg display   
    Decoding_the_world seg0(
        .SEG_SELECT_IN (StrobeCount),
        .BIN_IN(MuxOut[3:0]),
        .DOT_IN(MuxOut[4]),
        .SEG_SELECT_OUT(SEG_SELECT_OUT),
        .HEX_OUT(HEX_OUT)
    );
    
    // Assign the LED light for the control_signal
    assign Pump_Outer_Control_LED = Pump_Outer_Control_Signal;
    assign Pump_Outer_Control = Pump_Outer_Control_Signal;
    
    assign Pump_Inner_Control_LED = Pump_Inner_Control_Signal;
    assign Pump_Inner_Control = Pump_Inner_Control_Signal;
    
    assign Value_Outer_Control_LED = Value_Outer_Control_Signal;
    assign Value_Outer_Control = Value_Outer_Control_Signal;
    
    assign Valve_Inner_Control_LED = Valve_Inner_Control_Signal;
    assign Valve_Inner_Control = Valve_Inner_Control_Signal;
        
    assign Full_state = rx_full;
    assign Empty_state = rx_empty;
endmodule
