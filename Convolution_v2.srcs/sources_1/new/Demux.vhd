library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Demux is
    generic(
        Data_length : natural := 64
    );
    Port ( 
        sel      : in  std_logic;    
        entrada  : in  std_logic_vector(Data_length-1 downto 0);
        salida_1 : out std_logic_vector(Data_length-1 downto 0);
        salida_0 : out std_logic_vector(Data_length-1 downto 0)        
    );
end Demux;

architecture Behavioral of Demux is
begin
    process(entrada, sel)
    begin
        salida_1 <= (others => '0');  
        salida_0 <= (others => '0');        
        case sel is
            when '1' => 
                salida_1 <= entrada;
                salida_0 <= (others => '0');         
            when '0' => 
                salida_1 <= (others => '0');                     
                salida_0 <= entrada;
        end case;
    end process;
end Behavioral;