// Deterministic behavioural DRAM-model test: A, SW, B and wide W read ports.
module tb_sunnyone_dram;
  localparam int D=8, P=16, AB=8, WORDS=64, LAT=2;
  logic clk=0, rst=1, a_req=0, a_we=0, sw_req=0, b_req=0, b_tag=0, b_we=0, w_req=0, dump=0;
  logic [31:0] a_addr=0, sw_addr=0, b_addr=0, w_addr=0;
  logic [31:0] a_wdata=0;
  logic [3:0] a_be=0;
  logic [63:0] a_rdata;
  logic a_rvalid;
  logic [63:0] sw_wdata=0;
  logic [7:0] sw_be=0;
  logic [1:0] b_wmask=0;
  logic [63:0] b_wdata=0, b_rdata;
  logic b_rvalid, b_rtag;
  logic [127:0] w_rdata;
  logic w_rvalid, rd_idle;

  always #5 clk=~clk;
  otpu_dram #(.WORDS(WORDS),.D(D),.LAT(LAT),.P(P),.AB(AB),.CB(8),.AW(32),.SWW(2)) dut (
    .clk,.rst,.a_req,.a_we,.a_addr,.a_wdata,.a_be,.a_rvalid,.a_rdata,
    .sw_req,.sw_addr,.sw_wdata,.sw_be,
    .b_req,.b_tag,.b_we,.b_wmask,.b_wdata,.b_addr,.b_rvalid,.b_rtag,.b_rdata,
    .w_req,.w_addr,.w_rvalid,.w_rdata,.rd_idle,.dump
  );

  task automatic tick;
    @(posedge clk); #1;
  endtask
  task automatic fail(input string msg);
    $display("FAIL: %s",msg); $fatal(1);
  endtask
  task automatic wait_a;
    int n=0;
    while (!a_rvalid && n<8) begin tick(); n++; end
    if (!a_rvalid) fail("A read timeout");
  endtask
  task automatic wait_b;
    int n=0;
    while (!b_rvalid && n<8) begin tick(); n++; end
    if (!b_rvalid) fail("B read timeout");
  endtask
  task automatic wait_w;
    int n=0;
    while (!w_rvalid && n<8) begin tick(); n++; end
    if (!w_rvalid) fail("W read timeout");
  endtask

  initial begin
    repeat(3) tick(); rst=0; tick();
    // Port A full-word write, then byte-lane read.
    @(negedge clk); a_req=1; a_we=1; a_addr=4; a_wdata=32'h11223344; a_be=4'hf;
    tick(); @(negedge clk); a_req=0; a_we=0;
    a_req=1; tick(); wait_a();
    if (a_rdata[31:0] !== 32'h11223344) fail("A write/read mismatch");
    if (a_rdata[63:32] !== 0) fail("A adjacent word should initialise to zero");
    @(negedge clk); a_req=0;

    // Port A byte-enable preserves untouched bytes.
    @(negedge clk); a_req=1; a_we=1; a_addr=4; a_wdata=32'h00aa0000; a_be=4'b0010;
    tick(); @(negedge clk); a_req=0; a_we=0; a_be=0;
    a_req=1; tick(); wait_a();
    if (a_rdata[31:0] !== 32'h1122aa44) begin $display("A byte-enable got=%h expected=1122aa44",a_rdata[31:0]); fail("A byte-enable mismatch"); end
    @(negedge clk); a_req=0;

    // SW writes two adjacent words with independent byte masks.
    @(negedge clk); sw_req=1; sw_addr=8; sw_wdata={32'h55667788,32'hdeadbeef}; sw_be=8'hff;
    tick(); @(negedge clk); sw_req=0; sw_be=0;
    a_req=1; a_addr=8; tick(); wait_a();
    if (a_rdata !== 64'h55667788deadbeef) fail("SW write/read mismatch");
    @(negedge clk); a_req=0;

    // Port B masked two-word burst write and tagged read.
    @(negedge clk); b_req=1; b_we=1; b_addr=10; b_wmask=2'b11;
    b_wdata=64'hcafebabef00dcafe; tick();
    @(negedge clk); b_req=0; b_we=0; b_wmask=0; b_tag=1; b_req=1;
    tick(); wait_b();
    if (b_rdata !== 64'hcafebabef00dcafe) fail("B burst write/read mismatch");
    if (b_rtag !== 1'b1) fail("B request tag mismatch");
    @(negedge clk); b_req=0; b_tag=0;

    // Wide W port returns two ordered 64-bit lanes (no channel hash).
    @(negedge clk); w_req=1; w_addr=8; tick(); wait_w();
    if (w_rdata !== 128'hcafebabef00dcafe55667788deadbeef) fail("W wide-lane ordering mismatch");
    @(negedge clk); w_req=0; tick();
    if (!rd_idle) fail("read-idle did not assert after pipelines drained");

    $display("DRAMTEST PASS: A/SW/B/W, byte masks, tags, ordering, latency and idle");
    $finish;
  end
endmodule
