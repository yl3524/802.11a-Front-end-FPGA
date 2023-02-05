`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/22/2022 01:41:53 AM
// Design Name: 
// Module Name: interleaver1
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

module interleaver1(
    input logic reset,
    input logic clk,
    // Write ports
    input logic wr_en,
    input logic [8:0] wr_addr,
    input logic data_in,
    // Read ports
    input logic rd_en,
    input logic [5:0] rd_addr, // 48 address
    output logic [5:0] data_out, // 6 bits per subcarrier
    // Control signals
    input logic [8:0] cap, // capacity of data
    input logic [2:0] bpsc, // 1, 2, 4, 6 bits/subcarrier
    input logic clear,
    output logic full
    );
    
    logic [287:0] data; // Data queue
    logic [8:0] counter; // Data counter(indicate full or not)
    
    assign full = (counter == cap) ? 1:0;
    
//    initial begin
//        data = 0;
//        counter = 0;
//    end
    
    always_ff @(posedge clk) begin
        if(reset) begin
            data <= 0;
            counter <= 0;
        end
        else if(clear) begin
            counter <= 0;
        end
        else if(wr_en) begin
            data[wr_addr] <= data_in;
            counter <= counter + 1;
        end
        else if(rd_en && full) begin
            case(bpsc)
                3'd1:
                    data_out <= {5'd0, data[rd_addr]};
                3'd2:
                    data_out <= {4'd0, data[bpsc*rd_addr +: 1]};
                3'd4:
                    data_out <= {2'd0, data[bpsc*rd_addr +: 3]};
                3'd6:
                    data_out <= data[bpsc*rd_addr +: 5];
                default:
                    data_out <= 6'd0;
            endcase
        end
    end
endmodule
