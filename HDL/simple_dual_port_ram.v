`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/21/2025 04:51:28 PM
// Design Name: 
// Module Name: simple_dual_port_ram
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


module simple_dual_port_ram(clk_i,ena_i,enb_i,wea_i,addra_i,addrb_i,dia_i,dob_o);
parameter MEMORY_WIDTH = 72;
parameter ADDRS_WIDTH = 8;
input clk_i,ena_i,enb_i,wea_i;
input [ADDRS_WIDTH - 1 : 0] addra_i,addrb_i;
input [MEMORY_WIDTH - 1 : 0] dia_i;
output [MEMORY_WIDTH - 1 : 0] dob_o;
reg [MEMORY_WIDTH - 1 : 0] ram [2**ADDRS_WIDTH - 1 : 0];
reg [MEMORY_WIDTH - 1 :0] doa_o,dob_o;

always @(posedge clk_i) begin
    if (ena_i) begin
        if (wea_i)
            ram[addra_i] <= dia_i;
        end
    end

always @(posedge clk_i) begin
    if (enb_i)
        dob_o <= ram[addrb_i];
    end

endmodule

