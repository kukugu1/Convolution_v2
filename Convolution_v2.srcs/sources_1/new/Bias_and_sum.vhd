library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Bias_and_sum  is
    generic(
        Data_in_length  : natural := 22;
        Data_out_length : natural := 32;
        Bias_length     : natural := 8
    );
    Port (
        Bias       : in  std_logic_vector(Bias_length-1 downto 0);
        Data_in    : in  std_logic_vector(Data_in_length-1 downto 0);
        Data_out   : out std_logic_vector(Data_out_length-1 downto 0)
    );
end Bias_and_sum ;

architecture Behavioral of Bias_and_sum is
begin

    Data_out <= std_logic_vector(
                    resize(signed(Data_in), Data_out_length) +
                    resize(signed(Bias),    Data_out_length)
                );

end Behavioral;