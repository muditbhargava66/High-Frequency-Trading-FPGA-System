`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/14/2024 01:29:42 AM
// Design Name: 
// Module Name: tb_top_level
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

module tb_top_level;

  // Parameters
  parameter CLK_PERIOD = 10;  // Clock period in nanoseconds

  // Inputs
  reg clk;
  reg rst_n;
  reg [47:0] eth_rx_data;
  reg eth_rx_valid;
  reg eth_tx_ready;
  reg [31:0] custom_ip_control;

  // Outputs
  wire eth_rx_ready;
  wire [47:0] eth_tx_data;
  wire eth_tx_valid;
  wire [31:0] custom_ip_status;

  // Instantiate the top-level module
  top_level dut (
    .clk(clk),
    .rst_n(rst_n),
    .eth_rx_data(eth_rx_data),
    .eth_rx_valid(eth_rx_valid),
    .eth_rx_ready(eth_rx_ready),
    .eth_tx_data(eth_tx_data),
    .eth_tx_valid(eth_tx_valid),
    .eth_tx_ready(eth_tx_ready),
    .custom_ip_control(custom_ip_control),
    .custom_ip_status(custom_ip_status)
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
    eth_rx_data = 48'h0;
    eth_rx_valid = 1'b0;
    eth_tx_ready = 1'b1;
    custom_ip_control = 32'h0;

    // Reset the module
    #(CLK_PERIOD*2);
    rst_n = 1'b1;

    // Test case 1: Send Ethernet data
    #(CLK_PERIOD*2);
    eth_rx_data = 48'h1122334455;
    eth_rx_valid = 1'b1;
    #(CLK_PERIOD);
    eth_rx_valid = 1'b0;
    wait(eth_tx_valid);
    #(CLK_PERIOD);

    // Test case 2: Configure custom IP control register
    #(CLK_PERIOD*2);
    custom_ip_control = 32'hABCDEF01;
    #(CLK_PERIOD*2);

    // Test case 3: Send Ethernet data with custom IP configured
    #(CLK_PERIOD*2);
    eth_rx_data = 48'h6677889900;
    eth_rx_valid = 1'b1;
    #(CLK_PERIOD);
    eth_rx_valid = 1'b0;
    wait(eth_tx_valid);
    #(CLK_PERIOD);

    // Test case 4: Check custom IP status register
    #(CLK_PERIOD*2);
    $display("Custom IP status register: %h", custom_ip_status);
    if (custom_ip_status[7:0] == 8'd1)
      $display("Custom IP status is correct");
    else
      $error("Incorrect custom IP status");

    // End the simulation
    #(CLK_PERIOD*10);
    $finish;
  end

  // Verify the Ethernet transmit data
  always @(posedge clk) begin
    if (eth_tx_valid) begin
      $display("Ethernet transmit data: %h", eth_tx_data);
      if (eth_tx_data == 48'h1122334455)
        $display("Ethernet transmit data is correct");
      else
        $error("Incorrect Ethernet transmit data");
    end
  end

endmodule
