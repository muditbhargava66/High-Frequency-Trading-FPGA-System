module tcp_layer (
  input wire clk,
  input wire rst_n,
  
  // IP layer interface
  input wire [31:0] ip_rx_data,
  input wire ip_rx_valid,
  output wire ip_rx_ready,
  output wire [31:0] ip_tx_data,
  output wire ip_tx_valid,
  input wire ip_tx_ready,
  
  // Application layer interface
  output wire [31:0] app_rx_data,
  output wire app_rx_valid,
  input wire app_rx_ready,
  input wire [31:0] app_tx_data,
  input wire app_tx_valid,
  output wire app_tx_ready
);

  // Instantiate the tcp_ip_stack module
  tcp_ip_stack tcp_ip_stack_inst (
    .clk(clk),
    .rst_n(rst_n),
    .app_tx_data(app_tx_data),
    .app_tx_valid(app_tx_valid),
    .app_tx_ready(app_tx_ready),
    .app_rx_data(app_rx_data),
    .app_rx_valid(app_rx_valid),
    .app_rx_ready(app_rx_ready),
    .eth_tx_data(ip_tx_data),
    .eth_tx_valid(ip_tx_valid),
    .eth_tx_ready(ip_tx_ready),
    .eth_rx_data(ip_rx_data),
    .eth_rx_valid(ip_rx_valid),
    .eth_rx_ready(ip_rx_ready)
  );

  // TCP packet parameters
  parameter TCP_SRC_PORT = 16'h1234;
  parameter TCP_DST_PORT = 16'h5678;
  parameter TCP_SEQ_NUM_INIT = 32'h00000000;
  parameter TCP_ACK_NUM_INIT = 32'h00000000;
  parameter TCP_WINDOW_SIZE = 16'h7FFF;
  parameter TCP_CHECKSUM_ENABLE = 1;

  // TCP states
  parameter TCP_STATE_CLOSED = 2'b00;
  parameter TCP_STATE_SYN_SENT = 2'b01;
  parameter TCP_STATE_ESTABLISHED = 2'b10;
  parameter TCP_STATE_FIN_WAIT = 2'b11;

  // Packet buffers
  reg [31:0] rx_buffer;
  reg rx_buffer_valid;
  reg [31:0] tx_buffer;
  reg tx_buffer_valid;

  // TCP state variables
  reg [1:0] tcp_state;
  reg [31:0] tcp_seq_num;
  reg [31:0] tcp_ack_num;

  // TCP layer logic
  always @(posedge clk) begin
    if (!rst_n) begin
      // Reset logic
      tcp_state <= TCP_STATE_CLOSED;
      tcp_seq_num <= TCP_SEQ_NUM_INIT;
      tcp_ack_num <= TCP_ACK_NUM_INIT;
      rx_buffer_valid <= 0;
      tx_buffer_valid <= 0;
    end else begin
      case (tcp_state)
        TCP_STATE_CLOSED: begin
          if (app_tx_valid && app_tx_ready) begin
            // Send SYN packet
            tcp_state <= TCP_STATE_SYN_SENT;
            tcp_seq_num <= TCP_SEQ_NUM_INIT;
            tx_buffer <= {TCP_SRC_PORT, TCP_DST_PORT, tcp_seq_num, 32'h00000000, 16'h5002, TCP_WINDOW_SIZE, 16'h0000};
            tx_buffer_valid <= 1;
          end
        end

        TCP_STATE_SYN_SENT: begin
          if (ip_rx_valid && ip_rx_ready && ip_rx_data[31:16] == {TCP_DST_PORT, TCP_SRC_PORT} && ip_rx_data[15:0] == 16'h5012) begin
            // Receive SYN-ACK packet
            tcp_state <= TCP_STATE_ESTABLISHED;
            tcp_ack_num <= ip_rx_data[47:32] + 1;
            tx_buffer <= {TCP_SRC_PORT, TCP_DST_PORT, tcp_seq_num, tcp_ack_num, 16'h5010, TCP_WINDOW_SIZE, 16'h0000};
            tx_buffer_valid <= 1;
          end
        end

        TCP_STATE_ESTABLISHED: begin
          if (app_tx_valid && app_tx_ready) begin
            // Send data packet
            tx_buffer <= {TCP_SRC_PORT, TCP_DST_PORT, tcp_seq_num, tcp_ack_num, 16'h5018, TCP_WINDOW_SIZE, 16'h0000, app_tx_data};
            tx_buffer_valid <= 1;
            tcp_seq_num <= tcp_seq_num + 1;
          end
        
          if (ip_rx_valid && ip_rx_ready) begin
            if (ip_rx_data[31:16] == {TCP_DST_PORT, TCP_SRC_PORT} && ip_rx_data[15:0] == 16'h5011) begin
              // Receive FIN-ACK packet
              tcp_state <= TCP_STATE_FIN_WAIT;
              tcp_ack_num <= ip_rx_data[31:0] + 1;
              tx_buffer <= {TCP_SRC_PORT, TCP_DST_PORT, tcp_seq_num, tcp_ack_num, 16'h5011, TCP_WINDOW_SIZE, 16'h0000};
              tx_buffer_valid <= 1;
            end else if (ip_rx_data[15:0] == 16'h5018) begin
              // Receive data packet
              rx_buffer <= ip_rx_data;
              rx_buffer_valid <= 1;
              tcp_ack_num <= ip_rx_data[31:0] + 1;
              tx_buffer <= {TCP_SRC_PORT, TCP_DST_PORT, tcp_seq_num, tcp_ack_num, 16'h5010, TCP_WINDOW_SIZE, 16'h0000};
              tx_buffer_valid <= 1;
            end
          end
        end

        TCP_STATE_FIN_WAIT: begin
          if (app_rx_ready && app_rx_valid) begin
            // Application acknowledged FIN
            tcp_state <= TCP_STATE_CLOSED;
          end
        end
      endcase

      // Clear buffer valid flags when data is consumed
      if (tx_buffer_valid && ip_tx_ready) begin
        tx_buffer_valid <= 0;
      end
      if (rx_buffer_valid && app_rx_ready) begin
        rx_buffer_valid <= 0;
      end
    end
  end

  // Receive path
  assign app_rx_data = rx_buffer;
  assign app_rx_valid = rx_buffer_valid;
  assign ip_rx_ready = !rx_buffer_valid || app_rx_ready;

  // Transmit path
  assign ip_tx_data = tx_buffer;
  assign ip_tx_valid = tx_buffer_valid;
  assign app_tx_ready = (tcp_state == TCP_STATE_ESTABLISHED) && !tx_buffer_valid;

  // Checksum calculation (optional)
  // TODO: Implement TCP checksum calculation if enabled

endmodule