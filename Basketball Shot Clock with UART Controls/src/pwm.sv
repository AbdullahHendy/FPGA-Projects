`timescale 1ns / 1ps

module pwm #
(
   parameter int R = 8
)
(
   input logic clk,
   input logic rst,
   input logic [31:0] dvsr, //dvsr = Fsys/(2^R * Fpwm)
   input logic [R:0] duty, //1 more bit to make 100% duty cycle
   output logic pwm_out
);

logic [R-1:0] d_reg;
logic [R-1:0] d_next;
logic [31:0] q_reg;
logic [31:0] q_next;
logic [R:0] d_ext; //extension
logic pwm_reg;
logic pwm_next;
logic tick;


always_ff @(posedge clk or posedge rst) begin
  if (rst) begin
      q_reg <= 0;
      d_reg <= 0;
      pwm_reg <= 0;
  end else begin
      q_reg <= q_next;
      d_reg <= d_next;
      pwm_reg <= pwm_next;
  end
end

assign q_next = (q_reg == dvsr) ? '0 : q_reg + 1;
assign tick = (q_reg == 0) ? 1'b1 : 1'b0; //assert when q_reg reaches dvsr
assign d_next = (tick == 1'b1) ? d_reg + 1 : d_reg;
assign d_ext = {1'b0, d_reg};
assign pwm_next = (d_ext < duty) ? 1'b1 : 1'b0;
assign pwm_out = pwm_reg;

endmodule
