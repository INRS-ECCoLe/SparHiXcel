`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/12/2024 01:30:01 PM
// Design Name: 
// Module Name: multiplier
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


module multiplier
    #(
        parameter I_WIDTH = 8,
        parameter F_WIDTH = 8
    )
    (
        input signed [I_WIDTH - 1 : 0] in_feature_i,
        input signed [F_WIDTH - 1 : 0] f_weight_i,
        output signed [I_WIDTH + F_WIDTH - 1 : 0] out_mul_o
    );
    
          
         assign out_mul_o = in_feature_i * f_weight_i;
         
endmodule
