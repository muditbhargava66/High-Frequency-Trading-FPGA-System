module custom_ip_core (
  input wire clk,
  input wire rst_n,
  // AXI stream interface for input
  input wire [31:0] s_axis_tdata,
  input wire s_axis_tvalid,
  output reg s_axis_tready,
  // AXI stream interface for output
  output reg [31:0] m_axis_tdata,
  output reg m_axis_tvalid,
  input wire m_axis_tready,
  // Control and status signals
  input wire [31:0] control_reg,
  output reg [31:0] status_reg
);

  // Packet buffer
  reg [31:0] packet_buffer [0:255];
  reg [7:0] packet_length;

  // Internal registers
  reg [31:0] internal_reg1;
  reg [31:0] internal_reg2;

  // State machine
  parameter STATE_IDLE = 2'b00;
  parameter STATE_PROCESS = 2'b01;
  parameter STATE_TRANSMIT = 2'b10;

  reg [1:0] current_state;
  reg [1:0] next_state;

  // Custom IP core logic
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      // Reset logic
      packet_length <= 0;
      internal_reg1 <= 0;
      internal_reg2 <= 0;
      current_state <= STATE_IDLE;
      s_axis_tready <= 1;
      m_axis_tvalid <= 0;
      status_reg <= 0;
    end else begin
      case (current_state)
        STATE_IDLE: begin
          if (s_axis_tvalid && s_axis_tready) begin
            // Receive input data
            packet_buffer[packet_length] <= s_axis_tdata;
            packet_length <= packet_length + 1;
            if (s_axis_tdata[31:24] == 8'hFF) begin
              // End of packet marker received
              next_state <= STATE_PROCESS;
            end
          end
        end

        STATE_PROCESS: begin
          // Process the received packet
          // Perform custom IP core functionality here
          internal_reg1 <= packet_buffer[0] + control_reg;
          internal_reg2 <= packet_buffer[1] * control_reg;
          // ...

          // Prepare the output packet
          packet_buffer[0] <= internal_reg1;
          packet_buffer[1] <= internal_reg2;
          // ...

          next_state <= STATE_TRANSMIT;
        end

        STATE_TRANSMIT: begin
          if (m_axis_tready && m_axis_tvalid) begin
            // Transmit output data
            if (packet_length > 0) begin
              m_axis_tdata <= packet_buffer[packet_length - 1];
              packet_length <= packet_length - 1;
            end else begin
              // End of packet
              m_axis_tdata <= 32'hFFFFFFFF;
              next_state <= STATE_IDLE;
            end
          end
        end
      endcase

      current_state <= next_state;
    end
  end

  // Ready signals
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      s_axis_tready <= 1;
      m_axis_tvalid <= 0;
    end else begin
      s_axis_tready <= (current_state == STATE_IDLE);
      m_axis_tvalid <= (current_state == STATE_TRANSMIT);
    end
  end

  // Status register
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      status_reg <= 0;
    end else begin
      status_reg <= {24'b0, packet_length};
    end
  end

endmodule