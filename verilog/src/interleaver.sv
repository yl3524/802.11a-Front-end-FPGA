`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/24/2023 09:08:48 PM
// Design Name: 
// Module Name: interleaver
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


module interleaver(
    // Basic
    input  logic       reset,
    input  logic       clk,
    // Input A
    input  logic       wrA_en,
    input  logic       dataA_in,
    // Input B
    input  logic       wrB_en,
    input  logic       dataB_in,
    // Read ports
    input  logic       rd_en,
    input  logic [5:0] rd_addr,
    output logic [5:0] data_out, // 6-bit out
    // Control signal
    input  logic [8:0] cap,
    input  logic [2:0] bpsc, // 1, 2, 4, 6 bits/subcarrier
    input  logic       clear,
    output logic       full 
    );
    
    logic [287:0] data; // Data queue
    logic   [8:0] counter; // Data counter(indicate full or not) 

    logic   [1:0] bit_sel; // Combine both enable signals
    assign bit_sel = {wrB_en, wrA_en};

    logic   [8:0] cbps; // Coded bit per subcarrier
    assign cbps = 48 * {6'b0,bpsc};

    assign full = ( counter == cap  ) ? 1'b1 : 1'b0;

    // Main logic
    always_ff @(posedge clk) begin
        if(reset) begin 
            data <= 0;
            counter <= 0;
        end 
        else if (clear) counter <= 0;
        else if (bit_sel != 2'b0) begin
            case(bit_sel)
                2'b01: begin
                    data[wrA_addr] <= dataA_in;
                    counter <= counter + 1;
                end 
                2'b10: begin
                    data[wrB_addr] <= dataB_in;
                    counter <= counter + 1;
                end 
                2'b11: begin
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
        else if (rd_en && full) begin 
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
    
    // Adress generation logic
    logic   [8:0] s; // Used in address generation
    

    logic   [8:0] wrA_addr_i; // Intermidiate step of write address A
    logic   [8:0] wrB_addr_i; // Intermediate step of write address B
    logic   [8:0] wrA_addr; // Data A write address
    logic   [8:0] wrB_addr; // Data B write address
    
    assign wrA_addr_i = (cbps >> 4) * (counter % 16) + (counter >> 4);
    assign wrB_addr_i = (cbps >> 4) * ((counter + 1) % 16) + ((counter + 1) >> 4);
    assign s = ((bpsc >> 1) > 1) ? (bpsc >> 1) : 1;
    assign wrA_addr = s * (wrA_addr_i / s)  + ((wrA_addr_i + cbps - (((wrA_addr_i << 4) / cbps))) % s);
    assign wrB_addr = s * (wrB_addr_i / s)  + ((wrB_addr_i + cbps - (((wrB_addr_i << 4) / cbps))) % s);
    
    
endmodule
