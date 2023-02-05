`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/31/2023 01:23:55 AM
// Design Name: 
// Module Name: sensitivity_test
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


module sensitivity_test(
	input logic clk,
	input logic start,
	output logic [5:0] ct64
);
	always_ff @(posedge clk ) begin
		if(start) ct64 <= 6'b000000;
		else ct64 <= ct64 + 1;
	end
endmodule

