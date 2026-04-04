`timescale 1ns / 1ps

module fifo(
   input    clk, 
   input    rstn, 
   input    drop,
   input    wr_en,
   input    rd_en, 
   input    [9:0] din, 
   output   reg [9:0] dout, 
   output   full, 
   output   empty 
);
   reg [9:0] mem [63:0]; 
   reg [5:0] wptr; 
   reg [5:0] rptr; 
   reg [6:0] count;
   always @(posedge clk or negedge rstn) begin
       if (!rstn || drop) begin
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
           else begin
               dout <= 0;
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
   assign full = (count == 64); 
   assign empty = (count == 0); 
endmodule