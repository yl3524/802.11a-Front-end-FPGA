`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/12/2022 03:49:48 AM
// Design Name: 
// Module Name: convEncoder
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


module convEncoder(
    input logic reset, // Active HIGH
    input logic clk,
    // Input ports
    input logic en, // Active HIGH
    input logic data_in,
    // Output ports
    output logic data_A_out,
    output logic data_B_out
    );
    
    logic [5:0] state;
    assign data_A_out = data_in ^ state[4] ^ state[3] ^ state[1] ^ state[0];
    assign data_B_out = data_in ^ state[5] ^ state[4] ^ state[3] ^ state[0]; 
    
    always_ff @(posedge clk) begin
        if (reset) state <= 6'b0;
        else if(en) state <= { data_in, state[5:1] };
    end
endmodule
