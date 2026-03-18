`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/18/2026 03:42:42 PM
// Design Name: 
// Module Name: process_packet
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


module process_packet(
    input   clk,
    input   rstn,
    input   valid,
    input   last,
    input   [7:0] data,
    output  [7:0] data_o,
    output  valid_o,
    output  last_o     
    );
    
    reg [7:0] data_o_r;
    reg [1:0] counter;
    reg valid_o_r;
    reg last_o_r;
    
    always @(posedge clk) begin
        if (~rstn) begin
            data_o_r    <= 0;
            counter     <= 0;
        end
        else begin
            if (valid) begin
                
                data_o_r    <= data_o;
            end
            else if (counter == 1) begin
                data_o_r    <= 0;
            end
            else begin
                
            end
        end
    end
endmodule
