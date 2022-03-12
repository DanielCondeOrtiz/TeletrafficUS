% Función que emula el comportamiento de un sistema M/M/m/m
%
% Parámetros:
%     tasa_llegadas:      valor medio de la tasa de llegadas según Poisson
%     tiempo_servicio:    valor medio del tiempo de servicio según exponencial
%     servidores:         número de servidores del sistema M/M/m/m
%     min_tiempo:         tiempo mínimo de duración de la simulación
%
% Devuelve: un array con los siguientes elementos:
%     tasa de llegadas observada
%     tiempo de servicio medido
%     tráfico cursado durante la simulación
%     tiempo medio de permanencia en el sistema
%     número medio de usuarios en el sistema
%     probabilidades de estado de cada uno de los posibles estados.
%          El array va de 1 a servidores+1, indicando las probabilidades de
%          los estados 0 a servidores.
%

function result = MMmmInicial(tasa_llegadas,
                              tiempo_servicio,
                              servidores,
                              min_tiempo)

  %% 'Constantes' utilizadas
  SALIDA  = 1;
  LLEGADA = 0;

  %% Valores teóricos
  To = tasa_llegadas * tiempo_servicio;
  TcTeorico = To * (1 - erlangB(To, servidores));
  display(['  Tc: ', num2str(TcTeorico)]);

  %% inicialización
  tiempo_simulado       = 0.0;
  ultimo_evento         = 0.0;
  usuarios_en_cola      = 0;
  usuarios_en_servicio  = 0;
  siguientes_salidas(1:servidores) = Inf;
  siguiente_llegada     = exprnd(1 / tasa_llegadas);

  %% %%%%% Inicializamos los acumuladores necesarios
  %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %% Establecemos el final del bucles tras un tiempo simulado,
  %% en el momento en que el sistema quede vacío.
  while (tiempo_simulado < min_tiempo || usuarios_en_servicio > 0)
    %% Seleccionamos el primer servidor en terminar y su instante de salida
    [siguiente_salida, indice] = min(siguientes_salidas);
    %% Comprobamos el tipo de evento y actualizamos el tiempo actual.
    if (siguiente_salida > siguiente_llegada)
      evento = LLEGADA;
      tiempo_simulado = siguiente_llegada;
      %% %%%%% Actualizamos el número de llegadas
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    else
      evento = SALIDA;
      tiempo_simulado = siguiente_salida;
      %% %%%%% Actualizamos el número de salidas
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    intervalo = tiempo_simulado - ultimo_evento;
 
    %% %%%%% Actualizamos los acumuladores
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %% Procesamos el evento correspondiente:
    if (evento == LLEGADA)
      %% Se ha producido una nueva llegada
      if (usuarios_en_servicio < servidores)
        %% Hay servidores libres
        usuarios_en_servicio = usuarios_en_servicio + 1;
        %% Programamos el siguiente instante de salida
        t_servicio = exprnd(tiempo_servicio);
        siguientes_salidas(buscaLibre(siguientes_salidas)) = tiempo_simulado + t_servicio;
        %% %%%%% Acumulamos los tiempos de servicio
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     end
      %% Programamos la siguiente llegada
      t_llegada = exprnd(1 / tasa_llegadas);
      siguiente_llegada = tiempo_simulado + t_llegada;
      %% %%%%% Acumulamos el tiempo entre llegadas
      %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    else
      %% Se ha producido una salida
      siguientes_salidas(indice) = Inf;
      %% Quitamos a un usuario del servidor
      usuarios_en_servicio = usuarios_en_servicio - 1;
    end
    ultimo_evento = tiempo_simulado;
  end
  
  %% %%%%% Calculamos los valores medios
  %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %% %%%%% Rellenamos el array resultado
  %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  result = [ 0 ];
end




%% Función que busca un servidor libre (tiempo de salida igual a Inf)
% Parámetros:
%     salidas:      array con los tiempos de salida de cada servidor
% Devuelve: el índice del primer elemenento con tiempo de salida Inf
function indice = buscaLibre(salidas)
    indice = find(salidas==Inf, 1);
end
