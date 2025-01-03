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
    parameter ADDR_WIDTH = 15 
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
    output reg [DATA_WIDTH - 1 : 0] data_out_a_o,
    output reg [DATA_WIDTH - 1 : 0] data_out_b_o 
    );
    
   
    reg [DATA_WIDTH-1:0] bram [0:(2**ADDR_WIDTH)-1];

    // Port A Read/Write Process
    always @(posedge clk_i or posedge bram_rst_i) begin
        if (bram_rst_i) begin
            data_out_a_o <= 0;  // Reset output to 0
        end else begin
            if (bram_wr_en_a_i) begin
                bram[addr_a_i] <= data_in_a_i; // Write to BRAM on port A
            end
            data_out_a_o <= bram[addr_a_i];    // Read from BRAM on port A
        end
    end

    // Port B Read/Write Process
    always @(posedge clk_i or posedge bram_rst_i) begin
        if (bram_rst_i) begin
            data_out_b_o <= 0;  // Reset output to 0
        end else begin
            if (bram_wr_en_b_i) begin
                bram[addr_b_i] <= data_in_b_i; // Write to BRAM on port B
            end
            data_out_b_o <= bram[addr_b_i];    // Read from BRAM on port B
        end
    end
    
endmodule
