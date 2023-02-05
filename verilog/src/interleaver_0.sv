`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/21/2022 01:41:45 AM
// Design Name: 
// Module Name: interleaver0
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//  input: 2 one-bit input A and B will be placed into specific places in queue. 
//  full: indicates whether queue is full. 
//  Once queue is full, lsb will be sent to output, queue will be shifted left for one bit. 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module interleaver0(
    input  logic reset, 
    input  logic clk,
    // input A
    input  logic wrA_en,
    input  logic [8:0] wrA_addr, // 9 bit for 288 = 48subcarriers * 6bit/subcarrier
    input  logic dataA_in,
    // input B
    input  logic wrB_en,
    input  logic [8:0] wrB_addr,
    input  logic dataB_in,
    // read port
    input  logic rd_en,
    output logic data_out,
    // Control signal
    input  logic [8:0] cap, // capacity for internal queue
    input  logic clear,
    output logic full
    );
    
    logic [287:0] data; // Data queue
    logic [8:0] counter; // Data counter(indicate full or not)
    logic [1:0] bit_sel;
    
    assign bit_sel = {wrB_en, wrA_en}; 
    assign full = (counter == cap) ? 1 : 0; 
    //assign busy = (bit_sel != 2'b00 && !full) ? 1:0;
    
    always_ff @(posedge clk) begin
        if(reset) begin
            data <= 0;
            counter <= 0;
        end
        else if(clear) counter <= 0;
        else if(bit_sel != 2'b0) begin
            case(bit_sel)
                2'b01: begin // Write only A
                    data[wrA_addr] <= dataA_in;
                    counter <= counter + 1;
                end
                2'b10: begin // Write only B
                    data[wrB_addr] <= dataB_in;
                    counter <= counter + 1;
                end
                2'b11: begin // Write both bits
                    data[wrA_addr] <= dataA_in;
                    data[wrB_addr] <= dataB_in;
                    counter <= counter + 2;
                end
                default: begin
                    data[wrA_addr] <= dataA_in;
                    data[wrB_addr] <= dataB_in;
                    counter <= counter + 2;
                end  
            endcase
        end
        else if(rd_en && full) begin // Queue
            data_out <= data[0]; 
            data <= data >> 1; 
        end        
    end
    
endmodule
