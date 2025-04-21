`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/14/2024 12:49:05 PM
// Design Name: 
// Module Name: weight_reg
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


module weight_reg
    #(
        parameter F_WIDTH = 8
    )
    (
        input signed [F_WIDTH - 1 : 0] f_weight_i,
        input clk_i,
        input wreg_rst_i,
        input wreg_wr_en_i,
        output reg signed [F_WIDTH - 1 : 0] f_weight_o
    );
        
        always @ (posedge clk_i) begin  //  or posedge wreg_rst_i deleted
        
            if (wreg_rst_i) begin
                f_weight_o <= 0;
                
            end else if (wreg_wr_en_i) begin
             
                    f_weight_o <= f_weight_i;
                
            end
        end
endmodule
