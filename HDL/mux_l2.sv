`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/02/2025 04:08:38 PM
// Design Name: 
// Module Name: mux_l2
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


module mux_l2
    #(
    parameter I_WIDTH = 8,
    parameter F_WIDTH = 8,
    parameter SEL_WIDTH_MUX = 3,
    parameter NUMBER_INPUT_MUX = 8
    )
    (
    input signed [I_WIDTH + F_WIDTH - 1 : 0] data_in_i [0 : NUMBER_INPUT_MUX - 1],
    input [SEL_WIDTH_MUX - 1 : 0] sel_mux_i,
    output reg signed [I_WIDTH + F_WIDTH - 1 : 0] data_out_o
    
    );
    
    assign data_out_o = data_in_i[sel_mux_i];
endmodule
