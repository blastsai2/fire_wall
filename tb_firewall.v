`timescale 1ns/1ps

module tb_firewall;

reg clk;
reg rstn;

// APB
reg psel;
reg penable;
reg pwrite;
reg [31:0] paddr;
reg [31:0] pwdata;
wire [31:0] prdata;
wire pready;
wire [31:0] pslverr;

// Stream input
reg [7:0] data;
reg valid;
reg last;

// Output
wire [7:0] data_o;
wire valid_o;
wire last_o;
wire [7:0] user_id;

reg [7:0] pkt [0:63];
integer i;

// DUT
firewall dut (
    .pclk(clk),
    .presetn(rstn),
    .psel(psel),
    .penable(penable),
    .paddr(paddr),
    .pwrite(pwrite),
    .pwdata(pwdata),
    .prdata(prdata),
    .pready(pready),
    .pslverr(pslverr),

    .data(data),
    .valid(valid),
    .last(last),
    .data_o(data_o),
    .valid_o(valid_o),
    .last_o(last_o),
    .user_id(user_id)
);

//////////////////////
// Clock
//////////////////////
always #5 clk = ~clk;

//////////////////////
// APB write task
//////////////////////
task apb_write(input [7:0] addr, input [31:0] data_in);
begin
    @(posedge clk);
    #1
    psel    = 1;
    pwrite  = 1;
    paddr   = addr;
    pwdata  = data_in;
    penable = 0;

    @(posedge clk);
    #1
    penable = 1;

    wait (pready == 1);
    @(posedge clk);
    #1
    psel    = 0;
    penable = 0;
end
endtask

task send_packet;
begin
    @(posedge clk);
    valid = 1;
    last  = 0;

    for (i = 0; i < 64; i = i + 1) begin
        data = pkt[i];
        if (i == 63) last = 1;
        @(posedge clk);
    end

    valid = 0;
    last  = 0;
end
endtask

task gen_packet(input [47:0] ip_byte);
begin
    for (i = 0; i < 64; i = i + 1) begin
        pkt[i] = $random;
    end

    pkt[6] = ip_byte[7:0];
    pkt[7] = ip_byte[15:8];
    pkt[8] = ip_byte[23:16];
    pkt[9] = ip_byte[31:24];
    pkt[10] = ip_byte[39:32];
    pkt[11] = ip_byte[47:40];
end
endtask

initial begin
    clk = 0;
    rstn = 0;

    psel = 0;
    penable = 0;
    pwrite = 0;
    paddr = 0;
    pwdata = 0;

    data = 0;
    valid = 0;
    last = 0;

    #20;
    rstn = 1;
    #3000

    // CONFIG
    apb_write(8'h00, 32'd255); 
    apb_write(8'h04, 32'hCCDD1232);
    apb_write(8'h08, 32'hAABB);
    
    apb_write(8'h00, 32'd250); 
    apb_write(8'h04, 32'hFFFFFFFF);
    apb_write(8'h08, 32'hFFFF);
    
    apb_write(8'h00, 32'd0); 
    apb_write(8'h04, 32'h01234567);
    apb_write(8'h08, 32'hABCD);
    
    apb_write(8'h00, 32'd10); 
    apb_write(8'h04, 32'h256712312);
    apb_write(8'h08, 32'hAABB);

    // TEST 1: valid
    gen_packet(48'hAABBCCDD1232);
    send_packet();

    #100;
    
    // TEST 3
    gen_packet(48'hAAAAAAAAAAAA);
    send_packet();
    
    #100;

    // TEST 2: invalid
    gen_packet(48'hFFFFFFFFFFFF);
    send_packet();


    #1000;

    $stop;
end

endmodule