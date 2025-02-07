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
        parameter N_ROWS_ARRAY = 4,
        parameter N_COLS_ARRAY = 4,
        parameter I_WIDTH = 8,
        parameter F_WIDTH = 8,
        parameter N = 3,
        parameter LEN_TRANSFER = 4,
        parameter MAX_LEN_TRANSFER = 4,
        parameter SEL_MUX_TR_WIDTH = $clog2(MAX_LEN_TRANSFER),
        
        parameter ADDRS_WIDTH = $clog2(N),
        parameter SEL_WIDTH = $clog2(N),
        parameter NUM_COL_WIDTH = $clog2(N+1)
    )
    (
        input signed [I_WIDTH - 1: 0] in_feature_i [0 : N_ROWS_ARRAY - 1],
        input [SEL_WIDTH - 1: 0] f_sel_i [0 : N_ROWS_ARRAY - 1], // you can determine f_sel_i by how many a weight shifted to right in an elastic group. f_sel_i= number of shifted location of an element of weights in an elastic group
        input [NUM_COL_WIDTH -1 : 0]row_num_i [0 : N_ROWS_ARRAY - 1],
        input rst_i,
        input load_i,
        input ready_i,
        input start_op_i,
        input clk_i,
        input [$clog2(N+1)-1 : 0]filter_size_i,
        input signed [F_WIDTH - 1 : 0] f_weight_i [0 : N_ROWS_ARRAY - 1],
        //input wr_en_i,
        input [NUM_COL_WIDTH - 1 : 0] column_num_i [0 : N_ROWS_ARRAY - 1], // it indicates that that pe is located in which column of the elastic group
        //input mreg_addrs_rst_i,
        //input mreg_start_i,
        input [SEL_MUX_TR_WIDTH - 1 : 0] sel_mux_tr_i[0 : N_ROWS_ARRAY - 1],
        //input en_adder_1_i[0 : N_ROWS_ARRAY - 1],
        //input en_adder_2_i[0 : N_ROWS_ARRAY - 1],
        input [NUM_COL_WIDTH - 1 : 0] number_of_columns_i[0 : N_ROWS_ARRAY - 1],
        input en_adder_node_i [0 : N_ROWS_ARRAY - 1],
        input sel_mux_node_i [0 : N_ROWS_ARRAY - 1],

        output signed [F_WIDTH + I_WIDTH - 1 : 0] result_o [0 : N_COLS_ARRAY - 1]
    );
       /* reg [$clog2(N+1)-1 : 0]filter_size;
        always@(posedge clk_i)begin
            filter_size <=filter_size_i;
        end*/
        wire signed [F_WIDTH + I_WIDTH - 1 : 0] output_pe [0 : N_ROWS_ARRAY -1] [0 : N_COLS_ARRAY -1];
        wire signed [F_WIDTH + I_WIDTH - 1 : 0] out_reg_shift [0 : N_ROWS_ARRAY -1] [0 : N_COLS_ARRAY -1];
        wire signed [F_WIDTH + I_WIDTH - 1 : 0] out_mux [0 : N_ROWS_ARRAY -1] [0 : N_COLS_ARRAY -1];
        wire signed [F_WIDTH + I_WIDTH - 1 : 0] out_node [0 : N_ROWS_ARRAY -1] [0 : N_COLS_ARRAY -1];
        wire signed [F_WIDTH + I_WIDTH - 1 : 0] down_pe [0 : N_ROWS_ARRAY -1] [0 : N_COLS_ARRAY -1];
        wire signed [F_WIDTH - 1 : 0] f_weight [0 : N_ROWS_ARRAY -1] [0 : N_COLS_ARRAY -1];
        wire [SEL_MUX_TR_WIDTH - 1 : 0] sel_mux_tr [0 : N_ROWS_ARRAY - 1] [1 : N_COLS_ARRAY -1];
        wire [NUM_COL_WIDTH - 1 : 0] column_num [0 : N_ROWS_ARRAY -1] [0 : N_COLS_ARRAY -1];
        wire [NUM_COL_WIDTH - 1 : 0] number_of_columns [0 : N_ROWS_ARRAY -1] [0 : N_COLS_ARRAY -1];
        wire [SEL_WIDTH - 1: 0] f_sel [0 : N_ROWS_ARRAY -1] [0 : N_COLS_ARRAY -1];
//        wire en_adder_1 [0 : N_ROWS_ARRAY -1] [0 : N_COLS_ARRAY -1];
//        wire en_adder_2 [0 : N_ROWS_ARRAY -1] [0 : N_COLS_ARRAY -1];
        wire en_adder_node [0 : N_ROWS_ARRAY -1] [0 : N_COLS_ARRAY -1];
        wire sel_mux_node [0 : N_ROWS_ARRAY -1] [0 : N_COLS_ARRAY -1];
        wire sel_mux_tr_rst[0 : N_ROWS_ARRAY -1] [0 : N_COLS_ARRAY -1];
        wire sel_mux_tr_ld[0 : N_ROWS_ARRAY -1] [0 : N_COLS_ARRAY -1];
        wire number_of_columns_rst[0 : N_ROWS_ARRAY -1] [0 : N_COLS_ARRAY -1];
        wire number_of_columns_ld[0 : N_ROWS_ARRAY -1] [0 : N_COLS_ARRAY -1];
        wire out_reg_shift_rst[0 : N_ROWS_ARRAY -1] [0 : N_COLS_ARRAY -1];
        wire out_reg_shift_ld[0 : N_ROWS_ARRAY -1] [0 : N_COLS_ARRAY -1];
        wire node_rst[0 : N_ROWS_ARRAY -1] [0 : N_COLS_ARRAY -1];
        wire node_ld[0 : N_ROWS_ARRAY -1] [0 : N_COLS_ARRAY -1];
        wire path_node_rst[0 : N_ROWS_ARRAY -1] [0 : N_COLS_ARRAY -1];
        wire path_node_ld[0 : N_ROWS_ARRAY -1] [0 : N_COLS_ARRAY -1];
        
        
        genvar a, b;
        generate
            for (a = 0; a < N_ROWS_ARRAY; a = a + 1) begin
                for (b = 0; b < N_COLS_ARRAY; b = b + 1) begin
                    assign out_reg_shift_ld[a][b] = 1;//(column_num[a][b] == number_of_columns[a][b]) && ((a+1) % filter_size_i == 0);
                    if (b == 0) begin 
                        out_reg_shift
                        #(
                            .I_WIDTH(I_WIDTH),
                            .F_WIDTH(F_WIDTH),
                            .N(N),
                            .NUM_COL_WIDTH(NUM_COL_WIDTH)
                        )
                        out_shift_block
                        (
                            .in_data_i(output_pe[a][b]),
                            .number_of_columns_i(number_of_columns_i[a]),
                            .number_of_columns_rst_i(number_of_columns_rst[a][b]),
                            .number_of_columns_ld_i(number_of_columns_ld[a][b]),
                            .clk_i(clk_i),
                            .out_reg_shift_rst_i(out_reg_shift_rst[a][b]),
                            .out_reg_shift_ld_i(out_reg_shift_ld[a][b]),
                            .filter_size_i(filter_size_i),
                            .number_of_columns_o(number_of_columns[a][b]),
                            .out_data_o(out_reg_shift[a][b])
                        );
                        
                    end else begin
                        out_reg_shift
                        #(
                            .I_WIDTH(I_WIDTH),
                            .F_WIDTH(F_WIDTH),
                            .N(N),
                            .NUM_COL_WIDTH(NUM_COL_WIDTH)
                        )
                        out_shift_block
                        (
                            .in_data_i(output_pe[a][b]),
                            .number_of_columns_i(number_of_columns[a][b-1]),
                            .number_of_columns_rst_i(number_of_columns_rst[a][b]),
                            .number_of_columns_ld_i(number_of_columns_ld[a][b]),
                            .clk_i(clk_i),
                            .out_reg_shift_rst_i(out_reg_shift_rst[a][b]),
                            .out_reg_shift_ld_i(out_reg_shift_ld[a][b]),
                            .filter_size_i(filter_size_i),
                            .number_of_columns_o(number_of_columns[a][b]),
                            .out_data_o(out_reg_shift[a][b])
                        );
                    end
                end
            
            end 
        
        endgenerate 
        genvar c, d;
        generate
            for (c = 0; c < N_ROWS_ARRAY; c = c + 1) begin
                for (d = 0; d < N_COLS_ARRAY; d = d + 1) begin
                    if (c == 0) begin 
                        if (d == 0) begin   
                            vertical_node
                            #(
                                .I_WIDTH(I_WIDTH),
                                .F_WIDTH(F_WIDTH)
                            )
                            node_block
                            (
                                .top_node_data_i({(F_WIDTH+I_WIDTH){1'b0}}),
                                .mux_data_i(out_mux[c][d]),
                                .en_adder_node_i(en_adder_node_i[c]),
                                .sel_mux_node_i(sel_mux_node_i[c]),
                                .clk_i(clk_i),
                                .node_rst_i(node_rst[c][d]),
                                .path_node_rst_i(path_node_rst[c][d]),
                                .path_node_ld_i(path_node_ld[c][d]),
                                .node_ld_i(node_ld[c][d]),
                                .sel_mux_node_o(sel_mux_node[c][d]),
                                .en_adder_node_o(en_adder_node[c][d]),
                                .out_node_o(out_node[c][d])
                            );
                        end else begin
                            vertical_node
                            #(
                                .I_WIDTH(I_WIDTH),
                                .F_WIDTH(F_WIDTH)
                            )
                            node_block
                            (
                                .top_node_data_i({(F_WIDTH+I_WIDTH){1'b0}}),
                                .mux_data_i(out_mux[c][d]),
                                .en_adder_node_i(en_adder_node[c][d-1]),
                                .sel_mux_node_i(sel_mux_node[c][d-1]),
                                .clk_i(clk_i),
                                .node_rst_i(node_rst[c][d]),
                                .path_node_rst_i(path_node_rst[c][d]),
                                .path_node_ld_i(path_node_ld[c][d]),
                                .node_ld_i(node_ld[c][d]),
                                .sel_mux_node_o(sel_mux_node[c][d]),
                                .en_adder_node_o(en_adder_node[c][d]),
                                .out_node_o(out_node[c][d])
                            );
                        end       
                    end else begin
                        if (d == 0) begin
                            vertical_node
                            #(
                                .I_WIDTH(I_WIDTH),
                                .F_WIDTH(F_WIDTH)
                            )
                            node_block
                            (
                                .top_node_data_i(out_node[c - 1][d]),
                                .mux_data_i(out_mux[c][d]),
                                .en_adder_node_i(en_adder_node_i[c]),
                                .sel_mux_node_i(sel_mux_node_i[c]),
                                .clk_i(clk_i),
                                .node_rst_i(node_rst[c][d]),
                                .path_node_rst_i(path_node_rst[c][d]),
                                .path_node_ld_i(path_node_ld[c][d]),
                                .node_ld_i(node_ld[c][d]),
                                .sel_mux_node_o(sel_mux_node[c][d]),
                                .en_adder_node_o(en_adder_node[c][d]),
                                .out_node_o(out_node[c][d])
                            );
                        end else begin
                            vertical_node
                            #(
                                .I_WIDTH(I_WIDTH),
                                .F_WIDTH(F_WIDTH)
                            )
                            node_block
                            (
                                .top_node_data_i(out_node[c - 1][d]),
                                .mux_data_i(out_mux[c][d]),
                                .en_adder_node_i(en_adder_node[c][d-1]),
                                .sel_mux_node_i(sel_mux_node[c][d-1]),
                                .clk_i(clk_i),
                                .node_rst_i(node_rst[c][d]),
                                .path_node_rst_i(path_node_rst[c][d]),
                                .path_node_ld_i(path_node_ld[c][d]),
                                .node_ld_i(node_ld[c][d]),
                                .sel_mux_node_o(sel_mux_node[c][d]),
                                .en_adder_node_o(en_adder_node[c][d]),
                                .out_node_o(out_node[c][d])
                            );
                        end    
                    end
                end
            
            end 
        assign result_o = out_node [N_ROWS_ARRAY - 1][0 : N_COLS_ARRAY -1];
        endgenerate 
        
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
                                .f_sel_i(f_sel_i[x]),
                                .row_num_i(row_num_i[x]),
                                .filter_size_i(filter_size_i),
                                //.f_sel_rst_i(rst_i),
                                //.f_sel_ld_i(wr_en_i),
                                //.freg_rst_i(rst_i),
                                .rst_i(rst_i),
                                .load_i(load_i),
                                .ready_i(ready_i),
                                .start_op_i(start_op_i),
                                .clk_i(clk_i),
                                .f_weight_i(f_weight_i[x]),
                                //.wreg_rst_i(rst_i),
                                //.wreg_wr_en_i(wr_en_i),
                                .column_num_i(column_num_i[x]),
                                //.column_num_rst_i(rst_i),
                                //.column_num_ld_i(wr_en_i),
                                //.mreg_addrs_rst_i(mreg_addrs_rst_i),
                                //.mreg_start_i(mreg_start_i),
                                //.mreg_rst_i(rst_i),
                                //.mreg_wr_en_i(wr_en_i),
                                .top_pe_in_i({(F_WIDTH+I_WIDTH){1'b0}}),
                                //.en_adder_1_i(en_adder_1_i[x]),
                                //.en_adder_rst_i(rst_i),
                                //.en_adder_ld_i(wr_en_i),
                                //.oreg_1_rst_i(rst_i),
                                //.oreg_1_ld_i(wr_en_i),
                                .left_pe_in_i({(F_WIDTH+I_WIDTH){1'b0}}),
                                //.en_adder_2_i(en_adder_2_i[x]),
                                //.oreg_2_rst_i(rst_i),
                                //.oreg_2_ld_i(wr_en_i),
                                
                                .sel_mux_tr_rst_o(sel_mux_tr_rst[x][y]),
                                .sel_mux_tr_ld_o(sel_mux_tr_ld[x][y]),
                                .number_of_columns_rst_o(number_of_columns_rst[x][y]),
                                .number_of_columns_ld_o(number_of_columns_ld[x][y]),
                                .out_reg_shift_rst_o(out_reg_shift_rst[x][y]),
                                .node_rst_o(node_rst[x][y]),
                                .node_ld_o(node_ld[x][y]),
                                .path_node_rst_o(path_node_rst[x][y]),
                                .path_node_ld_o(path_node_ld[x][y]),
                                
//                                .en_adder_1_o(en_adder_1[x][y]),
//                                .en_adder_2_o(en_adder_2[x][y]),
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
                                .row_num_i(row_num_i[x]),
                                .filter_size_i(filter_size_i),
//                                .f_sel_rst_i(rst_i),
//                                .f_sel_ld_i(wr_en_i),
//                                .freg_rst_i(rst_i),
                                .rst_i(rst_i),
                                .load_i(load_i),
                                .ready_i(ready_i),
                                .start_op_i(start_op_i),
                                .clk_i(clk_i),
                                .f_weight_i(f_weight[x][y-1]),
//                                .wreg_rst_i(rst_i),
//                                .wreg_wr_en_i(wr_en_i),
                                .column_num_i(column_num[x][y-1]),
//                                .column_num_rst_i(rst_i),
//                                .column_num_ld_i(wr_en_i),
//                                .mreg_addrs_rst_i(mreg_addrs_rst_i),
//                                .mreg_start_i(mreg_start_i),
//                                .mreg_rst_i(rst_i),
//                                .mreg_wr_en_i(wr_en_i),
                                .top_pe_in_i({(F_WIDTH+I_WIDTH){1'b0}}),
                                //.en_adder_1_i(en_adder_1[x][y-1]),
//                                .en_adder_rst_i(rst_i),
//                                .en_adder_ld_i(wr_en_i),
//                                .oreg_1_rst_i(rst_i),
//                                .oreg_1_ld_i(wr_en_i),
                                .left_pe_in_i(output_pe[x][y-1]),
                                //.en_adder_2_i(en_adder_2[x][y-1]),
//                                .oreg_2_rst_i(rst_i),
//                                .oreg_2_ld_i(wr_en_i),

                                .sel_mux_tr_rst_o(sel_mux_tr_rst[x][y]),
                                .sel_mux_tr_ld_o(sel_mux_tr_ld[x][y]),
                                .number_of_columns_rst_o(number_of_columns_rst[x][y]),
                                .number_of_columns_ld_o(number_of_columns_ld[x][y]),
                                .out_reg_shift_rst_o(out_reg_shift_rst[x][y]),
                                .node_rst_o(node_rst[x][y]),
                                .node_ld_o(node_ld[x][y]),
                                .path_node_rst_o(path_node_rst[x][y]),
                                .path_node_ld_o(path_node_ld[x][y]),

                                //.en_adder_1_o(en_adder_1[x][y]),
                                //.en_adder_2_o(en_adder_2[x][y]),
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
                                .row_num_i(row_num_i[x]),
                                .filter_size_i(filter_size_i),
//                                .f_sel_rst_i(rst_i),
//                                .f_sel_ld_i(wr_en_i),
//                                .freg_rst_i(rst_i),
                                .rst_i(rst_i),
                                .load_i(load_i),
                                .ready_i(ready_i),
                                .start_op_i(start_op_i),
                                .clk_i(clk_i),
                                .f_weight_i(f_weight_i[x]),
//                                .wreg_rst_i(rst_i),
//                                .wreg_wr_en_i(wr_en_i),
                                .column_num_i(column_num_i[x]),
//                                .column_num_rst_i(rst_i),
//                                .column_num_ld_i(wr_en_i),
//                                .mreg_addrs_rst_i(mreg_addrs_rst_i),
//                                .mreg_start_i(mreg_start_i),
//                                .mreg_rst_i(rst_i),
//                                .mreg_wr_en_i(wr_en_i),
                                .top_pe_in_i(down_pe[x-1][y]),
                                //.en_adder_1_i(en_adder_1_i[x]),
//                                .en_adder_rst_i(rst_i),
//                                .en_adder_ld_i(wr_en_i),
//                                .oreg_1_rst_i(rst_i),
//                                .oreg_1_ld_i(wr_en_i),
                                .left_pe_in_i({(F_WIDTH+I_WIDTH){1'b0}}),
                                //.en_adder_2_i(en_adder_2_i[x]),
//                                .oreg_2_rst_i(rst_i),
//                                .oreg_2_ld_i(wr_en_i),

                                .sel_mux_tr_rst_o(sel_mux_tr_rst[x][y]),
                                .sel_mux_tr_ld_o(sel_mux_tr_ld[x][y]),
                                .number_of_columns_rst_o(number_of_columns_rst[x][y]),
                                .number_of_columns_ld_o(number_of_columns_ld[x][y]),
                                .out_reg_shift_rst_o(out_reg_shift_rst[x][y]),
                                .node_rst_o(node_rst[x][y]),
                                .node_ld_o(node_ld[x][y]),
                                .path_node_rst_o(path_node_rst[x][y]),
                                .path_node_ld_o(path_node_ld[x][y]),

                                //.en_adder_1_o(en_adder_1[x][y]),
                                //.en_adder_2_o(en_adder_2[x][y]),
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
                                .row_num_i(row_num_i[x]),
                                .filter_size_i(filter_size_i),
//                                .f_sel_rst_i(rst_i),
//                                .f_sel_ld_i(wr_en_i),
//                                .freg_rst_i(rst_i),
                                .rst_i(rst_i),
                                .load_i(load_i),
                                .ready_i(ready_i),
                                .start_op_i(start_op_i),
                                .clk_i(clk_i),
                                .f_weight_i(f_weight[x][y-1]),
//                                .wreg_rst_i(rst_i),
//                                .wreg_wr_en_i(wr_en_i),
                                .column_num_i(column_num[x][y-1]),
//                                .column_num_rst_i(rst_i),
//                                .column_num_ld_i(wr_en_i),
//                                .mreg_addrs_rst_i(mreg_addrs_rst_i),
//                                .mreg_start_i(mreg_start_i),
//                                .mreg_rst_i(rst_i),
//                                .mreg_wr_en_i(wr_en_i),
                                .top_pe_in_i(down_pe[x-1][y]),
                                //.en_adder_1_i(en_adder_1[x][y-1]),
//                                .en_adder_rst_i(rst_i),
//                                .en_adder_ld_i(wr_en_i),
//                                .oreg_1_rst_i(rst_i),
//                                .oreg_1_ld_i(wr_en_i),
                                .left_pe_in_i(output_pe[x][y-1]),
                                //.en_adder_2_i(en_adder_2[x][y-1]),
//                                .oreg_2_rst_i(rst_i),
//                                .oreg_2_ld_i(wr_en_i),

                                .sel_mux_tr_rst_o(sel_mux_tr_rst[x][y]),
                                .sel_mux_tr_ld_o(sel_mux_tr_ld[x][y]),
                                .number_of_columns_rst_o(number_of_columns_rst[x][y]),
                                .number_of_columns_ld_o(number_of_columns_ld[x][y]),
                                .out_reg_shift_rst_o(out_reg_shift_rst[x][y]),
                                .node_rst_o(node_rst[x][y]),
                                .node_ld_o(node_ld[x][y]),
                                .path_node_rst_o(path_node_rst[x][y]),
                                .path_node_ld_o(path_node_ld[x][y]),

                                //.en_adder_1_o(en_adder_1[x][y]),
                                //.en_adder_2_o(en_adder_2[x][y]),
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
                                .sel_mux_tr_rst_i(sel_mux_tr_rst[i][j]),
                                .sel_mux_tr_ld_i(sel_mux_tr_ld[i][j]),
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
                                .sel_mux_tr_rst_i(sel_mux_tr_rst[i][j]),
                                .sel_mux_tr_ld_i(sel_mux_tr_ld[i][j]),
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
                                .sel_mux_tr_rst_i(sel_mux_tr_rst[i][j]),
                                .sel_mux_tr_ld_i(sel_mux_tr_ld[i][j]),
                                .sel_mux_tr_o(sel_mux_tr[i][j]),
                                .tr_data_o(out_mux[i][j])
                                
                            );
                    end
                end
            end
        endgenerate
    
endmodule
