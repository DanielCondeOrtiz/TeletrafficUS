%% Función que calcula la probabilidad de retardo según ErlangC
%% Parámetros:
%%     A:    tráfico ofrecido
%%     m:    número de servidores
%% Devuelve: la probabilidad de demora.
function bd = erlangC(A, m)
    bd = erlangB(A, m) / (1 - A/m * (1 - erlangB(A, m)));
end

