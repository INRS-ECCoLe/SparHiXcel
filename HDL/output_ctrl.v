`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/28/2025 03:57:30 PM
// Design Name: 
// Module Name: output_ctrl
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


module output_ctrl
    #(
        parameter NUMBER_SUPPORTED_FILTERS = 30,
        parameter N_COLS_ARRAY = 16,
        parameter DRAM_ADDR_WIDTH = 18,
        parameter BRAM_ADDR_WIDTH = 11
    )
    (
        input clk_i,
        input general_rst_i,
        input [3:0]sa_state_i,
        input order_empty_bram_i,
        output reg bram_ready_o,
        output reg [BRAM_ADDR_WIDTH - 1 : 0] bram_rd_address_o,
        output reg [DRAM_ADDR_WIDTH - 1 : 0] dram_wr_address_o,
        output [$clog2(NUMBER_SUPPORTED_FILTERS) - 1 : 0] sel_mux_final_o,
        output [0 : ((NUMBER_SUPPORTED_FILTERS + N_COLS_ARRAY - 1) / N_COLS_ARRAY)  - 1] bram_wr_en_b_o 
        
    
    );
    
    
endmodule
