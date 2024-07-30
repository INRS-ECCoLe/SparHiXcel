`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/12/2024 01:30:01 PM
// Design Name: 
// Module Name: mul_reg
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


module mul_reg
    #(
        parameter I_WIDTH = 8,
        parameter F_WIDTH = 8,
        parameter N = 3,
        parameter ADDRS_WIDTH = $clog2(N-1)
    )
    (
        input signed [I_WIDTH + F_WIDTH - 1 : 0] wr_data_i,
        input [ADDRS_WIDTH - 1 : 0] mreg_wr_addrs_i,
        input [ADDRS_WIDTH - 1 : 0] mreg_rd_addrs_i,
        input clk_i,
        input mreg_rst_i,
        input mreg_wr_en_i,
        output signed [I_WIDTH + F_WIDTH - 1 : 0] rd_data_o
    );
        integer i;
        reg signed [I_WIDTH + F_WIDTH - 1 : 0] memory [0 : N-2];
        
        always @ (posedge clk_i or posedge mreg_rst_i) begin 
            if (mreg_rst_i) begin
                for(i = 0 ; i < (N - 1) ; i = i + 1) begin
                    memory[i] <= {(I_WIDTH + F_WIDTH){1'b0}}; 
                end
            end else if (mreg_wr_en_i) begin
                    memory[mreg_wr_addrs_i] <= wr_data_i;
                
            end
         end
        assign rd_data_o = memory[mreg_rd_addrs_i];
endmodule 