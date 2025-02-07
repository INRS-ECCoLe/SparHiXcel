`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/14/2024 02:59:24 PM
// Design Name: 
// Module Name: pe
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


module pe 
    #(
        parameter I_WIDTH = 8,
        parameter F_WIDTH = 8,
        parameter N = 3,
        parameter ADDRS_WIDTH = $clog2(N),
        parameter SEL_WIDTH = $clog2(N), 
        parameter NUM_COL_WIDTH = $clog2(N+1)
    )
    (
        input signed [I_WIDTH - 1: 0] in_feature_i,
        input [SEL_WIDTH - 1: 0] f_sel_i,
//        input f_sel_rst_i,
//        input f_sel_ld_i,
//        input freg_rst_i,
        input rst_i,
        input load_i,
        input ready_i,
        input start_op_i,
        input clk_i,
        input [NUM_COL_WIDTH -1 : 0]row_num_i,
        input [$clog2(N+1)-1 : 0]filter_size_i,
        input signed [F_WIDTH - 1 : 0] f_weight_i,
//        input wreg_rst_i,
//        input wreg_wr_en_i,
        input [NUM_COL_WIDTH - 1 : 0] column_num_i,
//        input column_num_rst_i,
//        input column_num_ld_i,
//        input mreg_addrs_rst_i,
//        input mreg_start_i,
//        input mreg_rst_i,
//        input mreg_wr_en_i,
        input signed [I_WIDTH + F_WIDTH - 1 : 0] top_pe_in_i,
        //input en_adder_1_i,
//        input en_adder_rst_i,
//        input en_adder_ld_i,
//        input oreg_1_rst_i,
//        input oreg_1_ld_i,
        input signed [I_WIDTH + F_WIDTH - 1 : 0] left_pe_in_i,
        //input en_adder_2_i,
//        input oreg_2_rst_i,
//        input oreg_2_ld_i,

        output sel_mux_tr_rst_o,
        output sel_mux_tr_ld_o,
        output number_of_columns_rst_o,
        output number_of_columns_ld_o,
        output out_reg_shift_rst_o,
        output node_rst_o,
        output node_ld_o,
        output path_node_rst_o,
        output path_node_ld_o,

        //output en_adder_1_o,
        //output en_adder_2_o,
        output [NUM_COL_WIDTH - 1 : 0] column_num_o,
        output [SEL_WIDTH - 1: 0] f_sel_o,
        output signed [F_WIDTH - 1 : 0] f_weight_o,
        output [F_WIDTH + I_WIDTH - 1 : 0] down_pe_o,
        output signed [F_WIDTH + I_WIDTH - 1 : 0] output_pe_o
    );
        wire [ADDRS_WIDTH - 1 : 0] mreg_rd_addrs;
        wire [ADDRS_WIDTH - 1 : 0] mreg_wr_addrs;
        wire signed [I_WIDTH - 1: 0] out_feature;
        wire signed [I_WIDTH + F_WIDTH - 1 : 0] out_mul;
        wire signed [I_WIDTH + F_WIDTH - 1 : 0] result_mul_to_adder;
        wire signed [I_WIDTH + F_WIDTH - 1 : 0] sum_1;
        wire signed [F_WIDTH + I_WIDTH - 1 : 0] o_reg_1 = down_pe_o;
        wire signed [I_WIDTH + F_WIDTH - 1 : 0] sum_2;
        wire freg_rst;
        wire freg_ld;
        wire wreg_rst;
        wire wreg_wr_en;
        wire mreg_rst;
        wire mreg_wr_en;
        wire oreg_1_rst;
        wire oreg_1_ld;
        wire oreg_2_rst;
        wire oreg_2_ld;
        wire en_adder_1;
        wire en_adder_2;
        //reg [$clog2(N+1)-1 : 0]filter_size;
/*        always@(posedge clk_i)begin
            filter_size <=filter_size_i;
        end*/
        
        
        //feature_block
        in_shift_reg 
        #(
            .I_WIDTH(I_WIDTH),
            .SEL_WIDTH(SEL_WIDTH),
            .N(N)
        )
        feature_block
        (
            .in_feature_i(in_feature_i),
            .f_sel_i(f_sel_o),
            .freg_rst_i(freg_rst),
            .freg_ld_i(freg_ld),
            .clk_i(clk_i),
            .out_feature_o(out_feature)
        );
       
       //Weight_block 
       weight_reg
       #(
            .F_WIDTH(F_WIDTH)
       )
       Weight_block
       (
            .f_weight_i(f_weight_i),
            .clk_i(clk_i),
            .wreg_rst_i(wreg_rst),
            .wreg_wr_en_i(wreg_wr_en),
            .f_weight_o(f_weight_o)
       ); 
       //multiply_block 
       multiplier
       #(
            .F_WIDTH(F_WIDTH),
            .I_WIDTH(I_WIDTH)
       )
       multiply_block
       (
            .in_feature_i(out_feature),
            .f_weight_i(f_weight_o),
            .out_mul_o(out_mul)
       );
       // control_block
       
        control
        #(
            .N(N),
            .ADDRS_WIDTH(ADDRS_WIDTH),
            .NUM_COL_WIDTH(NUM_COL_WIDTH)
        )
        control_block
        (
            .column_num_i(column_num_i),
            .clk_i(clk_i),
            .row_num_i(row_num_i),
            .filter_size_i(filter_size_i),
//            .column_num_rst_i(column_num_rst_i),
//            .column_num_ld_i(column_num_ld_i),
//            .mreg_addrs_rst_i(mreg_addrs_rst_i),
//            .mreg_start_i(mreg_start_i),
            .f_sel_i(f_sel_i),
//            .f_sel_rst_i(f_sel_rst_i),
//            .f_sel_ld_i(f_sel_ld_i),
//            .en_adder_1_i(en_adder_1_i),
//            .en_adder_2_i(en_adder_2_i),
//            .en_adder_rst_i(en_adder_rst_i),
//            .en_adder_ld_i(en_adder_ld_i),
            .rst_i(rst_i),
            .load_i(load_i),
            .ready_i(ready_i),
            .start_op_i(start_op_i),
            .freg_rst_o(freg_rst),//new
            .freg_ld_o(freg_ld),
            .wreg_rst_o(wreg_rst),
            .wreg_wr_en_o(wreg_wr_en),
            .mreg_rst_o(mreg_rst),
            .mreg_wr_en_o(mreg_wr_en),
            .oreg_1_rst_o(oreg_1_rst),
            .oreg_1_ld_o(oreg_1_ld),
            .oreg_2_rst_o(oreg_2_rst),
            .oreg_2_ld_o(oreg_2_ld),
            
            .sel_mux_tr_rst_o(sel_mux_tr_rst_o),
            .sel_mux_tr_ld_o(sel_mux_tr_ld_o),
            .number_of_columns_rst_o(number_of_columns_rst_o),
            .number_of_columns_ld_o(number_of_columns_ld_o),
            .out_reg_shift_rst_o(out_reg_shift_rst_o),
            .node_rst_o(node_rst_o),
            .node_ld_o(node_ld_o),
            .path_node_rst_o(path_node_rst_o),
            .path_node_ld_o(path_node_ld_o),
            
            .en_adder_1_o(en_adder_1),
            .en_adder_2_o(en_adder_2),
            .column_num_o(column_num_o),
            .f_sel_o(f_sel_o),
            .mreg_wr_addrs_o(mreg_wr_addrs),
            .mreg_rd_addrs_o(mreg_rd_addrs)
        );
    
       //mul_reg_block
       mul_reg
       #(
            .F_WIDTH(F_WIDTH),
            .I_WIDTH(I_WIDTH),
            .N(N),
            .ADDRS_WIDTH(ADDRS_WIDTH)
       )
       mul_reg_block
       (
            .wr_data_i(out_mul),
            .mreg_wr_addrs_i(mreg_wr_addrs),
            .mreg_rd_addrs_i(mreg_rd_addrs),
            .clk_i(clk_i),
            .mreg_rst_i(mreg_rst),
            .mreg_wr_en_i(mreg_wr_en),
            .rd_data_o(result_mul_to_adder)
       ); 
        
       //adder_1_block
       adder
       #(
            .F_WIDTH(F_WIDTH),
            .I_WIDTH(I_WIDTH)
       )
       adder_1_block
       (
            .a_i(result_mul_to_adder),
            .b_i(top_pe_in_i),
            .en_adder_i(en_adder_1),
            .sum_o(sum_1),
            .c_o()
       );
       
       //out_reg_1_block
       o_reg
       #(
            .F_WIDTH(F_WIDTH),
            .I_WIDTH(I_WIDTH)     
       )
       out_reg_1_block
       (
            .wr_data_i(sum_1),
            .clk_i(clk_i),
            .oreg_rst_i(oreg_1_rst),
            .oreg_wr_en_i(oreg_1_ld),
            .rd_data_o(down_pe_o)
       );
       
       //adder_2_block
       adder
       #(
            .F_WIDTH(F_WIDTH),
            .I_WIDTH(I_WIDTH)
       )
       adder_2_block
       (
            .a_i(o_reg_1),
            .b_i(left_pe_in_i),
            .en_adder_i(en_adder_2),
            .sum_o(sum_2),
            .c_o()
       );
       
       //out_reg_2_block
       o_reg
       #(
            .F_WIDTH(F_WIDTH),
            .I_WIDTH(I_WIDTH)     
       )
       out_reg_2_block
       (
            .wr_data_i(sum_2),
            .clk_i(clk_i),
            .oreg_rst_i(oreg_2_rst),
            .oreg_wr_en_i(oreg_2_ld),
            .rd_data_o(output_pe_o)
       );
        
endmodule