% Función que emula el comportamiento de un sistema M/M/m/m
%
% Parámetros:
%     tasa_llegadas:      valor medio de la tasa de llegadas según Poisson
%     tiempo_servicio:    valor medio del tiempo de servicio según exponencial
%     servidores:         número de servidores del sistema M/M/m/m
%     min_eventos:        número mínimo de eventos de la emulación
%
% Devuelve: un array con los siguientes elementos:
%     tráfico cursado durante la emulación
%     tráfico perdido durante la emulación
%     tiempo medio de permanencia en el sistema
%     número medio de usuarios en el sistema
%     probabilidades de estado de cada uno de los posibles estados.
%          El array va de 1 a servidores+1, indicando las probabilidades de
%          los estados 0 a servidores.
%

function result = MMmm(tasa_llegadas, tiempo_servicio, servidores, min_eventos)

  %% 'Constantes' utilizadas
  SALIDA  = 1;
  LLEGADA = 0;

  %% Variables de la emulación
  num_salidas           = 0;      % Número de salidas procesadas
  tiempo_emulado        = 0.0;    % Tiempo de emulación. Inicialmente a cero
                                  % se actualiza con cada evento
  ultimo_evento         = 0.0;    % Instante del último evento procesado
  en_servicio           = 0;      % Número de usuarios siendo servidos
  siguiente_llegada     = exprnd(1/tasa_llegadas);
                                  % Programamos la primera llegada
  siguiente_salida      = Inf;    % Como no hay usuarios, no puede haber salidas
  siguientes_salidas(1:servidores) = Inf;
                                  % Todos los servidores están inicialmente libres.
                                  % Un servidor está ocupado cuando el valor del
                                  % array correspondiente al servidor no es Inf.

  %% Estadísticas de la emulación
  ac_Tc                 = 0.0;    % Acumulado de tráfico cursado
  ac_Tp                 = 0.0;    % Acumulado de tráfico perdido
  ac_t                  = 0.0;    % Acumulado de tiempo de permanencia
  ac_n                  = 0.0;    % Acumulado de usuarios en el sistema
  ac_pn(1:servidores+1) = 0.0;    % Acumulado de probabilidades de estado
                                  %    (de 0 a servidores)

  %% Establecemos el final del bucle tras el número de eventos indicado
  %% en el momento en que el sistema quede vacío.
  while (num_salidas < min_eventos || en_servicio > 0)
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Actualizamos el tiempo actual y comprobamos el tipo de evento.
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [siguiente_salida, indice] = min(siguientes_salidas);
    if (siguiente_llegada < siguiente_salida)
      evento = LLEGADA;
      tiempo_emulado = siguiente_llegada;
    else
      evento = SALIDA;
      tiempo_emulado = siguiente_salida;
      %% Sólo contamos los eventos de salida.
      num_salidas ++;
    end
    %% Calculamos el tiempo transcurrido desde el último evento
    intervalo = tiempo_emulado - ultimo_evento;

    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % A cada nuevo evento, actualizamos las diferentes estadísticas
    % desde el evento anterior
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Trafico cursado
    ac_Tc += en_servicio * intervalo;
    %% Tiempo de permanencia en el sistema
    ac_t += en_servicio * intervalo;
    %% Usuarios en el sistema
    ac_n += en_servicio * intervalo;
    %% Tiempo de permanencia en el estado correspondiente
    ac_pn(en_servicio + 1) += intervalo;

    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Procesamos el evento correspondiente:
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    if (evento == LLEGADA)
      %% Se ha producido una nueva llegada
      %% Obtenemos el tiempo de servicio de la nueva llegada
      t_servicio = exprnd(tiempo_servicio);
      if (en_servicio < servidores)
        %% Hay servidores libres
        en_servicio ++;
        %% Buscamos un servidor libre
        servidor_libre = buscaLibre(siguientes_salidas);
        %% Programamos el siguiente instante de salida
        siguientes_salidas(servidor_libre) = tiempo_emulado + t_servicio;
      else
        %% Se pierde la llegada: acumulamos el tráfico perdido
        ac_Tp += t_servicio;
      end
      %% Programamos la siguiente llegada
      t_llegada = exprnd(1/tasa_llegadas);
      siguiente_llegada = tiempo_emulado + t_llegada;
    else
      %% Se ha producido una salida
      siguientes_salidas(indice) = Inf;
      %% Quitamos a un usuario del servidor
      en_servicio --;
    end
    %% Almacenamos el instante del evento para poder calcular el tiempo al
    %% siguiente evento
    ultimo_evento = tiempo_emulado;
  end

  %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Obtenemos las estadísticas
  % Los tiempos se promedian por el número de usuarios
  % Los usuarios por el tiempo emulado
  %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  Tc = ac_Tc / tiempo_emulado;
  Tp = ac_Tp / tiempo_emulado;
  t  = ac_t / num_salidas;
  n  = ac_n / tiempo_emulado;
  pn = ac_pn / tiempo_emulado;
  result = [Tc, Tp, t, n, pn];
end

%% Función que busca un servidor libre (tiempo de salida igual a Inf)
%% Parámetros:
%%     salidas:      array con los tiempos de salida de cada servidor
%% Devuelve: el índice del primer elemenento con tiempo de salida Inf
function indice = buscaLibre(salidas)
  indice = find(salidas==Inf, 1);
end
