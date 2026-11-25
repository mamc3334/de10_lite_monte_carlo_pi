module lane#(
    parameter       SEED = 32'd1 // from lane_array
)(
    input           clk,
    input           rst_n,
    input           lane_en,

    output reg      lane_hit
);
    
    // Instantiate the RNG module
    wire[31:0] rand_out;

    rng #(.SEED(SEED)) u_rng (
        .clk(clk), .rst_n(rst_n), .en(lane_en), .rand_out(rand_out)
    );

    wire[15:0] X = rand_out[31:16]; // upper 16 bits
    wire[15:0] Y = rand_out[15:0];  // lower 16 bits

    wire[31:0] X_squared = X * X;
    wire[31:0] Y_squared = Y * Y;

    wire[32:0] sum = {1'b0, X_squared} + {1'b0, Y_squared}; // 33 bits to avoid overflow

    always @(posedge clk) begin
        if (!rst_n) begin
            lane_hit <= 1'b0; 
        end
        else if(lane_en) begin
            lane_hit <= (sum < 33'h100000000); // check if inside unit circle
        end
        else begin
            lane_hit <= 1'b0; // no hit if lane is not enabled
        end
    end
endmodule