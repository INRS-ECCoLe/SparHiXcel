`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/17/2024 11:40:46 AM
// Design Name: 
// Module Name: control
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


module control
    #(
        parameter N = 3,
        parameter ADDRS_WIDTH = $clog2(N-1),
        parameter NUM_COL_WIDTH = $clog2(N),
        parameter SEL_WIDTH = $clog2(N)
    )
    (
        input [NUM_COL_WIDTH - 1 : 0] column_num_i, // 1 2 3 4 ...
        input clk_i,
        input column_num_rst_i,// internal
        input column_num_ld_i, // internal
        input mreg_start_i,
        input mreg_addrs_rst_i, //works as initializer for the address
        input [SEL_WIDTH - 1: 0] f_sel_i,
        input f_sel_rst_i,
        input f_sel_ld_i,
        input en_adder_1_i,
        input en_adder_rst_i,
        input en_adder_ld_i,
        input en_adder_2_i,
        output reg en_adder_1_o,
        output reg en_adder_2_o,
        output reg [NUM_COL_WIDTH - 1 : 0] column_num_o,
        output reg [SEL_WIDTH - 1: 0] f_sel_o,
        output reg [ADDRS_WIDTH - 1 : 0] mreg_wr_addrs_o,
        output [ADDRS_WIDTH - 1 : 0] mreg_rd_addrs_o
    );
    
        always @ (posedge clk_i) begin 
            if (mreg_addrs_rst_i) begin 
                if (column_num_o < N) begin
                    mreg_wr_addrs_o <= column_num_o - 1;
                end else begin
                    mreg_wr_addrs_o <= 0;
                end
            end  else if (mreg_start_i) begin
                if (mreg_wr_addrs_o == 0) begin
                    mreg_wr_addrs_o <= N - 2;
                end else begin 
                    mreg_wr_addrs_o <= mreg_wr_addrs_o - 1;
                end
            end
       
        end
        assign mreg_rd_addrs_o = ( mreg_wr_addrs_o == (N - 2) ) ? 0 : (mreg_wr_addrs_o + 1) ;    
        
        // REGISTER FOR F_SEL_I
        always @ (posedge clk_i or posedge f_sel_rst_i) begin 
        
            if (f_sel_rst_i) begin
                f_sel_o <= 0;
                
            end else if (f_sel_ld_i) begin
             
                    f_sel_o <= f_sel_i;
                
            end
        end
        
         // REGISTER FOR column_num_i
        always @ (posedge clk_i or posedge column_num_rst_i) begin 
        
            if (column_num_rst_i) begin
                column_num_o <= 0;
                
            end else if (column_num_ld_i) begin
             
                    column_num_o <= column_num_i;
                
            end
        end
        
        // REGISTER FOR en_adder_1_i
        always @ (posedge clk_i or posedge en_adder_rst_i) begin 
        
            if (en_adder_rst_i) begin
                en_adder_1_o <= 0;
                
            end else if (en_adder_ld_i) begin
             
                    en_adder_1_o <= en_adder_1_i;
                
            end
        end
        
        // REGISTER FOR en_adder_2_i
        always @ (posedge clk_i or posedge en_adder_rst_i) begin 
        
            if (en_adder_rst_i) begin
                en_adder_2_o <= 0;
                
            end else if (en_adder_ld_i) begin
             
                    en_adder_2_o <= en_adder_2_i;
                
            end
        end
endmodule
