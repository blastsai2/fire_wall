`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/14/2026 08:16:56 AM
// Design Name: 
// Module Name: firewall
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


module firewall(
    input           pclk,
    input           presetn,
    input           psel,
    input           penable,
    input   [31:0]  paddr,
    input           pwrite,
    input   [31:0]  pwdata,
    output  [31:0]  prdata,
    output          pready,
    output  [31:0]  pslverr,  
    
     
    input   [7:0]   data,
    input           valid,
    input           last,
    output  [7:0]   data_o,
    output          valid_o,
    output          last_o,
    output  [7:0]   user_id
    );
    
    wire [7:0]  prdata_w;
    wire ready_w;
    wire write_w;
    wire read_w;
    wire [8:0]   ID_mem; 
    
    wire [47:0] IP_address;
    wire search;
    wire drop;
    wire write_fifo;
    wire read_fifo;

    wire [9:0] data_i_fifo;
    wire [9:0] data_o_fifo;

    wire [8:0] ID_mem;
    wire done;
    wire valid_IP;
    
    wire [7:0]  user_id_w;
    wire valid_o_w;
    
    apb_controller u_apb_ctrl (
        .pclk(pclk),  
        .presetn(presetn),
        .psel(psel),   
        .penable(penable),
        .paddr(paddr),  
        .pwrite(pwrite), 
        .pwdata(pwdata), 
        .pready(ready_w), 
        .pslverr(pslverr),
        .write(write_w),
        .read(read_w)
    );
    
    firewall_control u_firewall_control(
        .clk(pclk),           
        .rstn(presetn),          
        .valid(valid),         
        .last(last),          
        .data(data),

        .IP_address(IP_address),

        .ID_mem(ID_mem),
        .done(done),
        .valid_IP(valid_IP),

        .user_ID(user_id_w),

        .data_o(data_o), 
        .valid_o(valid_o_w),   
        .last_o(last_o),

        .write_fifo(write_fifo),
        .read_fifo(read_fifo),
        .drop(drop),

        .data_i_fifo(data_i_fifo),
        .data_o_fifo(data_o_fifo),

        .search(search)            
    );
    
    fifo #(
        .WIDTH(10),
        .DEPTH(64)
    ) u_fifo
    (
        .clk(pclk),
        .rstn(presetn),

        .wr_en(valid),
        .rd_en(read_fifo),

        .din({last, valid, data}),
        .dout(data_o_fifo),

//        .din(data_i_fifo),
//        .dout(write_fifo),

        .full(),
        .empty()
    );
    
    mem_control u_mem_control(
        .clk(pclk),
        .rstn(presetn),

        .wr_addr_apb(paddr[7:0]),
        .wr_data_apb(pwdata),
        .wr_en_apb(write_w),
        .ready_apb(ready_w),

        .search(search),
        .user_ID(ID_mem),
        .data_fw(IP_address),

        .done(done),
        .valid(valid_IP)
    );
    
    counter_data u_counter_data (
        .clk(pclk),
        .rstn(presetn),
        .wr_en(valid_o_w),
        .wr_addr(user_id_w)
    );
    
    assign prdata = {24'b0, prdata_w};
    assign valid_o = valid_o_w;
    assign user_id = user_id_w;
    assign pready  = ready_w;
endmodule
