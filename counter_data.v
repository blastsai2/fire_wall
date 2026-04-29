`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/16/2026 04:55:29 PM
// Design Name: 
// Module Name: counter_data
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


module counter_data 
(
    input   clk,
    input   rstn,
    input   wr_en,
    input   [7:0]   wr_addr,
    input   rd_en,
    input   [7:0]   rd_addr,
    output  [31:0]  rd_data  
);
    
    reg [31:0] count_byte [255:0];
    reg resetting;
    integer i;
    
    reg [7:0] reset_cnt;
    
    
    reg [31:0]  rd_data_r;
    
    always @(posedge clk) begin
        if (~rstn) begin
            reset_cnt <= 0;
            resetting <= 1;
        end
        else if (resetting) begin     
            if (reset_cnt == 255) begin
                resetting <= 0;
                reset_cnt <= 0;
            end
            else begin
                reset_cnt <= reset_cnt + 1;
            end
                count_byte[reset_cnt] <= 0;
        end
    end
    
    always @(posedge clk) begin
        if (~resetting & rstn) begin
            if (wr_en) begin
                count_byte[wr_addr] <= count_byte[wr_addr] + 1;
            end
            if (rd_en) begin
                rd_data_r   <= count_byte[rd_addr];
            end
        end
    end
    
    assign rd_data = rd_data_r;
endmodule
