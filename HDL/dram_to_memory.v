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
    input [DATA_IN_BITWIDTH - 1 :0] data_in_i,         // DATA_IN_BITWIDTH-bit input data
    input data_valid_i,            // Signal indicating valid input data
    output reg [DATA_OUT_BITWIDTH -1 : 0] data_out_o, // DATA_OUT_BITWIDTH-bit accumulated data
    output reg memory_write_enable // BRAM write enable signal
    );
    localparam DIV_CEILING = (DATA_IN_BITWIDTH + DATA_OUT_BITWIDTH - 1) / DATA_IN_BITWIDTH;
    localparam DATA_ACCU_BITWIDTH = DATA_IN_BITWIDTH * DIV_CEILING;
    reg [DATA_ACCU_BITWIDTH - 1 : 0] accumulated_data; // Register to store accumulated DATA_OUT_BITWIDTH bits
    reg [$clog2(DATA_ACCU_BITWIDTH) -1 : 0] bit_count;          // Counter for the number of bits accumulated
    reg [DATA_IN_BITWIDTH - 1 :0] data_in;
    wire counter;
    always @(posedge clk_i or posedge dram_to_mem_rst_i) begin
        if (dram_to_mem_rst_i) begin
            data_in <= {DATA_IN_BITWIDTH{1'b0}};
        end else if (data_valid_i) begin 
            data_in <= data_in_i;
        end
    end
    counter
    #(
        .COUNTER_WIDTH(1)    
    )
    count_one_clk_delay
    (
        .clk_i(clk_i),
        .counter_rst_i(dram_to_mem_rst_i),
        .counter_ld_i(data_valid_i&& counter != 1),
        .count_num_o(counter)
    ); 
    always @(posedge clk_i or posedge dram_to_mem_rst_i) begin
        if (dram_to_mem_rst_i) begin
            accumulated_data <= {DATA_ACCU_BITWIDTH{1'b0}};  // Reset accumulated data
            bit_count <= {$clog2(DATA_ACCU_BITWIDTH){1'b0}};           // Reset bit count
            memory_write_enable <= 0;      // Disable BRAM write
            data_out_o <= {DATA_OUT_BITWIDTH{1'b0}};
        end else if (data_valid_i && (counter == 1)) begin
            //if (DATA_IN_BITWIDTH < DATA_OUT_BITWIDTH) begin

            if (bit_count < DATA_ACCU_BITWIDTH - 1)begin
            
                accumulated_data <= {accumulated_data[DATA_ACCU_BITWIDTH - DATA_IN_BITWIDTH - 1 : 0], data_in};
                bit_count <= bit_count + DATA_IN_BITWIDTH;
          
            end
            
            // If DATA_OUT_BITWIDTH bits are accumulated, store them to BRAM
            if (bit_count >= DATA_OUT_BITWIDTH) begin
            
                data_out_o <= accumulated_data[DATA_ACCU_BITWIDTH - 1 : DATA_ACCU_BITWIDTH - DATA_OUT_BITWIDTH];    // Store accumulated data
                memory_write_enable <= 1;           // Enable BRAM write
                bit_count <= 0;                   // Reset bit count
                
            end else begin
                memory_write_enable <= 0;           // No write to BRAM yet
            end

        end 
    end
endmodule


