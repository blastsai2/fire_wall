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
    input   [8:0]  ID_mem,
    input   done_check,
    output  [7:0]  user_ID,
    output  [7:0]  data_o,
    output  valid_o,
    output  last_o,
    output  [10:0] number_byte;
    );
    
    wire valid_ID;
    reg  [7:0]  data_1;
    reg  [7:0]  data_2;
    reg  valid_1;
    reg  valid_2;
    reg  last_1;
    reg  last_2;
    
    reg  [7:0]  user_ID_r;
    reg  [7:0]  data_o_r;
    reg  valid_o_r;
    reg  last_o_r;
    reg  [10:0]  counter;
    reg  [10:0]  counter_1;
    reg  [10:0]  counter_2;
    
    //Set delay signal
    always @(posedge clk) begin
        if (~rstn) begin
            data_1 <= 0;
            data_2 <= 0;
            counter_1 <= 0;
            counter_2 <= 0;
            valid_1 <= 0;
            valid_2 <= 0;
            last_1 <= 0;
            last_2 <= 0;
        end 
        else begin
            data_1 <= data;
            data_2 <= data_1;
            counter_1 <= counter;
            counter_2 <= counter_1;
            valid_1 <= valid;
            valid_2 <= valid_1;
            last_1 <= last;
            last_2 <= last_1;
        end
    end
    
    //Counter signal to detect byte IP source
    always @(posedge clk) begin
        if (~rstn) begin
            counter     <= 0;
        end
        else begin
            if (valid) begin
                counter <= counter + 1;
            end
            else begin
                counter <= 0;
            end
        end
    end
    
    assign valid_ID = (counter == 2) ? ((counter == 2) && (ID_mem != 9'h1ff)) : valid_ID; //signal valid for dectect byte IP source
    //Check valid for IP source and gen output
    always @(posedge clk) begin
        if (~rstn) begin
            data_o_r    <= 0;
            valid_o_r   <= 0;
            last_o_r    <= 0;
            user_ID_r   <= 0;
        end
        else begin
            valid_o_r <= 0;
            last_o_r  <= 0;
            
            if (valid_ID && valid_2) begin
                user_ID_r <= ID_mem[7:0];
                valid_o_r   <= valid_2;
                last_o_r    <= last_2;
                if (counter_2 != 1) begin
                    data_o_r    <= data_2;
                end
                else begin
                    data_o_r    <= 0;
                end
            end
        end
    end
    
    assign user_ID = user_ID_r;
    assign data_o = data_o_r;
    assign valid_o = valid_o_r;
    assign last_o = last_o_r;
    assign number_byte = counter;
endmodule
