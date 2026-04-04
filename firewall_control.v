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
    output  [47:0] IP_address,
    input   [8:0]  ID_mem,
    input   done_check,
    input   valid_IP,
    input   done,
    output  end_packet,
    output  [7:0]  user_ID,
    output  [7:0]  data_o,
    output  valid_o,
    output  last_o,
    output  write_fifo,
    output  read_fifo,
    output  drop,
    output  [9:0] data_i_fifo,
    input  [9:0] data_o_fifo,
    output  search
    );
    
    reg  search_r;
    reg  drop_r;
    reg  write_fifo_r;
    reg  read_fifo_r;
    
    reg  [7:0]  user_ID_r;
    reg  [7:0]  data_o_r;
    reg  valid_o_r;
    reg  last_o_r;
    reg  [10:0]  counter;
    reg  [10:0]  counter_1;
    reg  [10:0]  counter_2;
    
    reg [9:0] data_i_fifo_r;
    reg [47:0] IP_address_r;
    reg [2:0] count_byte;

    
    //Counter signal to detect byte IP source
    always @(posedge clk) begin
        if (~rstn) begin
            counter     <= 0;
        end
        else begin
            if (valid) begin
                if (last) begin
                    counter <= 0;
                end
                else begin
                    counter <= counter + 1;
                end
            end
        end
    end
    
    //Extract IP address from packet
    always @(posedge clk) begin
        if (~rstn) begin
            IP_address_r <= 0;
            count_byte   <= 0;
        end
        else begin
            if (valid && counter >= 6 && counter <=11) begin
                IP_address_r <= {data, IP_address_r[47:8]};
            end
        end
    end
    
    //Search signal
    always @(posedge clk) begin
        if (~rstn) begin
            search_r <= 0;
        end
        else begin
            if (counter == 11) begin
                search_r <= 1;
            end
            else if (done) begin
                search_r <= 0;
            end
        end
    end
    
    //Drop for FIFO
    always @(posedge clk) begin
        if (~rstn) begin
            drop_r <= 0;
        end
        else begin
            if (done && ~valid_IP) begin
                drop_r <= 1;
            end
            else if (done && valid_IP) begin
                drop_r <= 0;
            end
            if (data_o_fifo[9]) begin
                drop_r <= 0;
            end
        end
    end
    
    //Write FIFO
    always @(posedge clk) begin
        if (~rstn) begin
            write_fifo_r <= 0;
            data_i_fifo_r <= 0;
        end
        else begin
            write_fifo_r  <= valid;
            data_i_fifo_r <= {last, valid, data};
        end
    end
    
    //Read FIFO
    always @(posedge clk) begin
        if (~rstn) begin
            read_fifo_r <= 0;
        end
        else begin
            if (done && valid_IP) begin
                read_fifo_r <= 1;
            end
            if (data_o_fifo[9]) begin
                read_fifo_r <= 0;
            end
        end
    end
    
    //Gen output
    always @(posedge clk) begin
        if (~rstn) begin
            data_o_r    <= 0;
            valid_o_r   <= 0;
            last_o_r    <= 0;
            user_ID_r   <= 0;
        end
        else begin
            valid_o_r <= data_o_fifo[8];
            last_o_r  <= data_o_fifo[9];
            data_o_r  <= data_o_fifo[7:0];
            user_ID_r <= ID_mem;
        end
    end
    
    assign user_ID = user_ID_r;
    assign data_o = data_o_r;
    assign valid_o = valid_o_r;
    assign last_o = last_o_r;
    assign search = search_r;
    assign drop = drop_r;
    assign write_fifo = write_fifo_r;
    assign read_fifo = read_fifo_r;
    assign data_i_fifo = data_i_fifo_r;
    assign IP_address = IP_address_r;
    assign end_packet = last_o_r;
endmodule
