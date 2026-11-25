module rng#(
    parameter       SEED = 32'd1
)(
    input           clk,
    input           rst_n,
    input           en,

    output reg [31:0]    rand_out
);
    reg[31:0] next_num;
    
    //sequential
    always @(*) begin 
        next_num = rand_out ^ (rand_out << 13);
        next_num = next_num ^ (next_num >> 17);
        next_num = next_num ^ (next_num << 5);
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            rand_out <= SEED;
        end
        else if(en) begin
            rand_out <= next_num;
        end
    end
endmodule