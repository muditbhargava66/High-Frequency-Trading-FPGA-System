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
    eth_rx_data = {16'h1234, 32'h12345678};  // Update data format
    eth_rx_valid = 1'b1;
    #(CLK_PERIOD);
    eth_rx_valid = 1'b0;
    wait(eth_tx_valid);
    #(CLK_PERIOD);

    // Test case 2: Configure custom IP control register
    #(CLK_PERIOD*2);
    custom_ip_control = 32'hABCDEF01;
    #(CLK_PERIOD*2);

    // Test case 3: Send order data
    #(CLK_PERIOD*2);
    eth_rx_data = {16'h5678, 2'b00, 2'b00, 8'h10, 8'h20, 8'h30, 4'h4};  // Order data
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

    // Test case 5: Send multiple orders
    #(CLK_PERIOD*2);
    eth_rx_data = {16'hAABB, 2'b01, 2'b01, 8'h40, 8'h50, 8'h60, 4'h7};  // Order data
    eth_rx_valid = 1'b1;
    #(CLK_PERIOD);
    eth_rx_data = {16'hCCDD, 2'b10, 2'b10, 8'h70, 8'h80, 8'h90, 4'hA};  // Order data
    #(CLK_PERIOD);
    eth_rx_valid = 1'b0;
    wait(eth_tx_valid);
    #(CLK_PERIOD);

    // End the simulation
    #(CLK_PERIOD*10);
    $finish;
  end

  // Verify the Ethernet transmit data
  always @(posedge clk) begin
    if (eth_tx_valid) begin
      $display("Ethernet transmit data: %h", eth_tx_data);
      // Add checks for expected transmit data based on test cases
    end
  end

  // Verify the trade data
  always @(posedge clk) begin
    if (dut.order_matching_inst.trade_valid) begin
      $display("Trade data: %h", dut.order_matching_inst.trade_data);
      // Add checks for expected trade data based on test cases
    end
  end

  // Verify the risk management
  always @(posedge clk) begin
    if (dut.risk_mgmt_inst.trade_approved) begin
      $display("Trade approved by risk management");
    end else if (dut.order_matching_inst.trade_valid) begin
      $display("Trade rejected by risk management");
    end
  end

endmodule