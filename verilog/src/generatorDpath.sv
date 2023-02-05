`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/18/2023 07:25:42 PM
// Design Name: 
// Module Name: generatorDpath
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


module generatorDpath(
    // Basic
    input  logic        clk,
    input  logic        reset,
    // Data input
    input  logic        data_in,
    
    // Stage 0: Scrambler + Convolutional Encoder + Interleaver
    
    input  logic        wr_en_FIFOr, // Simple FIFO for RATE (4bit)
    input  logic        rd_en_FIFOr,
    output logic [3:0]  rate,
    
    input  logic        wr_en_FIFOl, // Simple FIFO for LENGTH (12bit)
    input  logic        rd_en_FIFOl,
    output logic [11:0] length,      // length of octet
    
    input  logic        field_sel, // field selection: DATA or SIGNAL
    
    input  logic        en_encoder, // Convolutional encoder
    
    input  logic        wrA_en_intlver, // Interleaver 
    input  logic        wrB_en_intlver,
    input  logic        rd_en_intlver,
    input  logic [5:0]  rd_addr_intlver,
    input  logic [8:0]  cap_intlver,
    input  logic [2:0]  bpsc,
    input  logic        clear_intlver,
    output logic        full_intlver,

    input  logic        en_mapping, // Mapping table
    input  logic        is_zero,
    input  logic        is_pilot,
    input  logic        pilot_indicator
    );
    
    // Stage 0
    simpleFIFO #(4) FIFOr // Simple FIFO for RATE
    (
        .reset    (reset),
        .clk      (clk),
        .wr_en    (wr_en_FIFOr),
        .data_in  (data_in),
        .data_out (rate),
        .rd_en    (rd_en_FIFOr)
    );
    
    simpleFIFO #(12) FIFOl // Simple FIFO for RATE
    (
        .reset    (reset),
        .clk      (clk),
        .wr_en    (wr_en_FIFOl),
        .data_in  (data_in),
        .data_out (length),
        .rd_en    (rd_en_FIFOl)
    );
    
    logic field_mux_out;
    assign field_mux_out = field_sel ? 0: data_in; // TODO: replace 0 by DATA field
    
    logic encoder_outA, encoder_outB;
    convEncoder encoder
    (
        .reset(reset),
        .clk(clk),
        .en(en_encoder),
        .data_in(field_mux_out),
        .data_A_out(encoder_outA),
        .data_B_out(encoder_outB)
    );
    
    logic [5:0] data_out_intlver;
    
    interleaver intlver
    (
        .reset    (reset),
        .clk      (clk),
        .wrA_en   (wrA_en_intlver),
        .dataA_in (encoder_outA),
        .wrB_en   (wrB_en_intlver),
        .dataB_in (encoder_outB),
        .rd_en    (rd_en_intlver),
        .rd_addr  (rd_addr_intlver),
        .data_out (data_out_intlver),
        .cap      (cap_intlver),
        .bpsc     (bpsc),
        .clear    (clear_intlver),
        .full     (full_intlver)
    );

    // STAGE 1
    logic signed [12:0] q, i;

    mapTable mapping
    (
        .en              (en_mapping),
        .data_in         (data_out_intlver),
        .q               (q),
        .i               (i),
        .bpsc            (bpsc),
        .is_zero         (is_zero),
        .is_pilot        (is_pilot),
        .pilot_indicator (pilot_indicator)
    );


endmodule
