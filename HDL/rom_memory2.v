`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/19/2024 04:58:56 PM
// Design Name: 
// Module Name: rom_memory2
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


module rom_memory2
    #(
        parameter MEMORY_WIDTH = 72,
        parameter ADDRS_WIDTH = 8
    )
    (
        input [ADDRS_WIDTH - 1 : 0] addrs_mem_i,
        input rd_mem_ld_i,
        input clk_i,
        input [MEMORY_WIDTH - 1 : 0] mem2_data_i,
        input [ADDRS_WIDTH - 1 : 0] wr_addrs_mem2_i,
        input wr_mem2_ld_i,
        output reg [MEMORY_WIDTH - 1 : 0] mem_data_o
    );

    reg [MEMORY_WIDTH - 1 : 0] memory [ADDRS_WIDTH - 1 : 0] ;
    
    always @(posedge clk_i) begin
        if (wr_mem2_ld_i == 1) begin
            memory[wr_addrs_mem2_i] <= mem2_data_i;
        end 
        if (rd_mem_ld_i == 1) begin
            mem_data_o <= memory[addrs_mem_i];
        end else begin
            mem_data_o <= {MEMORY_WIDTH{1'b0}};
        end
    end
 
   // assign mem_data_o = rd_mem_ld_i ? memory[addrs_mem_i] : {MEMORY_WIDTH{1'b0}};
   
    initial begin
      $readmemb("weight.mem",memory);
    end
    

endmodule
