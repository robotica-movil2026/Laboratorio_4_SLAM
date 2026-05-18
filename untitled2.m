clc; clear; close all;

%% DATOS MANUALES

distancias = [24 26 20 25.5 34 35.2 45.5 47.5 41 29 22 25 27]/100;

paredes = [16 13 15 16.5 16 16 16 14 17 15 16 14.5 16]/100;

N = length(distancias);

%% PARAMETROS DE ORIENTACION

theta0 = deg2rad(20);     % ajustar luego
offset = [0 0];

%% RECONSTRUCCION

esquinas = zeros(N,2);

% primera esquina
esquinas(1,:) = distancias(1)*[cos(theta0) sin(theta0)];

angulo = theta0;

for i=2:N

    L = paredes(i-1);

    dx = L*cos(angulo);
    dy = L*sin(angulo);

    candidato = esquinas(i-1,:) + [dx dy];

    r = norm(candidato);

    error_radio = distancias(i)-r;

    direccion = candidato/norm(candidato);

    candidato = candidato + error_radio*direccion;

    esquinas(i,:) = candidato;

    angulo = atan2( ...
        esquinas(i,2)-esquinas(i-1,2), ...
        esquinas(i,1)-esquinas(i-1,1));
end

%% cerrar poligono
esquinas = [esquinas; esquinas(1,:)];

%% GRAFICAR MODELO MANUAL

figure;
hold on
grid on
axis equal

plot(esquinas(:,1),esquinas(:,2),'r-o','LineWidth',2)

plot(0,0,'ko','MarkerSize',12)

xlabel('X')
ylabel('Y')

title('Trayectoria reconstruida')

tablaDatos = readtable('datos_lidar.csv');

x = tablaDatos.X;
y = tablaDatos.Y;

figure
hold on
axis equal
grid on

scatter(x,y,5,'b','filled')

plot(esquinas(:,1),esquinas(:,2), ...
    'r-o','LineWidth',2)

plot(0,0,'ko','LineWidth',2)

legend('LIDAR','Modelo Manual')



theta = 0:0.5:360;

mejorError = inf;

for k=1:length(theta)

    theta0 = deg2rad(theta(k));

    % reconstruir

    ...

    % distancia promedio a nube lidar
    err = pdist2(esquinas,[x y]);

    score = mean(min(err,[],2));

    if score<mejorError

        mejorError = score;
        mejorTheta = theta0;

    end
end



D = pdist2(esquinas,[x y]);

error_min = min(D,[],2);

RMSE = sqrt(mean(error_min.^2))