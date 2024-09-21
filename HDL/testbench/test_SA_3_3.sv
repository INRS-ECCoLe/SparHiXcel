`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/10/2024 03:25:26 PM
// Design Name: 
// Module Name: test_SA_3_3
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


module test_SA_3_3();
    //parameter num_tests = 20;
    parameter N_ROWS_ARRAY = 9;
    parameter N_COLS_ARRAY = 8;
    parameter I_WIDTH = 8;
    parameter F_WIDTH = 8;
    parameter N = 3; 
    parameter LEN_TRANSFER = 4;
    parameter MAX_LEN_TRANSFER = 4;
    parameter SEL_MUX_TR_WIDTH = $clog2(MAX_LEN_TRANSFER);
        
    parameter ADDRS_WIDTH = $clog2(N);
    parameter SEL_WIDTH = $clog2(N);
    parameter NUM_COL_WIDTH = $clog2(N+1);
        
    reg signed [I_WIDTH - 1: 0] in_feature_i [0 : N_ROWS_ARRAY - 1];
    reg [SEL_WIDTH - 1: 0] f_sel_i [0 : N_ROWS_ARRAY - 1];
    reg [NUM_COL_WIDTH -1 : 0]row_num_i [0 : N_ROWS_ARRAY - 1];
    reg rst_i;
    reg load_i;
    reg ready_i;
    reg start_op_i;
    reg clk_i;
    reg [$clog2(N+1)-1 : 0]filter_size_i;
    reg signed [F_WIDTH - 1 : 0] f_weight_i [0 : N_ROWS_ARRAY - 1];
      
    reg [NUM_COL_WIDTH - 1 : 0] column_num_i [0 : N_ROWS_ARRAY - 1];
      
    reg [SEL_MUX_TR_WIDTH - 1 : 0] sel_mux_tr_i[0 : N_ROWS_ARRAY - 1];
    //reg en_adder_1_i[0 : N_ROWS_ARRAY - 1];
    //reg en_adder_2_i[0 : N_ROWS_ARRAY - 1];
    reg [NUM_COL_WIDTH - 1 : 0] number_of_columns_i[0 : N_ROWS_ARRAY - 1];
    reg en_adder_node_i [0 : N_ROWS_ARRAY - 1];
    reg sel_mux_node_i [0 : N_ROWS_ARRAY - 1];

    wire signed [F_WIDTH + I_WIDTH - 1 : 0] result [0 : N_COLS_ARRAY - 1];
    
    systolic_array 
    #(
        .N_ROWS_ARRAY(N_ROWS_ARRAY),
        .N_COLS_ARRAY(N_COLS_ARRAY),
        .I_WIDTH(I_WIDTH),
        .F_WIDTH(F_WIDTH),
        .N(N),
        .LEN_TRANSFER(LEN_TRANSFER),
        .MAX_LEN_TRANSFER(MAX_LEN_TRANSFER),
        .SEL_MUX_TR_WIDTH(SEL_MUX_TR_WIDTH),
        .ADDRS_WIDTH(ADDRS_WIDTH),
        .SEL_WIDTH(SEL_WIDTH),
        .NUM_COL_WIDTH(NUM_COL_WIDTH) 
    )
    uut
    (
        .in_feature_i(in_feature_i),
        .f_sel_i(f_sel_i),
        .row_num_i(row_num_i),
        .rst_i(rst_i),
        .load_i(load_i),
        .ready_i(ready_i),
        .start_op_i(start_op_i),
        .clk_i(clk_i),
        .filter_size_i(filter_size_i),
        .f_weight_i(f_weight_i),
        .column_num_i(column_num_i),
        .sel_mux_tr_i(sel_mux_tr_i),
        //.en_adder_1_i(en_adder_1_i),
        //.en_adder_2_i(en_adder_2_i),
        .number_of_columns_i(number_of_columns_i),
        .en_adder_node_i(en_adder_node_i),
        .sel_mux_node_i(sel_mux_node_i),
        .result_o(result)    
    );
    
    integer i;
    initial begin
        filter_size_i = 3;
        start_op_i = 0;
        rst_i = 1;
        #20;
        rst_i = 0;
        #10;
        foreach (row_num_i[i]) begin
            if (i==0) row_num_i[i]= 1;
            else if (i==1) row_num_i[i]= 2;
            else if (i==2) row_num_i[i]= 3;
            else if (i==3) row_num_i[i]= 1;
            else if (i==4) row_num_i[i]= 2;
            else if (i==5) row_num_i[i]= 3;
            else if (i==6) row_num_i[i]= 1;
            else if (i==7) row_num_i[i]= 2;
            else if (i==8) row_num_i[i]= 3;
               
        end
        
        foreach (en_adder_node_i[i]) begin
            if (i==0) en_adder_node_i[i] = 0;
            else if (i==1) en_adder_node_i[i] = 0;   
            else if (i==2) en_adder_node_i[i] = 1;
            else if (i==3) en_adder_node_i[i] = 0;
            else if (i==4) en_adder_node_i[i] = 0;
            else if (i==5) en_adder_node_i[i] = 1;   
            else if (i==6) en_adder_node_i[i] = 0;
            else if (i==7) en_adder_node_i[i] = 0;
            else if (i==8) en_adder_node_i[i] = 1;      
        end
        
        foreach (f_weight_i[i]) begin
            if (i==0) f_weight_i[i]= 0;
            else if (i==1) f_weight_i[i]= 1;
            else if (i==2) f_weight_i[i]= 0;
            else if (i==3) f_weight_i[i]= 1;
            else if (i==4) f_weight_i[i]= 3;
            else if (i==5) f_weight_i[i]= 1;
            else if (i==6) f_weight_i[i]= -1;
            else if (i==7) f_weight_i[i]= 0; 
            else if (i==8) f_weight_i[i]= 0;   
        end
        foreach (sel_mux_node_i[i]) begin
            if (i==0) sel_mux_node_i[i]= 1;
            else if (i==1) sel_mux_node_i[i]= 1;
            else if (i==2) sel_mux_node_i[i]= 0;
            else if (i==3) sel_mux_node_i[i]= 1;
            else if (i==4) sel_mux_node_i[i]= 1;
            else if (i==5) sel_mux_node_i[i]= 0;
            else if (i==6) sel_mux_node_i[i]= 1;
            else if (i==7) sel_mux_node_i[i]= 1; 
            else if (i==8) sel_mux_node_i[i]= 0;
        end
        foreach (column_num_i[i]) begin
            if (i==0) column_num_i[i]= 3;
            else if (i==1) column_num_i[i]= 3;
            else if (i==2) column_num_i[i]= 3;
            else if (i==3) column_num_i[i]= 2;
            else if (i==4) column_num_i[i]= 2;
            else if (i==5) column_num_i[i]= 2;
            else if (i==6) column_num_i[i]= 2;
            else if (i==7) column_num_i[i]= 2;
            else if (i==8) column_num_i[i]= 2; 
        end
        foreach (number_of_columns_i[i]) begin
            if (i==0) number_of_columns_i[i]= 3;
            else if (i==1) number_of_columns_i[i]= 3;
            else if (i==2) number_of_columns_i[i]= 3;
            else if (i==3) number_of_columns_i[i]= 2;
            else if (i==4) number_of_columns_i[i]= 2;
            else if (i==5) number_of_columns_i[i]= 2;
            else if (i==6) number_of_columns_i[i]= 2;
            else if (i==7) number_of_columns_i[i]= 2;
            else if (i==8) number_of_columns_i[i]= 2;    
        end
        /*
        foreach (en_adder_1_i[i]) begin
            if (i==0) en_adder_1_i[i]= 0;
            else if (i==1) en_adder_1_i[i]= 1;
            else if (i==2) en_adder_1_i[i]= 1;
            else if (i==3) en_adder_1_i[i]= 0;
            else if (i==4) en_adder_1_i[i]= 1;
            else if (i==5) en_adder_1_i[i]= 1;
            else if (i==6) en_adder_1_i[i]= 0;
            else if (i==7) en_adder_1_i[i]= 1;
            else if (i==8) en_adder_1_i[i]= 1;   
        end
        foreach (en_adder_2_i[i]) begin
            if (i==0) en_adder_2_i[i]= 0;
            else if (i==1) en_adder_2_i[i]= 0;
            else if (i==2) en_adder_2_i[i]= 1;
            else if (i==3) en_adder_2_i[i]= 0;
            else if (i==4) en_adder_2_i[i]= 0;
            else if (i==5) en_adder_2_i[i]= 1;
            else if (i==6) en_adder_2_i[i]= 0;
            else if (i==7) en_adder_2_i[i]= 0;
            else if (i==8) en_adder_2_i[i]= 1;   
        end
        */
        foreach (f_sel_i[i]) begin
            if (i==0)f_sel_i[i]= 2;
            else if (i==1) f_sel_i[i]= 2;
            else if (i==2) f_sel_i[i]= 2;
            else if (i==3) f_sel_i[i]= 2;
            else if (i==4) f_sel_i[i]= 1;
            else if (i==5) f_sel_i[i]= 2;
            else if (i==6) f_sel_i[i]= 2;
            else if (i==7) f_sel_i[i]= 2;
            else if (i==8) f_sel_i[i]= 2;
               
        end
        
        foreach (sel_mux_tr_i[i]) begin
            if (i==0) sel_mux_tr_i[i] = 0;
            else if (i==1) sel_mux_tr_i[i] = 0;   
            else if (i==2) sel_mux_tr_i[i] = 0;
            else if (i==3) sel_mux_tr_i[i] = 0;
            else if (i==4) sel_mux_tr_i[i] = 0;   
            else if (i==5) sel_mux_tr_i[i] = 0;
            else if (i==6) sel_mux_tr_i[i] = 0;
            else if (i==7) sel_mux_tr_i[i] = 0;   
            else if (i==8) sel_mux_tr_i[i] = 0;   
        end
        #10;
        load_i = 1;
        #10;
        foreach (en_adder_node_i[i]) begin
            if (i==0) en_adder_node_i[i] = 0;
            else if (i==1) en_adder_node_i[i] = 0;   
            else if (i==2) en_adder_node_i[i] = 0;
            else if (i==3) en_adder_node_i[i] = 0;
            else if (i==4) en_adder_node_i[i] = 0;
            else if (i==5) en_adder_node_i[i] = 0;   
            else if (i==6) en_adder_node_i[i] = 0;
            else if (i==7) en_adder_node_i[i] = 0;
            else if (i==8) en_adder_node_i[i] = 0;      
        end
        
        foreach (f_weight_i[i]) begin
            if (i==0) f_weight_i[i]= 3;
            else if (i==1) f_weight_i[i]= 2;
            else if (i==2) f_weight_i[i]= 0;
            else if (i==3) f_weight_i[i]= 1;
            else if (i==4) f_weight_i[i]= 2;
            else if (i==5) f_weight_i[i]= -1;
            else if (i==6) f_weight_i[i]= 1;
            else if (i==7) f_weight_i[i]= -2;
            else if (i==8) f_weight_i[i]= -1;   
        end
        /*
        foreach (sel_mux_node_i[i]) begin
            if (i==0) sel_mux_node_i[i]= 1;
            else if (i==1) sel_mux_node_i[i]= 1;
            else if (i==2) sel_mux_node_i[i]= 1;
            else if (i==3) sel_mux_node_i[i]= 1;
            else if (i==4) sel_mux_node_i[i]= 1;
            else if (i==5) sel_mux_node_i[i]= 1;
            else if (i==6) sel_mux_node_i[i]= 1;
            else if (i==7) sel_mux_node_i[i]= 1;
            else if (i==8) sel_mux_node_i[i]= 1; 
        end
        */
        foreach (sel_mux_node_i[i]) begin
            if (i==0) sel_mux_node_i[i]= 1;
            else if (i==1) sel_mux_node_i[i]= 1;
            else if (i==2) sel_mux_node_i[i]= 0;
            else if (i==3) sel_mux_node_i[i]= 1;
            else if (i==4) sel_mux_node_i[i]= 1;
            else if (i==5) sel_mux_node_i[i]= 0;
            else if (i==6) sel_mux_node_i[i]= 1;
            else if (i==7) sel_mux_node_i[i]= 1; 
            else if (i==8) sel_mux_node_i[i]= 0;
        end
        
        //
        foreach (column_num_i[i]) begin
            if (i==0) column_num_i[i]= 2;
            else if (i==1) column_num_i[i]= 2;
            else if (i==2) column_num_i[i]= 2;
            else if (i==3) column_num_i[i]= 1;
            else if (i==4) column_num_i[i]= 1;
            else if (i==5) column_num_i[i]= 1;
            else if (i==6) column_num_i[i]= 1;
            else if (i==7) column_num_i[i]= 1;
            else if (i==8) column_num_i[i]= 1; 
        end
        foreach (number_of_columns_i[i]) begin
            if (i==0) number_of_columns_i[i]= 3;
            else if (i==1) number_of_columns_i[i]= 3;
            else if (i==2) number_of_columns_i[i]= 3;
            else if (i==3) number_of_columns_i[i]= 2;
            else if (i==4) number_of_columns_i[i]= 2;
            else if (i==5) number_of_columns_i[i]= 2;
            else if (i==6) number_of_columns_i[i]= 2;
            else if (i==7) number_of_columns_i[i]= 2;
            else if (i==8) number_of_columns_i[i]= 2;    
        end
        /*
        foreach (en_adder_1_i[i]) begin
            if (i==0) en_adder_1_i[i]= 0;
            else if (i==1) en_adder_1_i[i]= 1;
            else if (i==2) en_adder_1_i[i]= 1;
            else if (i==3) en_adder_1_i[i]= 0;
            else if (i==4) en_adder_1_i[i]= 1;
            else if (i==5) en_adder_1_i[i]= 1;
            else if (i==6) en_adder_1_i[i]= 0;
            else if (i==7) en_adder_1_i[i]= 1;
            else if (i==8) en_adder_1_i[i]= 1;   
        end
        foreach (en_adder_2_i[i]) begin
            if (i==0) en_adder_2_i[i]= 0;
            else if (i==1) en_adder_2_i[i]= 0;
            else if (i==2) en_adder_2_i[i]= 1;
            else if (i==3) en_adder_2_i[i]= 0;
            else if (i==4) en_adder_2_i[i]= 0;
            else if (i==5) en_adder_2_i[i]= 0;
            else if (i==6) en_adder_2_i[i]= 0;
            else if (i==7) en_adder_2_i[i]= 0;
            else if (i==8) en_adder_2_i[i]= 0;   
        end
        */
        foreach (f_sel_i[i]) begin
            if (i==0)f_sel_i[i]= 1;
            else if (i==1) f_sel_i[i]= 2;
            else if (i==2) f_sel_i[i]= 2;
            else if (i==3) f_sel_i[i]= 2;
            else if (i==4) f_sel_i[i]= 2;
            else if (i==5) f_sel_i[i]= 2;
            else if (i==6) f_sel_i[i]= 2;
            else if (i==7) f_sel_i[i]= 1;
            else if (i==8) f_sel_i[i]= 0;
               
        end
        foreach (sel_mux_tr_i[i]) begin
            if (i==0) sel_mux_tr_i[i] = 0;
            else if (i==1) sel_mux_tr_i[i] = 0;   
            else if (i==2) sel_mux_tr_i[i] = 0;
            else if (i==3) sel_mux_tr_i[i] = 0;
            else if (i==4) sel_mux_tr_i[i] = 0;   
            else if (i==5) sel_mux_tr_i[i] = 0;
            else if (i==6) sel_mux_tr_i[i] = 0;
            else if (i==7) sel_mux_tr_i[i] = 0;   
            else if (i==8) sel_mux_tr_i[i] = 0;   
        end
        #10;
        foreach (en_adder_node_i[i]) begin
            if (i==0) en_adder_node_i[i] = 0;
            else if (i==1) en_adder_node_i[i] = 0;   
            else if (i==2) en_adder_node_i[i] = 1;
            else if (i==3) en_adder_node_i[i] = 0;
            else if (i==4) en_adder_node_i[i] = 0;
            else if (i==5) en_adder_node_i[i] = 1;   
            else if (i==6) en_adder_node_i[i] = 0;
            else if (i==7) en_adder_node_i[i] = 0;
            else if (i==8) en_adder_node_i[i] = 1;      
        end
        
        foreach (f_weight_i[i]) begin
            if (i==0) f_weight_i[i]= -2;
            else if (i==1) f_weight_i[i]= 3;
            else if (i==2) f_weight_i[i]= 5;
            else if (i==3) f_weight_i[i]= 1;
            else if (i==4) f_weight_i[i]= 1;
            else if (i==5) f_weight_i[i]= 0;
            else if (i==6) f_weight_i[i]= -2;
            else if (i==7) f_weight_i[i]= 1;
            else if (i==8) f_weight_i[i]= -1;   
        end
        foreach (sel_mux_node_i[i]) begin
            if (i==0) sel_mux_node_i[i]= 1;
            else if (i==1) sel_mux_node_i[i]= 1;
            else if (i==2) sel_mux_node_i[i]= 0;
            else if (i==3) sel_mux_node_i[i]= 1;
            else if (i==4) sel_mux_node_i[i]= 1;
            else if (i==5) sel_mux_node_i[i]= 0;
            else if (i==6) sel_mux_node_i[i]= 1;
            else if (i==7) sel_mux_node_i[i]= 1;
            else if (i==8) sel_mux_node_i[i]= 0; 
        end
        foreach (column_num_i[i]) begin
            if (i==0) column_num_i[i]= 1;
            else if (i==1) column_num_i[i]= 1;
            else if (i==2) column_num_i[i]= 1;
            else if (i==3) column_num_i[i]= 3;
            else if (i==4) column_num_i[i]= 3;
            else if (i==5) column_num_i[i]= 3;
            else if (i==6) column_num_i[i]= 1;
            else if (i==7) column_num_i[i]= 1;
            else if (i==8) column_num_i[i]= 1; 
        end
        foreach (number_of_columns_i[i]) begin
            if (i==0) number_of_columns_i[i]= 3;
            else if (i==1) number_of_columns_i[i]= 3;
            else if (i==2) number_of_columns_i[i]= 3;
            else if (i==3) number_of_columns_i[i]= 3;
            else if (i==4) number_of_columns_i[i]= 3;
            else if (i==5) number_of_columns_i[i]= 3;
            else if (i==6) number_of_columns_i[i]= 1;
            else if (i==7) number_of_columns_i[i]= 1;
            else if (i==8) number_of_columns_i[i]= 1;    
        end
        /*
        foreach (en_adder_1_i[i]) begin
            if (i==0) en_adder_1_i[i]= 0;
            else if (i==1) en_adder_1_i[i]= 1;
            else if (i==2) en_adder_1_i[i]= 1;
            else if (i==3) en_adder_1_i[i]= 0;
            else if (i==4) en_adder_1_i[i]= 1;
            else if (i==5) en_adder_1_i[i]= 1;
            else if (i==6) en_adder_1_i[i]= 0;
            else if (i==7) en_adder_1_i[i]= 1;
            else if (i==8) en_adder_1_i[i]= 1;   
        end
        foreach (en_adder_2_i[i]) begin
            if (i==0) en_adder_2_i[i]= 0;
            else if (i==1) en_adder_2_i[i]= 0;
            else if (i==2) en_adder_2_i[i]= 0;
            else if (i==3) en_adder_2_i[i]= 0;
            else if (i==4) en_adder_2_i[i]= 0;
            else if (i==5) en_adder_2_i[i]= 1;
            else if (i==6) en_adder_2_i[i]= 0;
            else if (i==7) en_adder_2_i[i]= 0;
            else if (i==8) en_adder_2_i[i]= 0;   
        end
        */
        foreach (f_sel_i[i]) begin
            if (i==0)f_sel_i[i]= 1;
            else if (i==1) f_sel_i[i]= 2;
            else if (i==2) f_sel_i[i]= 0;
            else if (i==3) f_sel_i[i]= 2;
            else if (i==4) f_sel_i[i]= 2;
            else if (i==5) f_sel_i[i]= 2;
            else if (i==6) f_sel_i[i]= 1;
            else if (i==7) f_sel_i[i]= 2;
            else if (i==8) f_sel_i[i]= 0;
               
        end
        foreach (sel_mux_tr_i[i]) begin
            if (i==0) sel_mux_tr_i[i] = 0;
            else if (i==1) sel_mux_tr_i[i] = 0;   
            else if (i==2) sel_mux_tr_i[i] = 0;
            else if (i==3) sel_mux_tr_i[i] = 0;
            else if (i==4) sel_mux_tr_i[i] = 0;   
            else if (i==5) sel_mux_tr_i[i] = 0;
            else if (i==6) sel_mux_tr_i[i] = 0;
            else if (i==7) sel_mux_tr_i[i] = 0;   
            else if (i==8) sel_mux_tr_i[i] = 0;   
        end
        
        #10;
        foreach (en_adder_node_i[i]) begin
            if (i==0) en_adder_node_i[i] = 0;
            else if (i==1) en_adder_node_i[i] = 0;   
            else if (i==2) en_adder_node_i[i] = 1;
            else if (i==3) en_adder_node_i[i] = 0;
            else if (i==4) en_adder_node_i[i] = 0;
            else if (i==5) en_adder_node_i[i] = 1;   
            else if (i==6) en_adder_node_i[i] = 0;
            else if (i==7) en_adder_node_i[i] = 0;
            else if (i==8) en_adder_node_i[i] = 1;      
        end
        
        foreach (f_weight_i[i]) begin
            if (i==0) f_weight_i[i]= 1;
            else if (i==1) f_weight_i[i]= 2;
            else if (i==2) f_weight_i[i]= 1;
            else if (i==3) f_weight_i[i]= 4;
            else if (i==4) f_weight_i[i]= -3;
            else if (i==5) f_weight_i[i]= -1;
            else if (i==6) f_weight_i[i]= 0;
            else if (i==7) f_weight_i[i]= 0;
            else if (i==8) f_weight_i[i]= 1;   
        end
        foreach (sel_mux_node_i[i]) begin
            if (i==0) sel_mux_node_i[i]= 1;
            else if (i==1) sel_mux_node_i[i]= 1;
            else if (i==2) sel_mux_node_i[i]= 0;
            else if (i==3) sel_mux_node_i[i]= 1;
            else if (i==4) sel_mux_node_i[i]= 1;
            else if (i==5) sel_mux_node_i[i]= 0;
            else if (i==6) sel_mux_node_i[i]= 1;
            else if (i==7) sel_mux_node_i[i]= 1;
            else if (i==8) sel_mux_node_i[i]= 0; 
        end
        foreach (column_num_i[i]) begin
            if (i==0) column_num_i[i]= 2;
            else if (i==1) column_num_i[i]= 2;
            else if (i==2) column_num_i[i]= 2;
            else if (i==3) column_num_i[i]= 2;
            else if (i==4) column_num_i[i]= 2;
            else if (i==5) column_num_i[i]= 2;
            else if (i==6) column_num_i[i]= 3;
            else if (i==7) column_num_i[i]= 3;
            else if (i==8) column_num_i[i]= 3; 
        end
        foreach (number_of_columns_i[i]) begin
            if (i==0) number_of_columns_i[i]= 2;
            else if (i==1) number_of_columns_i[i]= 2;
            else if (i==2) number_of_columns_i[i]= 2;
            else if (i==3) number_of_columns_i[i]= 3;
            else if (i==4) number_of_columns_i[i]= 3;
            else if (i==5) number_of_columns_i[i]= 3;
            else if (i==6) number_of_columns_i[i]= 3;
            else if (i==7) number_of_columns_i[i]= 3;
            else if (i==8) number_of_columns_i[i]= 3;    
        end
        /*
        foreach (en_adder_1_i[i]) begin
            if (i==0) en_adder_1_i[i]= 0;
            else if (i==1) en_adder_1_i[i]= 1;
            else if (i==2) en_adder_1_i[i]= 1;
            else if (i==3) en_adder_1_i[i]= 0;
            else if (i==4) en_adder_1_i[i]= 1;
            else if (i==5) en_adder_1_i[i]= 1;
            else if (i==6) en_adder_1_i[i]= 0;
            else if (i==7) en_adder_1_i[i]= 1;
            else if (i==8) en_adder_1_i[i]= 1;   
        end
        foreach (en_adder_2_i[i]) begin
            if (i==0) en_adder_2_i[i]= 0;
            else if (i==1) en_adder_2_i[i]= 0;
            else if (i==2) en_adder_2_i[i]= 1;
            else if (i==3) en_adder_2_i[i]= 0;
            else if (i==4) en_adder_2_i[i]= 0;
            else if (i==5) en_adder_2_i[i]= 1;
            else if (i==6) en_adder_2_i[i]= 0;
            else if (i==7) en_adder_2_i[i]= 0;
            else if (i==8) en_adder_2_i[i]= 1;   
        end
        */
        foreach (f_sel_i[i]) begin
            if (i==0)f_sel_i[i]= 1;
            else if (i==1) f_sel_i[i]= 1;
            else if (i==2) f_sel_i[i]= 2;
            else if (i==3) f_sel_i[i]= 2;
            else if (i==4) f_sel_i[i]= 2;
            else if (i==5) f_sel_i[i]= 2;
            else if (i==6) f_sel_i[i]= 2;
            else if (i==7) f_sel_i[i]= 2;
            else if (i==8) f_sel_i[i]= 2;
               
        end
        foreach (sel_mux_tr_i[i]) begin
            if (i==0) sel_mux_tr_i[i] = 0;
            else if (i==1) sel_mux_tr_i[i] = 0;   
            else if (i==2) sel_mux_tr_i[i] = 1;
            else if (i==3) sel_mux_tr_i[i] = 0;
            else if (i==4) sel_mux_tr_i[i] = 0;   
            else if (i==5) sel_mux_tr_i[i] = 0;
            else if (i==6) sel_mux_tr_i[i] = 0;
            else if (i==7) sel_mux_tr_i[i] = 0;   
            else if (i==8) sel_mux_tr_i[i] = 0;   
        end
        
         #10;
        foreach (en_adder_node_i[i]) begin
            if (i==0) en_adder_node_i[i] = 0;
            else if (i==1) en_adder_node_i[i] = 0;   
            else if (i==2) en_adder_node_i[i] = 0;
            else if (i==3) en_adder_node_i[i] = 0;
            else if (i==4) en_adder_node_i[i] = 0;
            else if (i==5) en_adder_node_i[i] = 0;   
            else if (i==6) en_adder_node_i[i] = 0;
            else if (i==7) en_adder_node_i[i] = 0;
            else if (i==8) en_adder_node_i[i] = 0;      
        end
        
        foreach (f_weight_i[i]) begin
            if (i==0) f_weight_i[i]= -1;
            else if (i==1) f_weight_i[i]= -3;
            else if (i==2) f_weight_i[i]= 1;
            else if (i==3) f_weight_i[i]= 1;
            else if (i==4) f_weight_i[i]= -2;
            else if (i==5) f_weight_i[i]= 1;
            else if (i==6) f_weight_i[i]= 4;
            else if (i==7) f_weight_i[i]= -2; 
            else if (i==8) f_weight_i[i]= -1;   
        end
        /*
        foreach (sel_mux_node_i[i]) begin
            if (i==0) sel_mux_node_i[i]= 1;
            else if (i==1) sel_mux_node_i[i]= 1;
            else if (i==2) sel_mux_node_i[i]= 1;
            else if (i==3) sel_mux_node_i[i]= 1;
            else if (i==4) sel_mux_node_i[i]= 1;
            else if (i==5) sel_mux_node_i[i]= 1;
            else if (i==6) sel_mux_node_i[i]= 1;
            else if (i==7) sel_mux_node_i[i]= 1;
            else if (i==8) sel_mux_node_i[i]= 1; 
        end
        */
        
        foreach (sel_mux_node_i[i]) begin
            if (i==0) sel_mux_node_i[i]= 1;
            else if (i==1) sel_mux_node_i[i]= 1;
            else if (i==2) sel_mux_node_i[i]= 0;
            else if (i==3) sel_mux_node_i[i]= 1;
            else if (i==4) sel_mux_node_i[i]= 1;
            else if (i==5) sel_mux_node_i[i]= 0;
            else if (i==6) sel_mux_node_i[i]= 1;
            else if (i==7) sel_mux_node_i[i]= 1; 
            else if (i==8) sel_mux_node_i[i]= 0;
        end
        //
        
        
        
        foreach (column_num_i[i]) begin
            if (i==0) column_num_i[i]= 1;
            else if (i==1) column_num_i[i]= 1;
            else if (i==2) column_num_i[i]= 1;
            else if (i==3) column_num_i[i]= 1;
            else if (i==4) column_num_i[i]= 1;
            else if (i==5) column_num_i[i]= 1;
            else if (i==6) column_num_i[i]= 2;
            else if (i==7) column_num_i[i]= 2;
            else if (i==8) column_num_i[i]= 2; 
        end
        foreach (number_of_columns_i[i]) begin
            if (i==0) number_of_columns_i[i]= 2;
            else if (i==1) number_of_columns_i[i]= 2;
            else if (i==2) number_of_columns_i[i]= 2;
            else if (i==3) number_of_columns_i[i]= 3;
            else if (i==4) number_of_columns_i[i]= 3;
            else if (i==5) number_of_columns_i[i]= 3;
            else if (i==6) number_of_columns_i[i]= 3;
            else if (i==7) number_of_columns_i[i]= 3;
            else if (i==8) number_of_columns_i[i]= 3;    
        end
        /*
        foreach (en_adder_1_i[i]) begin
            if (i==0) en_adder_1_i[i]= 0;
            else if (i==1) en_adder_1_i[i]= 1;
            else if (i==2) en_adder_1_i[i]= 1;
            else if (i==3) en_adder_1_i[i]= 0;
            else if (i==4) en_adder_1_i[i]= 1;
            else if (i==5) en_adder_1_i[i]= 1;
            else if (i==6) en_adder_1_i[i]= 0;
            else if (i==7) en_adder_1_i[i]= 1;
            else if (i==8) en_adder_1_i[i]= 1;   
        end
        foreach (en_adder_2_i[i]) begin
            if (i==0) en_adder_2_i[i]= 0;
            else if (i==1) en_adder_2_i[i]= 0;
            else if (i==2) en_adder_2_i[i]= 0;
            else if (i==3) en_adder_2_i[i]= 0;
            else if (i==4) en_adder_2_i[i]= 0;
            else if (i==5) en_adder_2_i[i]= 0;
            else if (i==6) en_adder_2_i[i]= 0;
            else if (i==7) en_adder_2_i[i]= 0;
            else if (i==8) en_adder_2_i[i]= 1;   
        end
        */
        foreach (f_sel_i[i]) begin
            if (i==0)f_sel_i[i]= 2;
            else if (i==1) f_sel_i[i]= 1;
            else if (i==2) f_sel_i[i]= 2;
            else if (i==3) f_sel_i[i]= 2;
            else if (i==4) f_sel_i[i]= 2;
            else if (i==5) f_sel_i[i]= 2;
            else if (i==6) f_sel_i[i]= 2;
            else if (i==7) f_sel_i[i]= 2;
            else if (i==8) f_sel_i[i]= 2;
               
        end
        foreach (sel_mux_tr_i[i]) begin
            if (i==0) sel_mux_tr_i[i] = 0;
            else if (i==1) sel_mux_tr_i[i] = 0;   
            else if (i==2) sel_mux_tr_i[i] = 2;
            else if (i==3) sel_mux_tr_i[i] = 0;
            else if (i==4) sel_mux_tr_i[i] = 0;   
            else if (i==5) sel_mux_tr_i[i] = 2;
            else if (i==6) sel_mux_tr_i[i] = 0;
            else if (i==7) sel_mux_tr_i[i] = 0;   
            else if (i==8) sel_mux_tr_i[i] = 0;   
        end
        
         #10;
        foreach (en_adder_node_i[i]) begin
            if (i==0) en_adder_node_i[i] = 0;
            else if (i==1) en_adder_node_i[i] = 0;   
            else if (i==2) en_adder_node_i[i] = 0;
            else if (i==3) en_adder_node_i[i] = 0;
            else if (i==4) en_adder_node_i[i] = 0;
            else if (i==5) en_adder_node_i[i] = 0;   
            else if (i==6) en_adder_node_i[i] = 0;
            else if (i==7) en_adder_node_i[i] = 0;
            else if (i==8) en_adder_node_i[i] = 0;      
        end
        foreach (f_weight_i[i]) begin
            if (i==0) f_weight_i[i]= 0;
            else if (i==1) f_weight_i[i]= 3;
            else if (i==2) f_weight_i[i]= 1;
            else if (i==3) f_weight_i[i]= 0;
            else if (i==4) f_weight_i[i]= 2;
            else if (i==5) f_weight_i[i]= 0;
            else if (i==6) f_weight_i[i]= 3;
            else if (i==7) f_weight_i[i]= -1;
            else if (i==8) f_weight_i[i]= -3;   
        end
        
        /*
        foreach (sel_mux_node_i[i]) begin
            if (i==0) sel_mux_node_i[i]= 1;
            else if (i==1) sel_mux_node_i[i]= 1;
            else if (i==2) sel_mux_node_i[i]= 1;
            else if (i==3) sel_mux_node_i[i]= 1;
            else if (i==4) sel_mux_node_i[i]= 1;
            else if (i==5) sel_mux_node_i[i]= 1;
            else if (i==6) sel_mux_node_i[i]= 1;
            else if (i==7) sel_mux_node_i[i]= 1;
            else if (i==8) sel_mux_node_i[i]= 1; 
        end*/
        
        //
        foreach (sel_mux_node_i[i]) begin
            if (i==0) sel_mux_node_i[i]= 1;
            else if (i==1) sel_mux_node_i[i]= 1;
            else if (i==2) sel_mux_node_i[i]= 0;
            else if (i==3) sel_mux_node_i[i]= 1;
            else if (i==4) sel_mux_node_i[i]= 1;
            else if (i==5) sel_mux_node_i[i]= 0;
            else if (i==6) sel_mux_node_i[i]= 1;
            else if (i==7) sel_mux_node_i[i]= 1; 
            else if (i==8) sel_mux_node_i[i]= 0;
        end
        
        
        ///
        foreach (column_num_i[i]) begin
            if (i==0) column_num_i[i]= 3;
            else if (i==1) column_num_i[i]= 3;
            else if (i==2) column_num_i[i]= 3;
            else if (i==3) column_num_i[i]= 1;
            else if (i==4) column_num_i[i]= 1;
            else if (i==5) column_num_i[i]= 1;
            else if (i==6) column_num_i[i]= 1;
            else if (i==7) column_num_i[i]= 1;
            else if (i==8) column_num_i[i]= 1; 
        end
        foreach (number_of_columns_i[i]) begin
            if (i==0) number_of_columns_i[i]= 3;
            else if (i==1) number_of_columns_i[i]= 3;
            else if (i==2) number_of_columns_i[i]= 3;
            else if (i==3) number_of_columns_i[i]= 1;
            else if (i==4) number_of_columns_i[i]= 1;
            else if (i==5) number_of_columns_i[i]= 1;
            else if (i==6) number_of_columns_i[i]= 3;
            else if (i==7) number_of_columns_i[i]= 3;
            else if (i==8) number_of_columns_i[i]= 3;    
        end
        /*
        foreach (en_adder_1_i[i]) begin
            if (i==0) en_adder_1_i[i]= 0;
            else if (i==1) en_adder_1_i[i]= 1;
            else if (i==2) en_adder_1_i[i]= 1;
            else if (i==3) en_adder_1_i[i]= 0;
            else if (i==4) en_adder_1_i[i]= 1;
            else if (i==5) en_adder_1_i[i]= 1;
            else if (i==6) en_adder_1_i[i]= 0;
            else if (i==7) en_adder_1_i[i]= 1;
            else if (i==8) en_adder_1_i[i]= 1;   
        end
        foreach (en_adder_2_i[i]) begin
            if (i==0) en_adder_2_i[i]= 0;
            else if (i==1) en_adder_2_i[i]= 0;
            else if (i==2) en_adder_2_i[i]= 1;
            else if (i==3) en_adder_2_i[i]= 0;
            else if (i==4) en_adder_2_i[i]= 0;
            else if (i==5) en_adder_2_i[i]= 0;
            else if (i==6) en_adder_2_i[i]= 0;
            else if (i==7) en_adder_2_i[i]= 0;
            else if (i==8) en_adder_2_i[i]= 0;   
        end
        */
        foreach (f_sel_i[i]) begin
            if (i==0)f_sel_i[i]= 2;
            else if (i==1) f_sel_i[i]= 2;
            else if (i==2) f_sel_i[i]= 2;
            else if (i==3) f_sel_i[i]= 2;
            else if (i==4) f_sel_i[i]= 1;
            else if (i==5) f_sel_i[i]= 2;
            else if (i==6) f_sel_i[i]= 2;
            else if (i==7) f_sel_i[i]= 2;
            else if (i==8) f_sel_i[i]= 2;
               
        end
        foreach (sel_mux_tr_i[i]) begin
            if (i==0) sel_mux_tr_i[i] = 0;
            else if (i==1) sel_mux_tr_i[i] = 0;   
            else if (i==2) sel_mux_tr_i[i] = 0;
            else if (i==3) sel_mux_tr_i[i] = 0;
            else if (i==4) sel_mux_tr_i[i] = 0;   
            else if (i==5) sel_mux_tr_i[i] = 0;
            else if (i==6) sel_mux_tr_i[i] = 0;
            else if (i==7) sel_mux_tr_i[i] = 0;   
            else if (i==8) sel_mux_tr_i[i] = 0;   
        end
        
         #10;
        foreach (en_adder_node_i[i]) begin
            if (i==0) en_adder_node_i[i] = 0;
            else if (i==1) en_adder_node_i[i] = 0;   
            else if (i==2) en_adder_node_i[i] = 0;
            else if (i==3) en_adder_node_i[i] = 0;
            else if (i==4) en_adder_node_i[i] = 0;
            else if (i==5) en_adder_node_i[i] = 1;   
            else if (i==6) en_adder_node_i[i] = 0;
            else if (i==7) en_adder_node_i[i] = 0;
            else if (i==8) en_adder_node_i[i] = 1;      
        end
        foreach (f_weight_i[i]) begin
            if (i==0) f_weight_i[i]= 2;
            else if (i==1) f_weight_i[i]= 2;
            else if (i==2) f_weight_i[i]= 1;
            else if (i==3) f_weight_i[i]= -3;
            else if (i==4) f_weight_i[i]= 0;
            else if (i==5) f_weight_i[i]= 1;
            else if (i==6) f_weight_i[i]= -2;
            else if (i==7) f_weight_i[i]= 1;
            else if (i==8) f_weight_i[i]= 0;   
        end
       
        foreach (sel_mux_node_i[i]) begin
            if (i==0) sel_mux_node_i[i]= 1;
            else if (i==1) sel_mux_node_i[i]= 1;
            else if (i==2) sel_mux_node_i[i]= 0;
            else if (i==3) sel_mux_node_i[i]= 1;
            else if (i==4) sel_mux_node_i[i]= 1;
            else if (i==5) sel_mux_node_i[i]= 0;
            else if (i==6) sel_mux_node_i[i]= 1;
            else if (i==7) sel_mux_node_i[i]= 1;
            else if (i==8) sel_mux_node_i[i]= 0; 
        end
        foreach (column_num_i[i]) begin
            if (i==0) column_num_i[i]= 2;
            else if (i==1) column_num_i[i]= 2;
            else if (i==2) column_num_i[i]= 2;
            else if (i==3) column_num_i[i]= 2;
            else if (i==4) column_num_i[i]= 2;
            else if (i==5) column_num_i[i]= 2;
            else if (i==6) column_num_i[i]= 2;
            else if (i==7) column_num_i[i]= 2;
            else if (i==8) column_num_i[i]= 2; 
        end
        foreach (number_of_columns_i[i]) begin
            if (i==0) number_of_columns_i[i]= 3;
            else if (i==1) number_of_columns_i[i]= 3;
            else if (i==2) number_of_columns_i[i]= 3;
            else if (i==3) number_of_columns_i[i]= 2;
            else if (i==4) number_of_columns_i[i]= 2;
            else if (i==5) number_of_columns_i[i]= 2;
            else if (i==6) number_of_columns_i[i]= 2;
            else if (i==7) number_of_columns_i[i]= 2;
            else if (i==8) number_of_columns_i[i]= 2;    
        end
        /*
        foreach (en_adder_1_i[i]) begin
            if (i==0) en_adder_1_i[i]= 0;
            else if (i==1) en_adder_1_i[i]= 1;
            else if (i==2) en_adder_1_i[i]= 1;
            else if (i==3) en_adder_1_i[i]= 0;
            else if (i==4) en_adder_1_i[i]= 1;
            else if (i==5) en_adder_1_i[i]= 1;
            else if (i==6) en_adder_1_i[i]= 0;
            else if (i==7) en_adder_1_i[i]= 1;
            else if (i==8) en_adder_1_i[i]= 1;   
        end
        foreach (en_adder_2_i[i]) begin
            if (i==0) en_adder_2_i[i]= 0;
            else if (i==1) en_adder_2_i[i]= 0;
            else if (i==2) en_adder_2_i[i]= 1;
            else if (i==3) en_adder_2_i[i]= 0;
            else if (i==4) en_adder_2_i[i]= 0;
            else if (i==5) en_adder_2_i[i]= 1;
            else if (i==6) en_adder_2_i[i]= 0;
            else if (i==7) en_adder_2_i[i]= 0;
            else if (i==8) en_adder_2_i[i]= 1;   
        end
        */
        foreach (f_sel_i[i]) begin
            if (i==0)f_sel_i[i]= 1;
            else if (i==1) f_sel_i[i]= 2;
            else if (i==2) f_sel_i[i]= 2;
            else if (i==3) f_sel_i[i]= 1;
            else if (i==4) f_sel_i[i]= 2;
            else if (i==5) f_sel_i[i]= 1;
            else if (i==6) f_sel_i[i]= 1;
            else if (i==7) f_sel_i[i]= 1;
            else if (i==8) f_sel_i[i]= 1;
               
        end
        foreach (sel_mux_tr_i[i]) begin
            if (i==0) sel_mux_tr_i[i] = 0;
            else if (i==1) sel_mux_tr_i[i] = 0;   
            else if (i==2) sel_mux_tr_i[i] = 0;
            else if (i==3) sel_mux_tr_i[i] = 0;
            else if (i==4) sel_mux_tr_i[i] = 0;   
            else if (i==5) sel_mux_tr_i[i] = 0;
            else if (i==6) sel_mux_tr_i[i] = 0;
            else if (i==7) sel_mux_tr_i[i] = 0;   
            else if (i==8) sel_mux_tr_i[i] = 0;   
        end
        
         #10;
        foreach (en_adder_node_i[i]) begin
            if (i==0) en_adder_node_i[i] = 0;
            else if (i==1) en_adder_node_i[i] = 0;   
            else if (i==2) en_adder_node_i[i] = 0;
            else if (i==3) en_adder_node_i[i] = 0;
            else if (i==4) en_adder_node_i[i] = 0;
            else if (i==5) en_adder_node_i[i] = 0;   
            else if (i==6) en_adder_node_i[i] = 0;
            else if (i==7) en_adder_node_i[i] = 0; 
            else if (i==8) en_adder_node_i[i] = 0;     
        end
        foreach (f_weight_i[i]) begin
            if (i==0) f_weight_i[i]= 1;
            else if (i==1) f_weight_i[i]= -1;
            else if (i==2) f_weight_i[i]= -2;
            else if (i==3) f_weight_i[i]= 1;
            else if (i==4) f_weight_i[i]= 0;
            else if (i==5) f_weight_i[i]= 5;
            else if (i==6) f_weight_i[i]= 3;
            else if (i==7) f_weight_i[i]= 2;
            else if (i==8) f_weight_i[i]= 1;   
        end
        
        /*
        foreach (sel_mux_node_i[i]) begin
            if (i==0) sel_mux_node_i[i]= 1;
            else if (i==1) sel_mux_node_i[i]= 1;
            else if (i==2) sel_mux_node_i[i]= 1;
            else if (i==3) sel_mux_node_i[i]= 1;
            else if (i==4) sel_mux_node_i[i]= 1;
            else if (i==5) sel_mux_node_i[i]= 1;
            else if (i==6) sel_mux_node_i[i]= 1;
            else if (i==7) sel_mux_node_i[i]= 1;
            else if (i==8) sel_mux_node_i[i]= 1; 
        end*/
        
        
        ///       
        foreach (sel_mux_node_i[i]) begin
            if (i==0) sel_mux_node_i[i]= 1;
            else if (i==1) sel_mux_node_i[i]= 1;
            else if (i==2) sel_mux_node_i[i]= 0;
            else if (i==3) sel_mux_node_i[i]= 1;
            else if (i==4) sel_mux_node_i[i]= 1;
            else if (i==5) sel_mux_node_i[i]= 0;
            else if (i==6) sel_mux_node_i[i]= 1;
            else if (i==7) sel_mux_node_i[i]= 1; 
            else if (i==8) sel_mux_node_i[i]= 0;
        end
        
        
        //
        foreach (column_num_i[i]) begin
            if (i==0) column_num_i[i]= 1;
            else if (i==1) column_num_i[i]= 1;
            else if (i==2) column_num_i[i]= 1;
            else if (i==3) column_num_i[i]= 1;
            else if (i==4) column_num_i[i]= 1;
            else if (i==5) column_num_i[i]= 1;
            else if (i==6) column_num_i[i]= 1;
            else if (i==7) column_num_i[i]= 1;
            else if (i==8) column_num_i[i]= 1; 
        end
        foreach (number_of_columns_i[i]) begin
            if (i==0) number_of_columns_i[i]= 3;
            else if (i==1) number_of_columns_i[i]= 3;
            else if (i==2) number_of_columns_i[i]= 3;
            else if (i==3) number_of_columns_i[i]= 2;
            else if (i==4) number_of_columns_i[i]= 2;
            else if (i==5) number_of_columns_i[i]= 2;
            else if (i==6) number_of_columns_i[i]= 2;
            else if (i==7) number_of_columns_i[i]= 2;
            else if (i==8) number_of_columns_i[i]= 2;    
        end
        /*
        foreach (en_adder_1_i[i]) begin
            if (i==0) en_adder_1_i[i]= 0;
            else if (i==1) en_adder_1_i[i]= 1;
            else if (i==2) en_adder_1_i[i]= 1;
            else if (i==3) en_adder_1_i[i]= 0;
            else if (i==4) en_adder_1_i[i]= 1;
            else if (i==5) en_adder_1_i[i]= 1;
            else if (i==6) en_adder_1_i[i]= 0;
            else if (i==7) en_adder_1_i[i]= 1;
            else if (i==8) en_adder_1_i[i]= 1;   
        end
        foreach (en_adder_2_i[i]) begin
            if (i==0) en_adder_2_i[i]= 0;
            else if (i==1) en_adder_2_i[i]= 0;
            else if (i==2) en_adder_2_i[i]= 0;
            else if (i==3) en_adder_2_i[i]= 0;
            else if (i==4) en_adder_2_i[i]= 0;
            else if (i==5) en_adder_2_i[i]= 0;
            else if (i==6) en_adder_2_i[i]= 0;
            else if (i==7) en_adder_2_i[i]= 0;
            else if (i==8) en_adder_2_i[i]= 0;   
        end
        */
        foreach (f_sel_i[i]) begin
            if (i==0)f_sel_i[i]= 2;
            else if (i==1) f_sel_i[i]= 2;
            else if (i==2) f_sel_i[i]= 2;
            else if (i==3) f_sel_i[i]= 2;
            else if (i==4) f_sel_i[i]= 2;
            else if (i==5) f_sel_i[i]= 2;
            else if (i==6) f_sel_i[i]= 1;
            else if (i==7) f_sel_i[i]= 1;
            else if (i==8) f_sel_i[i]= 1;
               
        end
        foreach (sel_mux_tr_i[i]) begin
            if (i==0) sel_mux_tr_i[i] = 0;
            else if (i==1) sel_mux_tr_i[i] = 0;   
            else if (i==2) sel_mux_tr_i[i] = 0;
            else if (i==3) sel_mux_tr_i[i] = 0;
            else if (i==4) sel_mux_tr_i[i] = 0;   
            else if (i==5) sel_mux_tr_i[i] = 0;
            else if (i==6) sel_mux_tr_i[i] = 0;
            else if (i==7) sel_mux_tr_i[i] = 0;   
            else if (i==8) sel_mux_tr_i[i] = 0;   
        end
        
        load_i=0;
        ready_i=1;
        #10;
        //load_i=0;
           foreach (f_weight_i[i]) begin
            f_weight_i[i] = 0;   
        end
        #10;
        foreach (in_feature_i[i]) begin
            if (i==0) in_feature_i[i] = 0;
            else if (i==1)in_feature_i[i] = 0;  
            else if (i==2)in_feature_i[i] = 0; 
            else if (i==3)in_feature_i[i] = 0;
            else if (i==4)in_feature_i[i] = 0;  
            else if (i==5)in_feature_i[i] = 0; 
            else if (i==6)in_feature_i[i] = 0;
            else if (i==7)in_feature_i[i] = 0;  
            else if (i==8)in_feature_i[i] = 0;  
        end
        #10;
        foreach (in_feature_i[i]) begin
            if (i==0) in_feature_i[i] = 0;
            else if (i==1)in_feature_i[i] = 0;  
            else if (i==2)in_feature_i[i] = 0; 
            else if (i==3)in_feature_i[i] = 0;
            else if (i==4)in_feature_i[i] = 0;  
            else if (i==5)in_feature_i[i] = 0; 
            else if (i==6)in_feature_i[i] = 0;
            else if (i==7)in_feature_i[i] = 0;  
            else if (i==8)in_feature_i[i] = 0;  
        end
        #10;
        
        foreach (in_feature_i[i]) begin
            if (i==0) in_feature_i[i] = 1;
            else if (i==1)in_feature_i[i] = -2;  
            else if (i==2)in_feature_i[i] = 0; 
            else if (i==3)in_feature_i[i] = 0;
            else if (i==4)in_feature_i[i] = 0;  
            else if (i==5)in_feature_i[i] = 0; 
            else if (i==6)in_feature_i[i] = 0;
            else if (i==7)in_feature_i[i] = 0;  
            else if (i==8)in_feature_i[i] = 0;  
        end
        #10;
        ready_i=0;
      
        start_op_i = 1;
        
        
        foreach (in_feature_i[i]) begin
            if (i==0) in_feature_i[i] = 4;
            else if (i==1)in_feature_i[i] = 1;  
            else if (i==2)in_feature_i[i] = -3; 
            else if (i==3)in_feature_i[i] = 3;
            else if (i==4)in_feature_i[i] = -1;  
            else if (i==5)in_feature_i[i] = 1; 
            else if (i==6)in_feature_i[i] = 0;
            else if (i==7)in_feature_i[i] = 0;  
            else if (i==8)in_feature_i[i] = 0;  
        end
        #10;
        
        
        foreach (in_feature_i[i]) begin
            if (i==0) in_feature_i[i] = 0;
            else if (i==1)in_feature_i[i] = 3;  
            else if (i==2)in_feature_i[i] = 0; 
            else if (i==3)in_feature_i[i] = 2;
            else if (i==4)in_feature_i[i] = -3;  
            else if (i==5)in_feature_i[i] = 2; 
            else if (i==6)in_feature_i[i] = 2;
            else if (i==7)in_feature_i[i] = 4;  
            else if (i==8)in_feature_i[i] = -2;  
        end
        
        #10;
       
        foreach (in_feature_i[i]) begin
            if (i==0) in_feature_i[i] = -1;
            else if (i==1)in_feature_i[i] = -5;  
            else if (i==2)in_feature_i[i] = 2; 
            else if (i==3)in_feature_i[i] = -3;
            else if (i==4)in_feature_i[i] = 0;  
            else if (i==5)in_feature_i[i] = 1; 
            else if (i==6)in_feature_i[i] = -2;
            else if (i==7)in_feature_i[i] = 2;  
            else if (i==8)in_feature_i[i] = 1;  
        end 
        
        #10; 
         
        foreach (in_feature_i[i]) begin
            if (i==0) in_feature_i[i] = 0;
            else if (i==1)in_feature_i[i] = 2;  
            else if (i==2)in_feature_i[i] = 1; 
            else if (i==3)in_feature_i[i] = 3;
            else if (i==4)in_feature_i[i] = 2;  
            else if (i==5)in_feature_i[i] = -4; 
            else if (i==6)in_feature_i[i] = -2;
            else if (i==7)in_feature_i[i] = 1;  
            else if (i==8)in_feature_i[i] = 0;  
        end 
        
        #10;
       
        foreach (in_feature_i[i]) begin
            if (i==0) in_feature_i[i] = 0;
            else if (i==1)in_feature_i[i] = 0;  
            else if (i==2)in_feature_i[i] = 0; 
            else if (i==3)in_feature_i[i] = 3;
            else if (i==4)in_feature_i[i] = -3;  
            else if (i==5)in_feature_i[i] = -1; 
            else if (i==6)in_feature_i[i] = 3;
            else if (i==7)in_feature_i[i] = -1;  
            else if (i==8)in_feature_i[i] = -2;  
        end 
        #10; 
        foreach (in_feature_i[i]) begin
            if (i==0) in_feature_i[i] = 0;
            else if (i==1)in_feature_i[i] = 0;  
            else if (i==2)in_feature_i[i] = 0; 
            else if (i==3)in_feature_i[i] = 0;
            else if (i==4)in_feature_i[i] = 0;  
            else if (i==5)in_feature_i[i] = 0; 
            else if (i==6)in_feature_i[i] = 2;
            else if (i==7)in_feature_i[i] = 3;  
            else if (i==8)in_feature_i[i] = 1;  
        end
        #10;
        foreach (in_feature_i[i]) begin
            if (i==0) in_feature_i[i] = 0;
            else if (i==1)in_feature_i[i] = 0;  
            else if (i==2)in_feature_i[i] = 0; 
            else if (i==3)in_feature_i[i] = 0;
            else if (i==4)in_feature_i[i] = 0;  
            else if (i==5)in_feature_i[i] = 0; 
            else if (i==6)in_feature_i[i] = 0;
            else if (i==7)in_feature_i[i] = 0;  
            else if (i==8)in_feature_i[i] = 0;  
        end 
        #200;  
    end


    //initial begin
        
        
   // end

    //always @ (clk_i) clk_i <= #5 ~clk_i;
    always begin
       clk_i =  1'b1;
       #5; 
	   clk_i = 1'b0;
	   #5;
    end



endmodule
