% Función que emula el comportamiento de un sistema M/M/m
%
% Parámetros:
%     tasa_llegadas:      valor medio de la tasa de llegadas según Poisson
%     tiempo_servicio:    valor medio del tiempo de servicio según exponencial
%     servidores:         número de servidores del sistema M/M/m
%     min_salidas:        número mínimo de salidas de la simulación
%
% Devuelve: un array con los siguientes elementos:
%     tasa de llegadas observada
%     tiempo de servicio medido
%     tráfico cursado durante la emulación
%     tráfico demorado durante la emulación
%     tiempo medio de permanencia en el sistema
%     número medio de usuarios en el sistema
%     tiempo medio de espera en cola
%     número medio de usuarios en cola
%     probabilidades de estado de cada uno de los posibles estados.
%          El array va de 1 a ult_estado+1, indicando las probabilidades
%          de los estados 0 a ult_estado, agrupando en este último
%          todos los estados siguientes hasta el infinito.
%

% Debe situar en el código los siguientes bloques:
%    - Inicialización de los acumuladores necesarios para obtener los
%      siguientes valores medios:
%        * tasa de llegadas
%        * tiempo de servicio
%        * tráfico cursado
%        * tráfico demorado
%        * tiempo de permanencia
%        * usuarios en el sistema
%        * tiempo de espera en cola
%        * usuarios en cola
%        * probabilidades de estado
%    - Actualización de los acumuladores anteriores
%    - En cada evento, procesar llegadas, salidas y ocupaciones de servidor
%    - Obtener los valores medios a partir de los acumulados




function result = MMm(tasa_llegadas,tiempo_servicio,servidores,min_salidas)

  %% 'Constantes' utilizadas
  SALIDA   = 1;
  LLEGADA  = 0;
  MUL_COLA = 2;

  %% Inicialización de las variables de la emulación
  ult_estado            = MUL_COLA * servidores;
                                  % Último estado para el que contabilizamos 
                                  %    su probabilidad. Los estados sucesivos
                                  %    se acumulan todos juntos en éste.
  tiempo_simulado       = 0.0;    % Tiempo de emulación. Inicialmente a cero
                                  % se actualiza con cada evento
  ultimo_evento         = 0.0;    % Instante del último evento procesado
  usuarios_en_servicio  = 0;      % Número de usuarios siendo servidos
  usuarios_en_cola      = 0;      % Número de usuarios en cola
  siguientes_salidas(1:servidores) = Inf;
                                  % Todos los servidores están inicialmente libres.
                                  % Un servidor está ocupado cuando el valor del
                                  % array correspondiente al servidor no es Inf.
  siguiente_llegada     = exprnd(1 / tasa_llegadas);
                                  % Programamos la primera llegada
  num_salidas           = 0;      % Número de salidas procesadas
  num_llegadas=0;
  u_sis_acum=0;
  u_cola_acum=0;

  %% %%%%% Inicializamos los acumuladores necesarios
  t_llegada_acum=0;
  t_servicio_acum=0;
  tc_sim=0;
  t_cola=0;
  t_sistema=0;
  prob_estados=zeros(1,ult_estado+1);
  %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %% Establecemos el final del bucle tras el número de eventos indicado
  %% en el momento en que el sistema quede vacío.
  while (num_salidas < min_salidas || usuarios_en_servicio >0)
    %% Seleccionamos el primer servidor en terminar y su instante de salida
    [siguiente_salida, indice] = min(siguientes_salidas);
    %% Comprobamos el tipo de evento y actualizamos el tiempo actual.
    if (siguiente_llegada < siguiente_salida)
      evento = LLEGADA;
      tiempo_simulado = siguiente_llegada;
      num_llegadas=num_llegadas+1;
    else
      evento = SALIDA;
      tiempo_simulado = siguiente_salida;
      num_salidas=num_salidas+1;
    end
    %% Calculamos el tiempo transcurrido desde el último evento
    intervalo = tiempo_simulado - ultimo_evento;
    tc_sim=tc_sim+usuarios_en_servicio*intervalo;
    t_cola=t_cola+intervalo*usuarios_en_cola;
    %% El estado del sistema está limitado a ult_estado
    %% Se utiliza para calcular las probabilidades de estado
    numOrden = 1 + min(usuarios_en_cola + usuarios_en_servicio, ult_estado);

    %% %%%%% Actualizamos los acumuladores
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %% %%%%% Procesamos el evento correspondiente:
    if (evento == LLEGADA)
        usuarios_en_cola=usuarios_en_cola+1;
        t_llegada = exprnd(1 / tasa_llegadas);
      siguiente_llegada = tiempo_simulado + t_llegada;
        t_llegada_acum=t_llegada_acum+t_llegada;
    else %salida
        siguientes_salidas(indice) = Inf;
        usuarios_en_servicio = usuarios_en_servicio - 1;
    end
    
      if (usuarios_en_servicio < servidores && usuarios_en_cola>0)
        usuarios_en_servicio = usuarios_en_servicio + 1;
        usuarios_en_cola=usuarios_en_cola-1;
        t_servicio = exprnd(tiempo_servicio);
        t_servicio_acum=t_servicio_acum+t_servicio;
        siguientes_salidas(buscaLibre(siguientes_salidas)) = tiempo_simulado + t_servicio;
         end
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        u_sistema=usuarios_en_cola+usuarios_en_servicio;
       u_sis_acum=u_sis_acum+u_sistema;
       u_cola_acum=u_cola_acum+usuarios_en_cola;
       
       if(u_sistema<ult_estado)
           prob_estados(u_sistema+1)=prob_estados(u_sistema+1)+1;
       else
           prob_estados(end)=prob_estados(end)+1;
       end
    %% Almacenamos el instante del evento para poder calcular
    %% el tiempo al siguiente evento
    ultimo_evento = tiempo_simulado;
  end

  %% %%%%% Calculamos los valores medios
  %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %% %%%%% Rellenamos el array resultado
  %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  total=num_llegadas+num_salidas;
  t_sistema=t_cola+t_servicio_acum;
  result = [ num_salidas/t_llegada_acum; t_servicio_acum/num_salidas; tc_sim/tiempo_simulado;
              t_sistema/num_llegadas; u_sis_acum/total; t_cola/num_llegadas; u_cola_acum/total
              (prob_estados/total)'];
         
         disp('Tasa media de llegadas')
         disp(result(1))
         disp('Tiempo medio de servicio')
         disp(result(2))
         disp('Trafico medio cursado')
         disp(result(3))
         disp('Tiempo medio de permanencia en el sistema')
         disp(result(4))
         disp('Numero medio de usuarios en el sistema')
         disp(result(5))
         disp('Tiempo medio de permanencia en cola')
         disp(result(6))
         disp('Numero medio de usuarios en cola')
         disp(result(7))
         disp('Probabilidades de estado')
         disp(result(8:end))
end


%% Función que busca un servidor libre (tiempo de salida igual a Inf)
% Parámetros:
%     salidas:      array con los tiempos de salida de cada servidor
% Devuelve: el índice del primer elemenento con tiempo de salida Inf
function indice = buscaLibre(salidas)
    indice = find(salidas==Inf, 1);
end
