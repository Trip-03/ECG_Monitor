module heart_rate_display(
    input wire clk,
    input wire [31:0] timer,
    input wire reset,
    input wire displaying,
    input wire [7:0] heart_rate_avg,
    input wire [7:0] heart_beats_count,
    input wire [7:0] heart_beats_without_violations,
    input wire [7:0] min_heart_beats_threshold_violations,
    input wire [7:0] max_heart_beats_threshold_violations,
    output reg [6:0] seg_display_heart_rate_avg_0,
    output reg [6:0] seg_display_heart_rate_avg_1,
    output reg [6:0] seg_display_heart_rate_avg_2,
    output reg [6:0] seg_display_heart_beats_count_0,
    output reg [6:0] seg_display_heart_beats_count_1,
    output reg [6:0] seg_display_heart_beats_count_2,
    output reg [6:0] seg_display_heart_beats_without_violations_0,
    output reg [6:0] seg_display_heart_beats_without_violations_1,
    output reg [6:0] seg_display_heart_beats_without_violations_2,
    output reg [6:0] seg_display_min_heart_beats_threshold_violations_0,
    output reg [6:0] seg_display_min_heart_beats_threshold_violations_1,
    output reg [6:0] seg_display_min_heart_beats_threshold_violations_2,
    output reg [6:0] seg_display_max_heart_beats_threshold_violations_0,
    output reg [6:0] seg_display_max_heart_beats_threshold_violations_1,
    output reg [6:0] seg_display_max_heart_beats_threshold_violations_2
);

    function [6:0] convert_to_7seg(input [3:0] digit);
        begin
            case(digit)
                4'd0: convert_to_7seg = 7'b1111110; 
                4'd1: convert_to_7seg = 7'b0110000; 
                4'd2: convert_to_7seg = 7'b1101101;
                4'd3: convert_to_7seg = 7'b1111001;
                4'd4: convert_to_7seg = 7'b0110011; 
                4'd5: convert_to_7seg = 7'b1011011; 
                4'd6: convert_to_7seg = 7'b1011111; 
                4'd7: convert_to_7seg = 7'b1110000; 
                4'd8: convert_to_7seg = 7'b1111111; 
                4'd9: convert_to_7seg = 7'b1111011; 
                default: convert_to_7seg = 7'b0000000; 
            endcase
        end
    endfunction

    always @(posedge clk) begin
        if(reset) begin 
            seg_display_heart_rate_avg_2 <= 7'b0000000;
            seg_display_heart_rate_avg_1 <= 7'b0000000;
            seg_display_heart_rate_avg_0 <= 7'b0000000;
            
            seg_display_heart_beats_count_2 <= 7'b0000000;
            seg_display_heart_beats_count_1 <= 7'b0000000;
            seg_display_heart_beats_count_0 <= 7'b0000000;

            seg_display_heart_beats_without_violations_2 <= 7'b0000000;
            seg_display_heart_beats_without_violations_1 <= 7'b0000000;
            seg_display_heart_beats_without_violations_0 <= 7'b0000000;

            seg_display_min_heart_beats_threshold_violations_2 <= 7'b0000000;
            seg_display_min_heart_beats_threshold_violations_1 <= 7'b0000000;
            seg_display_min_heart_beats_threshold_violations_0 <= 7'b0000000;

            seg_display_max_heart_beats_threshold_violations_2 <= 7'b0000000;
            seg_display_max_heart_beats_threshold_violations_1 <= 7'b0000000;
            seg_display_max_heart_beats_threshold_violations_0 <= 7'b0000000;
        end else if (displaying) begin
            seg_display_heart_rate_avg_2 <= convert_to_7seg(heart_rate_avg / 100);
            seg_display_heart_rate_avg_1 <= convert_to_7seg((heart_rate_avg / 10) % 10);
            seg_display_heart_rate_avg_0 <= convert_to_7seg(heart_rate_avg % 10);
            
            seg_display_heart_beats_count_2 <= convert_to_7seg(heart_beats_count / 100);
            seg_display_heart_beats_count_1 <= convert_to_7seg((heart_beats_count / 10) % 10);
            seg_display_heart_beats_count_0 <= convert_to_7seg(heart_beats_count % 10);

            seg_display_heart_beats_without_violations_2 <= convert_to_7seg(heart_beats_without_violations / 100);
            seg_display_heart_beats_without_violations_1 <= convert_to_7seg((heart_beats_without_violations / 10) % 10);
            seg_display_heart_beats_without_violations_0 <= convert_to_7seg(heart_beats_without_violations % 10);

            seg_display_min_heart_beats_threshold_violations_2 <= convert_to_7seg(min_heart_beats_threshold_violations / 100);
            seg_display_min_heart_beats_threshold_violations_1 <= convert_to_7seg((min_heart_beats_threshold_violations / 10) % 10);
            seg_display_min_heart_beats_threshold_violations_0 <= convert_to_7seg(min_heart_beats_threshold_violations % 10);

            seg_display_max_heart_beats_threshold_violations_2 <= convert_to_7seg(max_heart_beats_threshold_violations / 100);
            seg_display_max_heart_beats_threshold_violations_1 <= convert_to_7seg((max_heart_beats_threshold_violations / 10) % 10);
            seg_display_max_heart_beats_threshold_violations_0 <= convert_to_7seg(max_heart_beats_threshold_violations % 10);
        end 
    end

endmodule
