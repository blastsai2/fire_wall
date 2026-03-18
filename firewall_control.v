`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/18/2026 02:47:42 PM
// Design Name: 
// Module Name: firewall_control
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


module firewall_control(
    input   clk,
    input   rstn,
    input   valid,
    input   last,
    input   [7:0]  data,
    input   [7:0]  ID_mem,
    input   done_check, 
    output  [7:0]  user_ID,
    output  [7:0]  data_o,
    output  valid_o,
    output  last_o
    );
    
    reg  [7:0]  user_ID_r;
    reg  [7:0]  data_o_r;
    reg  [23:0] fifo;
    reg  valid_o_r;
    reg  last_o_r;
    reg  [1:0]  counter;
    
    always @(posedge clk) begin
        if (~rstn) begin
            user_ID_r   <= 0;
            data_o_r    <= 0;
            valid_o_r   <= 0;
            last_o_r    <= 0;
            counter     <= 0;
        end
        else begin
            if (valid) begin
                counter <= counter + 1;
                fifo[counter] <= data;
            end
            if (done_check && ID_mem != {9{1'b1}}) begin
                user_ID_r   <= ID_mem;
                data_o_r    <= data_i;
            end
        end
    end
endmodule
