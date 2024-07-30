`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/18/2024 04:49:40 PM
// Design Name: 
// Module Name: mux_n_1
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


module mux_n_1
    #(
        parameter I_WIDTH = 8,
        parameter F_WIDTH = 8,
        parameter LEN_TRANSFER = 8,
        parameter MAX_LEN_TRANSFER = 8,
        parameter SEL_MUX_TR_WIDTH = $clog2(MAX_LEN_TRANSFER)
        
    )
    (
        input signed [I_WIDTH + F_WIDTH - 1 : 0] tr_data_i [0 : LEN_TRANSFER - 1],
        input [SEL_MUX_TR_WIDTH - 1 : 0] sel_mux_tr_i,
        input clk_i,
        input sel_mux_tr_rst_i,
        input sel_mux_tr_ld_i,
        output reg [SEL_MUX_TR_WIDTH - 1 : 0] sel_mux_tr_o,
        output signed [I_WIDTH + F_WIDTH - 1 : 0] tr_data_o
    );
        always @ (posedge clk_i or posedge sel_mux_tr_rst_i) begin 
        
            if (sel_mux_tr_rst_i) begin
                sel_mux_tr_o <= 0;
                
            end else if (sel_mux_tr_ld_i) begin
             
                    sel_mux_tr_o <= sel_mux_tr_i;
                
            end
        end
        
        assign tr_data_o = tr_data_i [sel_mux_tr_o];       
    
endmodule
