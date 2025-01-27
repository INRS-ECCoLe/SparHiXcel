`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/23/2025 02:38:50 PM
// Design Name: 
// Module Name: DRAM_ACCESS_CTRL
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


module DRAM_ACCESS_CTRL
    #(
        parameter DRAM_ADDR_WIDTH = 18,
        //parameter BRAM_ADDR_WIDTH = 11,
        parameter SIG_ADDRS_WIDTH = 16,
        parameter INPUT_FEATURE_ADDR_WIDTH = 16,
        parameter MAX_LOAD_TIME_MEM_WIDTH = 4,
        
        parameter DATA_IN_DRAM_WIDTH = 32,
        parameter PARAMETERS_WIDTH = 50,
        parameter ROM_SIG_WIDTH = 100,
        parameter N_ROWS_ARRAY = 16, 
        parameter I_WIDTH = 8,  
        parameter F_WIDTH = 8
    )
    (
        input clk_i,
        input general_rst_i,
        input [3:0]sa_state_i,
        input [DRAM_ADDR_WIDTH - 1 : 0] input_start_addr_dram_i,
        input [DRAM_ADDR_WIDTH - 1 : 0] input_finish_addr_dram_i,
        input [DRAM_ADDR_WIDTH - 1 : 0] weight_start_addr_dram_i,
        input [DRAM_ADDR_WIDTH - 1 : 0] weight_finish_addr_dram_i,
        input [DRAM_ADDR_WIDTH - 1 : 0] signal_start_addr_dram_i,
        input [DRAM_ADDR_WIDTH - 1 : 0] signal_finish_addr_dram_i,
        output [INPUT_FEATURE_ADDR_WIDTH - 1 : 0] input_wr_address_o,
        output [SIG_ADDRS_WIDTH - 1 : 0] weight_wr_address_o,
        output [SIG_ADDRS_WIDTH - 1 : 0] signal_wr_address_o,
        output [DRAM_ADDR_WIDTH - 1 : 0] dram_rd_address_o
    );
    localparam delay_input = (DATA_IN_DRAM_WIDTH + I_WIDTH * N_ROWS_ARRAY - 1) / DATA_IN_DRAM_WIDTH;
    localparam delay_signal = (DATA_IN_DRAM_WIDTH + ROM_SIG_WIDTH - 1) / DATA_IN_DRAM_WIDTH;
    localparam delay_weight = (DATA_IN_DRAM_WIDTH + F_WIDTH * N_ROWS_ARRAY - 1) / DATA_IN_DRAM_WIDTH;
    localparam delay_parameter = (DATA_IN_DRAM_WIDTH + PARAMETERS_WIDTH - 1) / DATA_IN_DRAM_WIDTH;
   
    
    reg input_addr_rst;
    reg input_addr_ld;
    reg weight_wr_addr_rst;
    reg weight_wr_addr_ld;
    reg dram_read_addr_rst;
    reg dram_read_addr_ld;
    reg signal_wr_addr_rst;
    reg signal_wr_addr_ld;
    reg load_time_mem_rst;
    reg load_time_mem_ld;
    wire [MAX_LOAD_TIME_MEM_WIDTH - 1 : 0] load_time_memory;
    
    
    localparam [2:0]
        reset = 3'b000 , parameters = 3'b001, weights = 3'b010,
        signals = 3'b011 , inputs = 3'b100 ;
    reg [2:0] p_state, n_state;
    always @(p_state or general_rst_i or sa_state_i) begin: state_transition
        case(p_state)
            reset:
                if (general_rst_i == 0 && sa_state_i == 4'b0000) n_state = parameters;
                else n_state = reset;
            parameters:
                if (load_time_memory == delay_parameter) n_state = weights;
                else n_state = parameters; 
            weights:
                if ((weight_wr_address_o == 2 ** SIG_ADDRS_WIDTH - 1) || (dram_rd_address_o == weight_finish_addr_dram_i)) n_state = signals;
                else n_state = weights;
            signals:
                if ( == 1) n_state = inputs;
                else n_state = signals;
            inputs:
                if (bram_ready_i == 1) n_state = reset;
                else n_state = inputs;    
            default:
                n_state = reset;
        endcase
        
    end
    //counter for weight_wr_address_o.
    counter
    #(
        .COUNTER_WIDTH(SIG_ADDRS_WIDTH)    
    )
    weight_write_address
    (
        .clk_i(clk_i),
        .counter_rst_i(weight_wr_addr_rst),
        .counter_ld_i(weight_wr_addr_ld),
        .count_num_o(weight_wr_address_o)
    );
    
    
    //counter for signal_wr_address_o.
    counter
    #(
        .COUNTER_WIDTH(SIG_ADDRS_WIDTH)    
    )
    signal_write_address
    (
        .clk_i(clk_i),
        .counter_rst_i(signal_wr_addr_rst),
        .counter_ld_i(signal_wr_addr_ld),
        .count_num_o(signal_wr_address_o)
    );
    
    
    //counter for input_wr_address_o.
    counter
    #(
        .COUNTER_WIDTH(INPUT_FEATURE_ADDR_WIDTH)    
    )
    input_write_address
    (
        .clk_i(clk_i),
        .counter_rst_i(input_addr_rst),
        .counter_ld_i(input_addr_ld),
        .count_num_o(input_wr_address_o)
    );
    
    //counter for dram_rd_address_o.
    counter
    #(
        .COUNTER_WIDTH(DRAM_ADDR_WIDTH)    
    )
    dram_read_address
    (
        .clk_i(clk_i),
        .counter_rst_i(dram_read_addr_rst),
        .counter_ld_i(dram_read_addr_ld),
        .count_num_o(dram_rd_address_o)
    );
    
    //counter for load_time_memory.
    counter
    #(
        .COUNTER_WIDTH(MAX_LOAD_TIME_MEM_WIDTH)    
    )
    load_time_mem
    (
        .clk_i(clk_i),
        .counter_rst_i(load_time_mem_rst),
        .counter_ld_i(load_time_mem_ld),
        .count_num_o(load_time_memory)
    );
endmodule
