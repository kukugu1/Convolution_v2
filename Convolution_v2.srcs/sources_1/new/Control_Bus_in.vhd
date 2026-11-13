library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity Control_Bus_in is
    generic(
        Register_kernel_size : integer := 27;
        matriz_size          : integer := 128
    );
    port(
        clk, selector, T_valid : in std_logic;
        Not_WAIT               : in std_logic;
        Bus_valid_Size         : in std_logic_vector(2 downto 0);
        kernel, Padding        : in std_logic_vector(1 downto 0);
        rst, CAP, SEL, T_ready : out std_logic;
        EN_1K, EN_1M           : buffer std_logic
    );
end Control_Bus_in;

architecture Behavioral of Control_Bus_in is
    signal imagen_size, kernel_size, padding_size : integer;
    type estados is(ini,E1,E2,E3,E4,E5,E6,E7,E8,E9,
                    E10,E11,E12,E13,E14,E15,E16,E17,E18,E19,
                    E20,E21,E22,E23,E24,E25,E26,E27,E28,E29,
                    E30,E31,E32,E33,E34,E35);
                    
    signal Est  : estados;
    signal x, y : integer range 0 to 132;
    
--     Bus_valid_Size <= "000" -- Tamaño de imagen 8x8
--     Bus_valid_Size <= "001" -- Tamaño de imagen 16x16
--     Bus_valid_Size <= "010" -- Tamaño de imagen 32x32
--     Bus_valid_Size <= "011" -- Tamaño de imagen 64x64
--     Bus_valid_Size <= "100" -- Tamaño de imagen 128x128
--     else           <= "100" -- Tamaño de imagen 128x128 (Valor invalido)

--     kernel <= "00" -- kernel 2x2
--     kernel <= "01" -- kernel 3x3
--     kernel <= "10" -- kernel 4x4
--     kernel <= "11" -- kernel 5x5

--     Padding <= "00" -- Padding de 0
--     Padding <= "01" -- Padding de 1
--     Padding <= "10" -- Padding de 2
--     Padding <= "11" -- Padding de 0 (Valor invalido)

begin

    imagen_size  <= 8 when Bus_valid_Size = "000" else 16 when Bus_valid_Size = "001" else
                    32 when Bus_valid_Size = "010" else 64 when Bus_valid_Size = "011" else
                    128 when Bus_valid_Size = "100" else 0;
                   
    kernel_size  <= 2 when kernel = "00" else 3 when kernel = "01" else
                    4 when kernel = "10" else 5 when kernel = "11";
                                       
    padding_size <= 0 when Padding = "00" else 1 when Padding = "01" else
                    2 when Padding = "10" else 0;
                   
    process(clk)
    begin
        if rising_edge(clk) then
            if Not_WAIT = '1' then
                case Est is
                    when ini =>
                        rst     <= '1';
                        CAP     <= '0';
                        EN_1K   <= '0';                    
                        EN_1M   <= '0';
                        SEL     <= '0';
                        T_ready <= '0';
                        Est     <= E1;
                                        
                    when E1 =>
                        if selector = '0' then
                            T_ready <= '1';
                            Est     <= E2;
                        else
                            SEL     <= '1';
                            Est     <= E3;
                        end if;   
                            
                    when E2 =>
                        if T_valid = '1' then
                            rst     <= '0';
                            CAP     <= '1';
                            T_ready <= '0';
                            Est     <= E4;
                        else
                            T_ready <= '1';
                            Est     <= E2;
                        end if;   
                            
                    when E3 =>
                        SEL <= '1';                                   
                        if Padding = "00" then
                            rst     <= '0';
                            T_ready <= '1';
                            Est     <= E8;
                        elsif Padding = "01" OR Padding = "10" then
                            EN_1M   <= '1';
                            Est     <= E18;
                        else
                            rst     <= '0';
                            CAP     <= '0';
                            EN_1K   <= '0';
                            EN_1M   <= '0';
                            SEL     <= '0';
                            T_ready <= '0';
                            Est     <= ini;
                        end if;
                        
                    when E4 =>
                        CAP   <= '0';
                        EN_1K <= '1';                              
                        Est   <= E5;
                        
                    when E5 =>
                        x     <= x + 1;
                        Est   <= E6;
                        
                    when E6 =>
                        if x = Register_kernel_size then
                            rst   <= '1';
                            x     <= 0;
                            EN_1K <= '0';
                            Est   <= E7;
                        else 
                            x     <= x + 1;
                            Est   <= E6;
                        end if;
                        
                    when E7 =>
                        y       <= 0;
                        rst     <= '1';
                        CAP     <= '0';
                        EN_1K   <= '0';                    
                        EN_1M   <= '0';
                        SEL     <= '0';
                        T_ready <= '0';
                        Est     <= E1;
                                                         
                    when E8 =>                             
                        if T_valid = '1' then
                            CAP     <= '1';
                            T_ready <= '0';
                            Est     <= E9;
                        else
                            rst     <= '0';
                            T_ready <= '1';
                            Est     <= E8;
                        end if; 
                    
                    when E9 =>
                        CAP   <= '0';
                        EN_1M <= '1';
                        Est   <= E10;
                        
                    when E10 =>
                        x     <= x + 1;
                        Est   <= E11;
                                 
                    when E11 =>
                        if x = matriz_size + 5 then
                            rst   <= '1';
                            EN_1M <= '0';
                            x     <= 0;
                            Est   <= E12;
                        else
                            x     <= x + 1;
                            Est   <= E11;
                        end if;
                
                    when E12 =>
                        y   <= y + 1;
                        Est <= E13;
                        
                    when E13 =>
                        if y = imagen_size then
                            y       <= 0;
                            Est     <= E14;
                        else 
                            rst     <= '0';
                            T_ready <= '1';
                            Est     <= E8;
                        end if;       
                        
                    when E14 =>
                        y <= 0;
                        if 5 - kernel_size - y = 0 then
                            y       <= 0;
                            rst     <= '1';
                            CAP     <= '0';
                            EN_1K   <= '0';                    
                            EN_1M   <= '0';
                            SEL     <= '0';
                            T_ready <= '0';
                            Est     <= E1;
                        else
                            EN_1M   <= '1';
                            Est     <= E15;
                        end if;
                        
                    when E15 =>
                        x   <= x + 1;
                        Est <= E16;
                        
                    when E16 =>
                        if x = matriz_size + 5 then
                            EN_1M <= '0';
                            x     <= 0;
                            y     <= y + 1;
                            Est   <= E17;
                        else 
                            x     <= x + 1;
                            Est   <= E16;
                        end if;
                        
                    when E17 =>
                        if 5 - kernel_size - y = 0 then
                            y       <= 0;
                            rst     <= '1';
                            CAP     <= '0';
                            EN_1K   <= '0';                    
                            EN_1M   <= '0';
                            SEL     <= '0';
                            T_ready <= '0';
                            Est     <= E1;
                        else
                            EN_1M   <= '1';
                            Est     <= E15;
                        end if;
                        
                    when E18 =>
                        x   <= x + 1;
                        Est <= E19;
                        
                    when E19 =>
                        if x = matriz_size + 5 then
                            EN_1M <= '0';
                            x     <= 0;
                            y     <= y + 1;
                            Est   <= E20;
                        else
                            x     <= x + 1;
                            Est   <= E19;
                        end if;
                        
                    when E20 =>
                        if y = padding_size then
                            x     <= 0;
                            y     <= 0;
                            Est   <= E21;
                        else
                            EN_1M <= '1';
                            Est   <= E18;
                        end if;
                        
                    when E21 =>
                        rst     <= '0';
                        EN_1M   <= '0';                    
                        T_ready <= '1';
                        Est     <= E22;      
                        
                    when E22 =>
                        if T_valid = '1' then
                            CAP     <= '1';
                            T_ready <= '0';
                            Est     <= E23;
                        else
                            rst     <= '0';
                            EN_1M   <= '0';                    
                            T_ready <= '1';
                            Est     <= E22;
                        end if;
                
                    when E23 =>
                        CAP   <= '0';                    
                        EN_1M <= '1';
                        Est   <= E24; 
                
                    when E24 =>
                        x   <= x + 1;
                        Est <= E25;
                        
                    when E25 =>
                        if x = matriz_size + 5 then
                            x     <= 0;
                            rst   <= '1';
                            EN_1M <= '0';
                            Est   <= E26;
                        else
                            x   <= x + 1;
                            Est <= E25;
                        end if;
                        
                    when E26 =>
                        y   <= y + 1;
                        Est <= E27;
                
                    when E27 =>
                        if y = imagen_size then
                            x       <= 0;
                            y       <= 0;
                            Est     <= E28;
                        else 
                            rst     <= '0';
                            EN_1M   <= '0';
                            T_ready <= '1';
                            Est     <= E22;
                        end if;
                        
                    when E28 =>
                        EN_1M <= '1';
                        Est   <= E29;
                        
                    when E29 =>
                        x   <= x + 1;
                        Est <= E30;
                        
                    when E30 =>
                        if x = matriz_size + 5 then 
                            x     <= 0;
                            EN_1M <= '0';
                            y     <= y + 1;
                            Est   <= E31;
                        else 
                            x     <= x + 1;
                            Est   <= E30;
                        end if;
                
                    when E31 =>
                        if y = padding_size then
                            y     <= 0;
                            Est   <= E32;
                        else
                            EN_1M <= '1';
                            Est   <= E29;
                        end if;
                        
                    when E32 =>
                        if 5 - kernel_size - y = 0 then
                            y       <= 0;
                            rst     <= '1';
                            CAP     <= '0';
                            EN_1K   <= '0';                    
                            EN_1M   <= '0';
                            SEL     <= '0';
                            T_ready <= '0';
                            Est     <= E1;
                        else
                            EN_1M   <= '1';
                            Est     <= E33;
                        end if;
                        
                    when E33 =>
                        x   <= x + 1;
                        Est <= E34;
                    
                    when E34 =>
                        if x = matriz_size + 5 then
                            x     <= 0;
                            y     <= y + 1;
                            EN_1M <= '0';
                            Est   <= E35;
                        else
                            x     <= x + 1;
                            Est   <= E34;
                        end if;
                        
                    when E35 =>
                        if 5 - kernel_size - y = 0 then
                            y       <= 0;
                            rst     <= '1';
                            CAP     <= '0';
                            EN_1K   <= '0';                    
                            EN_1M   <= '0';
                            SEL     <= '0';
                            T_ready <= '0';
                            Est     <= E1;
                        else
                            EN_1M   <= '1';
                            Est     <= E33;
                        end if;
                                                                                                                         
                    when others =>
                        rst     <= '1';
                        CAP     <= '0';
                        EN_1K   <= '0';                    
                        EN_1M   <= '0';
                        SEL     <= '0';
                        T_ready <= '0';                   
                end case;            
            end if;
        end if;
    end process;

end Behavioral;