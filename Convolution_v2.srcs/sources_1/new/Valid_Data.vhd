library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity Valid_Data is
    generic(
        DELAY_AdderTree_Enable : integer := 1;
        DELAY_VALID_OUT        : integer := 7
    );
    Port (
        clk                         : in std_logic;
        Bus_valid_Size              : in std_logic_vector(2 downto 0);
        kernel, Stride, Padding     : in std_logic_vector(1 downto 0);
        SR_Capture                  : buffer std_logic;
        AdderTree_Enable, VALID_OUT : out std_logic
    );
end Valid_Data;

architecture Behavioral of Valid_Data is
    signal imagen_size, kernel_size, padding_size, signal_mixer : integer;
    type sr_array is array (0 to DELAY_VALID_OUT-1) of std_logic;
    signal sr : sr_array;
    type estados is(ini,E1,E2,E3,E4,E5,E6,E7,E8,E9,
                    E10,E11,E12,E13,E14,E15,E16,E17,E18,E19,
                    E20,E21,E22,E23,E24);
    signal Est : estados;
    signal x, y, c : integer := 0;
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

--     Stride <= "00" -- Stride de 0 (Valor invalido)
--     Stride <= "01" -- Stride de 1
--     Stride <= "10" -- Stride de 2
--     Stride <= "11" -- Stride de 3

begin
    imagen_size  <= 8 when Bus_valid_Size = "000" else 16 when Bus_valid_Size = "001" else
                    32 when Bus_valid_Size = "010" else 64 when Bus_valid_Size = "011" else
                    128 when Bus_valid_Size = "100" else 128;
                   
    kernel_size  <= 2 when kernel = "00" else 3 when kernel = "01" else 
                    4 when kernel = "10" else 5 when kernel = "11";
                   
    padding_size <= 0 when Padding = "00" else 1 when Padding = "01" else
                    2 when Padding = "10" else 0;
    
    signal_mixer <= imagen_size + padding_size;
    
    process(clk)
    begin
        if rising_edge(clk) then
            sr(0) <= SR_Capture;
            for i in 1 to DELAY_VALID_OUT-1 loop
                sr(i) <= sr(i-1);
            end loop;
        end if;
    end process;
    
    process(clk)
    begin
        if rising_edge(clk) then
            case Est is
                when ini =>
                    if Stride = "01" then
                        SR_Capture <= '0';
                        x          <= x + 1;
                        Est        <= E1;
                    elsif Stride = "10" then
                        SR_Capture <= '0';
                        x          <= x + 1;
                        Est        <= E8;
                    elsif Stride = "11" then
                        Est        <= E16;
                    else
                        SR_Capture <= '0';
                        x          <= 0;
                        c          <= 0;
                        y          <= 0;
                        Est        <= ini;
                    end if;
                    
                when E1 =>
                    if x = 135*4+6 then
                        x          <= 0;
                        Est        <= E2;
                    else
                        x          <= x + 1;
                        Est        <= E1;
                    end if;
                    
                when E2 =>
                    SR_Capture <= '1';
                    x          <= x + 1;
                    c          <= c + 1;
                    Est        <= E3;
                                        
                when E3 =>
                    if x = signal_mixer - kernel_size then
                        SR_Capture <= '0';
                        x          <= 0;
                        c          <= c + 1;
                        Est        <= E4;
                    else
                        x          <= x + 1;
                        c          <= c + 1;
                        Est        <= E3;
                    end if;
                                    
                when E4 =>
                    if c = 135-1 then
                        c          <= 0;
                        y          <= y + 1;
                        Est        <= E5;
                    else
                        x          <= 0;
                        c          <= c + 1;
                        Est        <= E4;
                    end if;
                                     
                when E5 =>
                    if y = signal_mixer - kernel_size then
                        SR_Capture <= '1';
                        x          <= x + 1;
                        c          <= c + 1;
                        Est        <= E6;
                    else
                        SR_Capture <= '1';
                        x          <= x + 1;
                        c          <= c + 1;
                        Est        <= E3;
                    end if;
                                       
                when E6 => 
                    -- Solo para kernel de 5x5
                    if x = signal_mixer - kernel_size then
                        SR_Capture <= '0';
                        c          <= c + 1;
                        Est        <= E7;
                    else
                        x          <= x + 1;
                        c          <= c + 1;
                        Est        <= E6;
                    end if;
                
                when E7 =>
                    if c = 129 - 1 then
                        SR_Capture <= '0';
                        x          <= 0;
                        c          <= 0;
                        y          <= 0;
                        Est        <= ini;
                    else
                        c          <= c + 1;
                        Est        <= E7;
                    end if;
                    
                    -- ************ Stride 2 ************ 
                
                when E8 =>
                    if x = 135 * 4 + 6 then
                        x   <= 0;
                        Est <= E9;
                    else
                        x   <= x + 1;
                        Est <= E8;
                    end if;
                    
                when E9 =>
                    SR_Capture <= '1';
                    x          <= x + 1;
                    c          <= c + 1;
                    Est        <= E10;
                                     
                when E10 =>
                    SR_Capture <= '0';
                    c          <= c + 1;
                    Est        <= E11;
                                  
                when E11 =>
                    if x = (signal_mixer-kernel_size)/2 then
                        x          <= 0;
                        c          <= c + 1;
                        Est        <= E12;
                    else
                        SR_Capture <= '1';
                        x          <= x + 1;
                        c          <= c + 1;
                        Est        <= E10;
                    end if;   
                                     
                when E12 =>
                    if c = 135-1 then
                        x   <= x + 1;
                        Est <= E13;
                    else
                        x   <= 0;
                        c   <= c + 1;
                        Est <= E12;
                    end if;
                                        
                when E13 =>
                    if x = 135 then
                        x   <= 0;
                        c   <= 0;
                        y   <= y + 1;
                        Est <= E14;
                    else
                        x   <= x + 1;
                        Est <= E13;
                    end if;
                    
                when E14 =>
                    if y = (signal_mixer - kernel_size)/2 then
                        SR_Capture <= '1';
                        x          <= x + 1;
                        c          <= c + 1;
                        Est        <= E15;
                    else
                        SR_Capture <= '1';
                        x          <= x + 1;
                        c          <= c + 1;
                        Est        <= E10;
                    end if;
                
                when E15 =>
                    SR_Capture <= '0';
                    c          <= c + 1;
                    Est        <= E16;
                    
                when E16 =>
                    if x=(signal_mixer-kernel_size)/2 then
                        c          <= c + 1;
                        Est        <= E17;
                    else
                        SR_Capture <= '1';
                        x          <= x + 1;
                        c          <= c + 1;
                        Est        <= E15;
                    end if;
                
                when E17 =>
                    if c = 129 - 1 then
                        SR_Capture <= '0';
                        x          <= 0;
                        c          <= 0;
                        y          <= 0;
                        Est        <= ini;
                    else
                        c          <= c + 1;
                        Est        <= E17;
                    end if;
                when others =>
                    SR_Capture <= '0';
            end case;
        end if;
    end process;      
    
    AdderTree_Enable <= sr(DELAY_AdderTree_Enable-1);
    VALID_OUT <= sr(DELAY_VALID_OUT-1);

end Behavioral;
