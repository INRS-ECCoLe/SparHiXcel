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
        output reg input_ready_o,
        output reg weight_ready_o,
        output reg [INPUT_FEATURE_ADDR_WIDTH - 1 : 0] input_wr_address_o,
        output reg [SIG_ADDRS_WIDTH - 1 : 0] weight_wr_address_o,
        output reg [SIG_ADDRS_WIDTH - 1 : 0] signal_wr_address_o,
        output reg [DRAM_ADDR_WIDTH - 1 : 0] dram_rd_address_o,
        output [2:0] dram_access_state_o
    );
    localparam delay_input = 1 + (DATA_IN_DRAM_WIDTH + I_WIDTH * N_ROWS_ARRAY - 1) / DATA_IN_DRAM_WIDTH;
    localparam delay_signal = 1 + (DATA_IN_DRAM_WIDTH + ROM_SIG_WIDTH - 1) / DATA_IN_DRAM_WIDTH;
    localparam delay_weight = 1 + (DATA_IN_DRAM_WIDTH + F_WIDTH * N_ROWS_ARRAY - 1) / DATA_IN_DRAM_WIDTH;
    localparam delay_parameter = 1 + (DATA_IN_DRAM_WIDTH + PARAMETERS_WIDTH - 1) / DATA_IN_DRAM_WIDTH;
   
    
    reg input_addr_rst;
    //reg input_addr_ld;
    reg weight_wr_addr_rst;
    //reg weight_wr_addr_ld;
    reg dram_read_addr_rst;
    reg dram_read_addr_ld;
    reg signal_wr_addr_rst;
    //reg signal_wr_addr_ld;
    reg load_time_mem_rst;
    reg load_time_mem_ld;
    wire [MAX_LOAD_TIME_MEM_WIDTH - 1 : 0] load_time_memory;
    reg [MAX_LOAD_TIME_MEM_WIDTH - 1 : 0] max_value;
    wire [DRAM_ADDR_WIDTH - 1 : 0] dram_rd_address;
    
    
    localparam [2:0]
        reset = 3'b000 , parameters = 3'b001, weights = 3'b010,
        signals = 3'b011 , inputs = 3'b100 , filled = 3'b101;
    reg [2:0] p_state, n_state;
    assign dram_access_state_o = p_state;
    
    always @(*) begin: state_transition
        case(p_state)
            reset:
                if (general_rst_i == 0 && sa_state_i == 4'b0000) n_state = parameters;
                else n_state = reset;
            parameters:
                if (load_time_memory == delay_parameter - 1) n_state = weights;
                else n_state = parameters; 
            weights:
                if ((weight_wr_address_o == 2 ** SIG_ADDRS_WIDTH - 1) || (dram_rd_address_o == weight_finish_addr_dram_i)) n_state = signals;
                else n_state = weights;
            signals:
                if ((signal_wr_address_o == 2 ** SIG_ADDRS_WIDTH - 1) || (dram_rd_address_o == signal_finish_addr_dram_i)) n_state = inputs;
                else n_state = signals;
            inputs:
                if ((input_wr_address_o == 2 ** INPUT_FEATURE_ADDR_WIDTH - 1) || (dram_rd_address_o == input_finish_addr_dram_i)) n_state = filled;
                else n_state = inputs; 
            filled:
                if (general_rst_i == 1) n_state = reset;
                else n_state = filled;
            default:
                n_state = reset;
        endcase
        
    end

    always @(*) begin: output_assignments
        case(p_state)
            reset: begin
                load_time_mem_rst = 1;
                input_addr_rst = 1;
                weight_wr_addr_rst = 1;
                signal_wr_addr_rst = 1;
                dram_read_addr_rst = 1;
                
                load_time_mem_ld = 0;
                dram_read_addr_ld = 0;
                
                dram_rd_address_o = dram_rd_address;
                max_value = 0;
                
                input_ready_o = 0;
                weight_ready_o = 0;
            end
            parameters: begin
                load_time_mem_rst = 0;
                input_addr_rst = 0;
                weight_wr_addr_rst = 0;
                signal_wr_addr_rst = 0;
                dram_read_addr_rst = 0;
                
                load_time_mem_ld = 1;
                dram_read_addr_ld = 1;  
                
                dram_rd_address_o = dram_rd_address;
                max_value = delay_parameter - 1; 
                
                input_ready_o = 0;
                weight_ready_o = 0;
            end
            weights: begin
                load_time_mem_rst = 0;
                input_addr_rst = 0;
                weight_wr_addr_rst = 0;
                signal_wr_addr_rst = 0;
                dram_read_addr_rst = 0;
                
                load_time_mem_ld = 1;
                dram_read_addr_ld = 1;
                
                dram_rd_address_o = dram_rd_address + weight_start_addr_dram_i; 
                max_value = delay_weight - 1;
                                
                input_ready_o = 0;
                weight_ready_o = 0;
            end
            signals: begin
                load_time_mem_rst = 0;
                input_addr_rst = 0;
                weight_wr_addr_rst = 0;
                signal_wr_addr_rst = 0;
                dram_read_addr_rst = 0;
                
                load_time_mem_ld = 1;
                dram_read_addr_ld = 1;
                
                dram_rd_address_o = dram_rd_address + signal_start_addr_dram_i;
                max_value = delay_signal - 1;
                             
                input_ready_o = 0;
                weight_ready_o = 1;
            end
            inputs: begin
                load_time_mem_rst = 0;
                input_addr_rst = 0;
                weight_wr_addr_rst = 0;
                signal_wr_addr_rst = 0;
                dram_read_addr_rst = 0;
                
                load_time_mem_ld = 1;
                dram_read_addr_ld = 1;
                
                dram_rd_address_o = dram_rd_address + input_start_addr_dram_i;
                max_value = delay_input - 1;
                
                                
                if ((input_wr_address_o == 2 ** INPUT_FEATURE_ADDR_WIDTH - 1) || (dram_rd_address_o == input_finish_addr_dram_i)) begin 
                    input_ready_o = 1;
                end else input_ready_o = 0;
                
                weight_ready_o = 1;
            end
            
            filled: begin
                load_time_mem_rst = 1;
                input_addr_rst = 1;
                weight_wr_addr_rst = 1;
                signal_wr_addr_rst = 1;
                dram_read_addr_rst = 1;
                
                load_time_mem_ld = 0;
                dram_read_addr_ld = 0;
                
                dram_rd_address_o = dram_rd_address;
                max_value = 0;
                
                                             
                input_ready_o = 1;
                weight_ready_o = 1;
            end
            default: begin
                load_time_mem_rst = 1;
                input_addr_rst = 1;
                weight_wr_addr_rst = 1;
                signal_wr_addr_rst = 1;
                dram_read_addr_rst = 1;
                
                load_time_mem_ld = 0;
                dram_read_addr_ld = 0;
                
                dram_rd_address_o = dram_rd_address;
                max_value = 0;
                
                                             
                input_ready_o = 0;
                weight_ready_o = 0;
            end
        endcase 
    
    end
    
    always @ (posedge clk_i) begin: sequential
        if (general_rst_i) p_state <= reset;
        else p_state <= n_state;     
    end




    //Register and counter to track weight_wr_address_o
    
    always @(posedge clk_i or posedge weight_wr_addr_rst) begin
        if (weight_wr_addr_rst) begin
        
            weight_wr_address_o <= {SIG_ADDRS_WIDTH{1'b0}}; 
            
        end else if ((load_time_memory == delay_weight - 1) && p_state == weights) begin
        
            weight_wr_address_o <= weight_wr_address_o + 1; 

        end
    end

    
    //Register and counter to track signal_wr_address_o
    
    always @(posedge clk_i or posedge signal_wr_addr_rst) begin
        if (signal_wr_addr_rst) begin
        
            signal_wr_address_o <= {SIG_ADDRS_WIDTH{1'b0}}; 
            
        end else if ((load_time_memory == delay_signal - 1) && p_state == signals) begin
        
            signal_wr_address_o <= signal_wr_address_o + 1; 

        end
    end

    //Register and counter to track input_wr_address_o
    
    always @(posedge clk_i or posedge input_addr_rst) begin
        if (input_addr_rst) begin
        
            input_wr_address_o <= {INPUT_FEATURE_ADDR_WIDTH{1'b0}}; 
            
        end else if ((load_time_memory == delay_input - 1) && p_state == inputs) begin
        
            input_wr_address_o <= input_wr_address_o + 1; 

        end
    end
    // Detect state change by comparing present state and next state
    reg state_changed;
    always @(*) begin
        if (p_state != n_state)
            state_changed = 1'b1;  // State has changed
        else
            state_changed = 1'b0;  // State remains the same
    end
    //counter for dram_rd_address_o.
    counter
    #(
        .COUNTER_WIDTH(DRAM_ADDR_WIDTH)    
    )
    dram_read_address
    (
        .clk_i(clk_i),
        .counter_rst_i(dram_read_addr_rst || state_changed),
        .counter_ld_i(dram_read_addr_ld),
        .count_num_o(dram_rd_address)
    );
    

    //counter for load_time_memory.
    counter_with_max
    #(
        .COUNTER_WIDTH(MAX_LOAD_TIME_MEM_WIDTH)    
    )
    load_time_mem
    (
        .clk_i(clk_i),
        .counter_rst_i(load_time_mem_rst || state_changed),
        .counter_ld_i(load_time_mem_ld),
        .max_value(max_value),
        .count_num_o(load_time_memory)
    );
endmodule
