`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/20/2023 03:09:33 AM
// Design Name: 
// Module Name: top
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


module top(
    // Basic
    input logic clk,
    input logic reset,
    // Data input
    input logic data_in,
    input logic istream_val,
    output logic istream_rdy
    
    // demo ports

    );
    
    logic        wr_en_FIFOr; // Simple FIFO for RATE (4bit)
    logic        rd_en_FIFOr;
    logic        wr_en_FIFOl; // Simple FIFO for LENGTH (12bit)
    logic        rd_en_FIFOl;
    logic        field_sel;   // Field slection mux
    logic        en_encoder;  // Convolutional encoder

    logic        wrA_en_intlver; // Interleaver 
    logic        wrB_en_intlver;
    logic        rd_en_intlver;
    logic [5:0]  rd_addr_intlver;
    logic [8:0]  cap_intlver;
    logic [2:0]  bpsc;
    logic        clear_intlver;
    logic        full_intlver;

    logic        en_mapping;
    logic        is_zero;
    logic        is_pilot;
    logic        pilot_indicator;
    
    generatorDpath Dpath
    (
        .clk             (clk),
        .reset           (reset),
        .data_in         (data_in),
        .wr_en_FIFOr     (wr_en_FIFOr),
        .rd_en_FIFOr     (rd_en_FIFOr),
        .rate            (rate),
        .wr_en_FIFOl     (wr_en_FIFOl),
        .rd_en_FIFOl     (rd_en_FIFOl),
        .length          (length),
        .field_sel       (field_sel),
        .en_encoder      (en_encoder),
        .wrA_en_intlver  (wrA_en_intlver),
        .wrB_en_intlver  (wrB_en_intlver),
        .rd_en_intlver   (rd_en_intlver),
        .rd_addr_intlver (rd_addr_intlver),
        .cap_intlver     (cap_intlver),
        .bpsc            (bpsc),
        .clear_intlver   (clear_intlver),
        .full_intlver    (full_intlver),
        .en_mapping      (en_mapping),
        .is_zero         (is_zero),
        .is_pilot        (is_pilot),
        .pilot_indicator (pilot_indicator)
    );
    
    generatorCpath Cpath 
    (
        .clk             (clk),
        .reset           (reset),
        .istream_val     (istream_val),
        .istream_rdy     (istream_rdy),
        .wr_en_FIFOr     (wr_en_FIFOr),
        .rd_en_FIFOr     (rd_en_FIFOr),
        .rate            (rate),
        .wr_en_FIFOl     (wr_en_FIFOl),
        .rd_en_FIFOl     (rd_en_FIFOl),
        .length          (length),
        .field_sel       (field_sel),
        .en_encoder      (en_encoder),
        .wrA_en_intlver  (wrA_en_intlver),
        .wrB_en_intlver  (wrB_en_intlver),
        .rd_en_intlver   (rd_en_intlver),
        .rd_addr_intlver (rd_addr_intlver),
        .cap_intlver     (cap_intlver),
        .bpsc            (bpsc),
        .clear_intlver   (clear_intlver),
        .full_intlver    (full_intlver),
        .en_mapping      (en_mapping),
        .is_zero         (is_zero),
        .is_pilot        (is_pilot),
        .pilot_indicator (pilot_indicator)
    );
    
endmodule
