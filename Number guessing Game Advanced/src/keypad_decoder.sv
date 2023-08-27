`timescale 1ns / 1ps

module keypad_decoder(
    input clk,
    input rst,
    input [3:0] row,
    output [3:0] col,
    output [3:0] decode_out,
    output is_pressed
    );
    
    logic [3:0] col_reg;    
    logic [3:0] decode_out_reg;
    logic is_pressed_reg;
    logic [19:0] count;
    //for 50Mhz clock, wait time of 2ms between check, four column are needed: count is expected to reach about 400,0000 which fits in 20 bits
    always_ff@(posedge clk, posedge rst)
    begin
        if (rst == 1'b1) begin
            col_reg <= 4'b1111;
            decode_out_reg <= 4'b0000;
            is_pressed_reg <= 1'b0;
        end 
        else begin
            if (count == 20'd100000) begin
                col_reg <= 4'b0111; //pull R5 down
                count <= count + 1;
            end
            else if (count == 20'd100008) begin //wait for 8 clock cycles after pulling the first column down to check the rows
                if (row == 4'b0111) begin //(1,1) pressed
                    decode_out_reg <= 4'b0001;    
                    is_pressed_reg <= 1'b1;
                end
                else if (row == 4'b1011) begin //(2,1) pressed
                    decode_out_reg <= 4'b0100;    
                    is_pressed_reg <= 1'b1;                
                end
                else if (row == 4'b1101) begin //(3,1) pressed
                    decode_out_reg <= 4'b0111;    
                    is_pressed_reg <= 1'b1;                
                end                
                else if (row == 4'b1110) begin //(4,1) pressed
                    decode_out_reg <= 4'b0000;    
                    is_pressed_reg <= 1'b1;                
                end
                else begin
                    decode_out_reg <= decode_out_reg;    
                    is_pressed_reg <= 1'b0;                
                end
                count <= count + 1; //incrment count to get out of this case to check other cases
            end 
            else if (count == 20'd200000) begin
                col_reg <= 4'b1011; //pull R6 down
                count <= count + 1;
            end
            else if (count == 20'd200008) begin //wait for 8 clock cycles after pulling the first column down to check the rows
                if (row == 4'b0111) begin //(1,2) pressed
                    decode_out_reg <= 4'b0010;    
                    is_pressed_reg <= 1'b1;
                end
                else if (row == 4'b1011) begin //(2,2) pressed
                    decode_out_reg <= 4'b0101;    
                    is_pressed_reg <= 1'b1;                
                end
                else if (row == 4'b1101) begin //(3,2) pressed
                    decode_out_reg <= 4'b1000;    
                    is_pressed_reg <= 1'b1;                
                end                
                else if (row == 4'b1110) begin //(4,2) pressed
                    decode_out_reg <= 4'b1111;    
                    is_pressed_reg <= 1'b1;                
                end
                else begin
                    decode_out_reg <= decode_out_reg;    
                    is_pressed_reg <= 1'b0;                
                end
                count <= count + 1; //incrment count to get out of this case to check other cases
            end 
            else if (count == 20'd300000) begin
                col_reg <= 4'b1101; //pull R7 down
                count <= count + 1;
            end 
            else if (count == 20'd300008) begin //wait for 8 clock cycles after pulling the first column down to check the rows
                if (row == 4'b0111) begin //(1,3) pressed
                    decode_out_reg <= 4'b0011;    
                    is_pressed_reg <= 1'b1;
                end
                else if (row == 4'b1011) begin //(2,3) pressed
                    decode_out_reg <= 4'b0110;    
                    is_pressed_reg <= 1'b1;                
                end
                else if (row == 4'b1101) begin //(3,3) pressed
                    decode_out_reg <= 4'b1001;    
                    is_pressed_reg <= 1'b1;                
                end                
                else if (row == 4'b1110) begin //(4,3) pressed
                    decode_out_reg <= 4'b1110;    
                    is_pressed_reg <= 1'b1;                
                end
                else begin
                    decode_out_reg <= decode_out_reg;    
                    is_pressed_reg <= 1'b0;                
                end
                count <= count + 1; //incrment count to get out of this case to check other cases
            end             
            else if (count == 20'd400000) begin
                col_reg <= 4'b1110; //pull R8 down
                count <= count + 1;
            end 
            else if (count == 20'd400008) begin //wait for 8 clock cycles after pulling the first column down to check the rows
                if (row == 4'b0111) begin //(1,4) pressed
                    decode_out_reg <= 4'b1010;    
                    is_pressed_reg <= 1'b1;
                end
                else if (row == 4'b1011) begin //(2,4) pressed
                    decode_out_reg <= 4'b1011;    
                    is_pressed_reg <= 1'b1;                
                end
                else if (row == 4'b1101) begin //(3,4) pressed
                    decode_out_reg <= 4'b1100;    
                    is_pressed_reg <= 1'b1;                
                end                
                else if (row == 4'b1110) begin //(4,4) pressed
                    decode_out_reg <= 4'b1101;    
                    is_pressed_reg <= 1'b1;                
                end
                else begin
                    decode_out_reg <= decode_out_reg;    
                    is_pressed_reg <= 1'b0;                
                end
                count <= 20'd000000; //incrment count to get out of this case to check other cases
            end
            else begin
                count <= count + 1;
            end                         
        end     

    end    

    assign col = col_reg;
    assign decode_out = decode_out_reg;
    assign is_pressed = is_pressed_reg;
  
endmodule
