`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/20/2025 02:33:47 PM
// Design Name: 
// Module Name: dram_to_memory
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


module dram_to_memory
    #(
    parameter DATA_IN_BITWIDTH = 8,
    parameter DATA_OUT_BITWIDTH = 163
    )
    (
    input clk_i,                   // Clock signal
    input dram_to_mem_rst_i,                   // Reset signal
    input [DATA_IN_BITWIDTH - 1 :0] data_in_i,         // 8-bit input data
    input data_valid_i,            // Signal indicating valid input data
    output reg [DATA_OUT_BITWIDTH -1 : 0] data_out_o, // 163-bit accumulated data
    output reg memory_write_enable, // BRAM write enable signal
    );
    reg [DATA_OUT_BITWIDTH - 1 : 0] accumulated_data; // Register to store accumulated DATA_OUT_BITWIDTH bits
    reg [$clog2(DATA_OUT_BITWIDTH) -1 : 0] bit_count;          // Counter for the number of bits accumulated
    reg [DATA_IN_BITWIDTH - 1 : 0] carry_over_bits;    // Register to hold any leftover bits from previous rounds
    reg carry_flag;
    reg [DATA_IN_BITWIDTH - 1 : 0] carry_over_number_bits;
    always @(posedge clk_i or posedge dram_to_mem_rst_i) begin
        if (dram_to_mem_rst_i) begin
            accumulated_data <= {DATA_OUT_BITWIDTH{1'b0}};  // Reset accumulated data
            bit_count <= {$clog2(DATA_OUT_BITWIDTH){1'b0}};           // Reset bit count
            carry_over_bits <= {DATA_IN_BITWIDTH{1'b0}};     // Reset carry-over bits
            memory_write_enable <= 0;      // Disable BRAM write
            carry_flag <= 0;
            carry_over_number_bits <= {DATA_IN_BITWIDTH{1'b0}};
        end else if (data_valid_i) begin

            if (bit_count + DATA_IN_BITWIDTH + carry_over_number_bits < DATA_OUT_BITWIDTH)begin
                accumulated_data <= {accumulated_data[DATA_OUT_BITWIDTH - carry_over_number_bits - DATA_IN_BITWIDTH - 1:0], carry_over_bits [carry_over_number_bits - 1 : 0], data_in_i};
                bit_count <= bit_count + DATA_IN_BITWIDTH + carry_over_number_bits;
                carry_flag <= 0;
                carry_over_number_bits <= {DATA_IN_BITWIDTH{1'b0}};  
                carry_over_bits <= {DATA_IN_BITWIDTH{1'b0}};
            end else if (bit_count < DATA_OUT_BITWIDTH) begin
 
                accumulated_data <= {accumulated_data[bit_count : 0], data_in[DATA_IN_BITWIDTH -1 : DATA_IN_BITWIDTH - (DATA_OUT_BITWIDTH - bit_count - 1)]};
                carry_over_bits [DATA_IN_BITWIDTH - (DATA_OUT_BITWIDTH - bit_count - 1) - 1 : 0] <= data_in_i[DATA_IN_BITWIDTH - (DATA_OUT_BITWIDTH - bit_count - 1) - 1 : 0];  // Store remaining bits
                carry_over_number_bits <= DATA_IN_BITWIDTH- (DATA_OUT_BITWIDTH - bit_count - 1);
                bit_count <= bit_count + DATA_OUT_BITWIDTH - bit_count - 1;
                carry_flag <= 1;
            
            end
            
            // If DATA_OUT_BITWIDTH bits are accumulated, store them to BRAM
            if (bit_count >= DATA_OUT_BITWIDTH) begin
                data_out_o <= accumulated_data;    // Store accumulated data
                memory_write_enable <= 1;           // Enable BRAM write
                bit_count <= 0;                   // Reset bit count
            end else begin
                memory_write_enable <= 0;           // No write to BRAM yet
            end
        end
    end
endmodule


