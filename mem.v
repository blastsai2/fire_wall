`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/18/2026 11:18:00 AM
// Design Name: 
// Module Name: mem
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


module mem #(
    parameter WIDTH = 8,
    parameter DEPTH = 256
)
(
    input   clk,
    input   wr_en,
    input   [$clog2(DEPTH) - 1 : 0] wr_addr,
    input   [WIDTH - 1 : 0] wr_data,
    input   rd_en,
    input   [$clog2(DEPTH) - 1 : 0] rd_addr,
    output  [WIDTH - 1 : 0] rd_data
    );
    
    reg [WIDTH - 1 : 0] reg_mem [DEPTH - 1 : 0];
    reg [WIDTH - 1 : 0] rd_data_r;
    
//    integer i;
    
//    initial begin
//        for (i = 0; i < DEPTH; i = i + 1) begin
//            reg_mem[i] <= 0;
//        end
//    end
    
    always @(posedge clk) begin
        if (wr_en) begin
            reg_mem[wr_addr] <= wr_data;
        end
        if (rd_en) begin
            rd_data_r        <= reg_mem[rd_addr];
        end
    end
    
    assign rd_data = rd_data_r;
endmodule
