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
    input   [10:0] number_byte,
    output  [7:0]  data_o_apb,
    output  [8:0]  data_o_firewall
    );
    
    reg [7:0]  mem_IP [255:0];
    reg        mem_valid [255:0];
    reg [7:0]  data_o_apb_r;
    reg [8:0]  data_o_firewall_r;
    reg [7:0]  user_ID;
    reg [7:0]  IP_addr;
    integer i;
    
    //APB write and read; firewall read mem
    always @(posedge clk) begin
        if (~resetn) begin
            data_o_apb_r        <= 0;
        end
        else begin
            data_o_apb_r    <= 0;
            
            if (write) begin
                case (paddr[3:2])
                    2'b00: user_ID <= data_i_apb;
                    2'b01: IP_addr <= data_i_apb;
                    2'b10: ;
                    2'b11: ;
                endcase
                mem_IP[user_ID] <= ID_addr;
            end
            else if (read) begin
                case (paddr[3:2])
                    2'b00: data_o_apb_r <= mem_IP[data_i_apb];
                    2'b01: ;
                    2'b10: ;
                    2'b11: ;
                endcase
            end
        end
    end

    //Search IP address
    always @(posedge clk) begin
        data_o_firewall_r   <= 0;
        if (number_byte == 2) begin
        
end
    end
    
    assign data_o_apb = data_o_apb_r;
    assign data_o_firewall = data_o_firewall_r;
    
endmodule
