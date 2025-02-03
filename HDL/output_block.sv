`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/31/2024 04:02:13 PM
// Design Name: 
// Module Name: output_block
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


module output_block
    #(
    parameter N_COLS_ARRAY = 3,
    parameter I_WIDTH = 8,
    parameter F_WIDTH = 8,
    parameter NUMBER_MUX_OUT_1 = 1,
    parameter NUMBER_INPUT_MUX_OUT_1 = (N_COLS_ARRAY + NUMBER_MUX_OUT_1 - 1) / NUMBER_MUX_OUT_1,
    parameter SEL_WIDTH_MUX_OUT_1 = $clog2(1 + NUMBER_INPUT_MUX_OUT_1),  // +1 is for having zero in input of mux for times that there is no corresponding output for that filter.  
    parameter SEL_WIDTH_MUX_OUT_2 = $clog2(NUMBER_MUX_OUT_1),
    parameter BRAM_ADDR_WIDTH = 11
    )
    (
    input signed [F_WIDTH + I_WIDTH - 1 : 0] data_in_i [0 : N_COLS_ARRAY - 1],
    input clk_i,
    input [SEL_WIDTH_MUX_OUT_1 - 1 : 0] sel_mux_out_1_i,
    input [SEL_WIDTH_MUX_OUT_2 - 1 : 0] sel_mux_out_2_i,
    input reg_rst_i,
    input reg_wr_en_i,
    input sel_mux_rst_i,
    input sel_mux_ld_i,
    input bram_rst_i,
    input bram_wr_en_a_i,
    input bram_wr_en_b_i,
    input [BRAM_ADDR_WIDTH - 1 : 0] bram_addr_write_read_i,
    input [BRAM_ADDR_WIDTH - 1 : 0] bram_addr_read_write_i,
    input bram_wr_en_a_rst_i,
    input bram_wr_en_a_ld_i, 
//    input bram_wr_en_b_rst_i,
//    input bram_wr_en_b_ld_i, 
    
    output reg bram_wr_en_a_o,
//    output reg bram_wr_en_b_o,
    output reg [SEL_WIDTH_MUX_OUT_1 - 1 : 0] sel_mux_out_1_o,
    output reg [SEL_WIDTH_MUX_OUT_2 - 1 : 0] sel_mux_out_2_o,
    output signed [I_WIDTH + F_WIDTH - 1 : 0] d_out_o
    );
    
    wire signed [I_WIDTH + F_WIDTH - 1 : 0] out_1 [0 :NUMBER_MUX_OUT_1 - 1];
    wire signed [F_WIDTH + I_WIDTH - 1 : 0] data_in [0 : (NUMBER_INPUT_MUX_OUT_1 * NUMBER_MUX_OUT_1) - 1];
    wire signed [I_WIDTH + F_WIDTH - 1 : 0] out_reg [0 :NUMBER_MUX_OUT_1 - 1];
    wire signed [I_WIDTH + F_WIDTH - 1 : 0] out_2;
    wire [I_WIDTH + F_WIDTH - 1 : 0] bram_data_write_a;
    wire [I_WIDTH + F_WIDTH - 1 : 0] bram_data_write_b = {(I_WIDTH + F_WIDTH ){1'b0}};
    wire [I_WIDTH + F_WIDTH - 1 : 0] bram_data_read;
    
    genvar a;
    generate
        for(a = 0; a < (NUMBER_INPUT_MUX_OUT_1 * NUMBER_MUX_OUT_1) ; a = a + 1) begin
            if (a < N_COLS_ARRAY)begin
                assign data_in[a] = data_in_i[a];    
            end else begin
                assign data_in[a] = {(I_WIDTH + F_WIDTH){1'b0}};
            end
        end
    endgenerate
    
    genvar i;
    generate 
        for (i = 0; i < NUMBER_MUX_OUT_1; i = i + 1) begin
            mux
            #(
                .I_WIDTH(I_WIDTH),
                .F_WIDTH(F_WIDTH),
                .SEL_WIDTH_MUX(SEL_WIDTH_MUX_OUT_1),
                .NUMBER_INPUT_MUX(NUMBER_INPUT_MUX_OUT_1)
            )
            mux_out_1
            (
                .data_in_i(data_in[i* NUMBER_INPUT_MUX_OUT_1: (i + 1)*NUMBER_INPUT_MUX_OUT_1 - 1]),
                .sel_mux_i(sel_mux_out_1_o),
                .data_out_o(out_1[i])
            );
            
            
            o_reg
            #(
                .F_WIDTH(F_WIDTH),
                .I_WIDTH(I_WIDTH) 
            )
            out_reg
            (
                .wr_data_i(out_1[i]),
                .clk_i(clk_i),
                .oreg_rst_i(reg_rst_i),
                .oreg_wr_en_i(reg_wr_en_i),
                .rd_data_o(out_reg[i])
            );    
        end
    endgenerate
    
    
    mux_l2
    #(
        .I_WIDTH(I_WIDTH),
        .F_WIDTH(F_WIDTH),
        .SEL_WIDTH_MUX(SEL_WIDTH_MUX_OUT_2),
        .NUMBER_INPUT_MUX(NUMBER_MUX_OUT_1)
    )
    mux_out_2
    (
        .data_in_i(out_reg),
        .sel_mux_i(sel_mux_out_2_o),
        .data_out_o(out_2)
    );
    //Register for bram_wr_en_a
    
    always @ (posedge clk_i or posedge bram_wr_en_a_rst_i) begin 
        if (bram_wr_en_a_rst_i) begin
            bram_wr_en_a_o <= 0; 
        end else if (bram_wr_en_a_ld_i) begin   
            bram_wr_en_a_o <= bram_wr_en_a_i;     
        end
    end
/*    //Register for bram_wr_en_b
    
    always @ (posedge clk_i or posedge bram_wr_en_b_rst_i) begin 
        if (bram_wr_en_b_rst_i) begin
            bram_wr_en_b_o <= 0; 
        end else if (bram_wr_en_b_ld_i) begin   
            bram_wr_en_b_o <= bram_wr_en_b_i;     
        end
    end*/
    //Register for sel_mux_out_1
    
    always @ (posedge clk_i or posedge sel_mux_rst_i) begin 
        if (sel_mux_rst_i) begin
            sel_mux_out_1_o <= 0; 
        end else if (sel_mux_ld_i) begin   
            sel_mux_out_1_o <= sel_mux_out_1_i;     
        end
    end
     //Register for sel_mux_out_1
    
    always @ (posedge clk_i or posedge sel_mux_rst_i) begin 
        if (sel_mux_rst_i) begin
            sel_mux_out_2_o <= 0; 
        end else if (sel_mux_ld_i) begin   
            sel_mux_out_2_o <= sel_mux_out_2_i;     
        end
    end 
    
    //BRAM 
        
    BRAM_filter
    #(
        .DATA_WIDTH(I_WIDTH + F_WIDTH),
        .ADDR_WIDTH(BRAM_ADDR_WIDTH)
    )
    BRAM_f
    (
        .clk_i(clk_i),
        .bram_rst_i(bram_rst_i),
        .bram_wr_en_a_i(bram_wr_en_a_o),
        .bram_wr_en_b_i(bram_wr_en_b_i),
        .addr_a_i(bram_addr_write_read_i),
        .addr_b_i(bram_addr_read_write_i),
        .data_in_a_i(bram_data_write_a),
        .data_in_b_i(bram_data_write_b),
        .data_out_a_o(d_out_o),
        .data_out_b_o(bram_data_read) 
    );
    
    //adder
    
    adder_without_en
    #(
        .I_WIDTH(I_WIDTH),
        .F_WIDTH(F_WIDTH)
    )
    adder
    (
        .a_i(out_2),
        .b_i(bram_data_read),
        .sum_o(bram_data_write_a),
        .c_o()
    );
    
endmodule
