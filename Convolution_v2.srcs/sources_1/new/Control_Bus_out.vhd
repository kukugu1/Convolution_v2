library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Control_Bus_out is
    Port ( 
        clk, VALID_OUT, T_ready : in std_logic;
        Padding, kernel, Stride : in std_logic_vector(1 downto 0);
        Bus_valid_Size          : in std_logic_vector(2 downto 0);
        WAIT_0                  : buffer std_logic;        
        RST, CAP, EN_2, T_valid : out std_logic
    );
end Control_Bus_out;

architecture Behavioral of Control_Bus_out is
signal imagen_size, kernel_size, Padding_size, Stride_size : integer;
type estados is(ini,E1,E2,E3,E4,E5,E6);
signal Est  : estados;
signal x : integer := 0;
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

--     Stride <= "00" -- Stride de 1 (Valor invalido)
--     Stride <= "01" -- Stride de 1
--     Stride <= "10" -- Stride de 2
--     Stride <= "11" -- Stride de 3

begin
    imagen_size  <= 8 when Bus_valid_Size = "000" else 16 when Bus_valid_Size = "001" else
                    32 when Bus_valid_Size = "010" else 64 when Bus_valid_Size = "011" else
                    128 when Bus_valid_Size = "100" else 128;
                   
    kernel_size  <= 2 when kernel = "00" else 3 when kernel = "01" else
                    4 when kernel = "10" else 5 when kernel = "11";
    
    Padding_size <= 0 when Padding = "00" else 1 when Padding = "01" else
                    2 when Padding = "10" else 0;
                    
    Stride_size  <= 2 when Stride = "10" else 3 when Stride = "11" else
                    1;
                    
    process(clk)
    begin
        if falling_edge(clk) then
            case Est is
                when ini =>
                    RST <= '1';
                    CAP <= '0';
                    EN_2 <= '0';
                    T_valid <= '0';
                    WAIT_0 <= '0';
                    if VALID_OUT = '1' then
                        Est <= E1;
                    else
                        Est <= ini;
                    end if;        
                            
                when E1 =>
                    RST <= '0';
                    CAP <= '1';
                    EN_2 <= '0';
                    T_valid <= '0';
                    WAIT_0 <= '0';   
                    Est <= E2;
                                 
                when E2 =>
                    RST <= '0';
                    CAP <= '1';
                    EN_2 <= '1';
                    T_valid <= '0';
                    WAIT_0 <= '0'; 
                    Est <= E3;
                                   
                when E3 => 
                    x <= 0;
                    Est <= E4;
                    
                when E4 => 
                    x <= x + 1;
                    if x = ((imagen_size+2*Padding_size-kernel_size)/Stride_size)-2 then
                        Est <= E5;
                    else
                        Est <= E4;
                    end if;
                    
                when E5 =>
                    RST <= '0';
                    CAP <= '0';
                    EN_2 <= '0';
                    T_valid <= '0';
                    WAIT_0 <= '1'; 
                    Est <= E6;
                                        
                when E6 => 
                    RST <= '0';
                    CAP <= '0';
                    EN_2 <= '0';
                    T_valid <= '1';
                    WAIT_0 <= '1'; 
                    if T_ready = '1' then
                        Est <= ini;
                    else
                        Est <= E6;
                    end if;
                                    
                when others => 
                    RST <= '1';
                    CAP <= '0';
                    EN_2 <= '0';
                    T_valid <= '0';
                    WAIT_0 <= '0';
            end case;
        end if;
    end process;        

end Behavioral;
