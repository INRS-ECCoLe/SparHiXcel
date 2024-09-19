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

module sparhixcel_design
    #(
    
    )
    (
    input [$clog2(N+1)-1 : 0]filter_size_i,
    input clk_i,
    input general_rst_i,
    input end_feature_i,
    input end_weight_i
    );
  
    
    
    systolic_array
    #(
    .N_ROWS_ARRAY(),
    .N_COLS_ARRAY(),
    .I_WIDTH(),
    .F_WIDTH(),
    .N(),
    .LEN_TRANSFER(),
    .MAX_LEN_TRANSFER(),
    .SEL_MUX_TR_WIDTH(),
    .ADDRS_WIDTH(),
    .SEL_WIDTH(),
    .NUM_COL_WIDTH()
    )
    array_block
    (
    .in_feature_i(),
    .f_sel_i(), 
    .row_num_i(),
    .rst_i(),
    .load_i(),
    .ready_i(),
    .start_op_i(),
    .clk_i(),
    .filter_size_i(),
    .f_weight_i(),
    .column_num_i(),
    .sel_mux_tr_i(),
    .number_of_columns_i(),
    .en_adder_node_i(),
    .sel_mux_node_i(),

    .result_o()
    );
    
    
    
    
    SA_controller
    #(
    .N_ROWS_ARRAY(),
    .N_COLS_ARRAY(),
    .N(),
    .MAX_LEN_TRANSFER(),
    .SEL_MUX_TR_WIDTH(),
    .SEL_WIDTH(),
    .NUM_COL_WIDTH(),
    .ROM_SIG_WIDTH(),
    .SIG_ADDRS_WIDTH(),
    .LOAD_COUNTER_WIDTH(),
    .READY_COUNTER_WIDTH(),
    .WAITING_OP_COUNTER_WIDTH(),
    .COUNTER_ROUND_WIDTH(COUNTER_ROUND_WIDTH)
    )
    control_block
    (
    .rom_signals_data_i(),
    .filter_size_i(),
    .clk_i(),
    .general_rst_i(),
    .end_feature_i(),
    //.end_weight_i(),
    .rst_o(),
    .load_o(),
    .ready_o(),
    .start_op_o(),
    .rd_weight_ld_o(),
    .rd_feature_ld_o(),
    .rd_rom_signals_ld_o(),
    .addrs_rom_signal_o(),
    .f_sel_o(),
    .row_num_o(),
    .column_num_o(),
    .number_of_columns_o(),
    .sel_mux_tr_o(),
    .en_adder_node_o(),
    .sel_mux_node_o()
    );
    
    
    
    rom_signals
    #(
    
    )
    signal_mem
    (
    
    );
      
    
    
    
    
    
    
    
    
    
endmodule
