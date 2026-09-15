library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.constantes_pkg.all;

entity Convolution is
    generic(
        Data_length    : integer := 128;
        Data_in_length : natural := 22;
        Bias_length    : natural := 8;
        Bits        : integer := 8 
    );
    Port (
        Data_in  : in std_logic_vector((Data_length*Bits)-1 downto 0); --1024 datos    
        Bias     : in std_logic_vector(Bias_length-1 downto 0);
        clk, selector, T_valid_in, T_ready_in : in std_logic;
        Bus_valid_Size : in std_logic_vector(2 downto 0);
        Padding, kernel, Stride : in std_logic_vector(1 downto 0);
        T_ready_out, T_valid_out : out std_logic;
        data_out : out std_logic_vector((Data_length*Bits)-1 downto 0)
                         
    );
end Convolution;

architecture Behavioral of Convolution is
signal rst_RPS, CAP_RPS, SEL  : std_logic;
signal rst_RSP, CAP_RSP, EN_2 : std_logic;
signal SR_Capture, EN_1, clk_EN_1, AdderTree_Enable: std_logic;
 
begin

    OA : entity work.Operational_Architecture
    generic map(
        Data_length => Data_length,
        Data_in_length => Data_in_length,
        Bias_length => Bias_length
    )
    port map(
        Data_in => Data_in,
        Bias => Bias,
        clk => clk,
        clk_EN_1 => clk_EN_1,
        rst_RPS => rst_RPS,
        CAP_RPS => CAP_RPS,
        EN_1 => EN_1,
        SEL => SEL,
        rst_RSP => rst_RSP,
        CAP_RSP => CAP_RSP,
        EN_2 => EN_2,   
        SR_Capture => SR_Capture,
        AdderTree_Enable => AdderTree_Enable,
        data_out => data_out    
    );
    
    CA : entity work.Control_Architecture
    port map(
        clk => clk,
        selector => selector,
        T_valid_in => T_valid_in,
        T_ready_in => T_ready_in,
        Bus_valid_Size => Bus_valid_Size,
        kernel => kernel,
        Stride => Stride,
        Padding => Padding,    
        rst_RPS => rst_RPS,
        CAP_RPS => CAP_RPS,            
        SEL => SEL,     
        T_ready_out => T_ready_out,
        rst_RSP => rst_RSP,
        CAP_RSP => CAP_RSP,         
        EN_2 => EN_2,
        T_valid_out => T_valid_out,    
        SR_Capture => SR_Capture,        
        EN_1 => EN_1,            
        clk_EN_1 => clk_EN_1,
        AdderTree_Enable => AdderTree_Enable           
    );

end Behavioral;
