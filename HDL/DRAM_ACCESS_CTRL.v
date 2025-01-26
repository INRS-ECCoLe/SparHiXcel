`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/23/2025 02:38:50 PM
// Design Name: 
// Module Name: DRAM_ACCESS_CTRL
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


module DRAM_ACCESS_CTRL
    #(
        parameter DRAM_ADDR_WIDTH = 18,
        //parameter BRAM_ADDR_WIDTH = 11,
        parameter SIG_ADDRS_WIDTH = 16,
        parameter INPUT_FEATURE_ADDR_WIDTH = 16
        
    )
    (
        input clk_i,
        input general_rst_i,
        input [DRAM_ADDR_WIDTH - 1 : 0] input_start_addr_dram_i,
        input [DRAM_ADDR_WIDTH - 1 : 0] input_finish_addr_dram_i,
        input [DRAM_ADDR_WIDTH - 1 : 0] weight_start_addr_dram_i,
        input [DRAM_ADDR_WIDTH - 1 : 0] weight_finish_addr_dram_i,
        input [DRAM_ADDR_WIDTH - 1 : 0] signal_start_addr_dram_i,
        input [DRAM_ADDR_WIDTH - 1 : 0] signal_finish_addr_dram_i,
        output input_wr_address_o,
        output weight_signal_wr_address_o,
        output dram_rd_address_o
    );
    
    reg input_addr_rst;
    reg input_addr_ld;
    reg weight_signal_wr_addr_rst;
    reg weight_signal_wr_addr_ld;
    reg dram_read_addr_rst;
    reg dram_read_addr_ld;
    
    
    //counter for weight_signal_wr_address_o.
    counter
    #(
        .COUNTER_WIDTH(SIG_ADDRS_WIDTH)    
    )
    weight_signal_write_address
    (
        .clk_i(clk_i),
        .counter_rst_i(weight_signal_wr_addr_rst),
        .counter_ld_i(weight_signal_wr_addr_ld),
        .count_num_o(weight_signal_wr_address_o)
    );
    
    
    //counter for input_wr_address_o.
    counter
    #(
        .COUNTER_WIDTH(INPUT_FEATURE_ADDR_WIDTH)    
    )
    input_write_address
    (
        .clk_i(clk_i),
        .counter_rst_i(input_addr_rst),
        .counter_ld_i(input_addr_ld),
        .count_num_o(input_wr_address_o)
    );
    
    //counter for dram_rd_address_o.
    counter
    #(
        .COUNTER_WIDTH(DRAM_ADDR_WIDTH)    
    )
    dram_read_address
    (
        .clk_i(clk_i),
        .counter_rst_i(dram_read_addr_rst),
        .counter_ld_i(dram_read_addr_ld),
        .count_num_o(dram_rd_address_o)
    );
endmodule
