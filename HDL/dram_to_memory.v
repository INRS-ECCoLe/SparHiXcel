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
    (
    input clk,                   // Clock signal
    input rst,                   // Reset signal
    input [7:0] data_in,         // 8-bit input data
    input data_valid,            // Signal indicating valid input data
    output reg [162:0] bram_data, // 163-bit accumulated data
    output reg bram_write_enable, // BRAM write enable signal
    output reg [7:0] bram_addr   // BRAM address
    );
    reg [162:0] accumulated_data; // Register to store accumulated 163 bits
    reg [7:0] bit_count;          // Counter for the number of bits accumulated
    reg [7:0] carry_over_bits;    // Register to hold any leftover bits from previous rounds

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            accumulated_data <= 163'b0;  // Reset accumulated data
            bit_count <= 8'b0;           // Reset bit count
            carry_over_bits <= 8'b0;     // Reset carry-over bits
            bram_write_enable <= 0;      // Disable BRAM write
        end else if (data_valid) begin
            // Accumulate the new data, handling any carry-over bits from the previous round
            if (bit_count + 8 <= 163) begin
                // Just shift in the new 8-bit data without carry over
                accumulated_data <= {accumulated_data[154:0], data_in};
                bit_count <= bit_count + 8;
            end else begin
                // Handle leftover bits from previous round
                if (bit_count < 163) begin
                    // Shift in the remaining bits
                    accumulated_data <= {accumulated_data[154:0], data_in[7:0]};
                    carry_over_bits <= data_in[7:0];  // Store remaining bits
                    bit_count <= bit_count + 8;
                end
            end
            
            // If 163 bits are accumulated, store them to BRAM
            if (bit_count >= 163) begin
                bram_data <= accumulated_data;    // Store accumulated data
                bram_write_enable <= 1;           // Enable BRAM write
                bit_count <= 0;                   // Reset bit count
                carry_over_bits <= 8'b0;          // Reset carry-over bits
            end else begin
                bram_write_enable <= 0;           // No write to BRAM yet
            end
        end
    end
endmodule


