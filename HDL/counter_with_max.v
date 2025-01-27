`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/27/2025 11:32:40 AM
// Design Name: 
// Module Name: counter_with_max
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


module counter_with_max    
    #(
    parameter COUNTER_WIDTH = 4
    )
    (
    input clk_i,
    input counter_rst_i,
    input counter_ld_i,
    input [COUNTER_WIDTH - 1 : 0] max_value,
    output reg [COUNTER_WIDTH - 1 : 0] count_num_o
    );
    
    always @ (posedge clk_i) begin
        if (counter_rst_i) begin
            count_num_o <= {COUNTER_WIDTH{1'b0}};   
        end else if (counter_ld_i) begin
            if (count_num_o == max_value) begin
                count_num_o <= {COUNTER_WIDTH{1'b0}};
            end else begin
                count_num_o <= count_num_o + 1;    
            end
        end
        
    
    end
    
endmodule
