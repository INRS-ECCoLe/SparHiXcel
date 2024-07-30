`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/12/2024 12:03:51 PM
// Design Name: 
// Module Name: adder
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


module adder
    #(
        parameter I_WIDTH = 8,
        parameter F_WIDTH = 8
    )
    (
        input signed [I_WIDTH + F_WIDTH - 1 : 0] a_i,
        input signed [I_WIDTH + F_WIDTH - 1 : 0] b_i,
        input en_adder_i,
        output reg signed [I_WIDTH + F_WIDTH - 1 : 0] sum_o,
        output reg c_o
    );

        always @ (*)begin
            if (en_adder_i) begin
                {c_o,sum_o} = a_i + b_i;
            end else begin
                {c_o,sum_o} = {1'b0 , a_i} ;
            end 
        end
endmodule
