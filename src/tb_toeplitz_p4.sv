// SPDX-License-Identifier: MIT
// Copyright (c) 2025 Rok Zitko

// Testbench for Toeplitz extractor (parallelized version)
// Rok Zitko, April 2022

`default_nettype none

//`define VERBOSE
//`define DEBUG
`define COUNT_CLOCKS

timeunit 1ns;
timeprecision 100fs;

module tb_toeplitz_p4;

parameter BS = 64;
parameter N = 256;
parameter L = 128;
parameter WIDTH = 4;
parameter XSZ = N/BS;
parameter YSZ = L/BS;

reg clk;
initial clk <= 0;
always #0.5 clk <= ~clk;

reg reset;
initial begin
 reset <= 1;
 #1;
 reset <= 0;
end

reg [WIDTH-1:0] data;
wire [L-1:0] q;
wire qstrobe;

toeplitz_p #(.BS(BS), .N(N), .L(L), .WIDTH(WIDTH)) inst(.clk, .reset, .data, .q, .qstrobe);

reg qbit, qbiten;

serializer #(.L(L)) sinst(.clk, .reset, .q, .qstrobe, .qbit, .qbiten);

initial begin
  $timeformat(-9, 2, " ns", 20);
end

// Input feeding
reg [N-1:0] xx;
integer cnt;
always @(posedge clk) begin
  #0.1;
  data = xx[(N-WIDTH)-cnt*WIDTH +: WIDTH];
`ifdef DEBUG
  $display("time=%t data=%b", $time, data);
`endif
  cnt++;
end

task load(input string fn);
  logic [BS-1:0] x [0:XSZ-1];
  $readmemh(fn, x);
  xx = {x[0], x[1], x[2], x[3]};
  cnt = 0;
`ifdef DEBUG
  $display("time=%t xx=%b", $time, xx);
`endif
  #(N/WIDTH);
endtask

initial begin
  load("x64-nr1-hex.dat");
  load("x64-nr2-hex.dat");
  load("x64-nr3-hex.dat");
  load("x64-nr4-hex.dat");
end

// Output checking
task check(input string fn);
  logic [BS-1:0] y [0:YSZ-1];
  wait(qstrobe == 1);
  @(posedge clk);
  $display("time=%t", $time);
  $readmemh(fn, y);
`ifdef VERBOSE
  $display("q=%b", q);
  $display("y=%b", {y[0], y[1]});
  if(q === {y[0], y[1]})
    $display("PASS: %s", fn);
  else begin
    $display("FAIL: %s", fn);
    $display("   Obtido: q=%h", q);
    $display("   Esperado: y=%h", {y[0], y[1]});
    $fatal(1, "Resultado incorreto");
  end
`endif
  assert(q == {y[0], y[1]});
  #1;
endtask

initial begin
  check("y64-nr1-hex.dat");
  check("y64-nr2-hex.dat");
  check("y64-nr3-hex.dat");
  check("y64-nr4-hex.dat");
  $finish;
end

// lógica da contagem de pulsos de clock para cada operação

`ifdef COUNT_CLOCKS

integer cycle_count = 0;
integer start_cycle = 0;
integer previous_strobe_cycle = 0;
integer operation_count = 0;
integer total_cycles = 0;

always @(posedge clk) begin
  cycle_count = cycle_count + 1;
end

initial begin
  wait(reset == 0);
  @(posedge clk);
  #0.01;
  start_cycle = cycle_count;
end

always @(posedge qstrobe) begin
  #0.01;
  operation_count = operation_count + 1;
  if (operation_count == 1) begin
    total_cycles = cycle_count - start_cycle + 1;
  end else begin
    total_cycles = cycle_count - previous_strobe_cycle;
  end
  $display("--------------------------------");
  $display("Operation: %0d", operation_count);
  $display("Total clock cycles: %0d", total_cycles);
  $display("Simulation time: %t", $time);
  $display("--------------------------------");
  previous_strobe_cycle = cycle_count;
end
`endif 

endmodule: tb_toeplitz_p4
