`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/23/2024 02:33:23 PM
// Design Name: 
// Module Name: counter
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


module counter
    #(
    parameter COUNTER_WIDTH = 4
    )
    (
    input clk_i,
    input counter_rst_i,
    input counter_ld_i,
    output reg [COUNTER_WIDTH - 1 : 0] count_num_o
    );
    
    always @ (posedge clk_i) begin
        if (counter_rst_i) begin
            count_num_o <= {COUNTER_WIDTH{1'b0}};   
        end else if (counter_ld_i) begin
            count_num_o <= count_num_o + 1;    
        end
    
    end
    
    
    
    
endmodule
