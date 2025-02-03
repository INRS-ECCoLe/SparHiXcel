`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/28/2025 03:57:30 PM
// Design Name: 
// Module Name: output_ctrl
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


module output_ctrl
    #(
        parameter NUMBER_SUPPORTED_FILTERS = 30,
        parameter N_COLS_ARRAY = 16,
        parameter DRAM_ADDR_WIDTH = 18,
        parameter BRAM_ADDR_WIDTH = 11
    )
    (
        input clk_i,
        input general_rst_i,
//        input [3:0]sa_state_i,
        input order_empty_bram_i,
        input [BRAM_ADDR_WIDTH - 1 : 0] bram_addr_write_computation_i,
        input [BRAM_ADDR_WIDTH - 1 : 0] bram_addr_read_computation_i,
        output reg bram_ready_o,
        input [BRAM_ADDR_WIDTH - 1 : 0] bram_addr_max_i,
        output [$clog2(NUMBER_SUPPORTED_FILTERS) - 1 : 0] sel_mux_final_o,
        output  bram_wr_en_b_o [0 : ((NUMBER_SUPPORTED_FILTERS + N_COLS_ARRAY - 1) / N_COLS_ARRAY)  - 1][0 : N_COLS_ARRAY],
        output reg [BRAM_ADDR_WIDTH - 1 : 0] bram_addr_1_o,
        output reg [BRAM_ADDR_WIDTH - 1 : 0] bram_addr_2_o
    
    );
    wire [BRAM_ADDR_WIDTH - 1 : 0] bram_addr_write_store;
    wire [BRAM_ADDR_WIDTH - 1 : 0] bram_addr_read_store;
    reg bram_addr_max_rst;
    reg bram_addr_max_ld;
    reg [BRAM_ADDR_WIDTH - 1 : 0] bram_addr_max;
    reg num_filter_rst;
    reg bram_address_store_rst;
    reg bram_address_store_ld;
    wire [$clog2(NUMBER_SUPPORTED_FILTERS) - 1: 0] num_filter;
    
    
    localparam [1:0]
        reset = 2'b00 , load = 2'b01 ,store = 2'b10;
    reg p_state, n_state;
    
    always @(p_state or general_rst_i or order_empty_bram_i ) begin: state_transition
        case(p_state)
            reset:
                if (general_rst_i == 0 && order_empty_bram_i == 1) n_state = store;
                else n_state = reset;
            load:
                n_state = store;
            store:
                if (general_rst_i == 1 || ( num_filter == NUMBER_SUPPORTED_FILTERS - 1 && bram_addr_write_store ==  bram_addr_max)) n_state = reset;
                else n_state = store; 
            default:
                n_state = reset;
        endcase
        
    end
    
    
    always @(p_state or general_rst_i or order_empty_bram_i) begin: output_assignments
        case(p_state)
            reset: begin
                bram_ready_o = 1;
                bram_addr_1_o = bram_addr_write_computation_i;
                bram_addr_2_o = bram_addr_read_computation_i;
                bram_addr_max_rst = 1;
                bram_addr_max_ld = 0;
            end
            load: begin
                bram_ready_o = 0;
                bram_addr_1_o = bram_addr_read_store;
                bram_addr_2_o = bram_addr_write_store;
                bram_addr_max_rst = 0;
                bram_addr_max_ld = 1;
            end
            store: begin
                bram_ready_o = 0;
                bram_addr_1_o = bram_addr_read_store;
                bram_addr_2_o = bram_addr_write_store;
                bram_addr_max_rst = 0;
                bram_addr_max_ld = 0;
            end

            default: begin
                bram_ready_o = 1;
                bram_addr_1_o = bram_addr_write_computation_i;
                bram_addr_2_o = bram_addr_read_computation_i;
                bram_addr_max_rst = 1;
                bram_addr_max_ld = 0;
            end
        endcase 
    
    end
    
    always @ (posedge clk_i) begin: sequential
        if (general_rst_i) p_state <= reset;
        else p_state <= n_state;     
    end
    
    //Register for bram_addr_max_i
    always @ (posedge clk_i or posedge bram_addr_max_rst) begin 
        
        if (bram_addr_max_rst) begin
       
            bram_addr_max <= {BRAM_ADDR_WIDTH{1'b0}};
                   
        end else if (bram_addr_max_ld) begin
            
            bram_addr_max <= bram_addr_max_i;
           
        end
    end
    
    
    
    counter_with_max
    #(
        .COUNTER_WIDTH($clog2(NUMBER_SUPPORTED_FILTERS))    
    )
    num_filter
    (
        .clk_i(clk_i),
        .counter_rst_i(num_filter_rst),
        .counter_ld_i(bram_addr_read_store == bram_addr_max),
        .max_value(NUMBER_SUPPORTED_FILTERS - 1),
        .count_num_o(num_filter)
    );
    
    
    counter_with_max
    #(
        .COUNTER_WIDTH(BRAM_ADDR_WIDTH)    
    )
    bram_address_store
    (
        .clk_i(clk_i),
        .counter_rst_i(bram_address_store_rst),
        .counter_ld_i(bram_address_store_ld),
        .max_value(bram_addr_max),
        .count_num_o(bram_addr_read_store)
    );
    assign bram_addr_write_store = bram_addr_read_store - 1;
endmodule
