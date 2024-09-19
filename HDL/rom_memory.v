`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/19/2024 11:54:59 AM
// Design Name: 
// Module Name: rom_memory
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


module rom_memory
    #(
        parameter MEMORY_WIDTH = 72,
        parameter ADDRS_WIDTH = 8,
        parameter FINISH_MEM = 4
    )
    (
        input [ADDRS_WIDTH - 1 : 0] addrs_mem_i,
        input clk_i,
        input rd_mem_ld_i,
        output [MEMORY_WIDTH - 1 : 0] mem_data_o,
        output reg end_mem_o
    );

    reg [MEMORY_WIDTH - 1 : 0] memory [ADDRS_WIDTH - 1 : 0] ;
 
    assign mem_data_o = rd_mem_ld_i ? memory[addrs_mem_i] : {MEMORY_WIDTH{1'b0}};
   
    initial begin
      $readmemb("content.mem",memory);
    end
endmodule

