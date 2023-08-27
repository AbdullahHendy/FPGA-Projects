`timescale 1ns / 1ps


module rainbow(
    input clk,
    input rst,
    output red,
    output green,
    output blue
    );
    
    integer counter = 0;
    localparam gradient_counter_max = 156250; //800 Hz >>> 125M/800
    localparam duty_res = 8;
    logic gradient_pulse;

    
    typedef enum logic [2:0] {s1, s2, s3, s4, s5, s6} state;
    state curr_state;
    logic led_inc;
    logic led_dec;
    logic max;
    logic min;
    
    logic red_reg;
    logic green_reg;
    logic blue_reg;
    
    gradual_bright_inc #(
        .duty_res(duty_res),
        .gradient_counter_max(gradient_counter_max)
        )
        pwm_incr
        (
            .clk(clk),
            .rst(rst),
            .led(led_inc), //dvsr = 125M/(2^8 * 100) //100Hz
            .max(max)
        );  
        
    gradual_bright_dec #(
        .duty_res(duty_res),
        .gradient_counter_max(gradient_counter_max)
        )
        pwm_dec
        (
            .clk(clk),
            .rst(rst),
            .led(led_dec), //dvsr = 125M/(2^8 * 100) //100Hz
            .min(min)
        );         
            
    
    always_ff@(posedge clk, posedge rst) begin //generate pwm switching clock
        if (rst) begin
            counter <= 0;
        end 
        else begin
            if (counter < gradient_counter_max - 1) begin
                counter <= counter + 1;
                gradient_pulse <= 0;
            end
            else begin
                counter <= 0;
                gradient_pulse <= 1;
            end
        end
    end     

    
        
    always_ff@(posedge gradient_pulse, posedge rst) begin
        if (rst == 1'b1) begin
            curr_state <= s1;
            red_reg <= 1'b0;
            green_reg <= 1'b0;
            blue_reg <= 1'b0;
        end
        else begin //rising edge of clk
            case (curr_state)
                s1: begin
                        red_reg <= 1'b1;
                        green_reg <= led_inc;
                        blue_reg <= 1'b0;
                        if (max == 1) begin
                            curr_state <= s2;
                        end    
                      end
                s2: begin
                        red_reg <= led_dec;
                        green_reg <= 1'b1;
                        blue_reg <= 1'b0;
                        if (min == 1) begin
                            curr_state <= s3;
                        end    
                      end
                s3: begin
                        red_reg <= 1'b0;
                        green_reg <= 1'b1;
                        blue_reg <= led_inc;
                        if (max == 1) begin
                            curr_state <= s4;
                        end    
                      end
                s4: begin
                        red_reg <= 1'b0;
                        green_reg <= led_dec;
                        blue_reg <= 1'b1;
                        if (min == 1) begin
                            curr_state <= s5;
                        end    
                      end
                s5: begin
                        red_reg <= led_inc;
                        green_reg <= 1'b0;
                        blue_reg <= 1'b1;
                        if (max == 1) begin
                            curr_state <= s6;
                        end    
                      end
                s6: begin
                        red_reg <= 1'b1;
                        green_reg <= 1'b0;
                        blue_reg <= led_dec;
                        if (min == 1) begin
                            curr_state <= s1;
                        end    
                      end
            endcase    
        end    
    end   
   
   assign red = red_reg;
   assign green = green_reg;
   assign blue = blue_reg;
     
endmodule
