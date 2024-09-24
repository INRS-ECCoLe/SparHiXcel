`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/19/2024 01:53:18 PM
// Design Name: 
// Module Name: rom_signals
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


module rom_signals
    #(
        parameter MEMORY_WIDTH = 63,
        parameter ADDRS_WIDTH = 4
    )
    (
        input [ADDRS_WIDTH - 1 : 0] addrs_rom_signal_i,
        input rd_rom_signals_ld_i,
        input clk_i,
        input [ADDRS_WIDTH - 1 : 0] wr_addrs_rom_signal_i,
        input wr_rom_signals_ld_i,
        input [MEMORY_WIDTH - 1 : 0] rom_signals_data_i,
        output reg [MEMORY_WIDTH - 1 : 0] rom_signals_data_o
    );

    reg [MEMORY_WIDTH - 1 : 0] memory [ADDRS_WIDTH - 1 : 0] ;
    
    always @(posedge clk_i) begin
        if (wr_rom_signals_ld_i == 1) begin
            memory[wr_addrs_rom_signal_i] <= rom_signals_data_i;
        end
        if (rd_rom_signals_ld_i == 1) begin
            rom_signals_data_o <= memory[addrs_rom_signal_i];
        end else begin
            rom_signals_data_o <= {MEMORY_WIDTH{1'b0}};
        end
    end
    
    //assign rom_signals_data_o = rd_rom_signals_ld_i ? memory[addrs_rom_signal_i] : {MEMORY_WIDTH{1'b0}};
   
    initial begin
      $readmemb("signal.mem",memory);
    end
    

endmodule