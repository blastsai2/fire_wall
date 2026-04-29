`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/14/2026 11:29:35 AM
// Design Name: 
// Module Name: apb_controller
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


module apb_controller(
    input           pclk,
    input           presetn,
    input           psel,
    input           penable,
    input   [31:0]  paddr,
    input           pwrite,
    input   [31:0]  pwdata,
    input           pready,
    output  [31:0]  pslverr,
    output  write,
    output  read
    );
    
    reg             pready_r;
    reg             pslverr_r;
    reg             write_r;
    reg             read_r;
    
    //Write read ready signal
//    always @(posedge pclk) begin
//        if (~presetn) begin
//            pready_r <= 0;
//        end
//        else begin
//            if ((psel == 1) && (penable == 1)) begin
//                pready_r <= 1;
//            end
//            else begin
//                pready_r <= 0;
//            end
//        end
//    end
    
    //Write data
    always @(posedge pclk) begin
        if (~presetn) begin
            write_r <= 0;
        end
        else begin
            if (psel && penable && pwrite) begin
                write_r   <= 1;   
            end
            else begin
                write_r   <= 0;
            end
        end
    end

    //
    
    //Slave error
    always @(posedge pclk) begin
        if (~presetn) begin
            pslverr_r <= 0;
        end
    end
    
    //Read data
    always @(posedge pclk) begin
        if (~presetn) begin
            read_r <= 0;
        end
        else begin
            if (psel && penable && ~pwrite) begin
                read_r      <= 1; 
            end
            else begin
                read_r      <= 0;
            end
        end
    end
    
    assign pslverr  = pslverr_r;
//    assign pready   = pready_r;
    assign write    = write_r;
    assign read     = read_r;
    
endmodule
