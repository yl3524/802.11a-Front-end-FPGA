`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/20/2023 06:48:44 PM
// Design Name: 
// Module Name: top_tb
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


module top_tb();
    // Basic
    logic        clk, reset;
    // Data input
    logic        data_in, istream_val, istream_rdy;
    logic [3:0]  rate;
    logic [11:0] length;
    
    logic [31:0] vectornum;
    logic        input_vectors[10000:0];
    
    // Instantiate device under test
    top generator(clk, reset, data_in, istream_val, istream_rdy);
    
    // Generate clock
    always 
        begin
            clk = 1; #5; clk = 0; #5;
        end 
    
    // Import data source from .txt file
    initial begin
        $readmemb("D:/MEng/DesignProject/git/fpga/test_src/input_src.txt", input_vectors);
        vectornum = 0;
        #5; reset = 1; 
        #10; reset = 0;
    end
    
    // Bitstramm feeding logic
    always @(posedge clk) begin
        data_in <= input_vectors[vectornum];
    end
    
    // Pointer logic for input bitstream
    always @(negedge clk) begin
        if(istream_rdy && istream_val) begin
            vectornum <= vectornum + 1;
        end
    end
    
    // istream valid signal logic
    always @(posedge clk) begin
        if(!reset) begin
            if(input_vectors[vectornum] !== 1'bx) begin
                istream_val <= 1;
            end
            else begin
                istream_val <= 0;
            end
        end
    end
    
endmodule
