`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/18/2023 06:31:44 PM
// Design Name: 
// Module Name: ram
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


module ram(
    // Basic
    input  logic        clk,
    // Read/Write address
    input  logic [16:0] addr,
    // Write ports
    input  logic wr_en,
    input  logic [15:0] wr_data,
    // Read ports
    input  logic        rd_en,
    output logic [15:0] rd_data
    );
    
    logic [15:0] mem [87423:0];
    
    always_ff @(posedge clk) begin
        if (wr_en) begin
            mem[addr] <= wr_data;
        end
        else if (rd_en) begin
            rd_data <= mem[addr];
        end 
    end
endmodule
