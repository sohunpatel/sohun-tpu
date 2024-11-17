module lif (
    input             clk,
    input             reset_n,
    input      [ 7:0] spike_in,
    input      [63:0] weights           [8],
    input      [ 7:0] memb_potential_in,
    input      [ 7:0] threshold,
    input      [ 7:0] leak_value,
    input      [ 3:0] tref,
    input      [ 7:0] memb_potential_out,
    output reg        spike_out
);

  reg [3:0] tr = 0;
  reg [7:0] voltage;

endmodule
