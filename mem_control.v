`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/23/2026 10:47:48 AM
// Design Name: 
// Module Name: mem_control
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


module mem_control(
    input   clk,
    input   rstn,
    
    //APB signal
    input   [31 : 0]    wr_data_apb,
    input   [31 : 0]    wr_addr_apb,
    input   wr_en_apb,
    output  ready_apb,
//    input   [31 : 0]    rd_addr_apb,
//    output  [31 : 0]    rd_data_apb,
    
    //Firewall signal
    input   [47 : 0]    data_fw,
//    input   [7 : 0]     rd_addr_fw,
    input   search,
    output  [7 : 0]     user_ID,
    output  valid,
    output  done 
    );
    
    reg [4 : 0]     wr_mem_apb_addr_curr;
    wire [4 : 0]     rd_mem_apb_addr_curr;
    wire [2 : 0]     index_mem_reg_apb_curr;
    reg [383 : 0]   wr_mem_apb_data_curr;
    wire [47 : 0]    wr_IP_curr;
    reg wr_mem_apb_en_curr;
    reg rd_mem_apb_en_curr;
    
    reg [4 : 0]     rd_mem_apb_addr_nxt;
    reg [2 : 0]     index_mem_reg_apb_nxt;
    reg [383 : 0]   wr_mem_apb_data_nxt;
    reg [47 : 0]    wr_IP_nxt;
    
    reg [4 : 0]     rd_mem_fw_addr;
    reg [2 : 0]     index_mem_reg_fw;
    reg rd_mem_fw_en;
    
    wire [4 : 0]     wr_mem_addr;
    wire [4 : 0]     rd_mem_addr;
    wire [2 : 0]     index_mem_reg;
    wire [383 : 0]   wr_mem_data;
    wire [47 : 0]    wr_IP;
    wire [383 : 0]   rd_mem_data;
    wire wr_mem_en;
    wire rd_mem_en;
    
    reg wr_en_fifo;
    reg rd_en_fifo;
    wire fifo_empty;
    
    reg ready_apb_r;
    
    reg [7 : 0] user_ID_r;
    reg valid_r;
    reg done_r;
    integer i;
    
    reg [3 : 0] state;
    localparam IDLE             = 4'b000; 
    localparam WRITE_APB        = 4'b001; 
    localparam READ_MEM         = 4'b010; 
    localparam WRITE_MEM        = 4'b011; 
    localparam WAIT_WMEM        = 4'b100; 
    localparam WAIT_RMEM_APB    = 4'b101; 
    localparam SEARCH           = 4'b110; 
    localparam WAIT_RMEM_FW     = 4'b110; 
    localparam FIFO             = 4'b111; 
    localparam WAIT_FIFO        = 4'b1000;
    localparam DONE             = 4'b1001; 
    
    
    always @(posedge clk) begin
        if (~rstn) begin
            state  <= IDLE;
          
            index_mem_reg_apb_nxt <= 0;
            wr_mem_apb_addr_curr  <= 0;
            rd_mem_apb_addr_nxt   <= 0;
            wr_IP_nxt              <= 0;
            wr_mem_apb_en_curr  <= 0;
            ready_apb_r         <= 0;
            wr_mem_apb_data_curr<= 0;
            
            ready_apb_r <= 1;
            rd_mem_fw_addr <= 0;
            rd_mem_fw_en   <= 0;
            

            valid_r <= 0;
            done_r <= 0;
        end
        else begin
            case (state)
            
            IDLE: begin
                ready_apb_r <= 1;
                if (search) begin
                    state               <= SEARCH;
                    rd_mem_fw_addr      <= 0;
                    rd_mem_fw_en        <= 1;
                end
                else if (~fifo_empty) begin
//                    rd_en_fifo      <= 1;
                    state           <= FIFO;
                end
                else if (wr_en_apb) begin
//                    state           <= WRITE_APB;
                    case (wr_addr_apb[3:2])
                    2'b00: begin
                        index_mem_reg_apb_nxt   <= wr_data_apb[2 : 0];
                        wr_mem_apb_addr_curr    <= wr_data_apb >> 3;
                        rd_mem_apb_addr_nxt     <= wr_data_apb >> 3;
                        state                   <= IDLE;
                    end
                    2'b01: begin 
                        wr_IP_nxt[31 : 0]   <= wr_data_apb;
//                        state                   <= IDLE;
                    end
                    2'b10: begin 
                        state          <= FIFO;
                    end
//                    default: state  <= IDLE;
                    endcase
                    end
            end        
            
            WRITE_APB: begin
                ready_apb_r <= 0;
                
            end
            
            WAIT_RMEM_APB : begin
                ready_apb_r   <= 0;
                state         <= WRITE_MEM;
            end
            
            WRITE_MEM: begin
                wr_mem_apb_en_curr      <= 1;
                ready_apb_r             <= 1;
                wr_mem_apb_data_curr    <= (wr_IP_curr << (index_mem_reg_apb_curr*48));
                state                   <= IDLE;
            end
            
            WAIT_RMEM_FW: begin
                state       <= SEARCH;
            end
            
            SEARCH: begin
                valid_r <= 0;
                done_r  <= 0;
        
                // check 8 entries trong 1 row
                for (i = 0; i < 8; i = i + 1) begin
                    if (data_fw == rd_mem_data[i*48 +: 48]) begin
                        user_ID_r <= (rd_mem_addr << 3) + i;
                        valid_r <= 1;
                        done_r  <= 1;
                        state   <= DONE;
                    end
                end
        
                // nếu chưa match thì sang row tiếp
                if (rd_mem_addr == 8'd31) begin
                    state <= DONE;   // không tìm thấy
                    done_r <= 1;
                end 
                else begin
                    rd_mem_fw_addr <= rd_mem_fw_addr + 1;
                end
            end

            DONE:
            begin
                valid_r <= 0;
                state <= IDLE;
                done_r <= 0;
            end
            
            FIFO: begin
                ready_apb_r <= 0;
                rd_en_fifo  <= 1;
                state       <= WAIT_FIFO;          
            end
            
            WAIT_FIFO: begin
                rd_en_fifo  <= 0;
                rd_mem_apb_en_curr  <= 1;
                state               <= WAIT_RMEM_APB;
            end
            
            endcase
        end
    end
    

    fifo #(
        .WIDTH(56),
        .DEPTH(32)
    ) apb_IP_config_fifo (
        .clk(clk),                     
        .rstn(rstn),                                     
        .wr_en(wr_en_apb && wr_addr_apb[3:2] == 2'b10),                   
        .rd_en(rd_en_fifo),                   
        .din({rd_mem_apb_addr_nxt, index_mem_reg_apb_nxt, wr_IP_nxt[31 : 0], wr_data_apb[15:0]}),
        .dout({rd_mem_apb_addr_curr, index_mem_reg_apb_curr, wr_IP_curr}),
        .full(),                    
        .empty(fifo_empty)                     
    );
    
    mem #(
        .WIDTH(384),
        .DEPTH(32)
    ) mem_IP_config
    (
        .clk(clk),
        .wr_en(wr_mem_en),
        .wr_data(wr_mem_data),
        .wr_addr(wr_mem_addr),
        .rd_en(rd_mem_en),
        .rd_data(rd_mem_data),
        .rd_addr(rd_mem_addr)
    );
    
    assign rd_mem_addr = search ? rd_mem_fw_addr : rd_mem_apb_addr_curr;
    assign wr_mem_addr = wr_mem_apb_addr_curr;
    assign wr_mem_data = wr_mem_apb_data_curr;
    assign rd_mem_en   = search ? rd_mem_fw_en : rd_mem_apb_en_curr;
    assign wr_mem_en   = wr_mem_apb_en_curr;
    assign ready_apb   = ready_apb_r;
    
    
endmodule
