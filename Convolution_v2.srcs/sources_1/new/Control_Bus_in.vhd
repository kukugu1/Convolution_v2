library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity Control_Bus_in is
    generic(
        kernel_size : integer := 27;
        matriz_size : integer := 128
    );
    port(
        clk, selector, T_valid : in std_logic;
        Bus_valid_Size         : in std_logic_vector(2 downto 0);
        Padding                : in std_logic_vector(1 downto 0);
        rst, CAP, SEL, T_ready : out std_logic;
        EN_1, EN_1K            : buffer std_logic
    );
end Control_Bus_in;

architecture Behavioral of Control_Bus_in is
signal imagen_size, padding_size : integer;
type estados is(ini,E1,E2,E3,E4,E5,E6,E7,E8,E9,
                E10,E11,E12,E13,E14,E15,E16,E17,E18,E19,
                E20,E21,E22,E23,E24,E25,E26,E27,E28,E29);
                
signal Est  : estados;
signal x, y : integer range 0 to 132;
--     Bus_valid_Size <= "000" -- Tamaño de imagen 8x8
--     Bus_valid_Size <= "001" -- Tamaño de imagen 16x16
--     Bus_valid_Size <= "010" -- Tamaño de imagen 32x32
--     Bus_valid_Size <= "011" -- Tamaño de imagen 64x64
--     Bus_valid_Size <= "100" -- Tamaño de imagen 128x128

--     Padding <= "00" -- Padding de 0
--     Padding <= "01" -- Padding de 1
--     Padding <= "10" -- Padding de 2

begin

    imagen_size <= 8 when Bus_valid_Size = "000" else 16 when Bus_valid_Size = "001" else
                   32 when Bus_valid_Size = "010" else 64 when Bus_valid_Size = "011" else
                   128 when Bus_valid_Size = "100" else 0;
                   
    padding_size <= 0 when Padding = "00" else 1 when Padding = "01" else 
                    2 when Padding = "10" else 0;
                   
    process(clk)
    begin
        if rising_edge(clk) then
            case Est is
                when ini =>
                    rst <= '0';
                    CAP <= '0';
                    EN_1K <= '0';                    
                    EN_1 <= '0';
                    SEL <= '0';
                    T_ready <= '0';   
                    Est <= E1;
                                    
                when E1 => 
                    rst <= '1';
                    CAP <= '0';
                    EN_1K <= '0';
                    EN_1 <= '0';
                    SEL <= '0';
                    T_ready <= '0';
                    if selector = '0' then
                        Est <= E2;
                    else
                        Est <= E3;               
                    end if;   
                        
                when E2 =>   
                    T_ready <= '1';           
                    if T_valid = '1' then
                        Est <= E4;
                    else
                        Est <= E2;
                    end if;   
                        
                when E3 =>
                    SEL <= '1';                                   
                    if Padding = "00" then
                        Est <= E8;
                    elsif Padding = "01" then
                        Est <= E15;
                    end if;
                    
                when E4 =>
                    rst <= '0';
                    CAP <= '1';
                    T_ready <= '0';                              
                    Est <= E5;
                    
                when E5 =>
                    CAP <= '0';
                    EN_1K <= '1';
                    Est <= E6;
                    
                when E6 =>
                    if x = kernel_size-1 then
                        Est <= E7;
                    else 
                        x <= x + 1;
                        Est <= E6;
                    end if;
                    
                when E7 =>
                    rst <= '1';
                    EN_1K <= '0';
                    x <= 0;
                    Est <= E1;
                                                     
                when E8 =>
                    rst <= '0';
                    T_ready <= '1';                              
                    if T_valid = '1' then
                        Est <= E9;
                    else
                        Est <= E8;
                    end if; 
                
                when E9 =>
                    CAP <= '1';
                    T_ready <= '0';
                    Est <= E10; 
                    
                when E10 =>
                    CAP <= '0';
                    EN_1 <= '1';
                    Est <= E11;                    
                             
                when E11 =>
                    if x = matriz_size + 1 then 
                        Est <= E12;
                    else 
                        x <= x + 1;
                        Est <= E11;
                    end if;             

                when E12 =>
                    rst <= '1';
                    EN_1 <= '0';
                    x <= 0;
                    Est <= E13;
                    
                when E13 =>
                    y <= y + 1;
                    if y = imagen_size then
                        Est <= E14;
                    else 
                        Est <= E8;
                    end if;       
                    
                when E14 =>
                    y <= 0;
                    Est <= E1;        
                    
                when E15 =>
                    EN_1 <= '1';
                    Est <= E16;  
                    
                when E16 =>
                    x <= x + 1;
                    if x = matriz_size + 2 then 
                        Est <= E17;
                    else 
                        Est <= E15;
                    end if;  
                    
                when E17 =>
                    y <= y + 1;
                    if y = padding_size then 
                        Est <= E18;
                    else 
                        Est <= E15;
                    end if; 
                                                                                                         
                when E18 =>
                    x <= 0;
                    y <= 0;
                    Est <= E19;
                    
                when E19 =>
                    rst <= '0';
                    EN_1 <= '0';                    
                    T_ready <= '1';                              
                    if T_valid = '1' then
                        Est <= E20;
                    else
                        Est <= E19;
                    end if;       
                    
                when E20 =>
                    CAP <= '1';                    
                    T_ready <= '0';
                    Est <= E21;                                  
       
                when E21 =>
                    CAP <= '0';                    
                    EN_1 <= '1';
                    Est <= E22; 

                when E22 =>
                    x <= x + 1;
                    if x = matriz_size + 4 then 
                        Est <= E23;
                    else 
                        Est <= E22;
                    end if;
                    
                when E23 =>
                    rst <= '1';                    
                    EN_1 <= '0';
                    Est <= E24; 
                    
                when E24 =>
                    y <= y + 1;
                    if y = imagen_size then
                        Est <= E25;
                    else 
                        Est <= E19;
                    end if;                                         

                when E25 =>
                    x <= 0;
                    y <= 0;
                    Est <= E26;
                    
                when E26 =>                    
                    EN_1 <= '1';
                    Est <= E27;                     
                    
                when E27 =>
                    x <= x + 1;
                    if x = matriz_size + 4 then 
                        Est <= E28;
                    else 
                        Est <= E26;
                    end if;
                    
                when E28 =>
                    y <= y + 1;
                    if y = padding_size then
                        Est <= E29;
                    else 
                        Est <= E26;
                    end if;                                         

                when E29 =>
                    x <= 0;
                    y <= 0;
                    Est <= E1;
                                                                                                                                                       
                when others =>
                    rst <= '1';
                    CAP <= '0';
                    EN_1K <= '0';                    
                    EN_1 <= '0';
                    SEL <= '0';
                    T_ready <= '0';                   
            end case;
        end if;
    end process;

end Behavioral;