`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/19/2023 10:47:24 PM
// Design Name: 
// Module Name: generatorCpath
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


module generatorCpath(
    // Basic
    input  logic        clk,
    input  logic        reset,
    // Input data interface
    input  logic        istream_val,
    output logic        istream_rdy,
    
    // Stage 0 control signal
    
    output logic        rd_en_FIFOr, // Simple FIFO for RATE
    output logic        wr_en_FIFOr,
    input  logic [3:0]  rate,
    
    output logic        rd_en_FIFOl, // Simple FIFO for LENGTH
    output logic        wr_en_FIFOl,
    input  logic [11:0] length,
    
    output logic        field_sel,   // Field selection mux
    
    output logic        en_encoder,   // Convolutional encoder
    
    output  logic        wrA_en_intlver, // Interleaver 
    output  logic        wrB_en_intlver,
    output  logic        rd_en_intlver,
    output  logic [5:0]  rd_addr_intlver,
    output  logic [8:0]  cap_intlver,
    output  logic [2:0]  bpsc,
    output  logic        clear_intlver,
    input   logic        full_intlver,

    output  logic        en_mapping, // Mapping table
    output  logic        is_zero, 
    output  logic        is_pilot,
    output  logic        pilot_indicator
    );
    
    //----------------------------------------------------------------------
    // State Definitions
    //----------------------------------------------------------------------
    
    localparam STATE_IDLE   = 3'd0;
    localparam STATE_STAGE0 = 3'd1;
    localparam STATE_STAGE1 = 3'd2;
    // localparam STATE_STAGE2 = 3'd3;
    localparam STATE_WRITE  = 3'd4;
    
    //----------------------------------------------------------------------
    // State
    //----------------------------------------------------------------------
    
    logic [2:0] state_current;
    logic [2:0] state_next;
    
    always_ff @( posedge clk ) begin
        if ( reset ) begin
            state_current <= STATE_IDLE;
        end
        else begin
            state_current <= state_next;
        end
    end
    
    //----------------------------------------------------------------------
    // State Transitions
    //----------------------------------------------------------------------
    
    always_comb begin
        case( state_current )
        
            STATE_IDLE: begin
                if ( istream_val ) state_next = STATE_STAGE0;
            end
            STATE_STAGE0: begin
                if ( full_intlver ) state_next = STATE_STAGE1;
            end
            STATE_STAGE1: begin
                state_next = STATE_STAGE1; // TODO !!! 
            end
            
            default:
                state_next = STATE_IDLE;
                
        endcase         
    end
    
    //----------------------------------------------------------------------
    // States Outputs
    //----------------------------------------------------------------------
    
    localparam x = 1'bx;
    
    task cs
    (
        // input data interface
        input logic cs_istream_rdy,
        input logic cs_en_encoder,
        input logic cs_pilot_scrambler_clear,
        input logic cs_sb_counter_clear,
        input logic cs_en_mapping
    );
        begin
            istream_rdy           = cs_istream_rdy;
            en_encoder            = cs_en_encoder;
            pilot_scrambler_clear = cs_pilot_scrambler_clear;
            sb_counter_clear      = cs_sb_counter_clear;
            en_mapping            = cs_en_mapping;
        end
    endtask
    
    always_comb begin
        case( state_current )
            //  istream en_     pilot_scrambler subcarrier_ en_
            //  _rdy    encoder _clear          cnt_clear   mapping
            STATE_IDLE: begin
                cs(0,    0,     1,              1,          0);
            end
            STATE_STAGE0: begin
                cs(1,    1,     0,              1,          0);
            end
            STATE_STAGE1: begin
                cs(0,    0,     0,              0,          1);
            end
        endcase
    end 
    
    //----------------------------------------------------------------------
    // Other control signals
    //----------------------------------------------------------------------

    // GENERAL
    
    // istream_type flag: indicates which field is in process
    logic istream_type;
    // TODO !!! (according to symbol num)
    assign istream_type = 1'b0; // SIGNAL: 0, DATA: 1 
    
    // Symbol count
    logic [11:0] symbol_cnt;
    // TODO !!! (according to stage3)
    assign symbol_cnt = 12'd0;
    
    // STAGE 0

    // Stage 0 bit counter
    logic [4:0] SIGNAL_bit_cnt;
    always_ff @( posedge clk ) begin
        if ( state_current == STATE_IDLE ) SIGNAL_bit_cnt <= 5'd0;
        else if ( state_next == STATE_STAGE0 && !istream_type) SIGNAL_bit_cnt <= SIGNAL_bit_cnt + 1;
        else SIGNAL_bit_cnt <= 5'd0; 
    end
    
    // wr_en logic for simple FIFO of RATE
    assign wr_en_FIFOr = ( state_current == STATE_STAGE0 && SIGNAL_bit_cnt < 4 ) ? 1 : 0;
    
    // wr_en logic for simple FIFO of LENGTH
    assign wr_en_FIFOl = ( SIGNAL_bit_cnt > 4 && SIGNAL_bit_cnt < 17 ) ? 1 : 0;
    
    // rd_en logic for simple FIFO of RATE 
    // TODO !!! (according to istream_type)
    assign rd_en_FIFOr = 1'b1;
    
    // rd_en logic for simple FIFO of LENGTH
    // TODO !!! (according to istream_type)
    assign rd_en_FIFOl = 1'b1;
    
    // selection logic for field selection mux
    assign field_sel = istream_type;
    
    // Interleaver write enable logic
    always_comb begin
        if( state_current == STATE_STAGE0 && !istream_type ) {wrA_en_intlver, wrB_en_intlver} = 2'b11;
        else {wrA_en_intlver, wrB_en_intlver} = 2'b00;
        // TODO !!! enable logic when data field(puncture pattern)
    end

    // Interleaver capacity logic
    always_comb begin
        if( !istream_type ) cap_intlver = 9'd48;
        // TODO !!! cap logic when data field 
    end

    // Interleaver bpsc logic
    always_comb begin
        if( !istream_type ) bpsc = 3'd1;
        // TODO !!! bpsc logic when data field 
    end  
    
    // Interleaver clear logic
    assign clear_intlver = 1'b0; // TODO !!! when next stage finished

    // STAGE 1

    // Pilot polarity and pilot indicator logic
    logic [6:0] pilot_scambler_state;
    logic       pilot_scrambler_clear;
    logic       pilot_polarity;
    always_ff @(posedge clk) begin
        if( pilot_scrambler_clear || reset ) pilot_scambler_state <= 7'b1111111;
        else if( state_current == STATE_WRITE && state_next == STATE_STAGE0 ) // CHECKPOINT !!!
            pilot_scambler_state <= pilot_scambler_state << 1 + pilot_polarity;
    end
    assign pilot_polarity = pilot_scambler_state[6] ^ pilot_scambler_state[3]; // 0 -> 1 * {1,1,1,-1}, 1 -> -1 * {-1,-1,-1,1}
    assign pilot_indicator = ( is_pilot && pilot_polarity && sb_counter == 57 ) ? 0 : 1;

    // Subcarrier counter
    logic [5:0] sb_counter;
    logic       sb_counter_clear;
    always_ff @(posedge clk) begin
        if ( sb_counter_clear || reset ) sb_counter <= 0;
        else if ( state_current == STATE_STAGE1 ) sb_counter <= sb_counter + 1;
    end

    // is_pilot logic
    always_comb begin
        if (state_current == STATE_STAGE1) begin
            if ( sb_counter == 0 || (sb_counter > 26 && sb_counter < 38) ) is_zero = 1'b1;
            else is_zero = 1'b0;
        end
        else begin
            is_zero = 1'b0;
        end 
    end

    // is_zero logic
    always_comb begin
        if ( state_current == STATE_STAGE1 ) begin
            if ( sb_counter == 7 || sb_counter == 21 || sb_counter == 43 || sb_counter == 57 ) is_pilot = 1'b1;
            else is_pilot = 1'b0;
        end
        else is_pilot = 1'b0;
    end

    // Interleaver read enable adress
    assign rd_en_intlver = (state_current == STATE_STAGE1 && !is_zero && !is_pilot) ? 1 : 0;

    // Address read from interleaver logic
    always_comb begin
        if (state_current == STATE_STAGE1 && !is_zero && !is_pilot) begin
            if(sb_counter > 0 && sb_counter < 7) rd_addr_intlver = sb_counter + 23;
            else if (sb_counter > 7 && sb_counter < 21) rd_addr_intlver = sb_counter + 22;
            else if (sb_counter > 21 && sb_counter < 27) rd_addr_intlver = sb_counter + 21;
            else if (sb_counter > 37 && sb_counter < 43) rd_addr_intlver = sb_counter - 38;
            else if (sb_counter > 43 && sb_counter < 57) rd_addr_intlver = sb_counter - 37;
            else if (sb_counter > 57 ) rd_addr_intlver = sb_counter - 36;
        end 
    end



endmodule
