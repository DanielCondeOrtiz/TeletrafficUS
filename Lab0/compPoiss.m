%Daniel Conde Ortiz

function compPoiss (muestras)

media=mean(muestras)
varianza=var(muestras)

rango=[1:1:3*media]; 
 
frecuencias(1, length(rango)) = 0;

for i = 1:length(muestras)
  if muestras(i) <= length(frecuencias) && muestras(i) != 0
         frecuencias(ceil(muestras(i)))++;
  end
end
     
figure(3)
hist(muestras, length(rango));
title("Histograma de las muestras");
hold on;
plot(rango, frecuencias, "r");
title('Muestras obtenidas de la Exp');
hold off;

figure(4);
plot(rango,poisspdf(rango,media), 'linewidth', 2, 'color', 'red');
title("Función densidad de probabilidad de una exponencial");
hold on;
plot(rango, frecuencias/length(muestras), 'linewidth', 2);
title('Muestras obtenidas de la Exp')
hist(muestras, length(rango), 1);
hold off;  
end