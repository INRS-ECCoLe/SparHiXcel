`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/29/2024 11:26:36 AM
// Design Name: 
// Module Name: out_reg_shift
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

module out_reg_shift
    #(
        parameter I_WIDTH = 8,
        parameter F_WIDTH = 8,
        parameter N = 3,
        parameter NUM_COL_WIDTH = $clog2(N+1)
    )
    (
        input signed [I_WIDTH + F_WIDTH -1 : 0] in_data_i,
        input [NUM_COL_WIDTH - 1 : 0] number_of_columns_i,
        input number_of_columns_rst_i,
        input number_of_columns_ld_i,
        input clk_i,
        input out_reg_shift_rst_i,
        input out_reg_shift_ld_i,
        input [$clog2(N+1)-1 : 0]filter_size_i,
        output reg [NUM_COL_WIDTH - 1 : 0] number_of_columns_o,
        output signed [I_WIDTH + F_WIDTH -1 : 0] out_data_o 
    );
        integer i; 
        reg signed [I_WIDTH + F_WIDTH - 1 : 0] reg_shift [0 : N - 2]; 
   
        always @(posedge clk_i or posedge out_reg_shift_rst_i) begin
            if (out_reg_shift_rst_i) begin
                for(i = 0 ; i < N - 1 ; i = i + 1) begin
                    reg_shift[i] <= {I_WIDTH + F_WIDTH{1'b0}}; 
                end
            end else if (out_reg_shift_ld_i) begin 
                for(i = N-2 ; i > 0 ; i = i - 1) begin
                    reg_shift[i] <= reg_shift[i - 1];
                end
                reg_shift[0] <= in_data_i;
            end
        end
   
        
        assign out_data_o = (number_of_columns_o == filter_size_i) ? in_data_i : reg_shift[filter_size_i - number_of_columns_o - 1];
        
        always @ (posedge clk_i or posedge number_of_columns_rst_i) begin 
        
            if (number_of_columns_rst_i) begin
                number_of_columns_o <= 0;
                
            end else if (number_of_columns_ld_i) begin
             
                    number_of_columns_o <= number_of_columns_i;
                
            end
        end
    
endmodule

