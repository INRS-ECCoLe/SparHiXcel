`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/24/2025 02:57:59 PM
// Design Name: 
// Module Name: Dual_Port_Ram
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


module Dual_Port_Ram(clk_i,ena_i,enb_i,wea_i,addra_i,addrb_i,dia_i,dob_o);
    parameter MEMORY_WIDTH = 72;
    parameter ADDRS_WIDTH = 8;
    input clk_i,ena_i,enb_i,wea_i;
    input [ADDRS_WIDTH - 1 : 0] addra_i,addrb_i;
    input [MEMORY_WIDTH - 1 : 0] dia_i;
    output [MEMORY_WIDTH - 1 : 0] dob_o;
    //reg [MEMORY_WIDTH - 1 : 0] ram [2**ADDRS_WIDTH - 1 : 0];
    reg [MEMORY_WIDTH - 1 :0] doa_o,dob_o;
    
    localparam BANK_WIDTH = 36;
    localparam NUM_BANKS  = (MEMORY_WIDTH + BANK_WIDTH - 1) / BANK_WIDTH;
    localparam TOTAL_WIDTH = NUM_BANKS * BANK_WIDTH; // padded width
    
    wire [TOTAL_WIDTH-1:0] dia_padded;
    reg [TOTAL_WIDTH-1:0] dob_padded;
    
    assign dia_padded = { {(TOTAL_WIDTH - MEMORY_WIDTH){1'b0}}, dia_i };
    
    genvar i;
    generate
        for (i = 0; i < NUM_BANKS; i = i + 1) begin : bank
            // Width of this bank (last bank may be smaller)
            localparam integer WIDTH = (i == NUM_BANKS-1) ? (MEMORY_WIDTH - i*BANK_WIDTH) : BANK_WIDTH;
    
            // 1D RAM per bank
            (* ram_style = "block" *)
            reg [WIDTH-1:0] ram [0:(1<<ADDRS_WIDTH)-1];
    
            // Write port
            always @(posedge clk_i) begin
                if (ena_i && wea_i)
                    ram[addra_i] <= dia_padded[i*BANK_WIDTH +: WIDTH];
            end
    
            // Read port
            always @(posedge clk_i) begin
                if (enb_i)
                    dob_padded[i*BANK_WIDTH +: WIDTH] <= ram[addrb_i];
            end
        end
    endgenerate

    // Assign exact width output
    always @(posedge clk_i) begin
        if (enb_i)
            dob_o <= dob_padded[MEMORY_WIDTH-1 : 0]; // top MEMORY_WIDTH bits
    end
    
endmodule
