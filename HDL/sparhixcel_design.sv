`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/14/2024 05:27:27 PM
// Design Name: 
// Module Name: sparhixcel_design
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
localparam N_ROWS_ARRAY = 16;
localparam N_COLS_ARRAY = 16;
localparam I_WIDTH = 8;
localparam F_WIDTH = 8;
localparam N = 3;
localparam LEN_TRANSFER = 15;
localparam MAX_LEN_TRANSFER = 15;
localparam SEL_MUX_TR_WIDTH = $clog2(MAX_LEN_TRANSFER);

localparam INPUT_A_ROUND_WIDTH = 5;
localparam MAX_ITERATION_INPUT_ADDRESS_FOR_A_LAYER = 10;
localparam MAX_TOTAL_CHANNEL_NUM = 50;
localparam MAX_ITERATION_FILTER_NUM = 10;
localparam NUMBER_SUPPORTED_FILTERS = 30;
localparam NUMBER_MUX_OUT_1 = 4;
localparam NUMBER_INPUT_MUX_OUT_1 = (N_COLS_ARRAY + NUMBER_MUX_OUT_1 -1)/NUMBER_MUX_OUT_1; 
localparam SEL_WIDTH_MUX_OUT_1 = $clog2(NUMBER_INPUT_MUX_OUT_1);    
localparam SEL_WIDTH_MUX_OUT_2 = $clog2(NUMBER_MUX_OUT_1);
localparam BRAM_ADDR_WIDTH = 11;   
localparam DATA_IN_DRAM_WIDTH = 32;
localparam DRAM_ADDR_WIDTH = 18;
        
localparam ADDRS_WIDTH = $clog2(N);
localparam SEL_WIDTH = $clog2(N);
localparam NUM_COL_WIDTH = $clog2(N+1);

localparam ROM_SIG_WIDTH = (SEL_WIDTH + NUM_COL_WIDTH + SEL_MUX_TR_WIDTH + 1)*N_ROWS_ARRAY + ((NUMBER_SUPPORTED_FILTERS + N_COLS_ARRAY - 1) / N_COLS_ARRAY)*(SEL_WIDTH_MUX_OUT_1 + SEL_WIDTH_MUX_OUT_2 + 1) ;
localparam SIG_ADDRS_WIDTH = 16;   
        
localparam LOAD_COUNTER_WIDTH = 5;
localparam READY_COUNTER_WIDTH = 4;
localparam WAITING_OP_COUNTER_WIDTH = 4;
//localparam COUNTER_ROUND_WIDTH = 3;
localparam INPUT_FEATURE_ADDR_WIDTH = 16;
localparam PARAMETERS_WIDTH = $clog2(N+1) + $clog2(MAX_ITERATION_FILTER_NUM) + $clog2(NUMBER_SUPPORTED_FILTERS) +$clog2(MAX_TOTAL_CHANNEL_NUM) + $clog2(MAX_ITERATION_INPUT_ADDRESS_FOR_A_LAYER)+ (INPUT_FEATURE_ADDR_WIDTH)+ 6*DRAM_ADDR_WIDTH;
localparam MAX_LOAD_TIME_MEM_WIDTH = 4; //how many cycles needed to load one row of input, weight, signal and parameter memories 

module sparhixcel_design
    #(
    
    )
    (
        //input [$clog2(N_COLS_ARRAY) - 1 : 0 ] select_output_i,
//        input [$clog2(N+1)-1 : 0]filter_size_i,
        //input [COUNTER_ROUND_WIDTH - 1: 0] n_round_weight_i,
        //input [$clog2(INPUT_FEATURE_ADDR_WIDTH) - 1 : 0] end_addr_in_feature_i,
        input [DATA_IN_DRAM_WIDTH - 1 : 0] mem_data_i,
//        input [INPUT_FEATURE_ADDR_WIDTH - 1 : 0] wr_addrs_mem_i,
        //input wr_mem_ld_i,
        //input [N_ROWS_ARRAY * F_WIDTH - 1 : 0] mem2_data_i,
//        input [(INPUT_FEATURE_ADDR_WIDTH) - 1 : 0] wr_addrs_mem2_i,
        //input wr_mem2_ld_i,
//        input [(SIG_ADDRS_WIDTH) - 1 : 0] wr_addrs_rom_signal_i,
        //input wr_rom_signals_ld_i,
        //input [ROM_SIG_WIDTH - 1 : 0] rom_signals_data_i,
        input clk_i,
        input general_rst_i,
//        input [$clog2(NUMBER_SUPPORTED_FILTERS) - 1 : 0] sel_mux_final,
//        input bram_wr_en_b_i [0 : ((NUMBER_SUPPORTED_FILTERS + N_COLS_ARRAY - 1) / N_COLS_ARRAY)  - 1],
//        input [SEL_WIDTH_MUX_OUT_1 - 1 : 0] sel_mux_out_1_i,
//        input [SEL_WIDTH_MUX_OUT_2 - 1 : 0] sel_mux_out_2_i,
//        input mux_out_reg_rst,
//        input mux_out_reg_wr_en,
//        input sel_mux_out_rst,
//        input sel_mux_out_ld,
//        input bram_rst,
        //input bram_wr_en_a,
        //input bram_wr_en_b,
        //input [BRAM_ADDR_WIDTH - 1 : 0] bram_addr_write_read,
        //input [BRAM_ADDR_WIDTH - 1 : 0] bram_addr_read_write,
//        input [$clog2(MAX_ITERATION_FILTER_NUM) - 1 : 0] iteration_num_filters_i,
//        input [$clog2(NUMBER_SUPPORTED_FILTERS) - 1 : 0] num_filters_a_round_i,
//        input [$clog2(MAX_TOTAL_CHANNEL_NUM) - 1 : 0] total_num_channels_i,
//        input [$clog2(MAX_ITERATION_INPUT_ADDRESS_FOR_A_LAYER) - 1 : 0] iteration_num_inputs_i,
//        input [(INPUT_FEATURE_ADDR_WIDTH) - 1 : 0] num_input_a_round_i,

        
        
        output reg signed [F_WIDTH + I_WIDTH - 1 : 0] final_output_o,
        output [DRAM_ADDR_WIDTH - 1 : 0] dram_rd_address_o
    );
    
    wire rst;
    wire load;
    wire ready;
    wire start_op;
    wire rd_weight_ld;
    wire rd_weight_rst;
    wire rd_feature_ld;
    wire rd_rom_signals_ld;
    wire [(SIG_ADDRS_WIDTH) - 1 : 0]addrs_rom_signal;
    wire [ROM_SIG_WIDTH - 1 : 0] rom_signals_data;
    wire [SEL_WIDTH - 1: 0] f_sel [0 : N_ROWS_ARRAY - 1];
    wire [NUM_COL_WIDTH -1 : 0]row_num [0 : N_ROWS_ARRAY - 1];
    wire [NUM_COL_WIDTH - 1 : 0] column_num [0 : N_ROWS_ARRAY - 1];
    wire [NUM_COL_WIDTH - 1 : 0] number_of_columns[0 : N_ROWS_ARRAY - 1];
    wire [SEL_MUX_TR_WIDTH - 1 : 0] sel_mux_tr [0 : N_ROWS_ARRAY - 1];
    wire en_adder_node [0 : N_ROWS_ARRAY - 1];
    wire sel_mux_node [0 : N_ROWS_ARRAY - 1];
    wire [I_WIDTH * N_ROWS_ARRAY - 1: 0] in_feature_mem;
    wire signed [I_WIDTH - 1: 0] in_feature_array [0 : N_ROWS_ARRAY - 1];
    wire [F_WIDTH * N_ROWS_ARRAY - 1: 0] f_weight_mem;
    wire signed [F_WIDTH - 1: 0] f_weight_array [0 : N_ROWS_ARRAY - 1];
    wire [(INPUT_FEATURE_ADDR_WIDTH) - 1 : 0] in_feature_addr;
    reg signed [F_WIDTH - 1: 0] f_weight_array_reg [0 : N_ROWS_ARRAY - 1];
    //reg end_feature;
    wire [SEL_WIDTH_MUX_OUT_1 - 1 : 0] sel_mux_out_1 [0 : (NUMBER_SUPPORTED_FILTERS + N_COLS_ARRAY - 1) / N_COLS_ARRAY - 1][0 : N_COLS_ARRAY];
    wire [SEL_WIDTH_MUX_OUT_1 - 1 : 0] sel_mux_out_1_first [0 : (NUMBER_SUPPORTED_FILTERS + N_COLS_ARRAY - 1) / N_COLS_ARRAY - 1];
//    assign sel_mux_out_1[0][0]= sel_mux_out_1_i;
//    assign sel_mux_out_2[0][0]= sel_mux_out_2_i;
//    assign sel_mux_out_1[1][0]= sel_mux_out_1_i;
//    assign sel_mux_out_2[1][0]= sel_mux_out_2_i;
    wire [SEL_WIDTH_MUX_OUT_2 - 1 : 0] sel_mux_out_2 [0 : (NUMBER_SUPPORTED_FILTERS + N_COLS_ARRAY - 1) / N_COLS_ARRAY  - 1][0 : N_COLS_ARRAY];
    wire [SEL_WIDTH_MUX_OUT_2 - 1 : 0] sel_mux_out_2_first [0 : (NUMBER_SUPPORTED_FILTERS + N_COLS_ARRAY - 1) / N_COLS_ARRAY  - 1];
    wire mux_out_reg_rst;
    wire mux_out_reg_wr_en;
    wire sel_mux_out_rst;
    wire sel_mux_out_ld;
    wire bram_rst;
    wire bram_wr_en_a[0 : ((NUMBER_SUPPORTED_FILTERS + N_COLS_ARRAY - 1) / N_COLS_ARRAY)  - 1][0 : N_COLS_ARRAY];
    wire bram_wr_en_a_first[0 : ((NUMBER_SUPPORTED_FILTERS + N_COLS_ARRAY - 1) / N_COLS_ARRAY)  - 1];
    wire bram_wr_en_b [0 : ((NUMBER_SUPPORTED_FILTERS + N_COLS_ARRAY - 1) / N_COLS_ARRAY)  - 1][0 : N_COLS_ARRAY - 1];
    wire bram_wr_en_a_rst;
    wire bram_wr_en_a_ld; 
    wire bram_wr_en_b_rst;
    wire bram_wr_en_b_ld;
    //wire bram_wr_en_b;
    wire [BRAM_ADDR_WIDTH - 1 : 0] bram_addr_write_computation;
    wire [BRAM_ADDR_WIDTH - 1 : 0] bram_addr_read_computation;
    wire [BRAM_ADDR_WIDTH - 1 : 0] bram_addr_1;
    wire [BRAM_ADDR_WIDTH - 1 : 0] bram_addr_2;
    wire [BRAM_ADDR_WIDTH - 1 : 0] bram_addr_max;
    wire signed [F_WIDTH + I_WIDTH - 1 : 0] result_o [0 : N_COLS_ARRAY - 1];
    wire signed [F_WIDTH + I_WIDTH - 1 : 0] out_filter [0 : NUMBER_SUPPORTED_FILTERS - 1];
    wire [$clog2(NUMBER_SUPPORTED_FILTERS) - 1 : 0] sel_mux_final;
    
    wire [DRAM_ADDR_WIDTH - 1 : 0] input_start_addr_dram;
    wire [DRAM_ADDR_WIDTH - 1 : 0] input_finish_addr_dram;
    wire [DRAM_ADDR_WIDTH - 1 : 0] weight_start_addr_dram;
    wire [DRAM_ADDR_WIDTH - 1 : 0] weight_finish_addr_dram;
    wire [DRAM_ADDR_WIDTH - 1 : 0] signal_start_addr_dram;
    wire [DRAM_ADDR_WIDTH - 1 : 0] signal_finish_addr_dram;
    
    wire [N_ROWS_ARRAY * I_WIDTH - 1 : 0] mem_data_input;
    wire [N_ROWS_ARRAY * F_WIDTH - 1 : 0] mem_data_weight;
    wire [ROM_SIG_WIDTH - 1 : 0] mem_data_signal;
    wire wr_rom_signals_ld;
    wire wr_mem_ld;
    wire wr_mem2_ld;
    wire wr_parameters_ld;
    reg [PARAMETERS_WIDTH -1 : 0] data_parameters;
    wire [3:0]sa_state;
    wire input_ready; //from DRAM
    wire weight_ready;
    wire [2:0] dram_access_state;
    wire [SIG_ADDRS_WIDTH - 1 : 0] signal_wr_address;
    wire [SIG_ADDRS_WIDTH - 1 : 0] weight_wr_address;
    wire [INPUT_FEATURE_ADDR_WIDTH - 1 : 0] input_wr_address;
    wire order_empty_bram;
    wire bram_ready;
//    wire bram_wr_en_b [0 : ((NUMBER_SUPPORTED_FILTERS + N_COLS_ARRAY - 1) / N_COLS_ARRAY)  - 1];
    
    genvar t;
    generate 
        for (t = 0 ; t < ((NUMBER_SUPPORTED_FILTERS + N_COLS_ARRAY - 1) / N_COLS_ARRAY) ; t = t + 1) begin
            assign bram_wr_en_a[t][0] = bram_wr_en_a_first[t];
//            assign bram_wr_en_b[t][0] = bram_wr_en_b_i[t];
            assign sel_mux_out_1[t][0] = sel_mux_out_1_first [t];
            assign sel_mux_out_2[t][0] = sel_mux_out_2_first [t];    
        end
    endgenerate
    genvar i;
    generate 
        for (i = 0 ; i < N_ROWS_ARRAY ; i = i + 1) begin
            assign in_feature_array[i] = in_feature_mem [(i + 1)* I_WIDTH - 1 : i * I_WIDTH];
        end
    endgenerate 
    
    
    genvar j;
    generate 
        for (j = 0 ; j < N_ROWS_ARRAY ; j = j + 1) begin
            assign f_weight_array[j] = f_weight_mem [(j + 1)* F_WIDTH - 1 : j * F_WIDTH];
        end
    endgenerate
       
    //Register for f_sel_o
    integer a;
    always @ (posedge clk_i or posedge rd_weight_rst) begin 
        
        if (rd_weight_rst) begin
            for(a = 0; a < N_ROWS_ARRAY; a = a + 1)begin
                f_weight_array_reg[a] <= 0;
            end    
        end else if (rd_weight_ld) begin
            for(a = 0; a < N_ROWS_ARRAY; a = a + 1)begin
                f_weight_array_reg[a] <= f_weight_array[a];
            end   
        end
    end
    

    
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
    array_block
    (
        .in_feature_i(in_feature_array),
        .f_sel_i(f_sel), 
        .row_num_i(row_num),
        .rst_i(rst),
        .load_i(load),
        .ready_i(ready),
        .start_op_i(start_op),
        .clk_i(clk_i),
        .filter_size_i(filter_size_i),
        .f_weight_i(f_weight_array_reg),
        .column_num_i(column_num),
        .sel_mux_tr_i(sel_mux_tr),
        .number_of_columns_i(number_of_columns),
        .en_adder_node_i(en_adder_node),
        .sel_mux_node_i(sel_mux_node),
    
        .result_o(result_o)
    );
    
    
    
    
    SA_controller
    #(
        .N_ROWS_ARRAY(N_ROWS_ARRAY),
        .N_COLS_ARRAY(N_COLS_ARRAY),
        .N(N),
        .MAX_LEN_TRANSFER(MAX_LEN_TRANSFER),
        .SEL_MUX_TR_WIDTH(SEL_MUX_TR_WIDTH),
        .SEL_WIDTH(SEL_WIDTH),
        .NUM_COL_WIDTH(NUM_COL_WIDTH),
        .ROM_SIG_WIDTH(ROM_SIG_WIDTH),
        .SIG_ADDRS_WIDTH((SIG_ADDRS_WIDTH)),
        .LOAD_COUNTER_WIDTH(LOAD_COUNTER_WIDTH),
        .READY_COUNTER_WIDTH(READY_COUNTER_WIDTH),
        .WAITING_OP_COUNTER_WIDTH(WAITING_OP_COUNTER_WIDTH),
        //.COUNTER_ROUND_WIDTH(COUNTER_ROUND_WIDTH),
        .INPUT_FEATURE_ADDR_WIDTH((INPUT_FEATURE_ADDR_WIDTH)),
        .MAX_ITERATION_FILTER_NUM(MAX_ITERATION_FILTER_NUM),
        .NUMBER_SUPPORTED_FILTERS(NUMBER_SUPPORTED_FILTERS),
        .MAX_TOTAL_CHANNEL_NUM(MAX_TOTAL_CHANNEL_NUM),
        .MAX_ITERATION_INPUT_ADDRESS_FOR_A_LAYER(MAX_ITERATION_INPUT_ADDRESS_FOR_A_LAYER),
        .BRAM_ADDR_WIDTH(BRAM_ADDR_WIDTH),
        .SEL_WIDTH_MUX_OUT_1(SEL_WIDTH_MUX_OUT_1),
        .SEL_WIDTH_MUX_OUT_2(SEL_WIDTH_MUX_OUT_2),
        .DRAM_ADDR_WIDTH(DRAM_ADDR_WIDTH),
        .PARAMETERS_WIDTH(PARAMETERS_WIDTH)
    )
    control_block
    (
        .rom_signals_data_i(rom_signals_data),
        .parameters_data_i(data_parameters),
//        .wr_parameters_ld_i(wr_parameters_ld),
//        .filter_size_i(filter_size_i),
        .clk_i(clk_i),
        .general_rst_i(general_rst_i),
//        .iteration_num_filters_i(iteration_num_filters_i),
//        .num_filters_a_round_i(num_filters_a_round_i),
//        .total_num_channels_i(total_num_channels_i),
//        .iteration_num_inputs_i(iteration_num_inputs_i),
//        .num_input_a_round_i(num_input_a_round_i),
        .input_ready_i(input_ready),
        .weight_ready_i(weight_ready),
        .bram_ready_i(bram_ready),
       
        //.end_feature_i(end_feature),
        //.max_round_weight_i(n_round_weight_i),
        //.end_weight_i(),
        
        .in_feature_addr_o(in_feature_addr),
        .rst_o(rst),
        .load_o(load),
        .ready_o(ready),
        .start_op_o(start_op),
        .rd_weight_ld_o(rd_weight_ld),
        .rd_weight_rst_o(rd_weight_rst),
        .rd_feature_ld_o(rd_feature_ld),
        .rd_rom_signals_ld_o(rd_rom_signals_ld),
        .addrs_rom_signal_o(addrs_rom_signal),
        .bram_addr_write_read_o(bram_addr_write_computation),
        .bram_addr_read_write_o(bram_addr_read_computation),
        .bram_addr_max_o(bram_addr_max),
        .f_sel_o(f_sel),
        .row_num_o(row_num),
        .column_num_o(column_num),
        .number_of_columns_o(number_of_columns),
        .sel_mux_tr_o(sel_mux_tr),
        .sel_mux_out_1_o(sel_mux_out_1_first),
        .sel_mux_out_2_o(sel_mux_out_2_first),
        .bram_wr_en_a_o(bram_wr_en_a_first),
        .en_adder_node_o(en_adder_node),
        .sel_mux_node_o(sel_mux_node),
        .bram_rst_o(bram_rst),
        .sel_mux_out_ld_o(sel_mux_out_ld),
        .sel_mux_out_rst_o(sel_mux_out_rst),
        .mux_out_reg_wr_en_o(mux_out_reg_wr_en),
        .mux_out_reg_rst_o(mux_out_reg_rst),
        .bram_wr_en_a_rst_o(bram_wr_en_a_rst),
        .bram_wr_en_a_ld_o(bram_wr_en_a_ld), 
//        .bram_wr_en_b_rst_o(bram_wr_en_b_rst),
//        .bram_wr_en_b_ld_o(bram_wr_en_b_ld),
        .input_start_addr_dram_o(input_start_addr_dram),
        .input_finish_addr_dram_o(input_finish_addr_dram),
        .weight_start_addr_dram_o(weight_start_addr_dram),
        .weight_finish_addr_dram_o(weight_finish_addr_dram),
        .signal_start_addr_dram_o(signal_start_addr_dram),
        .signal_finish_addr_dram_o(signal_finish_addr_dram), 
        .sa_state_o(sa_state),
        .order_empty_bram_o(order_empty_bram)
    );
    
    DRAM_ACCESS_CTRL
    #(
        .DRAM_ADDR_WIDTH(DRAM_ADDR_WIDTH),
        .SIG_ADDRS_WIDTH(SIG_ADDRS_WIDTH),
        .INPUT_FEATURE_ADDR_WIDTH(INPUT_FEATURE_ADDR_WIDTH),
        .MAX_LOAD_TIME_MEM_WIDTH(MAX_LOAD_TIME_MEM_WIDTH),
        .DATA_IN_DRAM_WIDTH(DATA_IN_DRAM_WIDTH),
        .PARAMETERS_WIDTH(PARAMETERS_WIDTH),
        .ROM_SIG_WIDTH(ROM_SIG_WIDTH),
        .N_ROWS_ARRAY(N_ROWS_ARRAY),
        .I_WIDTH(I_WIDTH),
        .F_WIDTH(F_WIDTH)
    )
    dram_access_controller
    (
        .clk_i(clk_i),
        .general_rst_i(general_rst_i),
        .sa_state_i(sa_state),
        .input_start_addr_dram_i(input_start_addr_dram),
        .input_finish_addr_dram_i(input_finish_addr_dram),
        .weight_start_addr_dram_i(weight_start_addr_dram),
        .weight_finish_addr_dram_i(weight_finish_addr_dram),
        .signal_start_addr_dram_i(signal_start_addr_dram),
        .signal_finish_addr_dram_i(signal_finish_addr_dram),
        .input_ready_o(input_ready),
        .weight_ready_o(weight_ready),
        .input_wr_address_o(input_wr_address),
        .weight_wr_address_o(weight_wr_address),
        .signal_wr_address_o(signal_wr_address),
        .dram_rd_address_o(dram_rd_address_o),
        .dram_access_state_o(dram_access_state)
    );
    
    
    dram_to_memory
    #(
        .DATA_IN_BITWIDTH(DATA_IN_DRAM_WIDTH),
        .DATA_OUT_BITWIDTH(ROM_SIG_WIDTH)

    )
    dram_to_mem_signal
    (
        .clk_i(clk_i),                   
        .dram_to_mem_rst_i(general_rst_i),                   
        .data_in_i(mem_data_i),         
        .data_valid_i(dram_access_state == 3'b011),            
        .data_out_o(mem_data_signal), 
        .memory_write_enable(wr_rom_signals_ld) 
    );
    
    
    
    
    simple_dual_port_ram 
    #(
        .MEMORY_WIDTH(ROM_SIG_WIDTH),
        .ADDRS_WIDTH(SIG_ADDRS_WIDTH)
    )
    signal_mem
    (
        .clk_i(clk_i),
        .ena_i(1),
        .enb_i(rd_rom_signals_ld),
        .wea_i(wr_rom_signals_ld),
        .addra_i(signal_wr_address),
        .addrb_i(addrs_rom_signal),
        .dia_i(mem_data_signal),
        .dob_o(rom_signals_data)
    );
     
     
    dram_to_memory
    #(
        .DATA_IN_BITWIDTH(DATA_IN_DRAM_WIDTH),
        .DATA_OUT_BITWIDTH(N_ROWS_ARRAY * I_WIDTH)

    )
    dram_to_mem_input
    (
        .clk_i(clk_i),                   
        .dram_to_mem_rst_i(general_rst_i),                   
        .data_in_i(mem_data_i),         
        .data_valid_i(dram_access_state == 3'b100),            
        .data_out_o(mem_data_input), 
        .memory_write_enable(wr_mem_ld) 
    ); 
        
    simple_dual_port_ram 
    #(
        .MEMORY_WIDTH(N_ROWS_ARRAY * I_WIDTH),
        .ADDRS_WIDTH(INPUT_FEATURE_ADDR_WIDTH)
    )
    in_feature_memory
    (
        .clk_i(clk_i),
        .ena_i(1),
        .enb_i(rd_feature_ld),
        .wea_i(wr_mem_ld),
        .addra_i(input_wr_address),
        .addrb_i(in_feature_addr),
        .dia_i(mem_data_input),
        .dob_o(in_feature_mem)
    );
    /*
    rom_signals
    #(
        .MEMORY_WIDTH(ROM_SIG_WIDTH),
        .ADDRS_WIDTH(SIG_ADDRS_WIDTH)
    )
    signal_mem
    (
        .addrs_rom_signal_i(addrs_rom_signal),
        .rd_rom_signals_ld_i(rd_rom_signals_ld),
        .wr_addrs_rom_signal_i(wr_addrs_rom_signal_i),
        .clk_i(clk_i),
        .wr_rom_signals_ld_i(wr_rom_signals_ld_i),
        .rom_signals_data_i(rom_signals_data_i),
        .rom_signals_data_o(rom_signals_data)
    );
      
      
    rom_memory
    #(
        .MEMORY_WIDTH(N_ROWS_ARRAY * I_WIDTH),
        .ADDRS_WIDTH(INPUT_FEATURE_ADDR_WIDTH)
    )
    in_feature_memory
    (
        .addrs_mem_i(in_feature_addr),
        .rd_mem_ld_i(rd_feature_ld),
        .mem_data_i(mem_data_i),
        .clk_i(clk_i),
        .wr_addrs_mem_i(wr_addrs_mem_i),
        .wr_mem_ld_i(wr_mem_ld_i),
        .mem_data_o(in_feature_mem)
    );  
    */
      
    /*
    always @(*) begin
        if (end_addr_in_feature_i == in_feature_addr) end_feature = 1'b1;
        else end_feature = 1'b0;
    end
    */
    
    /*
    rom_memory2
    #(
        .MEMORY_WIDTH(N_ROWS_ARRAY * F_WIDTH),
        .ADDRS_WIDTH(INPUT_FEATURE_ADDR_WIDTH)
    )
    weight_memory
    (
        .addrs_mem_i(addrs_rom_signal),
        .rd_mem_ld_i(rd_weight_ld),
        .mem2_data_i(mem2_data_i),
        .clk_i(clk_i),
        .wr_addrs_mem2_i(wr_addrs_mem2_i),
        .wr_mem2_ld_i(wr_mem2_ld_i),
        .mem_data_o(f_weight_mem)
    );    
    
        */
    dram_to_memory
    #(
        .DATA_IN_BITWIDTH(DATA_IN_DRAM_WIDTH),
        .DATA_OUT_BITWIDTH(N_ROWS_ARRAY * F_WIDTH)

    )
    dram_to_mem_weight
    (
        .clk_i(clk_i),                   
        .dram_to_mem_rst_i(general_rst_i),                   
        .data_in_i(mem_data_i),         
        .data_valid_i(dram_access_state == 3'b010),            
        .data_out_o(mem_data_weight), 
        .memory_write_enable(wr_mem2_ld) 
    );
    
    simple_dual_port_ram 
    #(
        .MEMORY_WIDTH(N_ROWS_ARRAY * F_WIDTH),
        .ADDRS_WIDTH(SIG_ADDRS_WIDTH)
    )
    weight_memory
    (
        .clk_i(clk_i),
        .ena_i(1),
        .enb_i(rd_weight_ld),
        .wea_i(wr_mem2_ld),
        .addra_i(weight_wr_address),
        .addrb_i(addrs_rom_signal),
        .dia_i(mem_data_weight),
        .dob_o(f_weight_mem)
    );
    genvar f,col;
    generate
        for(f = 0; f < (NUMBER_SUPPORTED_FILTERS + N_COLS_ARRAY - 1)/ N_COLS_ARRAY ; f = f + 1) begin
            for (col = 0; col < N_COLS_ARRAY ; col = col + 1) begin
                if(f*N_COLS_ARRAY + col < NUMBER_SUPPORTED_FILTERS) begin 
                    output_block
                    #(
                        .N_COLS_ARRAY(N_COLS_ARRAY),
                        .I_WIDTH(I_WIDTH),
                        .F_WIDTH(F_WIDTH),
                        .NUMBER_MUX_OUT_1(NUMBER_MUX_OUT_1),
                        .NUMBER_INPUT_MUX_OUT_1(NUMBER_INPUT_MUX_OUT_1),
                        .SEL_WIDTH_MUX_OUT_1(SEL_WIDTH_MUX_OUT_1), 
                        .SEL_WIDTH_MUX_OUT_2(SEL_WIDTH_MUX_OUT_2),
                        .BRAM_ADDR_WIDTH(BRAM_ADDR_WIDTH)
                    )
                    output_filter_store
                    (
                        .data_in_i(result_o),
                        .clk_i(clk_i),
                        .sel_mux_out_1_i(sel_mux_out_1[f][col]),
                        .sel_mux_out_2_i(sel_mux_out_2[f][col]),
                        .reg_rst_i(mux_out_reg_rst),
                        .reg_wr_en_i(mux_out_reg_wr_en),
                        .sel_mux_rst_i(sel_mux_out_rst),
                        .sel_mux_ld_i(sel_mux_out_ld),
                        .bram_rst_i(bram_rst),
                        .bram_wr_en_a_i(bram_wr_en_a[f][col]),
                        .bram_wr_en_b_i(bram_wr_en_b[f][col]),
                        .bram_addr_write_read_i(bram_addr_1),
                        .bram_addr_read_write_i(bram_addr_2),
                        .bram_wr_en_a_rst_i(bram_wr_en_a_rst),
                        .bram_wr_en_a_ld_i(bram_wr_en_a_ld), 
//                        .bram_wr_en_b_rst_i(bram_wr_en_b_rst),
//                        .bram_wr_en_b_ld_i(bram_wr_en_b_ld), 
    
                        .bram_wr_en_a_o(bram_wr_en_a[f][col+1]),
//                        .bram_wr_en_b_o(bram_wr_en_b[f][col+1]),
                        .sel_mux_out_1_o(sel_mux_out_1[f][col + 1]),
                        .sel_mux_out_2_o(sel_mux_out_2[f][col + 1]),
                        .d_out_o(out_filter[f*N_COLS_ARRAY + col])
                    );
                    
                end
            end                                                                                                                                        
        end
    endgenerate 
    
    output_ctrl
    #(
        .NUMBER_SUPPORTED_FILTERS(NUMBER_SUPPORTED_FILTERS),
        .N_COLS_ARRAY(N_COLS_ARRAY),
        .DRAM_ADDR_WIDTH(DRAM_ADDR_WIDTH),
        .BRAM_ADDR_WIDTH(BRAM_ADDR_WIDTH)
    )
    control_output
    (
        .clk_i(clk_i),
        .general_rst_i(general_rst_i),
        .order_empty_bram_i(order_empty_bram),
        .bram_addr_write_computation_i(bram_addr_write_computation),
        .bram_addr_read_computation_i(bram_addr_read_computation),
        .bram_ready_o(bram_ready),
        .bram_addr_max_i(bram_addr_max),
        .sel_mux_final_o(sel_mux_final),
        .bram_wr_en_b_o(bram_wr_en_b),
        .bram_addr_1_o(bram_addr_1),
        .bram_addr_2_o(bram_addr_2)
        
    );
    
    always @(*) begin
        final_output_o = out_filter[sel_mux_final];  
    end
   
   
    dram_to_memory
    #(
        .DATA_IN_BITWIDTH(DATA_IN_DRAM_WIDTH),
        .DATA_OUT_BITWIDTH(PARAMETERS_WIDTH)

    )
    dram_to_parameters
    (
        .clk_i(clk_i),                   
        .dram_to_mem_rst_i(general_rst_i),                   
        .data_in_i(mem_data_i),         
        .data_valid_i(dram_access_state == 3'b001),            
        .data_out_o(data_parameters), 
        .memory_write_enable(wr_parameters_ld) 
    );
    
    
    
    
endmodule
