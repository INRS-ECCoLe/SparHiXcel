`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/17/2024 11:40:46 AM
// Design Name: 
// Module Name: control
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


module control
    #(
        parameter N = 3,
        parameter ADDRS_WIDTH = $clog2(N),
        parameter NUM_COL_WIDTH = $clog2(N+1),
        parameter SEL_WIDTH = $clog2(N)
    )
    (
        input [NUM_COL_WIDTH - 1 : 0] column_num_i, // 1 2 3 4 ...
        input clk_i,
        input [NUM_COL_WIDTH -1 : 0]row_num_i,
        input [$clog2(N+1)-1 : 0]filter_size_i,
        //input column_num_rst_i,
        //input column_num_ld_i, 
        //input mreg_start_i,
        //input mreg_addrs_rst_i, 
        input [SEL_WIDTH - 1: 0] f_sel_i,
        //input f_sel_rst_i,
        //input f_sel_ld_i,
        //input en_adder_1_i,
        //input en_adder_rst_i,
        //input en_adder_ld_i,
        //input en_adder_2_i,
        input rst_i,
        input load_i,
        input ready_i,
        input start_op_i,
        output reg freg_rst_o,//new
        output reg freg_ld_o,
        output reg wreg_rst_o,
        output reg wreg_wr_en_o,
        output reg mreg_rst_o,
        output reg mreg_wr_en_o,
        output reg oreg_1_rst_o,
        output reg oreg_1_ld_o,
        output reg oreg_2_rst_o,
        output reg oreg_2_ld_o,
        
        output reg sel_mux_tr_rst_o,
        output reg sel_mux_tr_ld_o,
        output reg number_of_columns_rst_o,
        output reg number_of_columns_ld_o,
        output reg out_reg_shift_rst_o,
        output reg node_rst_o,
        output reg node_ld_o,
        output reg path_node_rst_o,
        output reg path_node_ld_o,
        
        output  en_adder_1_o,
        output  en_adder_2_o,
        output reg [NUM_COL_WIDTH - 1 : 0] column_num_o,
        output reg [SEL_WIDTH - 1: 0] f_sel_o,
        output reg [ADDRS_WIDTH - 1 : 0] mreg_wr_addrs_o,
        output reg [ADDRS_WIDTH - 1 : 0] mreg_rd_addrs_o
    );
        
        reg mreg_addrs_rst, mreg_start,
         f_sel_rst, f_sel_ld,
         column_num_rst, column_num_ld;
         
        localparam [1:0]
            reset = 2'b00 , load = 2'b01,
            ready = 2'b10 , start = 2'b11;
        reg [1:0] p_state, n_state;
        
        //State Machine
        
        always @(p_state or rst_i or load_i or ready_i or start_op_i) begin: state_transition
            case(p_state)
                reset:
                    if (load_i == 1 && rst_i == 0) n_state = load;
                    else n_state = reset;
                load:
                    if (ready_i == 1 && load_i == 0) n_state = ready;
                    else n_state = load;
                ready:
                    if (start_op_i == 1 && ready_i == 0) n_state = start;
                    else n_state = ready;
                start:
                    if (rst_i == 1) n_state = reset;
                    else n_state = start;
                default:
                    n_state = reset;
            endcase
        
        end
        
        always @(p_state or rst_i or load_i or ready_i or start_op_i) begin: output_assignments
            case(p_state)
                reset: begin
                    freg_rst_o = 1;
                    wreg_rst_o = 1;
                    mreg_rst_o = 1;
                    f_sel_rst = 1;
                    oreg_1_rst_o = 1;
                    oreg_2_rst_o = 1;
                    column_num_rst = 1;
                    mreg_addrs_rst = 1;
                    //en_adder_rst = 1;
                    freg_ld_o = 0;
                    f_sel_ld = 0;
                    column_num_ld = 0;
                    wreg_wr_en_o = 0;
                    mreg_wr_en_o = 0;
                    oreg_1_ld_o = 0;
                    oreg_2_ld_o = 0;
                    //en_adder_ld = 0;
                    mreg_start = 0; 
                    
                    sel_mux_tr_rst_o = 1;
                    number_of_columns_rst_o = 1;
                    node_rst_o = 1;
                    path_node_rst_o = 1;
                    out_reg_shift_rst_o = 1;
                    sel_mux_tr_ld_o = 0;
                    number_of_columns_ld_o = 0;
                    node_ld_o = 0;
                    path_node_ld_o = 0;
                end       
                load: begin
                    freg_rst_o = 0;
                    wreg_rst_o=0;
                    mreg_rst_o = 0;
                    f_sel_rst = 0;
                    oreg_1_rst_o = 0;
                    oreg_2_rst_o = 0;
                    column_num_rst = 0;
                    mreg_addrs_rst = 0;
                    //en_adder_rst = 0;
                    freg_ld_o = 0;
                    f_sel_ld = 1;
                    column_num_ld = 1;
                    wreg_wr_en_o = 1;
                    mreg_wr_en_o = 0;
                    oreg_1_ld_o = 0;
                    oreg_2_ld_o = 0;
                    //en_adder_ld = 1;
                    mreg_start = 0;
                    
                    sel_mux_tr_rst_o = 0;
                    number_of_columns_rst_o = 0;
                    node_rst_o = 0;
                    path_node_rst_o = 0;
                    out_reg_shift_rst_o = 0;
                    sel_mux_tr_ld_o = 1;
                    number_of_columns_ld_o = 1;
                    node_ld_o = 0;
                    path_node_ld_o = 1;
                end
                ready: begin
                    freg_rst_o = 0;
                    wreg_rst_o=0;
                    mreg_rst_o = 0;
                    f_sel_rst = 0;
                    oreg_1_rst_o = 0;
                    oreg_2_rst_o = 0;
                    column_num_rst = 0;
                    mreg_addrs_rst = 0;
                    //en_adder_rst = 0;
                    freg_ld_o = 1;
                    f_sel_ld = 0;
                    column_num_ld = 0;
                    wreg_wr_en_o = 0;
                    mreg_wr_en_o = 0;
                    oreg_1_ld_o = 0;
                    oreg_2_ld_o = 0;
                    //en_adder_ld = 0;
                    mreg_start = 0;
                    
                    sel_mux_tr_rst_o = 0;
                    number_of_columns_rst_o = 0;
                    node_rst_o = 0;
                    path_node_rst_o = 0;
                    out_reg_shift_rst_o = 0;
                    sel_mux_tr_ld_o = 0;
                    number_of_columns_ld_o = 0;
                    node_ld_o = 0;
                    path_node_ld_o = 0;    
                end
                start: begin
                    freg_rst_o = 0;
                    wreg_rst_o=0;
                    mreg_rst_o = 0;
                    f_sel_rst = 0;
                    oreg_1_rst_o = 0;
                    oreg_2_rst_o = 0;
                    column_num_rst = 0;
                    mreg_addrs_rst = 0;
                    //en_adder_rst = 0;
                    freg_ld_o = 1;
                    f_sel_ld = 0;
                    column_num_ld = 0;
                    wreg_wr_en_o = 0;
                    mreg_wr_en_o = 1;
                    oreg_1_ld_o = 1;
                    oreg_2_ld_o = 1;
                    //en_adder_ld = 0;
                    mreg_start = 1; 
                    
                    sel_mux_tr_rst_o = 0;
                    number_of_columns_rst_o = 0;
                    node_rst_o = 0;
                    path_node_rst_o = 0;
                    out_reg_shift_rst_o = 0;
                    sel_mux_tr_ld_o = 0;
                    number_of_columns_ld_o = 0;
                    node_ld_o = 1;
                    path_node_ld_o = 0;      
                end
                default: begin
                    freg_rst_o = 1;
                    wreg_rst_o = 1;
                    mreg_rst_o = 1;
                    f_sel_rst = 1;
                    oreg_1_rst_o = 1;
                    oreg_2_rst_o = 1;
                    column_num_rst = 1;
                    mreg_addrs_rst = 1;
                    //en_adder_rst = 1;
                    freg_ld_o = 0;
                    f_sel_ld = 0;
                    column_num_ld = 0;
                    wreg_wr_en_o = 0;
                    mreg_wr_en_o = 0;
                    oreg_1_ld_o = 0;
                    oreg_2_ld_o = 0;
                    //en_adder_ld = 0;
                    mreg_start = 0; 
                    
                    sel_mux_tr_rst_o = 1;
                    number_of_columns_rst_o = 1;
                    node_rst_o = 1;
                    path_node_rst_o = 1;
                    out_reg_shift_rst_o = 1;
                    sel_mux_tr_ld_o = 0;
                    number_of_columns_ld_o = 0;
                    node_ld_o = 0;
                    path_node_ld_o = 0;  
                end    
            endcase
        
        
        end
        
        always @ (posedge clk_i) begin: sequential
            if (rst_i) p_state <= reset;
            else p_state <= n_state;     
        end
            
        //End of state machione
         
        
        always @ (posedge clk_i) begin 
            if (mreg_addrs_rst) begin 
                if(column_num_o - 1 == 0) begin
                    mreg_wr_addrs_o <= 0;
                end else begin
                    mreg_wr_addrs_o <= 1 + (N - column_num_o);
                end  
            end  else if (mreg_start) begin
                if (mreg_wr_addrs_o == N - 1) begin
                    mreg_wr_addrs_o <= 0;
                end else begin 
                    mreg_wr_addrs_o <= mreg_wr_addrs_o + 1;
                end
            end
       
        end
        //assign mreg_rd_addrs_o = ( mreg_wr_addrs_o == 0 ) ? N - 1 - (row_num_i%N) : ( mreg_wr_addrs_o == 1 && (row_num_i%N) == 0 ) ? 0 : ( mreg_wr_addrs_o == 1 && (row_num_i%N) != 0 )? N - (row_num_i%N): ;    
        always @ (*) begin
            if (mreg_wr_addrs_o == 0) begin
                mreg_rd_addrs_o <= N - 1 - (row_num_i - 1);    
            end else begin
                if (mreg_wr_addrs_o > (row_num_i - 1 )) begin
                    mreg_rd_addrs_o <= mreg_wr_addrs_o - 1 - (row_num_i - 1);    
                end else begin
                    mreg_rd_addrs_o <= N - 1 + (mreg_wr_addrs_o - (row_num_i - 1));   
                end
            end
        end
        // REGISTER FOR F_SEL_I
        always @ (posedge clk_i) begin //or posedge f_sel_rst deleted
        
            if (f_sel_rst) begin
                f_sel_o <= 0;
                
            end else if (f_sel_ld) begin
             
                    f_sel_o <= f_sel_i;
                
            end
        end
        
         // REGISTER FOR column_num_i
        always @ (posedge clk_i) begin  // or posedge column_num_rst deleted
        
            if (column_num_rst) begin
                column_num_o <= 0;
                
            end else if (column_num_ld) begin
             
                    column_num_o <= column_num_i;
                
            end
        end
        /*
        // REGISTER FOR en_adder_1_i
        always @ (posedge clk_i or posedge en_adder_rst) begin 
        
            if (en_adder_rst) begin
                en_adder_1_o <= 0;
                
            end else if (en_adder_ld) begin
             
                    en_adder_1_o <= en_adder_1_i;
                
            end
        end
        
        // REGISTER FOR en_adder_2_i
        always @ (posedge clk_i or posedge en_adder_rst) begin 
        
            if (en_adder_rst) begin
                en_adder_2_o <= 0;
                
            end else if (en_adder_ld) begin
             
                    en_adder_2_o <= en_adder_2_i;
                
            end
        end
        */
        
        //Generating en_adder_1_o and en_adder_2_o
        assign en_adder_1_o = (row_num_i > 1) ? 1 : 0;
        assign en_adder_2_o = (row_num_i == filter_size_i && column_num_o != 1)? 1 : 0;
endmodule
