%% Función que calcula la probabilidad de bloqueo según ErlangB
%% Parámetros:
%%     A:    tráfico ofrecido
%%     m:    número de servidores
%% Devuelve: la probabilidad de bloqueo.
function bll = erlangB(A, m)
    bll = 1 / erlangAux(A, m);
end

function i = erlangAux(A, m)
    if (m == 0)
        i = 1;
    else
        i = 1 + m * erlangAux(A, m-1) / A;
    end
end
