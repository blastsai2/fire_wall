`timescale 1ns / 1ps

module mem_IP_source(
    input           clk,
    input           resetn,

    // APB
    input    [7:0]  addr_i_apb,
    input    [31:0] data_i_apb,
    input           write,
    input           read,
    output   [7:0]  data_o_apb,

    // Firewall
    input    [47:0] data_i_firewall,
    input           search,
    input           end_packet,
    output   [8:0]  data_o_firewall,
    output   valid,
    output   done
    
);

    reg [383:0] mem_IP [31:0]; 
    reg [7:0] data_o_apb_r;
    reg [7:0] user_ID;
    reg [31:0] IP_addr_low;
    reg [15:0] IP_addr_high;
    reg done_r;

    //Mem control signal
    reg [47 : 0]    wr_mem_cfg_data_tmp;
    reg             wr_mem_cfg_en;
    reg             rd_mem_cfg_en;
    reg [31 : 0]    wr_mem_cfg_addr;
    reg [31 : 0]    rd_mem_cfg_addr;
    reg [391 : 0]   wr_mem_cfg_data;
    reg [391 : 0]   rd_mem_cfg_data;


    always @(posedge clk) begin
        if (~resetn) begin
            data_o_apb_r <= 0;
        end else begin
            data_o_apb_r <= 0;
            
                case (addr_i_apb[3:2])
                    2'b00: begin 
                        wr_mem_cfg_addr                 <= data_i_apb >> 3;
                        rd_mem_cfg_addr                 <= data_i_apb >> 3;
                    end
                    2'b01: wr_mem_cfg_data_tmp[31 : 0]  <= data_i_apb;
                    2'b10: begin 
                        wr_mem_cfg_data_tmp[47 : 32]    <= data_i_apb[15:0];
                        rd_mem_cfg_en                   <= 1;
                        state_apb_mem                   <= 1;
                    end
                    default: ;
                endcase

            else if (read) begin
                case (addr_i_apb[3:2])
//                    2'b00: data_o_apb_r <= user_ID;
//                    2'b01: data_o_apb_r <= IP_addr;
//                    2'b10: data_o_apb_r <= mem_IP[user_ID][7:0];
//                    default: data_o_apb_r <= 0;
                endcase
            end
        end
    end
    
//    mem

    assign data_o_apb = data_o_apb_r;

    reg [1:0] state;
    localparam IDLE   = 2'd0;
    localparam SEARCH = 2'd1;
    localparam DONE   = 2'd2;

    reg [7:0] i;
    reg [8:0] result;
    reg       valid_r;
    reg [3:0] k;

    always @(posedge clk) begin
        if (~resetn) begin
            state  <= IDLE;
            i      <= 0;
            result <= 0;
            valid_r <= 0;
            done_r <= 0;
        end else begin
            if (end_packet) begin
                done_r <= 0;
            end
        
            case (state)

            IDLE:
            begin
                valid_r <= 0;
                if (search) begin
                    i     <= 0;
                    state <= SEARCH;
                end
            end

            SEARCH: begin
                valid_r <= 0;
                done_r  <= 0;
        
                // check 8 entries trong 1 row
                for (k = 0; k < 8; k = k + 1) begin
                    if (data_i_firewall == mem_IP[i][k*48 +: 48]) begin
                        result  <= (i << 3) + k;   // i*8 + k
                        valid_r <= 1;
                        done_r  <= 1;
                        state   <= DONE;
                    end
                end
        
                // nếu chưa match thì sang row tiếp
                if (i == 8'd31) begin
                    state <= DONE;   // không tìm thấy
                    done_r <= 1;
                end 
                else begin
                    i <= i + 1;
                end
            end

            DONE:
            begin
                valid_r <= 0;
                state <= IDLE;
                done_r <= 0;
            end

            endcase
        end
    end

    reg [8:0] data_o_firewall_r;

    always @(posedge clk) begin
        if (~resetn) begin
            data_o_firewall_r <= 0;
        end else if (state == DONE && valid_r) begin
            data_o_firewall_r <= result;
        end
    end

    assign data_o_firewall = data_o_firewall_r;
    assign valid = valid_r;
    assign done = done_r;

endmodule