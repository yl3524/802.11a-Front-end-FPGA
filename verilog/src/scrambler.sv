`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/11/2022 12:33:38 AM
// Design Name: 
// Module Name: scrambler
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

module scrambler(
    input logic reset, // Active HIGH
    input logic clk,
    input logic clear,
    // Input ports
    input logic en, // Active HIGH
    input logic data_in, // bitstream in
    // Output ports
    output logic data_out // bitstream out
    );
    
    logic [6:0] state; // 7 bit states
    logic feedback;
    
    assign feedback = state[6] ^ state[3];
    assign data_out = data_in ^ feedback;
    
    always_ff @(posedge clk) begin
        if(reset) state <= 7'b1011101;
        else if(en) state <= {state[5:0], feedback};
    end
    
endmodule
