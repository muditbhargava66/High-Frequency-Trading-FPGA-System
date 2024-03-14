`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/14/2024 01:29:42 AM
// Design Name: 
// Module Name: tb_tcp_ip_stack
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

module tb_tcp_ip_stack;

  // Parameters
  parameter CLK_PERIOD = 10;  // Clock period in nanoseconds

  // Inputs
  reg clk;
  reg rst_n;
  reg [31:0] app_tx_data;
  reg app_tx_valid;
  reg [31:0] eth_rx_data;
  reg eth_rx_valid;
  reg eth_tx_ready;

  // Outputs
  wire app_tx_ready;
  wire [31:0] app_rx_data;
  wire app_rx_valid;
  wire [31:0] eth_tx_data;
  wire eth_tx_valid;
  wire eth_rx_ready;

  // Instantiate the TCP/IP stack module
  tcp_ip_stack dut (
    .clk(clk),
    .rst_n(rst_n),
    .app_tx_data(app_tx_data),
    .app_tx_valid(app_tx_valid),
    .app_tx_ready(app_tx_ready),
    .app_rx_data(app_rx_data),
    .app_rx_valid(app_rx_valid),
    .app_rx_ready(1'b1),
    .eth_tx_data(eth_tx_data),
    .eth_tx_valid(eth_tx_valid),
    .eth_tx_ready(eth_tx_ready),
    .eth_rx_data(eth_rx_data),
    .eth_rx_valid(eth_rx_valid),
    .eth_rx_ready(eth_rx_ready)
  );

  // Clock generation
  always begin
    clk = 1'b0;
    #(CLK_PERIOD/2);
    clk = 1'b1;
    #(CLK_PERIOD/2);
  end

  // Testbench stimulus
  initial begin
    // Initialize inputs
    rst_n = 1'b0;
    app_tx_data = 32'h0;
    app_tx_valid = 1'b0;
    eth_rx_data = 32'h0;
    eth_rx_valid = 1'b0;
    eth_tx_ready = 1'b1;

    // Reset the module
    #(CLK_PERIOD*2);
    rst_n = 1'b1;

    // Test case 1: Send application data
    #(CLK_PERIOD*2);
    app_tx_data = 32'h12345678;
    app_tx_valid = 1'b1;
    #(CLK_PERIOD);
    app_tx_valid = 1'b0;
    wait(eth_tx_valid);
    #(CLK_PERIOD);

    // Test case 2: Receive Ethernet data
    #(CLK_PERIOD*2);
    eth_rx_data = 32'h87654321;
    eth_rx_valid = 1'b1;
    #(CLK_PERIOD);
    eth_rx_valid = 1'b0;
    wait(app_rx_valid);
    #(CLK_PERIOD);

    // Test case 3: Send and receive multiple packets
    #(CLK_PERIOD*2);
    app_tx_data = 32'hAAAAAAAA;
    app_tx_valid = 1'b1;
    #(CLK_PERIOD);
    app_tx_data = 32'hBBBBBBBB;
    #(CLK_PERIOD);
    app_tx_data = 32'hCCCCCCCC;
    #(CLK_PERIOD);
    app_tx_valid = 1'b0;
    wait(eth_tx_valid);
    #(CLK_PERIOD*3);
    
    eth_rx_data = 32'h11111111;
    eth_rx_valid = 1'b1;
    #(CLK_PERIOD);
    eth_rx_data = 32'h22222222;
    #(CLK_PERIOD);
    eth_rx_data = 32'h33333333;
    #(CLK_PERIOD);
    eth_rx_valid = 1'b0;
    wait(app_rx_valid);
    #(CLK_PERIOD*3);

    // End the simulation
    #(CLK_PERIOD*10);
    $finish;
  end

  // Verify the transmitted Ethernet data
  always @(posedge clk) begin
    if (eth_tx_valid) begin
      $display("Transmitted Ethernet data: %h", eth_tx_data);
      if (eth_tx_data == 32'h12345678)
        $display("Ethernet transmit data is correct");
      else
        $error("Incorrect Ethernet transmit data");
    end
  end

  // Verify the received application data
  always @(posedge clk) begin
    if (app_rx_valid) begin
      $display("Received application data: %h", app_rx_data);
      if (app_rx_data == 32'h87654321)
        $display("Application receive data is correct");
      else
        $error("Incorrect application receive data");
    end
  end

endmodule