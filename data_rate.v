`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2026 02:04:13 PM
// Design Name: 
// Module Name: data_rate
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


module data_rate #(
    parameter TICK = 1000
)
(
    input   clk,
    input   rstn,
    input   [31:0] data_rate,
    output  sample_en,
    output  user_id
);

    reg sample_en_r;
    reg user_id_r;
    reg [31:0]  window_time;
    reg [31:0]  data_rate_mem [255:0];
    
    always @(posedge clk) begin
        if (~rstn) begin
            window_time <= 0;
        end
        else begin
            if (window_time < TICK) begin
                window_time <= window_time + 1;
            end
            else begin
                window_time <= 0;
                sample_en_r <= 1;  
            end     
        end
    end
    
    always @(posedge clk) begin
        if (~rstn) begin
            user_id_r <= 0;
        end
        else begin
            if (sample_en) begin
                data_rate_mem[user_id] <= data_rate 
            end
        end
    end
endmodule
