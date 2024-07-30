`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/18/2024 04:49:40 PM
// Design Name: 
// Module Name: vertical_node
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


module vertical_node
    #(
        parameter F_WIDTH = 8,
        parameter I_WIDTH = 8 
    )
    (
        input signed [I_WIDTH + F_WIDTH - 1 : 0] top_node_data_i,
        input signed [I_WIDTH + F_WIDTH - 1 : 0] mux_data_i,
        input en_adder_node_i,
        input clk_i,
        input node_rst_i,
        input en_adder_node_rst_i,
        input en_adder_node_ld_i,
        input node_ld_i,
        output reg en_adder_node_o,
        output reg signed [I_WIDTH + F_WIDTH - 1 : 0] out_node_o,
        output c_node_o
    );
        
        wire [I_WIDTH + F_WIDTH - 1 : 0] sum_node_o;
        adder
            #(
                .F_WIDTH(F_WIDTH),
                .I_WIDTH(I_WIDTH)
            )
            adder_block
            (
                .a_i(top_node_data_i),
                .b_i(mux_data_i),
                .en_adder_i(en_adder_node_o),
                .sum_o(sum_node_o),
                .c_o(c_node_o)
            );
         
        always @ (posedge clk_i or posedge node_rst_i) begin 
            if (node_rst_i) begin
                out_node_o <= 0;
            end else if (node_ld_i) begin 
                out_node_o <= sum_node_o;
            
            end
        end 
        
        always @ (posedge clk_i or posedge en_adder_node_rst_i) begin 
        
            if (en_adder_node_rst_i) begin
                en_adder_node_o <= 0;
                
            end else if (en_adder_node_ld_i) begin
             
                    en_adder_node_o <= en_adder_node_i;
                
            end
        end  
          
endmodule
