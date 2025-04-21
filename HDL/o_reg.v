`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/14/2024 02:59:24 PM
// Design Name: 
// Module Name: o_reg
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


module o_reg
#(
    parameter F_WIDTH = 8,
    parameter I_WIDTH = 8
    )
    (
    input signed [F_WIDTH + I_WIDTH - 1 : 0] wr_data_i,
    input clk_i,
    input oreg_rst_i,
    input oreg_wr_en_i,
    output reg signed [F_WIDTH + I_WIDTH - 1 : 0] rd_data_o
    );
   
    always @ (posedge clk_i) begin  // or posedge oreg_rst_i deleted
        if (oreg_rst_i) begin
            rd_data_o <= 0;
        end else if (oreg_wr_en_i) begin 
                rd_data_o <= wr_data_i;
            
        end
    end
endmodule
