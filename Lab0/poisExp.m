%Daniel Conde Ortiz

function poisExp(tasa,intervalo,tramos)
media=1/tasa;
muestras=exprnd(media,1,tramos*intervalo*tasa);

figure(1)
hist(muestras)
title('Histograma de la distribución exponencial')
t=[1:0.1:5*ceil(media)];

figure(2)
plot(t,exppdf(t,media))
title('FDP de la distribución exponencial')

cuenta=0;
poisson=[];
for i=1:length(muestras)
    cuenta=cuenta+muestras(i);
    if cuenta>=intervalo
        cuenta=cuenta-muestras(i);
        poisson=[poisson,cuenta];
        cuenta=muestras(i);
    end
end
compPoiss(poisson)

end