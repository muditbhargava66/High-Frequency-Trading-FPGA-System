`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/15/2024 10:51:28 PM
// Design Name: 
// Module Name: tb_risk_management
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

module tb_risk_management;

  // Parameters
  parameter CLK_PERIOD = 10;  // Clock period in nanoseconds

  // Inputs
  reg clk;
  reg rst_n;
  reg [31:0] trade_data;
  reg trade_valid;
  reg [31:0] position_update;
  reg position_update_valid;
  reg [31:0] exposure_update;
  reg exposure_update_valid;

  // Outputs
  wire trade_approved;
  wire [31:0] current_position;
  wire [31:0] current_exposure;

  // Instantiate the risk management module
  risk_management dut (
    .clk(clk),
    .rst_n(rst_n),
    .trade_data(trade_data),
    .trade_valid(trade_valid),
    .trade_approved(trade_approved),
    .position_update(position_update),
    .position_update_valid(position_update_valid),
    .current_position(current_position),
    .exposure_update(exposure_update),
    .exposure_update_valid(exposure_update_valid),
    .current_exposure(current_exposure),
    .max_exposure_limit(32'h1000000),
    .max_position_limit(32'h100000)
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
    trade_data = 32'h0;
    trade_valid = 1'b0;
    position_update = 32'h0;
    position_update_valid = 1'b0;
    exposure_update = 32'h0;
    exposure_update_valid = 1'b0;

    // Reset the module
    #(CLK_PERIOD*2);
    rst_n = 1'b1;

    // Test case 1: Valid trade within risk limits
    #(CLK_PERIOD*2);
    trade_data = 32'h00010000;  // Trade amount: 65536
    trade_valid = 1'b1;
    #(CLK_PERIOD);
    trade_valid = 1'b0;

    // Test case 2: Valid position update
    #(CLK_PERIOD*2);
    position_update = 32'h00020000;  // Position update: 131072
    position_update_valid = 1'b1;
    #(CLK_PERIOD);
    position_update_valid = 1'b0;

    // Test case 3: Valid exposure update
    #(CLK_PERIOD*2);
    exposure_update = 32'h00030000;  // Exposure update: 196608
    exposure_update_valid = 1'b1;
    #(CLK_PERIOD);
    exposure_update_valid = 1'b0;

    // Test case 4: Trade exceeding exposure limit
    #(CLK_PERIOD*2);
    trade_data = 32'h00800000;  // Trade amount: 8388608 (exceeds exposure limit)
    trade_valid = 1'b1;
    #(CLK_PERIOD);
    trade_valid = 1'b0;

    // Test case 5: Trade exceeding position limit
    #(CLK_PERIOD*2);
    trade_data = 32'h00100000;  // Trade amount: 1048576 (exceeds position limit)
    trade_valid = 1'b1;
    #(CLK_PERIOD);
    trade_valid = 1'b0;

    // End the simulation
    #(CLK_PERIOD*10);
    $finish;
  end

  // Assertion for trade approval
  always @(posedge clk) begin
    if (trade_valid) begin
      $display("Trade: amount = %d, approved = %b", trade_data, trade_approved);
      if (trade_data <= 32'h00400000) begin
        if (!trade_approved)
          $display("Trade should have been approved");
      end else begin
        if (trade_approved)
          $display("Trade should have been rejected");
      end
    end
  end

  // Assertion for current position and exposure
  always @(posedge clk) begin
    $display("Current position: %d, Current exposure: %d", current_position, current_exposure);
    if (current_position > 32'h100000)
      $display("Position limit exceeded");
    if (current_exposure > 32'h1000000)
      $display("Exposure limit exceeded");
  end

endmodule