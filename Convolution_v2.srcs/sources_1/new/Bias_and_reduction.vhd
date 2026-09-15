library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Bias_and_reduction is
    generic(
        Data_in_length : natural := 22;
        Bias_length    : natural := 8
    );
    Port ( 
        Bias       : in std_logic_vector(Bias_length-1 downto 0);    
        Data_in    : in std_logic_vector(Data_in_length-1 downto 0);
        Data_out   : out std_logic_vector(7 downto 0)
    );
end Bias_and_reduction;

architecture Behavioral of Bias_and_reduction is
    signal Sum_result   : std_logic_vector(Data_in_length-1 downto 0);
    
begin

    Sum_result <= std_logic_vector(signed(Data_in) + signed(Bias));
    Data_out <= Sum_result(Data_in_length-1 downto Data_in_length-8);

end Behavioral;
