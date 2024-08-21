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
        parameter ROM_SIG_WIDTH = 10,
        parameter SIG_ADDRS_WIDTH = 10
    )
    (
        input [SIG_ADDRS_WIDTH - 1 : 0] addrs_rom_signal_i,
        input rd_rom_signals_ld_i,
        output [ROM_SIG_WIDTH - 1 : 0] rom_signals_data_o
    );

    reg [ROM_SIG_WIDTH - 1 : 0] memory [SIG_ADDRS_WIDTH - 1 : 0] ;
 
    assign rom_signals_data_o = rd_rom_signals_ld_i ? memory[addrs_rom_signal_i] : {ROM_SIG_WIDTH{1'b0}};
   
    initial begin
      $readmemb("content.mem",memory);
    end

endmodule