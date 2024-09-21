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
        output [MEMORY_WIDTH - 1 : 0] mem_data_o
    );

    reg [MEMORY_WIDTH - 1 : 0] memory [ADDRS_WIDTH - 1 : 0] ;
 
    assign mem_data_o = rd_mem_ld_i ? memory[addrs_mem_i] : {MEMORY_WIDTH{1'b0}};
   
    initial begin
      $readmemb("weight.mem",memory);
    end
    

endmodule
