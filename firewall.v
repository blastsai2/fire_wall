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
    
    wire [7:0]  prdata_r;
    wire write_r;
    wire read_r;
    wire [8:0]   ID_mem; 
    
    apb_controller u_apb_ctrl (
        .pclk(pclk),  
        .presetn(presetn),
        .psel(psel),   
        .penable(penable),
        .paddr(paddr),  
        .pwrite(pwrite), 
        .pwdata(pwdata), 
        .pready(pready), 
        .pslverr(pslverr),
        .write(write_r),
        .read(read_r)
    );
    
    firewall_control u_firewall_control(
        .clk(pclk),           
        .rstn(presetn),          
        .valid(valid),         
        .last(last),          
        .data(data),   
        .ID_mem(ID_mem),        
        .user_ID(user_id),
        .data_o(data_o), 
        .valid_o(valid_o),   
        .last_o(last_o)              
    );
    
    mem_IP_source u_mem(
        .clk(pclk),                   
        .resetn(presetn),                
        .addr_i_apb(paddr[7:0]),     
        .data_i_apb(pwdata[8:0]),     
        .data_i_firewall(data),              
        .write(write_r),                 
        .read(read_r),                  
        .data_o_apb(prdata_r),     
        .data_o_firewall(ID_mem)                        
    );
    
    assign prdata = {24'b0, prdata_r};
endmodule
