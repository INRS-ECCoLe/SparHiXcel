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
localparam N_ROWS_ARRAY = 4;
localparam N_COLS_ARRAY = 4;
localparam I_WIDTH = 8;
localparam F_WIDTH = 8;
localparam N = 3;
localparam LEN_TRANSFER = 4;
localparam MAX_LEN_TRANSFER = 4;
localparam SEL_MUX_TR_WIDTH = $clog2(MAX_LEN_TRANSFER);
        
localparam ADDRS_WIDTH = $clog2(N);
localparam SEL_WIDTH = $clog2(N);
localparam NUM_COL_WIDTH = $clog2(N+1);

localparam ROM_SIG_WIDTH = 63;
localparam SIG_ADDRS_WIDTH = 10;   
        
localparam LOAD_COUNTER_WIDTH = 4;
localparam READY_COUNTER_WIDTH = 2;
localparam WAITING_OP_COUNTER_WIDTH = 4;
localparam COUNTER_ROUND_WIDTH = 3;
localparam INPUT_FEATURE_ADDR_WIDTH = 5;
    

module sparhixcel_design
    #(
    
    )
    (
        
        input [$clog2(N+1)-1 : 0]filter_size_i,
        ionput [COUNTER_ROUND_WIDTH : 0] n_round_weight_i,
        input clk_i,
        input general_rst_i,
        input end_feature_i,
        input end_weight_i,
        output signed [F_WIDTH + I_WIDTH - 1 : 0] result_o [0 : N_COLS_ARRAY - 1]
    );
    
    wire rst;
    wire load;
    wire ready;
    wire start_op;
    wire rd_weight_ld;
    wire rd_weight_rst;
    wire rd_feature_ld;
    wire rd_rom_signals_ld;
    wire [SIG_ADDRS_WIDTH - 1 : 0]addrs_rom_signal;
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
    wire [INPUT_FEATURE_ADDR_WIDTH - 1 : 0] in_feature_addr;
    reg signed [F_WIDTH - 1: 0] f_weight_array_reg [0 : N_ROWS_ARRAY - 1];
    
    genvar i;
    generate 
        for (i = 0 ; i < N_ROWS_ARRAY ; i = i + 1) begin
            assign in_feature_array[i] = in_feature_mem [(i + 1)* I_WIDTH - 1 : i * I_WIDTH];
        end
    endgenerate 
    
    
    genvar j;
    generate 
        for (j = 0 ; j < N_ROWS_ARRAY ; j = j + 1) begin
            assign f_weight_array[i] = f_weight_mem [(i + 1)* I_WIDTH - 1 : i * I_WIDTH];
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
        .SIG_ADDRS_WIDTH(SIG_ADDRS_WIDTH),
        .LOAD_COUNTER_WIDTH(LOAD_COUNTER_WIDTH),
        .READY_COUNTER_WIDTH(READY_COUNTER_WIDTH),
        .WAITING_OP_COUNTER_WIDTH(WAITING_OP_COUNTER_WIDTH),
        .COUNTER_ROUND_WIDTH(COUNTER_ROUND_WIDTH),
        .INPUT_FEATURE_ADDR_WIDTH(INPUT_FEATURE_ADDR_WIDTH)
    )
    control_block
    (
        .rom_signals_data_i(rom_signals_data),
        .filter_size_i(filter_size_i),
        .clk_i(clk_i),
        .general_rst_i(general_rst_i),
        .end_feature_i(),
        .max_round_weight_i(),
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
        .f_sel_o(f_sel),
        .row_num_o(row_num),
        .column_num_o(column_num),
        .number_of_columns_o(number_of_columns),
        .sel_mux_tr_o(sel_mux_tr),
        .en_adder_node_o(en_adder_node),
        .sel_mux_node_o(sel_mux_node)
    );
    
    
    
    rom_signals
    #(
        .MEMORY_WIDTH(ROM_SIG_WIDTH),
        .ADDRS_WIDTH(SIG_ADDRS_WIDTH)
    )
    signal_mem
    (
        .addrs_rom_signal_i(addrs_rom_signal),
        .rd_rom_signals_ld_i(rd_rom_signals_ld),
        .rom_signals_data_o(rom_signals_data)
    );
      
      
    rom_memory
    #(
        .MEMORY_WIDTH(ROM_SIG_WIDTH),
        .ADDRS_WIDTH(SIG_ADDRS_WIDTH)
    )
    in_feature_memory
    (
        .addrs_mem_i(in_feature_addr),
        .rd_mem_ld_i(rd_feature_ld),
        .mem_data_o(in_feature_mem)
    );    
    
    
    
    
    
    
    
    
endmodule
