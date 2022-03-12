% Función que emula el comportamiento de un sistema M/M/m
%
% Parámetros:
%     tasa_llegadas:      valor medio de la tasa de llegadas según Poisson
%     tiempo_servicio:    valor medio del tiempo de servicio según exponencial
%     servidores:         número de servidores del sistema M/M/m
%     min_llegadas:       número mínimo de llegadas de la emulación
%
% Devuelve: un array con los siguientes elementos:
%     tráfico cursado durante la emulación
%     tiempo medio de permanencia en el sistema
%     número medio de usuarios en el sistema
%     tiempo medio de espera en cola
%     número medio de usuarios en cola
%     probabilidades de estado de cada uno de los posibles estados.
%          El array va de 1 a ult_estado+1, indicando las probabilidades
%          de los estados 0 a ult_estado, agrupando en este último
%          todos los estados siguientes hasta el infinito.
%

function result = MMm(tasa_llegadas, tiempo_servicio, servidores, min_llegadas)

  % 'Constantes' utilizadas
  SALIDA   = 1;
  LLEGADA  = 0;
  MUL_COLA = 2;

  % Variables de la emulación
  ult_estado            = MUL_COLA * servidores;
                                  % Último estado para el que contabilizamos 
                                  %    su probabilidad. Los estados sucesivos
                                  %    se acumulan todos juntos en éste.
  num_llegadas          = 0;      % Número de llegadas procesadas
  tiempo_emulado        = 0.0;    % Tiempo de emulación. Inicialmente a cero
                                  % se actualiza con cada evento
  ultimo_evento         = 0.0;    % Instante del último evento procesado
  en_servicio           = 0;      % Número de usuarios siendo servidos
  en_cola               = 0;      % Número de usuarios en cola
  siguiente_llegada  = exprnd(1/tasa_llegadas);
                                  % Programamos la primera llegada
  siguiente_salida      = Inf;    % Como no hay usuarios, no puede haber salidas
  siguientes_salidas(1:servidores) = Inf;
                                  % Todos los servidores están inicialmente libres.
                                  % Un servidor está ocupado cuando el valor del
                                  % array correspondiente al servidor no es Inf.

  % Estadísticas de la emulación
  ac_Tc                 = 0.0;    % Acumulado de tráfico cursado
  ac_t                  = 0.0;    % Acumulado de tiempo de permanencia
  ac_n                  = 0.0;    % Acumulado de usuarios en el sistema
  ac_w                  = 0.0;    % Acumulado de tiempo de espera en cola
  ac_q                  = 0.0;    % Acumulado de usuarios en cola
  ac_pn(1:ult_estado+1) = 0.0;    % Acumulado de probabilidades de estado
                                  %    (de 0 a ult_estado, incluyendo en el
                                  %     último hasta el infinito)

  % Establecemos el final del bucle tras el número de eventos indicado
  % en el momento en que el sistema quede vacío.
  while (sum(num_llegadas) < min_llegadas || en_servicio > 0)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Actualizamos el tiempo actual y comprobamos el tipo de evento %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [siguiente_salida, indice] = min(siguientes_salidas);
    if (siguiente_llegada < siguiente_salida)
      evento = LLEGADA;
      tiempo_emulado = siguiente_llegada;
      % Contamos los eventos de llegada.
      num_llegadas = num_llegadas + 1;
    else
      evento = SALIDA;
      tiempo_emulado = siguiente_salida;
    end
    % Calculamos el tiempo transcurrido desde el último evento
    intervalo = tiempo_emulado - ultimo_evento;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % A cada nuevo evento, actualizamos las diferentes estadísticas
    % desde el evento anterior
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Acumulado del trafico cursado
    ac_Tc += en_servicio * intervalo;
    % Acumulado del tiempo de permanencia
    ac_t += (en_cola + en_servicio) * intervalo;
    % Acumulado de usuarios en el sistema
    ac_n += (en_cola + en_servicio) * intervalo;
    % Acumulado de tiempo de espera en cola
    ac_w += en_cola * intervalo;
    % Acumulado de usuarios en cola
    ac_q += en_cola * intervalo;
    % Acumulado de probabilidades de estado
    %    Determinamos el índice de la matriz correspondiente
    %    al estado del sistema.
    numOrden = 1 + min(sum(en_cola) + sum(en_servicio), ult_estado);
    ac_pn(numOrden) += intervalo;
 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Procesamos el evento correspondiente:
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    if (evento == LLEGADA)
      %%% Se ha producido una nueva llegada
      % Encolamos el nuevo usario
      en_cola++;
      % Programamos la siguiente llegada
      t_llegada = exprnd(1/tasa_llegadas);
      siguiente_llegada = tiempo_emulado + t_llegada;
    else
      %%% Se ha producido una salida
      siguientes_salidas(indice) = Inf;
      % Quitamos a un usuario del servidor
      en_servicio--;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Antes de salir comprobamos si hay algún servidor libre
    %     y usuarios en cola
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if (en_servicio < servidores && en_cola > 0)
      % Hay usuarios esperando y hay servidores libres
      en_cola--;
      en_servicio++;
      % Obtenemos el tiempo de servicio de la nueva llegada
      t_servicio = exprnd(tiempo_servicio);
      % Buscamos un servidor libre
      servidor_libre = buscaLibre(siguientes_salidas);
      % Programamos el siguiente instante de salida
      siguientes_salidas(servidor_libre) = tiempo_emulado + t_servicio;
    end
    % Almacenamos el instante del evento para poder calcular el tiempo al
    % siguiente evento
    ultimo_evento = tiempo_emulado;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Obtenemos las estadísticas
    % Los tiempos se promedian por el tiempo simulado
    % Los usuarios por el número de llegadas (que es igual al de salidas)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Tc = ac_Tc / tiempo_emulado;
    t = ac_t / num_llegadas;
    n = ac_n / tiempo_emulado;
    w = ac_w / num_llegadas;
    q = ac_q / tiempo_emulado;
    pn = ac_pn / tiempo_emulado;

    result = [Tc, t, n, w, q, pn]
end

%
% Función que busca en el array salidas la primera posición con valor Inf
%
function indice = buscaLibre(salidas)
    indice = find(salidas==Inf, 1);
end
