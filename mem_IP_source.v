`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/18/2026 03:03:15 PM
// Design Name: 
// Module Name: mem_IP_source
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


module mem_IP_source(
    input   clk,
    input   resetn,
    input   [7:0]  addr_i_apb,
    input   [8:0]  data_i_apb,
    input   [7:0]  data_i_firewall,
    input   write,
    input   read,
    output  [7:0]  data_o_apb,
    output  [8:0]  data_o_firewall
    );
    
    reg [8:0]  mem_IP [255:0];
    reg        mem_valid [255:0];
    reg [7:0]  data_o_apb_r;
    reg [8:0]  data_o_firewall_r;
    integer i;
    
    //APB write and read; firewall read mem
    always @(posedge clk) begin
        if (~resetn) begin
            data_o_apb_r        <= 0;
            data_o_firewall_r   <= 0;
        end
        else begin
            data_o_apb_r    <= 0;
            
            if (write) begin
                mem_IP[addr_i_apb] <= data_i_apb;
            end
            else if (read) begin
                data_o_apb_r  <= mem_IP[addr_i_apb][7:0];
            end
            
            data_o_firewall_r <= mem_IP[data_i_firewall];
        end
    end
    
    assign data_o_apb = data_o_apb_r;
    assign data_o_firewall = data_o_firewall_r;
    
endmodule
