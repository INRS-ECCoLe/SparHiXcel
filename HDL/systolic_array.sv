`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/19/2024 02:12:03 PM
// Design Name: 
// Module Name: systolic_array
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


module systolic_array
    #(
        parameter N_ROWS_ARRAY = 6,
        parameter N_COLS_ARRAY = 6,
        parameter I_WIDTH = 8,
        parameter F_WIDTH = 8,
        parameter N = 3,
        parameter LEN_TRANSFER = 8,
        parameter MAX_LEN_TRANSFER = 8,
        parameter SEL_MUX_TR_WIDTH = $clog2(MAX_LEN_TRANSFER),
        
        parameter ADDRS_WIDTH = $clog2(N-1),
        parameter SEL_WIDTH = $clog2(N),
        parameter NUM_COL_WIDTH = $clog2(N)
    )
    (
        input signed [I_WIDTH - 1: 0] in_feature_i [0 : N_ROWS_ARRAY - 1],
        input [SEL_WIDTH - 1: 0] f_sel_i [0 : N_ROWS_ARRAY - 1],
        input rst_i,

        input clk_i,
        input signed [F_WIDTH - 1 : 0] f_weight_i [0 : N_COLS_ARRAY - 1],
        input wr_en_i,
        input [NUM_COL_WIDTH - 1 : 0] column_num_i [0 : N_ROWS_ARRAY - 1],
        input mreg_addrs_rst_i,
        input mreg_start_i,
        input [SEL_MUX_TR_WIDTH - 1 : 0] sel_mux_tr_i[0 : N_ROWS_ARRAY - 1],

        input en_adder_1_i[0 : N_ROWS_ARRAY - 1],



        input en_adder_2_i[0 : N_ROWS_ARRAY - 1],




        output signed [F_WIDTH + I_WIDTH - 1 : 0] result [0 : N_COLS_ARRAY - 1]
    );
        
        wire signed [F_WIDTH + I_WIDTH - 1 : 0] output_pe [0 : N_ROWS_ARRAY -1] [0 : N_COLS_ARRAY -1];
        wire signed [F_WIDTH + I_WIDTH - 1 : 0] out_reg_shift [0 : N_ROWS_ARRAY -1] [0 : N_COLS_ARRAY -1];
        wire signed [F_WIDTH + I_WIDTH - 1 : 0] out_mux [0 : N_ROWS_ARRAY -1] [0 : N_COLS_ARRAY -1];
        wire signed [F_WIDTH + I_WIDTH - 1 : 0] out_node [0 : N_ROWS_ARRAY -1] [0 : N_COLS_ARRAY -1];
        wire signed [F_WIDTH + I_WIDTH - 1 : 0] down_pe [0 : N_ROWS_ARRAY -1] [0 : N_COLS_ARRAY -1];
        wire signed [F_WIDTH - 1 : 0] f_weight [0 : N_ROWS_ARRAY -1] [0 : N_COLS_ARRAY -1];
        wire [SEL_MUX_TR_WIDTH - 1 : 0] sel_mux_tr [0 : N_ROWS_ARRAY - 1] [1 : N_COLS_ARRAY -1];
        wire [NUM_COL_WIDTH - 1 : 0] column_num [0 : N_ROWS_ARRAY -1] [0 : N_COLS_ARRAY -1];
        wire [SEL_WIDTH - 1: 0] f_sel [0 : N_ROWS_ARRAY -1] [0 : N_COLS_ARRAY -1];
        wire en_adder_1 [0 : N_ROWS_ARRAY -1] [0 : N_COLS_ARRAY -1];
        wire en_adder_2 [0 : N_ROWS_ARRAY -1] [0 : N_COLS_ARRAY -1];
        
        genvar x, y;
        generate 
            for (x = 0 ; x < N_ROWS_ARRAY ; x = x + 1) begin: gen_rows
                for (y = 0 ; y < N_COLS_ARRAY ; y = y + 1) begin: gen_cols
                    if(x == 0) begin
                        if (y == 0) begin
                            pe 
                            #(
                                .I_WIDTH(I_WIDTH),
                                .F_WIDTH(F_WIDTH),
                                .N(N),
                                .ADDRS_WIDTH(ADDRS_WIDTH),
                                .SEL_WIDTH(SEL_WIDTH), 
                                .NUM_COL_WIDTH(NUM_COL_WIDTH)
                            )
                            pe_unit
                            (
                                .in_feature_i(in_feature_i[x]),
                                .f_sel_i(f_sel_i[0]),
                                .f_sel_rst_i(rst_i),
                                .f_sel_ld_i(wr_en_i),
                                .freg_rst_i(rst_i),
                                .clk_i(clk_i),
                                .f_weight_i(f_weight_i[y]),
                                .wreg_rst_i(rst_i),
                                .wreg_wr_en_i(wr_en_i),
                                .column_num_i(column_num_i[0]),
                                .column_num_rst_i(rst_i),
                                .column_num_ld_i(wr_en_i),
                                .mreg_addrs_rst_i(mreg_addrs_rst_i),
                                .mreg_start_i(mreg_start_i),
                                .mreg_rst_i(rst_i),
                                .mreg_wr_en_i(wr_en_i),
                                .top_pe_in_i(0),
                                .en_adder_1_i(en_adder_1_i[0]),
                                .en_adder_rst_i(rst_i),
                                .en_adder_ld_i(wr_en_i),
                                .oreg_1_rst_i(rst_i),
                                .oreg_1_ld_i(wr_en_i),
                                .left_pe_in_i(0),
                                .en_adder_2_i(en_adder_2_i[0]),
                                .oreg_2_rst_i(rst_i),
                                .oreg_2_ld_i(wr_en_i),
                                .en_adder_1_o(en_adder_1[x][y]),
                                .en_adder_2_o(en_adder_2[x][y]),
                                .column_num_o(column_num[x][y]),
                                .f_sel_o(f_sel[x][y]),
                                .f_weight_o(f_weight[x][y]),
                                .down_pe_o(down_pe[x][y]),
                                .output_pe_o(output_pe[x][y])
                            );
                        end else begin
                            pe 
                            #(
                                .I_WIDTH(I_WIDTH),
                                .F_WIDTH(F_WIDTH),
                                .N(N),
                                .ADDRS_WIDTH(ADDRS_WIDTH),
                                .SEL_WIDTH(SEL_WIDTH), 
                                .NUM_COL_WIDTH(NUM_COL_WIDTH)
                            )
                            pe_unit
                            (
                                .in_feature_i(in_feature_i[x]),
                                .f_sel_i(f_sel[x][y-1]),
                                .f_sel_rst_i(rst_i),
                                .f_sel_ld_i(wr_en_i),
                                .freg_rst_i(rst_i),
                                .clk_i(clk_i),
                                .f_weight_i(f_weight_i[y]),
                                .wreg_rst_i(rst_i),
                                .wreg_wr_en_i(wr_en_i),
                                .column_num_i(column_num[x][y-1]),
                                .column_num_rst_i(rst_i),
                                .column_num_ld_i(wr_en_i),
                                .mreg_addrs_rst_i(mreg_addrs_rst_i),
                                .mreg_start_i(mreg_start_i),
                                .mreg_rst_i(rst_i),
                                .mreg_wr_en_i(wr_en_i),
                                .top_pe_in_i(0),
                                .en_adder_1_i(en_adder_1[x][y-1]),
                                .en_adder_rst_i(rst_i),
                                .en_adder_ld_i(wr_en_i),
                                .oreg_1_rst_i(rst_i),
                                .oreg_1_ld_i(wr_en_i),
                                .left_pe_in_i(output_pe[x][y-1]),
                                .en_adder_2_i(en_adder_2[x][y-1]),
                                .oreg_2_rst_i(rst_i),
                                .oreg_2_ld_i(wr_en_i),
                                .en_adder_1_o(en_adder_1[x][y]),
                                .en_adder_2_o(en_adder_2[x][y]),
                                .column_num_o(column_num[x][y]),
                                .f_sel_o(f_sel[x][y]),
                                .f_weight_o(f_weight[x][y]),
                                .down_pe_o(down_pe[x][y]),
                                .output_pe_o(output_pe[x][y])
                            );
                        end        
                    end else begin
                        if (y == 0) begin
                            pe 
                            #(
                                .I_WIDTH(I_WIDTH),
                                .F_WIDTH(F_WIDTH),
                                .N(N),
                                .ADDRS_WIDTH(ADDRS_WIDTH),
                                .SEL_WIDTH(SEL_WIDTH), 
                                .NUM_COL_WIDTH(NUM_COL_WIDTH)
                            )
                            pe_unit
                            (
                                .in_feature_i(in_feature_i[x]),
                                .f_sel_i(f_sel_i[x]),
                                .f_sel_rst_i(rst_i),
                                .f_sel_ld_i(wr_en_i),
                                .freg_rst_i(rst_i),
                                .clk_i(clk_i),
                                .f_weight_i(f_weight[x-1][y]),
                                .wreg_rst_i(rst_i),
                                .wreg_wr_en_i(wr_en_i),
                                .column_num_i(column_num_i[x]),
                                .column_num_rst_i(rst_i),
                                .column_num_ld_i(wr_en_i),
                                .mreg_addrs_rst_i(mreg_addrs_rst_i),
                                .mreg_start_i(mreg_start_i),
                                .mreg_rst_i(rst_i),
                                .mreg_wr_en_i(wr_en_i),
                                .top_pe_in_i(down_pe[x-1][y]),
                                .en_adder_1_i(en_adder_1_i[x]),
                                .en_adder_rst_i(rst_i),
                                .en_adder_ld_i(wr_en_i),
                                .oreg_1_rst_i(rst_i),
                                .oreg_1_ld_i(wr_en_i),
                                .left_pe_in_i(0),
                                .en_adder_2_i(en_adder_2_i[x]),
                                .oreg_2_rst_i(rst_i),
                                .oreg_2_ld_i(wr_en_i),
                                .en_adder_1_o(en_adder_1[x][y]),
                                .en_adder_2_o(en_adder_2[x][y]),
                                .column_num_o(column_num[x][y]),
                                .f_sel_o(f_sel[x][y]),
                                .f_weight_o(f_weight[x][y]),
                                .down_pe_o(down_pe[x][y]),
                                .output_pe_o(output_pe[x][y])
                            );
                        end else begin
                            pe 
                            #(
                                .I_WIDTH(I_WIDTH),
                                .F_WIDTH(F_WIDTH),
                                .N(N),
                                .ADDRS_WIDTH(ADDRS_WIDTH),
                                .SEL_WIDTH(SEL_WIDTH), 
                                .NUM_COL_WIDTH(NUM_COL_WIDTH)
                            )
                            pe_unit
                            (
                                .in_feature_i(in_feature_i[x]),
                                .f_sel_i(f_sel[x][y-1]),
                                .f_sel_rst_i(rst_i),
                                .f_sel_ld_i(wr_en_i),
                                .freg_rst_i(rst_i),
                                .clk_i(clk_i),
                                .f_weight_i(f_weight[x-1][y]),
                                .wreg_rst_i(rst_i),
                                .wreg_wr_en_i(wr_en_i),
                                .column_num_i(column_num[x][y-1]),
                                .column_num_rst_i(rst_i),
                                .column_num_ld_i(wr_en_i),
                                .mreg_addrs_rst_i(mreg_addrs_rst_i),
                                .mreg_start_i(mreg_start_i),
                                .mreg_rst_i(rst_i),
                                .mreg_wr_en_i(wr_en_i),
                                .top_pe_in_i(down_pe[x-1][y]),
                                .en_adder_1_i(en_adder_1[x][y-1]),
                                .en_adder_rst_i(rst_i),
                                .en_adder_ld_i(wr_en_i),
                                .oreg_1_rst_i(rst_i),
                                .oreg_1_ld_i(wr_en_i),
                                .left_pe_in_i(output_pe[x][y-1]),
                                .en_adder_2_i(en_adder_2[x][y-1]),
                                .oreg_2_rst_i(rst_i),
                                .oreg_2_ld_i(wr_en_i),
                                .en_adder_1_o(en_adder_1[x][y]),
                                .en_adder_2_o(en_adder_2[x][y]),
                                .column_num_o(column_num[x][y]),
                                .f_sel_o(f_sel[x][y]),
                                .f_weight_o(f_weight[x][y]),
                                .down_pe_o(down_pe[x][y]),
                                .output_pe_o(output_pe[x][y])
                            );                      
                        end        
                    end
                end
            end
        endgenerate 
        
    
        
        
        
        
        genvar i, j, m;
        generate 
            for (j = 0; j < N_COLS_ARRAY ; j = j + 1) begin
                for (i =0 ; i < N_ROWS_ARRAY ; i = i + 1) begin
                    if (j == 0) begin
                        assign out_mux[i][j] = out_reg_shift[i][j];   
                         
                    end else if(j < LEN_TRANSFER) begin
                        wire signed [F_WIDTH + I_WIDTH - 1 : 0] in_mux [0 : j];
                        for (m = 0; m < j + 1; m = m + 1) begin
                            assign in_mux [j - m] = out_reg_shift [i][m] ;
                        end
                        if (j == 1) begin
                            mux_n_1 
                            #(
                                .I_WIDTH(I_WIDTH),
                                .F_WIDTH(F_WIDTH),
                                .LEN_TRANSFER(j+1),
                                .MAX_LEN_TRANSFER(MAX_LEN_TRANSFER),
                                .SEL_MUX_TR_WIDTH(SEL_MUX_TR_WIDTH)
                            )
                            mux_unit
                            (
                                .tr_data_i(in_mux),
                                .sel_mux_tr_i(sel_mux_tr_i[i]),
                                .clk_i(clk_i),
                                .sel_mux_tr_rst_i(rst_i),
                                .sel_mux_tr_ld_i(wr_en_i),
                                .sel_mux_tr_o(sel_mux_tr[i][j]),
                                .tr_data_o(out_mux[i][j])
                                
                            );
                        end else begin
                            mux_n_1 
                            #(
                                .I_WIDTH(I_WIDTH),
                                .F_WIDTH(F_WIDTH),
                                .LEN_TRANSFER(j+1),
                                .MAX_LEN_TRANSFER(MAX_LEN_TRANSFER),
                                .SEL_MUX_TR_WIDTH(SEL_MUX_TR_WIDTH)
                            )
                            mux_unit
                            (
                                .tr_data_i(in_mux),
                                .sel_mux_tr_i(sel_mux_tr[i][j - 1]),
                                .clk_i(clk_i),
                                .sel_mux_tr_rst_i(rst_i),
                                .sel_mux_tr_ld_i(wr_en_i),
                                .sel_mux_tr_o(sel_mux_tr[i][j]),
                                .tr_data_o(out_mux[i][j])
                                
                            );
                        end        
                    end else begin
                        wire signed [F_WIDTH + I_WIDTH - 1 : 0] in_mux [0 : LEN_TRANSFER - 1];
                        for (m = j; m > j - LEN_TRANSFER; m = m - 1) begin
                            assign in_mux [j - m] = out_reg_shift [i][m] ;
                        end
                        mux_n_1 
                            #(
                                .I_WIDTH(I_WIDTH),
                                .F_WIDTH(F_WIDTH),
                                .LEN_TRANSFER(MAX_LEN_TRANSFER),
                                .MAX_LEN_TRANSFER(MAX_LEN_TRANSFER),
                                .SEL_MUX_TR_WIDTH(SEL_MUX_TR_WIDTH)
                            )
                            mux_unit
                            (
                                .tr_data_i(in_mux),
                                .sel_mux_tr_i(sel_mux_tr[i][j - 1]),
                                .clk_i(clk_i),
                                .sel_mux_tr_rst_i(rst_i),
                                .sel_mux_tr_ld_i(wr_en_i),
                                .sel_mux_tr_o(sel_mux_tr[i][j]),
                                .tr_data_o(out_mux[i][j])
                                
                            );
                    end
                end
            end
        endgenerate
    
endmodule
