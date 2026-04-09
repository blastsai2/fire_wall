`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/01/2026 11:32:48 AM
// Design Name: 
// Module Name: testmem
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


module testmem(
    input   clk,
    input   [9:0] addr,
    input   [15:0] data_i,
    output  [15:0] data_o,
    output  [15:0] data_o_o
    );
    
    reg [15:0] data_o_1; 
    reg [15:0] data_o_2; 
    reg [30:0] i = 0;
    
    reg [15:0] mem [10485760:0];
    always @(posedge clk) begin
        if (i <= 10485760) begin
            mem[i] <= data_i;
            data_o_1 <= mem[addr];
            data_o_2 <= mem[addr+1];
            i <= i + 1;
        end
        else begin
            i <= 0;
        end
    end
    assign data_o = data_o_1;
    assign data_o_o = data_o_2;
endmodule
