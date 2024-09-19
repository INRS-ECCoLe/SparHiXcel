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
        parameter COUNTER_ROUND_WIDTH = 3
    )
    (
        input [ROM_SIG_WIDTH - 1 : 0] rom_signals_data_i,
        input [$clog2(N+1)-1 : 0]filter_size_i,
        input clk_i,
        input general_rst_i,
        input end_feature_i,
        input [COUNTER_ROUND_WIDTH - 1 : 0] max_round_weight_i,
        //input end_weight_i,
        output reg rst_o,
        output reg load_o,
        output reg ready_o,
        output reg start_op_o,
        output reg rd_weight_ld_o,
        output reg rd_feature_ld_o,
        output reg rd_rom_signals_ld_o,
        output [SIG_ADDRS_WIDTH - 1 : 0]addrs_rom_signal_o,
        output reg [SEL_WIDTH - 1: 0] f_sel_o [0 : N_ROWS_ARRAY - 1],
        output reg [NUM_COL_WIDTH -1 : 0]row_num_o [0 : N_ROWS_ARRAY - 1],
        output reg [NUM_COL_WIDTH - 1 : 0] column_num_o [0 : N_ROWS_ARRAY - 1],
        output reg [NUM_COL_WIDTH - 1 : 0] number_of_columns_o[0 : N_ROWS_ARRAY - 1],
        output reg [SEL_MUX_TR_WIDTH - 1 : 0] sel_mux_tr_o [0 : N_ROWS_ARRAY - 1],
        output reg en_adder_node_o [0 : N_ROWS_ARRAY - 1],
        output reg sel_mux_node_o [0 : N_ROWS_ARRAY - 1]                
    );
    reg [NUM_COL_WIDTH - 1 : 0] count_col [0 : N_ROWS_ARRAY - 1]; 
    reg rst_col, ld_col;
    reg f_sel_ld, f_sel_rst;
    reg sel_mux_tr_ld, sel_mux_tr_rst;
    reg number_of_columns_ld, number_of_columns_rst;
    reg en_adder_node_ld, en_adder_node_rst;
    reg counter_waiting_op_rst;
    reg counter_waiting_op_ld;
    reg counter_load_rst;
    reg counter_load_ld;
    reg counter_ready_rst;
    reg counter_ready_ld;
    reg counter_address_rom_rst;
    reg round_weight_ld;
    reg end_weight;
    wire [COUNTER_ROUND_WIDTH - 1 : 0]round_num_weight;
    //reg counter_address_rom_ld;
    wire [READY_COUNTER_WIDTH - 1 : 0] ready_count_num;
    wire [LOAD_COUNTER_WIDTH - 1 : 0] load_count_num;  
    wire [LOAD_COUNTER_WIDTH - 1 : 0] waiting_op_count_num; 
    wire [SEL_WIDTH - 1: 0] f_sel [0 : N_ROWS_ARRAY - 1];
    wire [NUM_COL_WIDTH - 1 : 0] number_of_columns[0 : N_ROWS_ARRAY - 1];
    wire [SEL_MUX_TR_WIDTH - 1 : 0] sel_mux_tr [0 : N_ROWS_ARRAY - 1];
    wire en_adder_node [0 : N_ROWS_ARRAY - 1];
    
     
    localparam [1:0]
        reset = 2'b00 , load = 2'b01,
        ready = 2'b10 , start = 2'b11;
    reg [1:0] p_state, n_state;

    always @(p_state or general_rst_i or end_weight or load_count_num or ready_count_num or end_feature_i or waiting_op_count_num or filter_size_i) begin: state_transition
        case(p_state)
            reset:
                if (general_rst_i == 0 && end_weight == 0) n_state = load;
                else n_state = reset;
            load:
                if (load_count_num == N_COLS_ARRAY) n_state = ready;
                else n_state = load;
            ready:
                if (ready_count_num == 2) n_state = start;
                else n_state = ready;
            start:
                if (general_rst_i == 0) n_state = reset;
                else if (end_feature_i == 1 && end_weight == 1) n_state = reset;
                else if (end_feature_i == 1 && (waiting_op_count_num == 2 * (filter_size_i - 1) + 6)) n_state = load;
                else n_state = start;
            default:
                n_state = reset;
        endcase
        
    end
     
    always @(p_state or general_rst_i or end_weight or load_count_num or ready_count_num or end_feature_i or waiting_op_count_num or filter_size_i) begin: output_assignments
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
                counter_address_rom_rst = 1;
                
                ld_col = 0;
                f_sel_ld = 0;
                sel_mux_tr_ld = 0;
                number_of_columns_ld = 0;
                en_adder_node_ld = 0;
                counter_waiting_op_ld = 0;
                counter_load_ld = 0;
                counter_ready_ld = 0;
                //counter_address_rom_ld = 0;
                
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
                counter_address_rom_rst = 0;
                
                ld_col = 1;
                f_sel_ld = 1;
                sel_mux_tr_ld = 1;
                number_of_columns_ld = 1;
                en_adder_node_ld = 1;
                counter_waiting_op_ld = 0;
                counter_load_ld = 1;
                counter_ready_ld = 0;
                //counter_address_rom_ld = 1;
                
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
                counter_address_rom_rst = 0;
                
                ld_col = 0;
                f_sel_ld = 0;
                sel_mux_tr_ld = 0;
                number_of_columns_ld = 0;
                en_adder_node_ld = 0;
                counter_waiting_op_ld = 0;
                counter_load_ld = 0;
                counter_ready_ld = 1;
                //counter_address_rom_ld = 0;
                
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
                counter_address_rom_rst = 0;
                
                ld_col = 0;
                f_sel_ld = 0;
                sel_mux_tr_ld = 0;
                number_of_columns_ld = 0;
                en_adder_node_ld = 0;
                if (end_feature_i) counter_waiting_op_ld = 1;
                else counter_waiting_op_ld = 0;
                counter_load_ld = 0;
                counter_ready_ld = 0;
                //counter_address_rom_ld = 0;
                
                rst_o = 0;
                load_o = 0;
                ready_o = 0;
                start_op_o = 1;
                rd_weight_ld_o = 0;
                rd_feature_ld_o = 1;
                rd_rom_signals_ld_o = 0;
            
            end
            
        endcase 
    
    end
    
    always @ (posedge clk_i) begin: sequential
        if (general_rst_i) p_state <= reset;
        else p_state <= n_state;     
    end
        
    
    // allocating ROM signal data to the corresponding signals and then we will send these signals to their registers we make in the controller.
    genvar j;
    generate
        for (j = 0 ; j < N_ROWS_ARRAY ; j = j + 1) begin
            assign f_sel[j] =  rom_signals_data_i [(j + 1)* SEL_WIDTH - 1 : j * SEL_WIDTH];
            assign number_of_columns[j] =  rom_signals_data_i [(j + 1)* NUM_COL_WIDTH + N_ROWS_ARRAY * SEL_WIDTH - 1 : j* NUM_COL_WIDTH + N_ROWS_ARRAY * SEL_WIDTH];
            assign sel_mux_tr [j] = rom_signals_data_i [(j+1) * SEL_MUX_TR_WIDTH  + N_ROWS_ARRAY * (NUM_COL_WIDTH + SEL_WIDTH) - 1 : j * SEL_MUX_TR_WIDTH  + N_ROWS_ARRAY * (NUM_COL_WIDTH + SEL_WIDTH)];
            assign en_adder_node [j] = rom_signals_data_i [(j+1) + N_ROWS_ARRAY * (SEL_MUX_TR_WIDTH + NUM_COL_WIDTH + SEL_WIDTH) - 1 : j + N_ROWS_ARRAY * (SEL_MUX_TR_WIDTH + NUM_COL_WIDTH + SEL_WIDTH)];
        
        end
    endgenerate
    // generating row numbers by a combinational hardware.  
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
    // generating column number by using number of columns as an input.
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
                sel_mux_tr_o[i] <= 0;
            end     
        end else if (sel_mux_tr_ld) begin
            for(i = 0; i < N_ROWS_ARRAY; i = i + 1)begin
                sel_mux_tr_o[i] <= sel_mux_tr[i];
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
    
    //counter for counting the number of rounds required by weights

    always @(*) begin
        if (load_count_num == N_COLS_ARRAY) round_weight_ld = 1;
        else round_weight_ld = 0;
    end 
    always @(*) begin
        if (round_num_weight == max_round_weight_i) end_weight = 1;
        else end_weight = 0;
    end 
    
    assign addrs_rom_signal_o = round_num_weight * N_COLS_ARRAY + load_count_num;
    
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
endmodule

