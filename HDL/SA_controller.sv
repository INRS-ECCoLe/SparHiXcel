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
        parameter SIG_ADDRS_WIDTH = 10,   
        
        parameter LOAD_COUNTER_WIDTH = 4,
        parameter READY_COUNTER_WIDTH = 2,
        parameter WAITING_OP_COUNTER_WIDTH = 4,
        //parameter COUNTER_ROUND_WIDTH = 3,
        parameter INPUT_FEATURE_ADDR_WIDTH = 16,
        parameter INPUT_A_ROUND_WIDTH = 5,
        parameter MAX_ITERATION_FILTER_NUM = 10,
        parameter NUMBER_SUPPORTED_FILTERS = 30,
        parameter MAX_TOTAL_CHANNEL_NUM = 50,
        parameter MAX_ITERATION_INPUT_ADDRESS_FOR_A_LAYER = 10,
        parameter BRAM_ADDR_WIDTH = 11,
        parameter SEL_WIDTH_MUX_OUT_1 = 2,
        parameter SEL_WIDTH_MUX_OUT_2 = 2,
        parameter DRAM_ADDR_WIDTH = 18,
        parameter PARAMETERS_WIDTH = 10
    )
    (
        input [ROM_SIG_WIDTH - 1 : 0] rom_signals_data_i,
        input [PARAMETERS_WIDTH - 1: 0] parameters_data_i,
//        input wr_parameters_ld_i,
//        input [$clog2(N+1)-1 : 0]filter_size_i,
        input clk_i,
        input general_rst_i,
        //input end_feature_i,
        //input [COUNTER_ROUND_WIDTH - 1 : 0] max_round_weight_i,
        //input [$clog2(MAX_TOTAL_FILTER_NUM) - 1 : 0] total_num_filters_i,
//        input [$clog2(MAX_ITERATION_FILTER_NUM) - 1 : 0] iteration_num_filters_i,
//        input [$clog2(NUMBER_SUPPORTED_FILTERS) - 1 : 0] num_filters_a_round_i,
//        input [$clog2(MAX_TOTAL_CHANNEL_NUM) - 1 : 0] total_num_channels_i,
        //input [$clog2(MAX_TOTAL_INPUT_ADDRESS_FOR_A_LAYER) - 1 : 0] total_num_inputs_i,
//        input [$clog2(MAX_ITERATION_INPUT_ADDRESS_FOR_A_LAYER) - 1 : 0] iteration_num_inputs_i,
//        input [(INPUT_A_ROUND_WIDTH) - 1 : 0] num_input_a_round_i,
        input input_ready_i, //from DRAM
        input weight_ready_i,
        input bram_ready_i,
        output [INPUT_FEATURE_ADDR_WIDTH - 1 : 0] in_feature_addr_o,
        output reg rst_o,
        output reg load_o,
        output reg ready_o,
        output reg start_op_o,
        output reg rd_weight_ld_o,//
        output reg rd_weight_rst_o,//
        output reg rd_feature_ld_o,//
        output reg rd_rom_signals_ld_o,//
        output [SIG_ADDRS_WIDTH - 1 : 0] addrs_rom_signal_o,
        output [BRAM_ADDR_WIDTH - 1 : 0] bram_addr_write_read_o,
        output [BRAM_ADDR_WIDTH - 1 : 0] bram_addr_read_write_o,
        output [BRAM_ADDR_WIDTH - 1 : 0] bram_addr_max_o,
        output reg [SEL_WIDTH - 1: 0] f_sel_o [0 : N_ROWS_ARRAY - 1],
        output reg [NUM_COL_WIDTH -1 : 0]row_num_o [0 : N_ROWS_ARRAY - 1],
        output reg [NUM_COL_WIDTH - 1 : 0] column_num_o [0 : N_ROWS_ARRAY - 1],
        output reg [NUM_COL_WIDTH - 1 : 0] number_of_columns_o[0 : N_ROWS_ARRAY - 1],
        output reg [SEL_MUX_TR_WIDTH - 1 : 0] sel_mux_tr_o [0 : N_ROWS_ARRAY - 1],
        output reg [SEL_WIDTH_MUX_OUT_1 - 1 : 0] sel_mux_out_1_o [0 : (NUMBER_SUPPORTED_FILTERS + N_COLS_ARRAY - 1) / N_COLS_ARRAY - 1],
        output reg [SEL_WIDTH_MUX_OUT_2 - 1 : 0] sel_mux_out_2_o [0 : (NUMBER_SUPPORTED_FILTERS + N_COLS_ARRAY - 1) / N_COLS_ARRAY - 1],
        output reg bram_wr_en_a_o [0 : ((NUMBER_SUPPORTED_FILTERS + N_COLS_ARRAY - 1) / N_COLS_ARRAY)  - 1],
        output reg en_adder_node_o [0 : N_ROWS_ARRAY - 1],
        output reg sel_mux_node_o [0 : N_ROWS_ARRAY - 1],
        output reg bram_rst_o,//
        output reg sel_mux_out_ld_o,//
        output reg sel_mux_out_rst_o,//
        output reg mux_out_reg_wr_en_o,//
        output reg mux_out_reg_rst_o,//
        output reg bram_wr_en_a_rst_o,//
        output reg bram_wr_en_a_ld_o, //
//        output reg bram_wr_en_b_rst_o,//
//        output reg bram_wr_en_b_ld_o,//
        output [DRAM_ADDR_WIDTH - 1 : 0] input_start_addr_dram_o,
        output [DRAM_ADDR_WIDTH - 1 : 0] input_finish_addr_dram_o,
        output [DRAM_ADDR_WIDTH - 1 : 0] weight_start_addr_dram_o,
        output [DRAM_ADDR_WIDTH - 1 : 0] weight_finish_addr_dram_o,
        output [DRAM_ADDR_WIDTH - 1 : 0] signal_start_addr_dram_o,
        output [DRAM_ADDR_WIDTH - 1 : 0] signal_finish_addr_dram_o, 
        output [3:0] sa_state_o,   
        output reg order_empty_bram_o  //          
    );
     
    
    reg [NUM_COL_WIDTH - 1 : 0] count_col [0 : N_ROWS_ARRAY - 1]; 
    reg rst_col, ld_col;//
    reg f_sel_ld, f_sel_rst;//
    reg sel_mux_tr_ld, sel_mux_tr_rst;//
    reg number_of_columns_ld, number_of_columns_rst;//
    reg en_adder_node_ld, en_adder_node_rst;//
    reg counter_waiting_op_rst;//
    reg counter_waiting_op_ld;//
    reg counter_load_rst;//
    reg counter_load_ld;//
    reg counter_ready_rst;//
    reg counter_ready_ld;//
    //reg counter_address_rom_rst;
    //reg round_weight_ld;
    //reg in_feature_address_rst;//
   //reg in_feature_address_ld;//
    //reg end_weight;
    //wire [COUNTER_ROUND_WIDTH - 1 : 0]round_num_weight;
    //reg counter_address_rom_ld;
    wire [READY_COUNTER_WIDTH - 1 : 0] ready_count_num;
    wire [LOAD_COUNTER_WIDTH - 1 : 0] load_count_num;  
    wire [WAITING_OP_COUNTER_WIDTH - 1 : 0] waiting_op_count_num; 
    wire [SEL_WIDTH - 1: 0] f_sel [0 : N_ROWS_ARRAY - 1];
    wire [NUM_COL_WIDTH - 1 : 0] number_of_columns[0 : N_ROWS_ARRAY - 1];
    wire [SEL_MUX_TR_WIDTH - 1 : 0] sel_mux_tr [0 : N_ROWS_ARRAY - 1];
    wire en_adder_node [0 : N_ROWS_ARRAY - 1];
    
    //wire num_input_a_round_rst;
    //wire num_input_a_round_ld;
    reg num_channel_rst;//
    reg [$clog2(MAX_TOTAL_CHANNEL_NUM) - 1 : 0] num_channel;
    reg increment_done_ch;   
    reg [$clog2(MAX_ITERATION_FILTER_NUM) - 1 : 0] iteration_num_filters; // number of iterations for covering all filters, for example: iteration_num_filters=3 that means the first iteration we cover like 25 filters , next iteration 27 filters, and the last we cover 23 filters and thus all 75 filters are finished
//    wire iteration_num_filters_rst;
//    wire iteration_num_filters_ld;
    reg [$clog2(NUMBER_SUPPORTED_FILTERS) - 1 : 0] num_filters_a_round; // number of filters that is covered in this round for example the first round we cover 25 filters from 75 filters in which this layer has.
//    wire num_filters_a_round_rst;
//    wire num_filters_a_round_ld;
    reg [$clog2(MAX_TOTAL_CHANNEL_NUM) - 1 : 0] total_num_channels; 
//    wire total_num_channels_rst;
//    wire total_num_channels_ld;
    reg [$clog2(MAX_ITERATION_INPUT_ADDRESS_FOR_A_LAYER) - 1 : 0] iteration_num_inputs;
//    wire iteration_num_inputs_rst;
//    wire iteration_num_inputs_ld;
    reg [(INPUT_A_ROUND_WIDTH) - 1 : 0] number_input_a_round;
    //wire number_input_a_round_rst;
    //wire number_input_a_round_ld;
    reg [$clog2(N+1)-1 : 0]filter_size;
    //wire filter_size_rst;
    //wire filter_size_ld;
    reg [$clog2(MAX_ITERATION_INPUT_ADDRESS_FOR_A_LAYER) - 1 : 0] count_round_input;
    reg increment_done_round_input;
    reg count_round_input_rst;//
    reg [$clog2(MAX_ITERATION_FILTER_NUM) - 1 : 0] count_round_filter;
    reg increment_done_round_filter;
    reg count_round_filter_rst;//
    reg addrs_rom_signal_rst;//
    reg addrs_rom_signal_ld;//
    reg bram_addr_write_read_rst;//
    reg bram_addr_write_read_ld;//
    wire [SEL_WIDTH_MUX_OUT_1 - 1 : 0] sel_mux_out_1 [0 : (NUMBER_SUPPORTED_FILTERS + N_COLS_ARRAY - 1) / N_COLS_ARRAY - 1];
    wire [SEL_WIDTH_MUX_OUT_2 - 1 : 0] sel_mux_out_2 [0 : (NUMBER_SUPPORTED_FILTERS + N_COLS_ARRAY - 1) / N_COLS_ARRAY - 1];
    wire bram_wr_en_a [0 : ((NUMBER_SUPPORTED_FILTERS + N_COLS_ARRAY - 1) / N_COLS_ARRAY)  - 1];
    //wire bram_wr_en_b;  
    reg [$clog2(MAX_TOTAL_CHANNEL_NUM) - 1 : 0] input_round_number;
    wire [$clog2(MAX_TOTAL_CHANNEL_NUM) - 1 : 0] max_input_round_number = (total_num_channels + N_ROWS_ARRAY - 1)/N_ROWS_ARRAY;
    reg [SEL_MUX_TR_WIDTH - 1 : 0] pre_sel_mux_tr [0 : N_ROWS_ARRAY - 1];
    reg start_wait_rst; 
    reg start_wait_ld;
    wire [WAITING_OP_COUNTER_WIDTH - 1 : 0] start_wait_count_num;
    
    localparam [3:0]
        reset = 4'b0000 , load = 4'b0001, wait_weight = 4'b0010,
        ready = 4'b0011 , start = 4'b0100 , waiting = 4'b0101,
        store = 4'b0110 , next_channels = 4'b0111 , next_filters = 4'b1000 ,
        next_input = 4'b1001, wait_bram = 4'b1010;
    reg [3:0] p_state, n_state;
    assign sa_state_o = p_state; 
    always @(p_state or general_rst_i or input_ready_i or load_count_num or count_round_filter or iteration_num_inputs or count_round_input or iteration_num_filters or num_channel or total_num_channels or ready_count_num or count_input_a_round or number_input_a_round or weight_ready_i or bram_ready_i or waiting_op_count_num or filter_size or max_input_round_number) begin: state_transition
        case(p_state)
            reset:
                if (general_rst_i == 0 && input_ready_i == 1 && weight_ready_i == 1 && bram_ready_i == 1) n_state = load;
                else if (general_rst_i == 0 && input_ready_i == 1 && weight_ready_i == 0) n_state = wait_weight; 
                else if (general_rst_i == 0 && input_ready_i == 1 && weight_ready_i == 1 && bram_ready_i == 0) n_state = wait_bram; 
                else n_state = reset;
            wait_weight:
                if (general_rst_i == 1) n_state = reset;
                else if (weight_ready_i == 1 && bram_ready_i == 1) n_state = load;
                else if (weight_ready_i == 1 && bram_ready_i == 0)n_state = wait_bram; 
                else n_state = wait_weight; 
            wait_bram:
                if (general_rst_i == 1) n_state = reset;
                else if (bram_ready_i == 1) n_state = load;
                else n_state = wait_bram;
            load:
                if (general_rst_i == 1) n_state = reset;
                else if (load_count_num == N_COLS_ARRAY - 1) n_state = ready;
                else n_state = load;
            ready:
                if (general_rst_i == 1) n_state = reset;
                else if (ready_count_num == 2) n_state = start;
                else n_state = ready;
            start:
                if (general_rst_i == 1) n_state = reset;
                else if ((bram_addr_write_read_o == 2**BRAM_ADDR_WIDTH - 2)|| (count_input_a_round == number_input_a_round - 1) || input_ready_i == 0) n_state = waiting;
                else n_state = start;
            waiting:
                if (general_rst_i == 1) n_state = reset;
                else if ((num_channel >= total_num_channels - N_ROWS_ARRAY/filter_size) && (waiting_op_count_num == 2 * (filter_size - 1) + 6 + max_input_round_number)) n_state = store;
                else if ((num_channel < total_num_channels - N_ROWS_ARRAY/filter_size)&& (waiting_op_count_num == 2 * (filter_size - 1) + 6 + max_input_round_number)) n_state = next_channels;
                else n_state = waiting;
            store:
                if (general_rst_i == 1) n_state = reset;
                else if ((count_round_filter == iteration_num_filters - 1) && (count_round_input == iteration_num_inputs - 1)) n_state = reset;
                else if ((count_round_filter == iteration_num_filters - 1) && (count_round_input != iteration_num_inputs - 1)) n_state = next_input; 
                else if (count_round_filter != iteration_num_filters - 1) n_state = next_filters; 
                else n_state = store;      
            next_channels:
                if (general_rst_i == 1) n_state = reset;
                else if (input_ready_i == 1 && weight_ready_i == 1 && bram_ready_i == 1) n_state = load;
                else if (input_ready_i == 1 && weight_ready_i == 0) n_state = wait_weight;
                else if (input_ready_i == 1 && weight_ready_i == 1 && bram_ready_i == 0) n_state = wait_bram;
                else n_state = next_channels;
            next_filters:
                if (general_rst_i == 1) n_state = reset;
                else if (input_ready_i == 1 && weight_ready_i == 1 && bram_ready_i == 1) n_state = load; 
                else if (input_ready_i == 1 && weight_ready_i == 0) n_state = wait_weight;
                else if (input_ready_i == 1 && weight_ready_i == 1 && bram_ready_i == 0) n_state = wait_bram;
                else n_state = next_filters;   
            next_input:
                if (general_rst_i == 1) n_state = reset;
                else if (input_ready_i == 1 && weight_ready_i == 1 && bram_ready_i == 1) n_state = load; 
                else if (input_ready_i == 1 && weight_ready_i == 0) n_state = wait_weight;
                else if (input_ready_i == 1 && weight_ready_i == 1 && bram_ready_i == 0) n_state = wait_bram;
                else n_state = next_input;
            default:
                n_state = reset;
        endcase
        
    end
     
    always @(p_state or general_rst_i or input_ready_i or load_count_num or count_round_filter or iteration_num_inputs or count_round_input or iteration_num_filters or num_channel or total_num_channels or ready_count_num or count_input_a_round or number_input_a_round or weight_ready_i or bram_ready_i or waiting_op_count_num or filter_size or max_input_round_number) begin: output_assignments
        case(p_state)
            reset: begin
                rst_col = 1;
                f_sel_rst = 1;
                sel_mux_tr_rst= 1;
                number_of_columns_rst = 1;
                en_adder_node_rst = 1;
                counter_load_rst = 1;
                counter_waiting_op_rst = 1;
                counter_ready_rst = 1;
                
                //new 
                num_channel_rst = 1;        //it should be one in store state 
                count_round_input_rst = 1;  //it should be one in only reset state 
                count_round_filter_rst = 1; //it should be one in next_input state 
                addrs_rom_signal_rst = 1;   //it should be one in only reset state 
                bram_addr_write_read_rst = 1; //it should be one in load state 
//                bram_wr_en_b_rst_o
                bram_wr_en_a_rst_o = 1;     //it should be zero in load, ready, start, waiting.
                mux_out_reg_rst_o = 1;      //it should be zero in load, ready, start, waiting.    
                sel_mux_out_rst_o = 1;      //it should be zero in load, ready, start, waiting.
                bram_rst_o = 1;             //it should be one only in reset state.
                start_wait_rst = 1;         //it should be zero in start state.
                
                start_wait_ld = 0;          //it should be one in start.
                sel_mux_out_ld_o = 0;       //it should be one only in load.
                mux_out_reg_wr_en_o = 0;    //it should be one only in load.
                bram_wr_en_a_ld_o = 0;      //it should be one only in load.
//                bram_wr_en_b_ld_o 
                addrs_rom_signal_ld = 0;    //it should be one only in load.
                bram_addr_write_read_ld = 0;//it should be one in start and waiting.  ****maybe i need to make this signal one after a delay in start state since it should wait until the first output to be reached to the bottom of the PE array.
                
                order_empty_bram_o = 0;     // only one in store state.    
                
                //counter_address_rom_rst = 1;
                //in_feature_address_rst = 1;
                rd_weight_rst_o = 1;        //only in load is zero.
                
                ld_col = 0;                 // only in load is one.
                f_sel_ld = 0;                // only in load is one.
                sel_mux_tr_ld = 0;            // only in load is one.   
                number_of_columns_ld = 0;        // only in load is one.
                en_adder_node_ld = 0;            // only in load is one.
                counter_waiting_op_ld = 0;       // only in waiting is one.
                counter_load_ld = 0;             // only in load is one.
                counter_ready_ld = 0;              // only in ready is one.  
                //counter_address_rom_ld = 0;
                //in_feature_address_ld = 0;
                
                rst_o = 1;                       //  in load, ready, start, waiting is zero.
                load_o = 0;                     // in load is 1.
                ready_o = 0;                    // in ready is 1.    
                start_op_o = 0;                 //in start and waiting is 1.
                rd_weight_ld_o = 0;         //only in load is one.
                rd_feature_ld_o = 0;        // in ready, start is 1.
                rd_rom_signals_ld_o = 0;    
                
            end
            wait_weight: begin
                rst_col = 1;
                f_sel_rst = 1;
                sel_mux_tr_rst= 1;
                number_of_columns_rst = 1;
                en_adder_node_rst = 1;
                counter_load_rst = 1;
                counter_waiting_op_rst = 1;
                counter_ready_rst = 1;
                
                //new 
                num_channel_rst = 0;
                count_round_input_rst = 0;
                count_round_filter_rst = 0; //it should be one in next_input state 
                addrs_rom_signal_rst = 0;
                bram_addr_write_read_rst = 0;
//                bram_wr_en_b_rst_o
                bram_wr_en_a_rst_o = 1;
                mux_out_reg_rst_o = 0;
                sel_mux_out_rst_o = 0;
                bram_rst_o = 0;
                start_wait_rst
                
                start_wait_ld
                sel_mux_out_ld_o = 0;
                mux_out_reg_wr_en_o = 0;
                bram_wr_en_a_ld_o = 0;
//                bram_wr_en_b_ld_o 
                addrs_rom_signal_ld = 0;
                bram_addr_write_read_ld = 0;
                
                order_empty_bram_o = 0; 
                
                //counter_address_rom_rst = 1;
                //in_feature_address_rst = 0;
                rd_weight_rst_o = 1;
                
                ld_col = 0;
                f_sel_ld = 0;
                sel_mux_tr_ld = 0;
                number_of_columns_ld = 0;
                en_adder_node_ld = 0;
                counter_waiting_op_ld = 0;
                counter_load_ld = 0;
                counter_ready_ld = 0;
                //counter_address_rom_ld = 0;
//in_feature_address_ld = 0;
                
                rst_o = 1;
                load_o = 0;
                ready_o = 0;
                start_op_o = 0;
                rd_weight_ld_o = 0;
                rd_feature_ld_o = 0;
                rd_rom_signals_ld_o = 0;
            
            end
            wait_bram: begin
                rst_col = 1;
                f_sel_rst = 1;
                sel_mux_tr_rst= 1;
                number_of_columns_rst = 1;
                en_adder_node_rst = 1;
                counter_load_rst = 1;
                counter_waiting_op_rst = 1;
                counter_ready_rst = 1;
                
                //new 
                num_channel_rst = 0;
                count_round_input_rst = 0;
                count_round_filter_rst = 0; //it should be one in next_input state 
                addrs_rom_signal_rst = 0;
                bram_addr_write_read_rst = 0;
//                bram_wr_en_b_rst_o
                bram_wr_en_a_rst_o = 1;
                mux_out_reg_rst_o = 0;
                sel_mux_out_rst_o = 0;
                bram_rst_o = 0;
                start_wait_rst
                
                start_wait_ld
                sel_mux_out_ld_o = 0;
                mux_out_reg_wr_en_o = 0;
                bram_wr_en_a_ld_o = 0;
//                bram_wr_en_b_ld_o 
                addrs_rom_signal_ld = 0;
                bram_addr_write_read_ld = 0;
                
                order_empty_bram_o = 0; 
                
                //counter_address_rom_rst = 1;
                //in_feature_address_rst = 0;
                rd_weight_rst_o = 1;
                
                ld_col = 0;
                f_sel_ld = 0;
                sel_mux_tr_ld = 0;
                number_of_columns_ld = 0;
                en_adder_node_ld = 0;
                counter_waiting_op_ld = 0;
                counter_load_ld = 0;
                counter_ready_ld = 0;
                //counter_address_rom_ld = 0;
//in_feature_address_ld = 0;
                
                rst_o = 1;
                load_o = 0;
                ready_o = 0;
                start_op_o = 0;
                rd_weight_ld_o = 0;
                rd_feature_ld_o = 0;
                rd_rom_signals_ld_o = 0;
            end
            load: begin
                rst_col = 0;
                f_sel_rst = 0;
                sel_mux_tr_rst= 0;
                number_of_columns_rst = 0;
                en_adder_node_rst = 0;
                counter_load_rst = 0;
                counter_waiting_op_rst = 1;
                counter_ready_rst = 0;
                           
                //new 
                num_channel_rst
                count_round_input_rst
                count_round_filter_rst
                addrs_rom_signal_rst
                bram_addr_write_read_rst
//                bram_wr_en_b_rst_o
                bram_wr_en_a_rst_o
                mux_out_reg_rst_o
                sel_mux_out_rst_o
                bram_rst_o
                start_wait_rst
                
                start_wait_ld
                sel_mux_out_ld_o
                mux_out_reg_wr_en_o
                bram_wr_en_a_ld_o
//                bram_wr_en_b_ld_o
                addrs_rom_signal_ld
                bram_addr_write_read_ld
                
                order_empty_bram_o
                
                //counter_address_rom_rst = 0;
                //in_feature_address_rst = 1;
                rd_weight_rst_o = 0;
                
                ld_col = 1;
                f_sel_ld = 1;
                sel_mux_tr_ld = 1;
                number_of_columns_ld = 1;
                en_adder_node_ld = 1;
                counter_waiting_op_ld = 0;
                counter_load_ld = 1;
                counter_ready_ld = 0;
                //counter_address_rom_ld = 1;
                //in_feature_address_ld = 0;
                
                rst_o = 0;
                load_o = 1;
                ready_o = 0;
                start_op_o = 0;
                rd_weight_ld_o = 1;
                rd_feature_ld_o = 0;
                rd_rom_signals_ld_o = 1;
            
            end
            ready: begin
                rst_col = 0;
                f_sel_rst = 0;
                sel_mux_tr_rst= 0;
                number_of_columns_rst = 0;
                en_adder_node_rst = 0;
                counter_load_rst = 1;
                counter_waiting_op_rst = 0;
                counter_ready_rst = 0;
                                
                //new 
                num_channel_rst
                count_round_input_rst
                count_round_filter_rst
                addrs_rom_signal_rst
                bram_addr_write_read_rst
//                bram_wr_en_b_rst_o
                bram_wr_en_a_rst_o
                mux_out_reg_rst_o
                sel_mux_out_rst_o
                bram_rst_o
                start_wait_rst
                
                start_wait_ld
                sel_mux_out_ld_o
                mux_out_reg_wr_en_o
                bram_wr_en_a_ld_o
//                bram_wr_en_b_ld_o
                addrs_rom_signal_ld
                bram_addr_write_read_ld
                
                order_empty_bram_o
                
                //counter_address_rom_rst = 0;
                //in_feature_address_rst = 0;
                rd_weight_rst_o = 0; 
                
                ld_col = 0;
                f_sel_ld = 0;
                sel_mux_tr_ld = 0;
                number_of_columns_ld = 0;
                en_adder_node_ld = 0;
                counter_waiting_op_ld = 0;
                counter_load_ld = 0;
                counter_ready_ld = 1;
                //counter_address_rom_ld = 0;
                //in_feature_address_ld = 1;
                
                rst_o = 0;
                load_o = 0;
                ready_o = 1;
                start_op_o = 0;
                rd_weight_ld_o = 0;
                rd_feature_ld_o = 1;
                rd_rom_signals_ld_o = 0;
            
            
            end
            start: begin
                rst_col = 0;
                f_sel_rst = 0;
                sel_mux_tr_rst= 0;
                number_of_columns_rst = 0;
                en_adder_node_rst = 0;
                counter_load_rst = 0;
                counter_waiting_op_rst = 0;
                counter_ready_rst = 1;
                                
                //new 
                num_channel_rst
                count_round_input_rst
                count_round_filter_rst
                addrs_rom_signal_rst
                bram_addr_write_read_rst
//                bram_wr_en_b_rst_o
                bram_wr_en_a_rst_o
                mux_out_reg_rst_o
                sel_mux_out_rst_o
                bram_rst_o
                start_wait_rst
                
                start_wait_ld
                sel_mux_out_ld_o
                mux_out_reg_wr_en_o
                bram_wr_en_a_ld_o
//                bram_wr_en_b_ld_o
                addrs_rom_signal_ld
                bram_addr_write_read_ld
                
                order_empty_bram_o
                
                //counter_address_rom_rst = 0;
                //in_feature_address_rst = 0;
                rd_weight_rst_o = 0;
                
                ld_col = 0;
                f_sel_ld = 0;
                sel_mux_tr_ld = 0;
                number_of_columns_ld = 0;
                en_adder_node_ld = 0;
                counter_waiting_op_ld = 0;      
                counter_load_ld = 0;
                counter_ready_ld = 0;
                //counter_address_rom_ld = 0;
                //in_feature_address_ld = 1;
                
                rst_o = 0;
                load_o = 0;
                ready_o = 0;
                start_op_o = 1;
                rd_weight_ld_o = 0;
                rd_feature_ld_o = 1;
                rd_rom_signals_ld_o = 0;
            
            end
            waiting: begin
                rst_col = 0;
                f_sel_rst = 0;
                sel_mux_tr_rst= 0;
                number_of_columns_rst = 0;
                en_adder_node_rst = 0;
                counter_load_rst = 0;
                counter_waiting_op_rst = 0;
                counter_ready_rst = 0;
                                
                //new 
                num_channel_rst
                count_round_input_rst
                count_round_filter_rst
                addrs_rom_signal_rst
                bram_addr_write_read_rst
//                bram_wr_en_b_rst_o
                bram_wr_en_a_rst_o
                mux_out_reg_rst_o
                sel_mux_out_rst_o
                bram_rst_o
                start_wait_rst
                
                start_wait_ld
                sel_mux_out_ld_o
                mux_out_reg_wr_en_o
                bram_wr_en_a_ld_o
//                bram_wr_en_b_ld_o
                addrs_rom_signal_ld
                bram_addr_write_read_ld
                
                order_empty_bram_o
                
                //counter_address_rom_rst = 0;
                //in_feature_address_rst = 1;
                rd_weight_rst_o = 0;
                
                ld_col = 0;
                f_sel_ld = 0;
                sel_mux_tr_ld = 0;
                number_of_columns_ld = 0;
                en_adder_node_ld = 0;
                counter_waiting_op_ld = 1;
         
                counter_load_ld = 0;
                counter_ready_ld = 0;
                //counter_address_rom_ld = 0;
                //in_feature_address_ld = 0;
                
                rst_o = 0;
                load_o = 0;
                ready_o = 0;
                start_op_o = 1;
                rd_weight_ld_o = 0;
                rd_feature_ld_o = 0;
                rd_rom_signals_ld_o = 0;
            
            end
            
            store: begin
                rst_col = 1;
                f_sel_rst = 1;
                sel_mux_tr_rst= 1;
                number_of_columns_rst = 1;
                en_adder_node_rst = 1;
                counter_load_rst = 1;
                counter_waiting_op_rst = 1;
                counter_ready_rst = 1;
                                
                //new 
                num_channel_rst
                count_round_input_rst
                count_round_filter_rst
                addrs_rom_signal_rst
                bram_addr_write_read_rst
//                bram_wr_en_b_rst_o
                bram_wr_en_a_rst_o
                mux_out_reg_rst_o
                sel_mux_out_rst_o
                bram_rst_o
                start_wait_rst
                
                start_wait_ld
                sel_mux_out_ld_o
                mux_out_reg_wr_en_o
                bram_wr_en_a_ld_o
//                bram_wr_en_b_ld_o
                addrs_rom_signal_ld
                bram_addr_write_read_ld
                
                order_empty_bram_o
                
                //counter_address_rom_rst = 0;
                //in_feature_address_rst = 1;
                rd_weight_rst_o = 0;
                
                ld_col = 0;
                f_sel_ld = 0;
                sel_mux_tr_ld = 0;
                number_of_columns_ld = 0;
                en_adder_node_ld = 0;
                counter_waiting_op_ld = 1;
         
                counter_load_ld = 0;
                counter_ready_ld = 0;
                //counter_address_rom_ld = 0;
                //in_feature_address_ld = 0;
                
                rst_o = 0;
                load_o = 0;
                ready_o = 0;
                start_op_o = 1;
                rd_weight_ld_o = 0;
                rd_feature_ld_o = 0;
                rd_rom_signals_ld_o = 0;
            end
            
            next_channels: begin 
                rst_col = 1;
                f_sel_rst = 1;
                sel_mux_tr_rst= 1;
                number_of_columns_rst = 1;
                en_adder_node_rst = 1;
                counter_load_rst = 1;
                counter_waiting_op_rst = 1;
                counter_ready_rst = 1;
                                
                //new 
                num_channel_rst
                count_round_input_rst
                count_round_filter_rst
                addrs_rom_signal_rst
                bram_addr_write_read_rst
//                bram_wr_en_b_rst_o
                bram_wr_en_a_rst_o
                mux_out_reg_rst_o
                sel_mux_out_rst_o
                bram_rst_o
                start_wait_rst
                
                start_wait_ld
                sel_mux_out_ld_o
                mux_out_reg_wr_en_o
                bram_wr_en_a_ld_o
//                bram_wr_en_b_ld_o
                addrs_rom_signal_ld
                bram_addr_write_read_ld
                
                order_empty_bram_o
                
                //counter_address_rom_rst = 0;
                //in_feature_address_rst = 1;
                rd_weight_rst_o = 0;
                
                ld_col = 0;
                f_sel_ld = 0;
                sel_mux_tr_ld = 0;
                number_of_columns_ld = 0;
                en_adder_node_ld = 0;
                counter_waiting_op_ld = 1;
         
                counter_load_ld = 0;
                counter_ready_ld = 0;
                //counter_address_rom_ld = 0;
                //in_feature_address_ld = 0;
                
                rst_o = 0;
                load_o = 0;
                ready_o = 0;
                start_op_o = 1;
                rd_weight_ld_o = 0;
                rd_feature_ld_o = 0;
                rd_rom_signals_ld_o = 0;
            end
            
            next_filters: begin
                rst_col = 1;
                f_sel_rst = 1;
                sel_mux_tr_rst= 1;
                number_of_columns_rst = 1;
                en_adder_node_rst = 1;
                counter_load_rst = 1;
                counter_waiting_op_rst = 1;
                counter_ready_rst = 1;
                                
                //new 
                num_channel_rst
                count_round_input_rst
                count_round_filter_rst
                addrs_rom_signal_rst
                bram_addr_write_read_rst
//                bram_wr_en_b_rst_o
                bram_wr_en_a_rst_o
                mux_out_reg_rst_o
                sel_mux_out_rst_o
                bram_rst_o
                start_wait_rst
                
                start_wait_ld
                sel_mux_out_ld_o
                mux_out_reg_wr_en_o
                bram_wr_en_a_ld_o
//                bram_wr_en_b_ld_o
                addrs_rom_signal_ld
                bram_addr_write_read_ld
                
                order_empty_bram_o
                
                //counter_address_rom_rst = 0;
                //in_feature_address_rst = 1;
                rd_weight_rst_o = 0;
                
                ld_col = 0;
                f_sel_ld = 0;
                sel_mux_tr_ld = 0;
                number_of_columns_ld = 0;
                en_adder_node_ld = 0;
                counter_waiting_op_ld = 1;
         
                counter_load_ld = 0;
                counter_ready_ld = 0;
                //counter_address_rom_ld = 0;
                //in_feature_address_ld = 0;
                
                rst_o = 0;
                load_o = 0;
                ready_o = 0;
                start_op_o = 1;
                rd_weight_ld_o = 0;
                rd_feature_ld_o = 0;
                rd_rom_signals_ld_o = 0;
            end
            
            next_input: begin
                rst_col = 1;
                f_sel_rst = 1;
                sel_mux_tr_rst= 1;
                number_of_columns_rst = 1;
                en_adder_node_rst = 1;
                counter_load_rst = 1;
                counter_waiting_op_rst = 1;
                counter_ready_rst = 1;
                                
                //new 
                num_channel_rst
                count_round_input_rst
                count_round_filter_rst
                addrs_rom_signal_rst
                bram_addr_write_read_rst
//                bram_wr_en_b_rst_o
                bram_wr_en_a_rst_o
                mux_out_reg_rst_o
                sel_mux_out_rst_o
                bram_rst_o
                start_wait_rst
                
                start_wait_ld
                sel_mux_out_ld_o
                mux_out_reg_wr_en_o
                bram_wr_en_a_ld_o
//                bram_wr_en_b_ld_o
                addrs_rom_signal_ld
                bram_addr_write_read_ld
                
                order_empty_bram_o
                
                //counter_address_rom_rst = 0;
                //in_feature_address_rst = 1;
                rd_weight_rst_o = 0;
                
                ld_col = 0;
                f_sel_ld = 0;
                sel_mux_tr_ld = 0;
                number_of_columns_ld = 0;
                en_adder_node_ld = 0;
                counter_waiting_op_ld = 1;
         
                counter_load_ld = 0;
                counter_ready_ld = 0;
                //counter_address_rom_ld = 0;
                //in_feature_address_ld = 0;
                
                rst_o = 0;
                load_o = 0;
                ready_o = 0;
                start_op_o = 1;
                rd_weight_ld_o = 0;
                rd_feature_ld_o = 0;
                rd_rom_signals_ld_o = 0;
            end
            
            default: begin
                rst_col = 1;
                f_sel_rst = 1;
                sel_mux_tr_rst= 1;
                number_of_columns_rst = 1;
                en_adder_node_rst = 1;
                counter_load_rst = 1;
                counter_waiting_op_rst = 1;
                counter_ready_rst = 1;
                                
                //new 
                num_channel_rst
                count_round_input_rst
                count_round_filter_rst
                addrs_rom_signal_rst
                bram_addr_write_read_rst
//                bram_wr_en_b_rst_o
                bram_wr_en_a_rst_o = 1;
                mux_out_reg_rst_o = 1;
                sel_mux_out_rst_o = 1;
                bram_rst_o = 
                start_wait_rst
                
                start_wait_ld
                sel_mux_out_ld_o
                mux_out_reg_wr_en_o
                bram_wr_en_a_ld_o
//                bram_wr_en_b_ld_o
                addrs_rom_signal_ld
                bram_addr_write_read_ld
                
                order_empty_bram_o
                
                //counter_address_rom_rst = 1;
                //in_feature_address_rst = 1;
                rd_weight_rst_o = 1;
                
                ld_col = 0;
                f_sel_ld = 0;
                sel_mux_tr_ld = 0;
                number_of_columns_ld = 0;
                en_adder_node_ld = 0;
                counter_waiting_op_ld = 0;
         
                counter_load_ld = 0;
                counter_ready_ld = 0;
                //counter_address_rom_ld = 0;
                //in_feature_address_ld = 0;
                
                rst_o = 1;
                load_o = 0;
                ready_o = 0;
                start_op_o = 0;
                rd_weight_ld_o = 0;
                rd_feature_ld_o = 0;
                rd_rom_signals_ld_o = 0;
            
            end
        endcase 
    
    end
    
    always @ (posedge clk_i) begin: sequential
        if (general_rst_i) p_state <= reset;
        else p_state <= n_state;     
    end
        
    
    // allocating ROM signal data to the corresponding signals and then we will send these signals to their registers we make in the controller.
    genvar j,c;
    generate
        for (j = 0 ; j < N_ROWS_ARRAY ; j = j + 1) begin
            assign f_sel[j] =  rom_signals_data_i [(j + 1)* SEL_WIDTH - 1 : j * SEL_WIDTH];
            assign number_of_columns[j] =  rom_signals_data_i [(j + 1)* NUM_COL_WIDTH + N_ROWS_ARRAY * SEL_WIDTH - 1 : j* NUM_COL_WIDTH + N_ROWS_ARRAY * SEL_WIDTH];
            assign sel_mux_tr [j] = rom_signals_data_i [(j+1) * SEL_MUX_TR_WIDTH  + N_ROWS_ARRAY * (NUM_COL_WIDTH + SEL_WIDTH) - 1 : j * SEL_MUX_TR_WIDTH  + N_ROWS_ARRAY * (NUM_COL_WIDTH + SEL_WIDTH)];
            assign en_adder_node [j] = rom_signals_data_i [(j+1) + N_ROWS_ARRAY * (SEL_MUX_TR_WIDTH + NUM_COL_WIDTH + SEL_WIDTH) - 1 : j + N_ROWS_ARRAY * (SEL_MUX_TR_WIDTH + NUM_COL_WIDTH + SEL_WIDTH)];
        
        end
        for (c = 0 ; c <(NUMBER_SUPPORTED_FILTERS + N_COLS_ARRAY - 1) / N_COLS_ARRAY ; c = c + 1) begin
            assign sel_mux_out_1[c] = rom_signals_data_i [(c + 1) * SEL_WIDTH_MUX_OUT_1 + N_ROWS_ARRAY * (SEL_MUX_TR_WIDTH + NUM_COL_WIDTH + SEL_WIDTH + 1) - 1 : c * SEL_WIDTH_MUX_OUT_1 + N_ROWS_ARRAY * (SEL_MUX_TR_WIDTH + NUM_COL_WIDTH + SEL_WIDTH + 1)];
            assign sel_mux_out_2[c] = rom_signals_data_i [(c + 1) * SEL_WIDTH_MUX_OUT_2 +  ((NUMBER_SUPPORTED_FILTERS + N_COLS_ARRAY - 1) / N_COLS_ARRAY) * SEL_WIDTH_MUX_OUT_1 + N_ROWS_ARRAY * (SEL_MUX_TR_WIDTH + NUM_COL_WIDTH + SEL_WIDTH + 1) - 1 : c * SEL_WIDTH_MUX_OUT_2 +  ((NUMBER_SUPPORTED_FILTERS + N_COLS_ARRAY - 1) / N_COLS_ARRAY) * SEL_WIDTH_MUX_OUT_1 + N_ROWS_ARRAY * (SEL_MUX_TR_WIDTH + NUM_COL_WIDTH + SEL_WIDTH + 1)];
            assign bram_wr_en_a[c] = rom_signals_data_i [(c + 1) +  ((NUMBER_SUPPORTED_FILTERS + N_COLS_ARRAY - 1) / N_COLS_ARRAY) * (SEL_WIDTH_MUX_OUT_1 + SEL_WIDTH_MUX_OUT_2) + N_ROWS_ARRAY * (SEL_MUX_TR_WIDTH + NUM_COL_WIDTH + SEL_WIDTH + 1) - 1 : c +  ((NUMBER_SUPPORTED_FILTERS + N_COLS_ARRAY - 1) / N_COLS_ARRAY) * (SEL_WIDTH_MUX_OUT_1 + SEL_WIDTH_MUX_OUT_2) + N_ROWS_ARRAY * (SEL_MUX_TR_WIDTH + NUM_COL_WIDTH + SEL_WIDTH + 1)];

        end
    endgenerate
    // generating row numbers by a combinational hardware.  

    generate
        assign filter_size = parameters_data_i[$clog2(N+1)-1 : 0];
        assign iteration_num_filters = parameters_data_i [$clog2(MAX_ITERATION_FILTER_NUM) + $clog2(N+1) - 1: $clog2(N+1)];
        assign num_filters_a_round = parameters_data_i [$clog2(NUMBER_SUPPORTED_FILTERS) + $clog2(MAX_ITERATION_FILTER_NUM) + $clog2(N+1) - 1: $clog2(MAX_ITERATION_FILTER_NUM) + $clog2(N+1)];
        assign total_num_channels = parameters_data_i [$clog2(MAX_TOTAL_CHANNEL_NUM)+ $clog2(NUMBER_SUPPORTED_FILTERS) + $clog2(MAX_ITERATION_FILTER_NUM) + $clog2(N+1) - 1 : $clog2(NUMBER_SUPPORTED_FILTERS) + $clog2(MAX_ITERATION_FILTER_NUM) + $clog2(N+1)]; 
        assign iteration_num_inputs = parameters_data_i [$clog2(MAX_ITERATION_INPUT_ADDRESS_FOR_A_LAYER)+ $clog2(MAX_TOTAL_CHANNEL_NUM)+ $clog2(NUMBER_SUPPORTED_FILTERS) + $clog2(MAX_ITERATION_FILTER_NUM) + $clog2(N+1) - 1 : $clog2(MAX_TOTAL_CHANNEL_NUM)+ $clog2(NUMBER_SUPPORTED_FILTERS) + $clog2(MAX_ITERATION_FILTER_NUM) + $clog2(N+1)];
        assign number_input_a_round = parameters_data_i [(INPUT_A_ROUND_WIDTH) + $clog2(MAX_ITERATION_INPUT_ADDRESS_FOR_A_LAYER)+ $clog2(MAX_TOTAL_CHANNEL_NUM)+ $clog2(NUMBER_SUPPORTED_FILTERS) + $clog2(MAX_ITERATION_FILTER_NUM) + $clog2(N+1) - 1 : $clog2(MAX_ITERATION_INPUT_ADDRESS_FOR_A_LAYER)+ $clog2(MAX_TOTAL_CHANNEL_NUM)+ $clog2(NUMBER_SUPPORTED_FILTERS) + $clog2(MAX_ITERATION_FILTER_NUM) + $clog2(N+1)];
        assign input_start_addr_dram_o = parameters_data_i [DRAM_ADDR_WIDTH + (INPUT_A_ROUND_WIDTH) + $clog2(MAX_ITERATION_INPUT_ADDRESS_FOR_A_LAYER)+ $clog2(MAX_TOTAL_CHANNEL_NUM)+ $clog2(NUMBER_SUPPORTED_FILTERS) + $clog2(MAX_ITERATION_FILTER_NUM) + $clog2(N+1) - 1 : (INPUT_A_ROUND_WIDTH) + $clog2(MAX_ITERATION_INPUT_ADDRESS_FOR_A_LAYER)+ $clog2(MAX_TOTAL_CHANNEL_NUM)+ $clog2(NUMBER_SUPPORTED_FILTERS) + $clog2(MAX_ITERATION_FILTER_NUM) + $clog2(N+1)] ;
        assign input_finish_addr_dram_o = parameters_data_i [2*DRAM_ADDR_WIDTH + (INPUT_A_ROUND_WIDTH) + $clog2(MAX_ITERATION_INPUT_ADDRESS_FOR_A_LAYER)+ $clog2(MAX_TOTAL_CHANNEL_NUM)+ $clog2(NUMBER_SUPPORTED_FILTERS) + $clog2(MAX_ITERATION_FILTER_NUM) + $clog2(N+1) - 1 : DRAM_ADDR_WIDTH + (INPUT_A_ROUND_WIDTH) + $clog2(MAX_ITERATION_INPUT_ADDRESS_FOR_A_LAYER)+ $clog2(MAX_TOTAL_CHANNEL_NUM)+ $clog2(NUMBER_SUPPORTED_FILTERS) + $clog2(MAX_ITERATION_FILTER_NUM) + $clog2(N+1)] ;
        assign weight_start_addr_dram_o = parameters_data_i [3*DRAM_ADDR_WIDTH + (INPUT_A_ROUND_WIDTH) + $clog2(MAX_ITERATION_INPUT_ADDRESS_FOR_A_LAYER)+ $clog2(MAX_TOTAL_CHANNEL_NUM)+ $clog2(NUMBER_SUPPORTED_FILTERS) + $clog2(MAX_ITERATION_FILTER_NUM) + $clog2(N+1) - 1 : 2*DRAM_ADDR_WIDTH + (INPUT_A_ROUND_WIDTH) + $clog2(MAX_ITERATION_INPUT_ADDRESS_FOR_A_LAYER)+ $clog2(MAX_TOTAL_CHANNEL_NUM)+ $clog2(NUMBER_SUPPORTED_FILTERS) + $clog2(MAX_ITERATION_FILTER_NUM) + $clog2(N+1)];
        assign weight_finish_addr_dram_o = parameters_data_i [4*DRAM_ADDR_WIDTH + (INPUT_A_ROUND_WIDTH) + $clog2(MAX_ITERATION_INPUT_ADDRESS_FOR_A_LAYER)+ $clog2(MAX_TOTAL_CHANNEL_NUM)+ $clog2(NUMBER_SUPPORTED_FILTERS) + $clog2(MAX_ITERATION_FILTER_NUM) + $clog2(N+1) - 1 : 3*DRAM_ADDR_WIDTH + (INPUT_A_ROUND_WIDTH) + $clog2(MAX_ITERATION_INPUT_ADDRESS_FOR_A_LAYER)+ $clog2(MAX_TOTAL_CHANNEL_NUM)+ $clog2(NUMBER_SUPPORTED_FILTERS) + $clog2(MAX_ITERATION_FILTER_NUM) + $clog2(N+1)];
        assign signal_start_addr_dram_o = parameters_data_i [5*DRAM_ADDR_WIDTH + (INPUT_A_ROUND_WIDTH) + $clog2(MAX_ITERATION_INPUT_ADDRESS_FOR_A_LAYER)+ $clog2(MAX_TOTAL_CHANNEL_NUM)+ $clog2(NUMBER_SUPPORTED_FILTERS) + $clog2(MAX_ITERATION_FILTER_NUM) + $clog2(N+1) - 1 : 4*DRAM_ADDR_WIDTH + (INPUT_A_ROUND_WIDTH) + $clog2(MAX_ITERATION_INPUT_ADDRESS_FOR_A_LAYER)+ $clog2(MAX_TOTAL_CHANNEL_NUM)+ $clog2(NUMBER_SUPPORTED_FILTERS) + $clog2(MAX_ITERATION_FILTER_NUM) + $clog2(N+1)];
        assign signal_finish_addr_dram_o = parameters_data_i [6*DRAM_ADDR_WIDTH + (INPUT_A_ROUND_WIDTH) + $clog2(MAX_ITERATION_INPUT_ADDRESS_FOR_A_LAYER)+ $clog2(MAX_TOTAL_CHANNEL_NUM)+ $clog2(NUMBER_SUPPORTED_FILTERS) + $clog2(MAX_ITERATION_FILTER_NUM) + $clog2(N+1) - 1 : 5*DRAM_ADDR_WIDTH + (INPUT_A_ROUND_WIDTH) + $clog2(MAX_ITERATION_INPUT_ADDRESS_FOR_A_LAYER)+ $clog2(MAX_TOTAL_CHANNEL_NUM)+ $clog2(NUMBER_SUPPORTED_FILTERS) + $clog2(MAX_ITERATION_FILTER_NUM) + $clog2(N+1)];
    endgenerate


    integer i , b;
    always@ (*) begin  
        b = 0;
        for(i = 0; i < N_ROWS_ARRAY; i = i + 1) begin
            if (b == filter_size) begin 
                b = 0;  
            end
            row_num_o[i] = b + 1'b1;
            b = b + 1; 
            if (row_num_o[i] == filter_size) sel_mux_node_o[i] = 0;
            else sel_mux_node_o[i] = 1;   
        end
        
    end
    // generating column number by using number of columns as an input.
    always @(posedge clk_i) begin
        if (rst_col)begin
            foreach(count_col[i]) begin
                count_col[i] <= 0;
            end    
        end else if (ld_col) begin
            for (i = 0; i < N_ROWS_ARRAY; i = i + 1) begin
                column_num_o[i] <= number_of_columns [i] - count_col[i];
                if (count_col[i] == number_of_columns[i]-1)
                    count_col[i] <= 0;
                else begin
                    count_col[i] <= count_col[i] + 1;    
                end
            end    
        end
    end
  
    //Register for f_sel_o
    
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
    //Register for sel_mux_out_1_o

    always @ (posedge clk_i or posedge sel_mux_out_rst_o) begin 
        
        if (sel_mux_out_rst_o) begin
            for(i = 0; i < (NUMBER_SUPPORTED_FILTERS + N_COLS_ARRAY - 1) / N_COLS_ARRAY ; i = i + 1)begin
                sel_mux_out_1_o [i] <= 0;
            end    
        end else if (sel_mux_out_ld_o) begin
            for(i = 0; i < (NUMBER_SUPPORTED_FILTERS + N_COLS_ARRAY - 1) / N_COLS_ARRAY ; i = i + 1)begin
                sel_mux_out_1_o [i] <= sel_mux_out_1 [i];
            end   
        end
    end
    //Register for sel_mux_out_2_o
    
    always @ (posedge clk_i or posedge sel_mux_out_rst_o) begin 
        
        if (sel_mux_out_rst_o) begin
            for(i = 0; i < (NUMBER_SUPPORTED_FILTERS + N_COLS_ARRAY - 1) / N_COLS_ARRAY ; i = i + 1)begin
                sel_mux_out_2_o [i] <= 0;
            end    
        end else if (sel_mux_out_ld_o) begin
            for(i = 0; i < (NUMBER_SUPPORTED_FILTERS + N_COLS_ARRAY - 1) / N_COLS_ARRAY ; i = i + 1)begin
                sel_mux_out_2_o [i] <= sel_mux_out_2 [i];
            end   
        end
    end
    //Register for bram_wr_en_a_o
    
    always @ (posedge clk_i or posedge bram_wr_en_a_rst_o) begin 
        
        if (bram_wr_en_a_rst_o) begin
            for(i = 0; i < (NUMBER_SUPPORTED_FILTERS + N_COLS_ARRAY - 1) / N_COLS_ARRAY ; i = i + 1)begin
                bram_wr_en_a_o [i] <= 0;
            end    
        end else if (bram_wr_en_a_ld_o) begin
            for(i = 0; i < (NUMBER_SUPPORTED_FILTERS + N_COLS_ARRAY - 1) / N_COLS_ARRAY ; i = i + 1)begin
                bram_wr_en_a_o [i] <= bram_wr_en_a [i];
            end   
        end
    end
    //Register for number_of_columns_o
    
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
    
    //Register for sel_mux_tr_o

    always @ (posedge clk_i or posedge sel_mux_tr_rst) begin 
        
        if (sel_mux_tr_rst) begin 
            for(i = 0; i < N_ROWS_ARRAY; i = i + 1)begin
                pre_sel_mux_tr[i] <= 0;
            end     
        end else if (sel_mux_tr_ld) begin
            for(i = 0; i < N_ROWS_ARRAY; i = i + 1)begin
                pre_sel_mux_tr[i] <= sel_mux_tr[i];
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
                sel_mux_tr_o[i] <= pre_sel_mux_tr[i];
            end  
        end
    end
    //Register for en_adder_node_o
    
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
/*
    //Register for filter_size
    always @ (posedge clk_i or posedge filter_size_rst) begin 
        
        if (filter_size_rst) begin
       
            filter_size <= {$clog2(N+1){1'b0}};
                   
        end else if (filter_size_ld) begin
            
            filter_size <= filter_size_i;
           
        end
    end
    //Register for number_input_a_round
    always @ (posedge clk_i or posedge number_input_a_round_rst) begin 
        
        if (number_input_a_round_rst) begin
       
            number_input_a_round <= {(INPUT_A_ROUND_WIDTH){1'b0}};
                   
        end else if (number_input_a_round_ld) begin
            
            number_input_a_round <= num_input_a_round_i;
           
        end
    end
    //Register for iteration_num_inputs
    always @ (posedge clk_i or posedge iteration_num_inputs_rst) begin 
        
        if (iteration_num_inputs_rst) begin
       
            iteration_num_inputs <= {$clog2(MAX_ITERATION_INPUT_ADDRESS_FOR_A_LAYER){1'b0}};
                   
        end else if (iteration_num_inputs_ld) begin
            
            iteration_num_inputs <= iteration_num_inputs_i;
           
        end
    end
    
    //Register for iteration_num_filters
    always @ (posedge clk_i or posedge iteration_num_filters_rst) begin 
        
        if (iteration_num_filters_rst) begin
       
            iteration_num_filters <= {$clog2(MAX_ITERATION_FILTER_NUM){1'b0}};
                   
        end else if (iteration_num_filters_ld) begin
            
            iteration_num_filters <= iteration_num_filters_i;
           
        end
    end
    //Register for num_filters_a_round
    always @ (posedge clk_i or posedge num_filters_a_round_rst) begin 
        
        if (num_filters_a_round_rst) begin
       
            num_filters_a_round <= {$clog2(NUMBER_SUPPORTED_FILTERS){1'b0}};
                   
        end else if (num_filters_a_round_ld) begin
            
            num_filters_a_round <= num_filters_a_round_i;
           
        end
    end

    //Register for total_num_channels
    always @ (posedge clk_i or posedge total_num_channels_rst) begin 
        
        if (total_num_channels_rst) begin
       
            total_num_channels <= {$clog2(MAX_TOTAL_CHANNEL_NUM){1'b0}};
                   
        end else if (total_num_channels_ld) begin
            
            total_num_channels <= total_num_channels_i;
           
        end
    end 
    */
    
    //Register and adder to track the number of processed channels 

    always @(posedge clk_i or posedge num_channel_rst) begin
        if (num_channel_rst) begin
            num_channel <= {$clog2(MAX_TOTAL_CHANNEL_NUM){1'b0}}; // Reset num_channel
            increment_done_ch <= 0; // Reset the increment_done_ch flag
            input_round_number <= 0;
        end else if (p_state == next_channels && !increment_done_ch) begin
        
            num_channel <= num_channel + N_ROWS_ARRAY/filter_size; 
            input_round_number <= input_round_number + 1; 
            // Set the flag to indicate the increment is done
            increment_done_ch <= 1;
        end else if (p_state != next_channels) begin
            // Reset the flag when leaving the waiting
            increment_done_ch <= 0;
        end
    end
    //Register and adder to track count_round_input 
    
    always @(posedge clk_i or posedge count_round_input_rst) begin
        if (count_round_input_rst) begin
            count_round_input <= {$clog2(MAX_ITERATION_INPUT_ADDRESS_FOR_A_LAYER){1'b0}}; // Reset count_round_input
            increment_done_round_input <= 0; // Reset the increment_done_round_input flag
        end else if (p_state == next_input && !increment_done_ch) begin
        
            count_round_input <= count_round_input + 1; 
            // Set the flag to indicate the increment is done
            increment_done_round_input <= 1;
        end else if (p_state != next_input) begin
            // Reset the flag when leaving the store
            increment_done_round_input <= 0;
        end
    end
    //Register and adder to track count_round_filter 

    always @(posedge clk_i or posedge count_round_filter_rst) begin
        if (count_round_filter_rst) begin
            count_round_filter <= {$clog2(MAX_ITERATION_FILTER_NUM){1'b0}}; // Reset count_round_filter
            increment_done_round_filter <= 0; // Reset the increment_done_round_filter flag
        end else if (p_state == next_filters && !increment_done_ch) begin
        
            count_round_filter <= count_round_filter + 1; 
            // Set the flag to indicate the increment is done
            increment_done_round_filter <= 1;
        end else if (p_state != next_filters) begin
            // Reset the flag when leaving the store
            increment_done_round_filter <= 0;
        end
    end
    //counter for loading signals and weights
      
    counter
    #(
        .COUNTER_WIDTH(LOAD_COUNTER_WIDTH)    
    )
    load_counter
    (
        .clk_i(clk_i),
        .counter_rst_i(counter_load_rst),
        .counter_ld_i(counter_load_ld),
        .count_num_o(load_count_num)
    );
     /*
    //counter for counting the number of rounds required by weights

    always @(*) begin
        if (load_count_num == N_COLS_ARRAY-1) round_weight_ld = 1;
        else round_weight_ld = 0;
    end 
   
    always @(*) begin
        if (round_num_weight == max_round_weight_i) end_weight = 1;
        else end_weight = 0;
    end 
    
    assign addrs_rom_signal_o = round_num_weight * N_COLS_ARRAY + load_count_num;
    */
    /*
    counter
    #(
        .COUNTER_WIDTH(COUNTER_ROUND_WIDTH)    
    )
    rounds_weights_counter
    (
        .clk_i(clk_i),
        .counter_rst_i(counter_address_rom_rst),
        .counter_ld_i(round_weight_ld),
        .count_num_o(round_num_weight)
    );
    */
         //counter for addrs_rom_signal_o.

      
    counter
    #(
        .COUNTER_WIDTH(SIG_ADDRS_WIDTH)    
    )
    addrs_rom_signal
    (
        .clk_i(clk_i),
        .counter_rst_i(addrs_rom_signal_rst),
        .counter_ld_i(addrs_rom_signal_ld),
        .count_num_o(addrs_rom_signal_o)
    );
     
    
    //counter for waiting required time for finishing operational stage after finishing input features.
     
    counter
    #(
        .COUNTER_WIDTH(WAITING_OP_COUNTER_WIDTH)    
    )
    waiting_op_counter
    (
        .clk_i(clk_i),
        .counter_rst_i(counter_waiting_op_rst),
        .counter_ld_i(counter_waiting_op_ld),
        .count_num_o(waiting_op_count_num)
    );
    //counter for waiting required time in start state for the first partial sum to be reached to the bottom of the PE array.

    counter
    #(
        .COUNTER_WIDTH(WAITING_OP_COUNTER_WIDTH)    
    )
    start_wait_counter
    (
        .clk_i(clk_i),
        .counter_rst_i(start_wait_rst),
        .counter_ld_i(start_wait_ld && (start_wait_count_num < 2 * (filter_size - 1) + 6 + max_input_round_number)),
        .count_num_o(start_wait_count_num)
    );
    //counter for ready state.
     
    counter
    #(
        .COUNTER_WIDTH(WAITING_OP_COUNTER_WIDTH)    
    )
    ready_counter
    (
        .clk_i(clk_i),
        .counter_rst_i(counter_ready_rst),
        .counter_ld_i(counter_ready_ld),
        .count_num_o(ready_count_num)
    );
    
     //counter for in_feature_address.

      
/*    counter
    #(
        .COUNTER_WIDTH(INPUT_FEATURE_ADDR_WIDTH)    
    )
    in_feature_address
    (
        .clk_i(clk_i),
        .counter_rst_i(in_feature_address_rst),
        .counter_ld_i(in_feature_address_ld),
        .count_num_o(in_feature_addr_o)
    );*/
    assign in_feature_addr_o = count_input_a_round + input_round_number * number_input_a_round + count_round_input *  max_input_round_number * number_input_a_round;
     //counter for count_input_a_round.
    counter
    #(
        .COUNTER_WIDTH(INPUT_A_ROUND_WIDTH)    
    )
    count_input
    (
        .clk_i(clk_i),
        .counter_rst_i(count_input_a_round_rst),
        .counter_ld_i(count_input_a_round_ld),
        .count_num_o(count_input_a_round)
    );    
    

    
    
      //counter for bram_addr_write_read.
    counter
    #(
        .COUNTER_WIDTH(BRAM_ADDR_WIDTH)    
    )
    bram_address
    (
        .clk_i(clk_i),
        .counter_rst_i(bram_addr_write_read_rst),
        .counter_ld_i(bram_addr_write_read_ld && (start_wait_count_num >= 2 * (filter_size - 1) + 6 + max_input_round_number)),
        .count_num_o(bram_addr_read_write_o)
    );
    assign bram_addr_write_read_o = bram_addr_read_write_o - 1; 
    assign bram_addr_max_o = bram_addr_read_write_o;
endmodule

