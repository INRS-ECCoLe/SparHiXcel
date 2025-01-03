`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/03/2025 05:43:29 PM
// Design Name: 
// Module Name: adder_without_en
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


module adder_without_en
    #(
        parameter I_WIDTH = 8,
        parameter F_WIDTH = 8
    )
    (
        input signed [I_WIDTH + F_WIDTH - 1 : 0] a_i,
        input signed [I_WIDTH + F_WIDTH - 1 : 0] b_i,

        output reg signed [I_WIDTH + F_WIDTH - 1 : 0] sum_o,
        output reg c_o
    );

        always @ (*)begin
            {c_o,sum_o} = a_i + b_i;
        end
endmodule
