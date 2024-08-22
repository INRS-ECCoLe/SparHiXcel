`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/19/2024 11:00:11 AM
// Design Name: 
// Module Name: SA_controller
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


module SA_controller
    #(
        parameter N_ROWS_ARRAY = 4,
        parameter N_COLS_ARRAY = 4,
        //parameter I_WIDTH = 8,
        //parameter F_WIDTH = 8,
        parameter N = 3,
        //parameter LEN_TRANSFER = 4,
        parameter MAX_LEN_TRANSFER = 4,
        parameter SEL_MUX_TR_WIDTH = $clog2(MAX_LEN_TRANSFER),
        
        //parameter ADDRS_WIDTH = $clog2(N),
        parameter SEL_WIDTH = $clog2(N),
        parameter NUM_COL_WIDTH = $clog2(N+1),
        parameter ROM_SIG_WIDTH = 100,
        parameter SIG_ADDRS_WIDTH = 10   
    )
    (
        input [ROM_SIG_WIDTH - 1 : 0] rom_signals_data_i,
      
        input [$clog2(N+1)-1 : 0]filter_size_i,
        input clk_i,
        input general_rst_i,
        output  rst_o,
        output  load_o,
        output  ready_o,
        output  start_op_o,
        output reg rd_weight_ld_o,
        output reg rd_feature_ld_o,
        output reg rd_rom_signals_ld_o,
        output reg [SIG_ADDRS_WIDTH - 1 : 0]addrs_rom_signal_o,
        output reg [SEL_WIDTH - 1: 0] f_sel_o [0 : N_ROWS_ARRAY - 1],
        output reg [NUM_COL_WIDTH -1 : 0]row_num_o [0 : N_ROWS_ARRAY - 1],
        output reg [NUM_COL_WIDTH - 1 : 0] column_num_o [0 : N_ROWS_ARRAY - 1],
        output reg [NUM_COL_WIDTH - 1 : 0] number_of_columns_o[0 : N_ROWS_ARRAY - 1],
        output reg [SEL_MUX_TR_WIDTH - 1 : 0] sel_mux_tr_o [0 : N_ROWS_ARRAY - 1],
        output reg en_adder_node_o [0 : N_ROWS_ARRAY - 1],
        output reg sel_mux_node_o [0 : N_ROWS_ARRAY - 1]
                     
    );
    /* 
    localparam [1:0]
        reset = 2'b00 , load = 2'b01,
        ready = 2'b10 , start = 2'b11;
    reg [1:0] p_state, n_state;
    
 
    always @(p_state or rst_o or load_o or ready_o or start_op_o) begin: state_transition
        case(p_state)
            reset:
                if (load_o == 1 && rst_o == 0) n_state = load;
                else n_state = reset;
            load:
                if (ready_o == 1 && load_o == 0) n_state = ready;
                else n_state = load;
            ready:
                if (start_op_o == 1 && ready_o == 0) n_state = start;
                else n_state = ready;
            start:
                if (rst_o == 1) n_state = reset;
                else n_state = start;
            default:
                n_state = reset;
        endcase
        
    end
   
    always @(p_state or rst_i or load_i or ready_i or start_op_i) begin: output_assignments
        //case(p_state)
    
    end
     */
    
    reg [NUM_COL_WIDTH - 1 : 0] count_col [0 : N_ROWS_ARRAY - 1]; 
    wire rst_col, ld_col;
    wire f_sel_ld, f_sel_rst;
    wire sel_mux_tr_ld, sel_mux_tr_rst;
    wire number_of_columns_ld, number_of_columns_rst;
    wire en_adder_node_ld, en_adder_node_rst;
    wire [SEL_WIDTH - 1: 0] f_sel [0 : N_ROWS_ARRAY - 1];
    wire [NUM_COL_WIDTH - 1 : 0] number_of_columns[0 : N_ROWS_ARRAY - 1];
    wire [SEL_MUX_TR_WIDTH - 1 : 0] sel_mux_tr [0 : N_ROWS_ARRAY - 1];
    wire en_adder_node [0 : N_ROWS_ARRAY - 1];
    genvar j;
    generate
        for (j = 0 ; j < N_ROWS_ARRAY ; j = j + 1) begin
            assign f_sel[j] =  rom_signals_data_i [(j + 1)* SEL_WIDTH - 1 : j * SEL_WIDTH];
            assign number_of_columns[j] =  rom_signals_data_i [(j + 1)* NUM_COL_WIDTH + N_ROWS_ARRAY * SEL_WIDTH - 1 : j* NUM_COL_WIDTH + N_ROWS_ARRAY * SEL_WIDTH];
            assign sel_mux_tr [j] = rom_signals_data_i [(j+1) * SEL_MUX_TR_WIDTH  + N_ROWS_ARRAY * (NUM_COL_WIDTH + SEL_WIDTH) - 1 : j * SEL_MUX_TR_WIDTH  + N_ROWS_ARRAY * (NUM_COL_WIDTH + SEL_WIDTH)];
            assign en_adder_node [j] = rom_signals_data_i [(j+1) + N_ROWS_ARRAY * (SEL_MUX_TR_WIDTH + NUM_COL_WIDTH + SEL_WIDTH) - 1 : j + N_ROWS_ARRAY * (SEL_MUX_TR_WIDTH + NUM_COL_WIDTH + SEL_WIDTH)];
        
        end
    endgenerate
    
    integer i , b;
    always@ (*) begin  
        b = 0;
        for(i = 0; i < N_ROWS_ARRAY; i = i + 1) begin
            if (b == filter_size_i) begin 
                b = 0;  
            end
            row_num_o[i] = b + 1'b1;
            b = b + 1; 
            if (row_num_o[i] == filter_size_i) sel_mux_node_o[i] = 0;
            else sel_mux_node_o[i] = 1;   
        end
        
    end
    
    always @(posedge clk_i) begin
        if (rst_col)begin
            foreach(count_col[i]) begin
                count_col[i] <= 0;
            end    
        end else if (ld_col) begin
            for (i = 0; i < N_ROWS_ARRAY; i = i + 1) begin
                column_num_o[i] <= number_of_columns_o [i] - count_col[i];
                if (count_col[i] == number_of_columns_o[i]-1)
                    count_col[i] <= 0;
                else begin
                    count_col[i] <= count_col[i] + 1;    
                end
            end    
        end
    end
  
    
    
    always @ (posedge clk_i or posedge f_sel_rst) begin 
        
        if (f_sel_rst) begin
            for(i = 0; i < N_ROWS_ARRAY; i = i + 1)begin
                f_sel_o[i] <= 0;
            end    
        end else if (f_sel_ld) begin
            for(i = 0; i < N_ROWS_ARRAY; i = i + 1)begin
                f_sel_o[i] <= f_sel[i];
            end   
        end
    end
    
    
    
    always @ (posedge clk_i or posedge number_of_columns_rst) begin 
        
        if (number_of_columns_rst) begin
            for(i = 0; i < N_ROWS_ARRAY; i = i + 1)begin
                number_of_columns_o[i] <= 0;
            end    
        end else if (number_of_columns_ld) begin
            for(i = 0; i < N_ROWS_ARRAY; i = i + 1)begin
                number_of_columns_o[i] <= number_of_columns[i];
            end     
        end
    end
    
    
    
    always @ (posedge clk_i or posedge sel_mux_tr_rst) begin 
        
        if (sel_mux_tr_rst) begin 
            for(i = 0; i < N_ROWS_ARRAY; i = i + 1)begin
                sel_mux_tr_o[i] <= 0;
            end     
        end else if (sel_mux_tr_ld) begin
            for(i = 0; i < N_ROWS_ARRAY; i = i + 1)begin
                sel_mux_tr_o[i] <= sel_mux_tr[i];
            end  
        end
    end
    
    
    
    always @ (posedge clk_i or posedge en_adder_node_rst) begin 
        
        if (en_adder_node_rst) begin
            for(i = 0; i < N_ROWS_ARRAY; i = i + 1)begin
                en_adder_node_o[i] <= 0;
            end       
        end else if (en_adder_node_ld) begin
            for(i = 0; i < N_ROWS_ARRAY; i = i + 1)begin
                en_adder_node_o[i] <= en_adder_node[i];
            end 
        end
    end
    
    
endmodule

