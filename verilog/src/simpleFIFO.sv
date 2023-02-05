`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2022 05:39:49 PM
// Design Name: 
// Module Name: simpleFIFO
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Simple FIFO used to store RATE and LENGTH from SIGNAL field
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module simpleFIFO
#(
    parameter length = 4)
(
    input  logic reset,
    input  logic clk,
    // Write ports
    input  logic wr_en,
    input  logic data_in,
    // Read ports
    output logic [length-1:0] data_out,
    input  logic rd_en
    );
    
    logic [length-1:0] data;
    always_ff @(posedge clk) begin
        if(reset) begin
            data <= 0;
        end
        else if (wr_en) begin
            data <= {data_in, data[length-1:1]};
        end
    end
    
    always_comb begin
        data_out = rd_en ? data : 0;
    end
endmodule
