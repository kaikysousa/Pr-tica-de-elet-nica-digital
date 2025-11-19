library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Topo_Aula is
    Port (
        clk     : in  STD_LOGIC; -- Clock de 50MHz (PIN_E1)
        rst_n   : in  STD_LOGIC; -- Reset (Botão, ativo baixo)
        
        -- Botões físicos da placa AX301
        key1    : in  STD_LOGIC; -- Incrementa A
        key2    : in  STD_LOGIC; -- Incrementa B
        key3    : in  STD_LOGIC; -- Incrementa Seletor
        
        -- Saídas físicas
        leds    : out STD_LOGIC_VECTOR(3 downto 0); -- LEDs da placa
        seg     : out STD_LOGIC_VECTOR(7 downto 0); -- Segmentos (a,b,c,d,e,f,g,dp)
        dig     : out STD_LOGIC_VECTOR(5 downto 0)  -- Escolha do dígito (DIG1 a DIG6)
    );
end Topo_Aula;

architecture Behavioral of Topo_Aula is

    -- Componente da sua ULA (deve ter o mesmo nome do seu arquivo anterior)
    component ULA is
        Port (
            entrada_a : in  STD_LOGIC_VECTOR(3 downto 0);
            entrada_b : in  STD_LOGIC_VECTOR(3 downto 0);
            seletor_operacao : in  STD_LOGIC_VECTOR(1 downto 0); 
            resultado_final     : out STD_LOGIC_VECTOR(3 downto 0); 
            indicador_overflow  : out STD_LOGIC;                    
            indicador_carry_out : out STD_LOGIC
        );
    end component;

    -- Sinais internos (Contadores)
    signal contador_A : unsigned(3 downto 0) := (others => '0');
    signal contador_B : unsigned(3 downto 0) := (others => '0');
    signal contador_S : unsigned(1 downto 0) := (others => '0');
    
    -- Sinais para conectar na ULA
    signal w_resultado : std_logic_vector(3 downto 0);
    signal w_over, w_cout : std_logic;

    -- Sinais para tratamento de botão (borda de subida simples)
    signal key1_ant, key2_ant, key3_ant : std_logic := '1';

    -- Tabela para Display de 7 segmentos (Anodo Comum ou Catodo Comum? Ajustado para AX301 padrão)
    function display_decode(valor : std_logic_vector(3 downto 0)) return std_logic_vector is
    begin
        case valor is
            -- Padrão AX301 (gfe_dcba) invertido se for anodo comum
            when "0000" => return "11000000"; -- 0
            when "0001" => return "11111001"; -- 1
            when "0010" => return "10100100"; -- 2
            when "0011" => return "10110000"; -- 3
            when "0100" => return "10011001"; -- 4
            when "0101" => return "10010010"; -- 5
            when "0110" => return "10000010"; -- 6
            when "0111" => return "11111000"; -- 7
            when "1000" => return "10000000"; -- 8
            when "1001" => return "10010000"; -- 9
            when "1010" => return "10001000"; -- A
            when "1011" => return "10000011"; -- B
            when "1100" => return "11000110"; -- C
            when "1101" => return "10100001"; -- D
            when "1110" => return "10000110"; -- E
            when "1111" => return "10001110"; -- F
            when others => return "11111111"; -- Apagado
        end case;
    end function;

begin

    -- Conectar a ULA
    Minha_ULA: ULA port map (
        entrada_a => std_logic_vector(contador_A),
        entrada_b => std_logic_vector(contador_B),
        seletor_operacao => std_logic_vector(contador_S),
        resultado_final => w_resultado,
        indicador_overflow => w_over,
        indicador_carry_out => w_cout
    );

    -- Processo para contar quando aperta os botões
    process(clk)
    begin
        if rising_edge(clk) then
            -- Detector de borda de descida (botão apertado = 0 na AX301)
            if key1_ant = '1' and key1 = '0' then
                contador_A <= contador_A + 1;
            end if;
            
            if key2_ant = '1' and key2 = '0' then
                contador_B <= contador_B + 1;
            end if;
            
            if key3_ant = '1' and key3 = '0' then
                contador_S <= contador_S + 1;
            end if;
            
            -- Reset
            if rst_n = '0' then
                contador_A <= (others => '0');
                contador_B <= (others => '0');
                contador_S <= (others => '0');
            end if;

            -- Atualiza estado anterior
            key1_ant <= key1;
            key2_ant <= key2;
            key3_ant <= key3;
        end if;
    end process;

    -- Saídas para os LEDs (conforme pedido: LED0=cout, LED1=over, LED2/3=Seletor)
    -- Nota: Na AX301 LED acende com '0' ou '1'? Geralmente '0'. 
    -- Se for '0', inverta: leds <= not (std_logic_vector(contador_S) & w_over & w_cout);
    leds(0) <= w_cout;
    leds(1) <= w_over;
    leds(3 downto 2) <= std_logic_vector(contador_S);

    -- Display (Mostra o resultado F)
    seg <= display_decode(w_resultado);
    dig <= "111110"; -- Ativa apenas o primeiro dígito (DIG0 = 0, os outros 1)

end Behavioral;