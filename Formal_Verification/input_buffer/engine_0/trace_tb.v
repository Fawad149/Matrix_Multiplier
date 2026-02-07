`ifndef VERILATOR
module testbench;
  reg [4095:0] vcdfile;
  reg clock;
`else
module testbench(input clock, output reg genclock);
  initial genclock = 1;
`endif
  reg genclock = 1;
  reg [31:0] cycle = 0;
  wire [0:0] PI_clk = clock;
  reg [0:0] PI_rst;
  reg [4:0] PI_rd_addr;
  reg [7:0] PI_wr_data;
  reg [0:0] PI_wr_en;
  reg [0:0] PI_comp_en;
  reg [4:0] PI_wr_addr;
  input_buffer UUT (
    .clk(PI_clk),
    .rst(PI_rst),
    .rd_addr(PI_rd_addr),
    .wr_data(PI_wr_data),
    .wr_en(PI_wr_en),
    .comp_en(PI_comp_en),
    .wr_addr(PI_wr_addr)
  );
`ifndef VERILATOR
  initial begin
    if ($value$plusargs("vcd=%s", vcdfile)) begin
      $dumpfile(vcdfile);
      $dumpvars(0, testbench);
    end
    #5 clock = 0;
    while (genclock) begin
      #5 clock = 0;
      #5 clock = 1;
    end
  end
`endif
  initial begin
`ifndef VERILATOR
    #1;
`endif
    // UUT.$auto$async2sync.\cc:107:execute$582  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$588  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$594  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$600  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$606  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$612  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$618  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$624  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$630  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$636  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$642  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$648  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$654  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$660  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$666  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$672  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$678  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$684  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$690  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$696  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$702  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$708  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$714  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$720  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$726  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$732  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$738  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$744  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$750  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$756  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$762  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$768  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$774  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$780  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$786  = 1'b0;
    // UUT.$auto$async2sync.\cc:116:execute$586  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$592  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$598  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$604  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$610  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$616  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$622  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$628  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$634  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$640  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$646  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$652  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$658  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$664  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$670  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$676  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$682  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$688  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$694  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$700  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$706  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$712  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$718  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$724  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$730  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$736  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$742  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$748  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$754  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$760  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$766  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$772  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$778  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$784  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$790  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$796  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$802  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$808  = 1'b1;
    UUT._witness_.anyinit_procdff_503 = 1'b0;
    UUT._witness_.anyinit_procdff_504 = 8'b10000000;
    UUT._witness_.anyinit_procdff_505 = 1'b0;
    UUT._witness_.anyinit_procdff_506 = 8'b10000000;
    UUT._witness_.anyinit_procdff_507 = 1'b0;
    UUT._witness_.anyinit_procdff_508 = 8'b10000000;
    UUT._witness_.anyinit_procdff_509 = 1'b0;
    UUT._witness_.anyinit_procdff_510 = 8'b10000000;
    UUT._witness_.anyinit_procdff_511 = 1'b0;
    UUT._witness_.anyinit_procdff_512 = 8'b10000000;
    UUT._witness_.anyinit_procdff_513 = 1'b0;
    UUT._witness_.anyinit_procdff_514 = 8'b10000000;
    UUT._witness_.anyinit_procdff_515 = 1'b0;
    UUT._witness_.anyinit_procdff_516 = 8'b00000000;
    UUT._witness_.anyinit_procdff_517 = 1'b0;
    UUT._witness_.anyinit_procdff_518 = 8'b10000000;
    UUT._witness_.anyinit_procdff_519 = 1'b0;
    UUT._witness_.anyinit_procdff_520 = 8'b10000000;
    UUT._witness_.anyinit_procdff_521 = 1'b0;
    UUT._witness_.anyinit_procdff_522 = 8'b10000000;
    UUT._witness_.anyinit_procdff_523 = 1'b0;
    UUT._witness_.anyinit_procdff_524 = 8'b10000000;
    UUT._witness_.anyinit_procdff_525 = 1'b0;
    UUT._witness_.anyinit_procdff_526 = 8'b10000000;
    UUT._witness_.anyinit_procdff_527 = 1'b0;
    UUT._witness_.anyinit_procdff_528 = 8'b10000000;
    UUT._witness_.anyinit_procdff_529 = 1'b0;
    UUT._witness_.anyinit_procdff_530 = 8'b10000000;
    UUT._witness_.anyinit_procdff_531 = 1'b0;
    UUT._witness_.anyinit_procdff_532 = 8'b10000000;
    UUT._witness_.anyinit_procdff_533 = 1'b0;
    UUT._witness_.anyinit_procdff_534 = 8'b00000000;
    UUT._witness_.anyinit_procdff_535 = 1'b0;
    UUT._witness_.anyinit_procdff_536 = 8'b10000000;
    UUT._witness_.anyinit_procdff_537 = 1'b0;
    UUT._witness_.anyinit_procdff_538 = 8'b10000000;
    UUT._witness_.anyinit_procdff_539 = 1'b0;
    UUT._witness_.anyinit_procdff_540 = 8'b10000000;
    UUT._witness_.anyinit_procdff_541 = 1'b0;
    UUT._witness_.anyinit_procdff_542 = 8'b10000000;
    UUT._witness_.anyinit_procdff_543 = 1'b0;
    UUT._witness_.anyinit_procdff_544 = 8'b10000000;
    UUT._witness_.anyinit_procdff_545 = 1'b0;
    UUT._witness_.anyinit_procdff_546 = 8'b10000000;
    UUT._witness_.anyinit_procdff_547 = 1'b0;
    UUT._witness_.anyinit_procdff_548 = 8'b10000000;
    UUT._witness_.anyinit_procdff_549 = 1'b0;
    UUT._witness_.anyinit_procdff_550 = 8'b10000000;
    UUT._witness_.anyinit_procdff_551 = 1'b0;
    UUT._witness_.anyinit_procdff_552 = 8'b10000000;
    UUT._witness_.anyinit_procdff_553 = 1'b0;
    UUT._witness_.anyinit_procdff_554 = 8'b10000000;
    UUT._witness_.anyinit_procdff_555 = 1'b0;
    UUT._witness_.anyinit_procdff_556 = 8'b10000000;
    UUT._witness_.anyinit_procdff_557 = 1'b0;
    UUT._witness_.anyinit_procdff_558 = 8'b10000000;
    UUT._witness_.anyinit_procdff_559 = 1'b0;
    UUT._witness_.anyinit_procdff_560 = 8'b10000000;
    UUT._witness_.anyinit_procdff_561 = 1'b0;
    UUT._witness_.anyinit_procdff_562 = 8'b10000000;
    UUT._witness_.anyinit_procdff_563 = 1'b0;
    UUT._witness_.anyinit_procdff_564 = 8'b00000000;
    UUT._witness_.anyinit_procdff_565 = 1'b0;
    UUT._witness_.anyinit_procdff_566 = 8'b00000000;
    UUT._witness_.anyinit_procdff_567 = 1'b0;
    UUT._witness_.anyinit_procdff_568 = 5'b10000;
    UUT._witness_.anyinit_procdff_569 = 8'b10000000;
    UUT.f_past_valid = 1'b0;
    UUT.mem[5'b11111] = 8'b00000000;
    UUT.mem[5'b11110] = 8'b00000000;
    UUT.mem[5'b11101] = 8'b00000000;
    UUT.mem[5'b11100] = 8'b00000000;
    UUT.mem[5'b11011] = 8'b00000000;
    UUT.mem[5'b11010] = 8'b00000000;
    UUT.mem[5'b11001] = 8'b10000000;
    UUT.mem[5'b11000] = 8'b10101111;
    UUT.mem[5'b10111] = 8'b00000000;
    UUT.mem[5'b10110] = 8'b00000000;
    UUT.mem[5'b10101] = 8'b00000000;
    UUT.mem[5'b10100] = 8'b00000000;
    UUT.mem[5'b10011] = 8'b11111111;
    UUT.mem[5'b10010] = 8'b11111111;
    UUT.mem[5'b10001] = 8'b01111111;
    UUT.mem[5'b10000] = 8'b10111111;
    UUT.mem[5'b01111] = 8'b00000000;
    UUT.mem[5'b01110] = 8'b00000000;
    UUT.mem[5'b01101] = 8'b00000000;
    UUT.mem[5'b01100] = 8'b00000000;
    UUT.mem[5'b01011] = 8'b00000000;
    UUT.mem[5'b01010] = 8'b00000000;
    UUT.mem[5'b01001] = 8'b00000000;
    UUT.mem[5'b01000] = 8'b00101111;
    UUT.mem[5'b00111] = 8'b00000000;
    UUT.mem[5'b00110] = 8'b00000000;
    UUT.mem[5'b00101] = 8'b00000000;
    UUT.mem[5'b00100] = 8'b00000000;
    UUT.mem[5'b00011] = 8'b00000000;
    UUT.mem[5'b00010] = 8'b00000000;
    UUT.mem[5'b00001] = 8'b10000000;
    UUT.mem[5'b00000] = 8'b10000000;

    // state 0
    PI_rst = 1'b1;
    PI_rd_addr = 5'b11000;
    PI_wr_data = 8'b01100000;
    PI_wr_en = 1'b0;
    PI_comp_en = 1'b0;
    PI_wr_addr = 5'b00000;
  end
  always @(posedge clock) begin
    // state 1
    if (cycle == 0) begin
      PI_rst <= 1'b0;
      PI_rd_addr <= 5'b10000;
      PI_wr_data <= 8'b00000000;
      PI_wr_en <= 1'b0;
      PI_comp_en <= 1'b1;
      PI_wr_addr <= 5'b00000;
    end

    // state 2
    if (cycle == 1) begin
      PI_rst <= 1'b0;
      PI_rd_addr <= 5'b00000;
      PI_wr_data <= 8'b00000000;
      PI_wr_en <= 1'b0;
      PI_comp_en <= 1'b0;
      PI_wr_addr <= 5'b00000;
    end

    genclock <= cycle < 2;
    cycle <= cycle + 1;
  end
endmodule
