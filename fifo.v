`timescale 1ns / 1ps

module fifo #(
    parameter WIDTH = 3,
    parameter DEPTH = 8
)
(
   input    clk, 
   input    rstn, 
   input    wr_en,
   input    rd_en, 
   input    [WIDTH - 1 : 0]     din, 
   output   reg [WIDTH - 1 : 0] dout, 
   output   full, 
   output   empty 
);
   reg [WIDTH - 1 : 0]          mem [DEPTH - 1 : 0]; 
   reg [$clog2(DEPTH) - 1 : 0]  wptr; 
   reg [$clog2(DEPTH) - 1 : 0]  rptr; 
   reg [$clog2(DEPTH) : 0]      count;
   always @(posedge clk or negedge rstn) begin
       if (!rstn) begin
           wptr <= 0;
           rptr <= 0;
           count <= 0;
       end else begin
           if (wr_en && !full) begin
               mem[wptr] <= din; 
               wptr <= wptr + 1; 
           end
           if (rd_en && !empty) begin
               dout <= mem[rptr]; 
               rptr <= rptr + 1; 
           end
           
           if (wr_en && !full) begin
                if (rd_en && !empty) begin
                    count <= count;
                end
                else begin
                    count <= count + 1;
                end
           end
           else if (rd_en && !empty) begin
                count <= count - 1;
           end
       end
   end
   assign full = (count == DEPTH); 
   assign empty = (count == 0); 
endmodule