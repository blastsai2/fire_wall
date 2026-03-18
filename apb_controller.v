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
    output  [31:0]  prdata,
    output          pready,
    output  [31:0]  pslverr
    );
    
    reg             pready_r;
    reg     [31:0]  slv_reg_r [7:0];
    reg             pslverr_r;
    reg     [31:0]  prdata_r;
    reg     [31:0]  pwdata_r;
    reg     [31:0]  paddr_r;
    reg             pslverr_r;
    reg             write;
    reg             read;
    integer         i;
    
    //Write ready signal
    always @(posedge pclk) begin
        if (~presetn) begin
            pready_r <= 0;
            for (i = 0; i < 8; i = i + 1) begin
                slv_reg_r[i] <= 32'hffff;
            end
        end
        else begin
            if ((psel == 1) && (pwrite == 1) && (penable == 1)) begin
                pready_r <= 1;
            end
            else begin
                pready_r <= 0;
            end
        end
    end
    
    //Write data
    always @(posedge pclk) begin
        if (~presetn) begin
            for (i = 0; i < 8; i = i + 1) begin
                slv_reg_r[i] <= {32{1'b1}};
            end
        end
        else begin
            if (pready_r && psel && penable && pwrite) begin
                slv_reg_r[paddr] <= pwdata; 
                write            <= 1;
            end
            else begin
                write   <= 0;
            end
        end
    end
    
    //Slave error
    always @(posedge pclk) begin
        if (~presetn) begin
            pslverr_r <= 0;
        end
        else begin
            if (pready_r && psel && penable && pwrite && ~pslverr) begin
                pslverr_r   <= 0;
            end
        end
    end
    
    //Read ready signal
    always @(posedge pclk) begin
        if (~presetn) begin
            pready_r <= 0;
        end
        else begin
            if ((psel == 1) && (pwrite == 0) && (penable == 1)) begin
                pready_r <= 1;
            end
            else begin
                pready_r <= 0;
            end
        end
    end
    
    //Read data
    always @(posedge pclk) begin
        if (~presetn) begin
            prdata_r  <= 0;
        end
        else begin
            if (pready_r && psel && penable && ~pwrite) begin
                prdata_r    <= slv_reg_r[paddr]; 
                read        <= 1; 
            end
            else begin
                read    <= 0;
            end
        end
    end
    
    //Slave error
    always @(posedge pclk) begin
        if (~presetn) begin
            pslverr_r <= 0;
        end
        else begin
            if (pready_r && psel && penable && ~pwrite && ~pslverr) begin
                pslverr_r   <= 0;
            end
        end
    end
    
    assign prdata   = prdata_r;
    assign pslverr  = pslverr_r;
    assign pready   = pready_r;
    
endmodule
