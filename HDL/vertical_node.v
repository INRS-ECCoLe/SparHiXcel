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
        input sel_mux_node_i,
        input clk_i,
        input node_rst_i,
        input path_node_rst_i,
        input path_node_ld_i,
        input node_ld_i,
        output reg sel_mux_node_o,
        output reg en_adder_node_o,
        output signed [I_WIDTH + F_WIDTH - 1 : 0] out_node_o,
        output c_node_o
    );
        
        reg signed [I_WIDTH + F_WIDTH - 1 : 0] out_reg_node;
        wire [I_WIDTH + F_WIDTH - 1 : 0] sum_node;
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
                .sum_o(sum_node),
                .c_o(c_node_o)
            );
         
        always @ (posedge clk_i) begin // or posedge node_rst_i deleted
            if (node_rst_i) begin
                out_reg_node <= 0;
            end else if (node_ld_i) begin 
                out_reg_node <= sum_node;
            
            end
        end 
        
        always @ (posedge clk_i) begin // or posedge path_node_rst_i deleted
        
            if (path_node_rst_i) begin
                en_adder_node_o <= 0;
                sel_mux_node_o <= 0;
            end else if (path_node_ld_i) begin
                en_adder_node_o <= en_adder_node_i;
                sel_mux_node_o <= sel_mux_node_i;
            end
        end  
        
        assign out_node_o = sel_mux_node_o ? top_node_data_i : out_reg_node;
          
endmodule
