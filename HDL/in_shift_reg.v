`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/12/2024 01:54:04 PM
// Design Name: 
// Module Name: in_shift_reg
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


module in_shift_reg
    #(
        parameter N = 3,
        parameter I_WIDTH = 8,
        parameter SEL_WIDTH = $clog2(N)
        
    )
    (
        input signed [I_WIDTH - 1: 0] in_feature_i,
        input [SEL_WIDTH - 1: 0] f_sel_i,
        input freg_rst_i,
        input freg_ld_i,
        input clk_i,
        output signed [I_WIDTH - 1: 0] out_feature_o
    );
        integer i; 
        reg signed [I_WIDTH - 1: 0] shift_reg [N-1:0]; 
   
        always @(posedge clk_i) begin // or posedge freg_rst_i deleted
            if (freg_rst_i) begin
                for(i = 0 ; i < N ; i = i + 1) begin
                    shift_reg[i] <= {I_WIDTH{1'b0}}; 
                end
            end else if (freg_ld_i) begin
                for(i = N-1 ; i > 0 ; i = i - 1) begin
                    shift_reg[i] <= shift_reg[i - 1];
                end
                shift_reg[0] <= in_feature_i;
            end
        end
   
        //always @ (*) begin
        assign out_feature_o = shift_reg[f_sel_i];
        //end 
        
endmodule
