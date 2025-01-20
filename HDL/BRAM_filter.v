`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/31/2024 04:55:36 PM
// Design Name: 
// Module Name: BRAM_filter
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


module BRAM_filter
    #(
    parameter DATA_WIDTH = 16,
    parameter ADDR_WIDTH = 11 
    )
    (
    input clk_i,
    input bram_rst_i,
    input bram_wr_en_a_i,
    input bram_wr_en_b_i,
    input [ADDR_WIDTH - 1 : 0] addr_a_i,
    input [ADDR_WIDTH - 1 : 0] addr_b_i,
    input [DATA_WIDTH - 1 : 0] data_in_a_i,
    input [DATA_WIDTH - 1 : 0] data_in_b_i,
    output [DATA_WIDTH - 1 : 0] data_out_a_o,
    output [DATA_WIDTH - 1 : 0] data_out_b_o 
    );
    
blk_mem_gen_0 bram
(
  .clka(clk_i),    // input wire clka
  .rsta(bram_rst_i),    // input wire rsta
  .ena(1),      // input wire ena
  .wea(bram_wr_en_a_i),      // input wire [0 : 0] wea
  .addra(addr_a_i),  // input wire [10 : 0] addra
  .dina(data_in_a_i),    // input wire [15 : 0] dina
  .douta(data_out_a_o),  // output wire [15 : 0] douta
  .clkb(clk_i),    // input wire clkb
  .rstb(bram_rst_i),    // input wire rstb
  .enb(1),      // input wire enb
  .web(bram_wr_en_a_i),      // input wire [0 : 0] web
  .addrb(addr_b_i),  // input wire [10 : 0] addrb
  .dinb(data_in_b_i),    // input wire [15 : 0] dinb
  .doutb(data_out_b_o)  // output wire [15 : 0] doutb
);

endmodule

