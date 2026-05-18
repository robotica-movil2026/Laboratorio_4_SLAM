clc; clear; close all;

%% =========================
% 1. DATOS MANUALES
%% =========================

% Distancias centro LIDAR -> esquina (cm)
r_cm = [24 26 20 25.5 34.3 35.2 45.5 47.5 41 29 22 25 27];

% Largo de cada pared (cm)
L_cm = [16 13 15 16.5 16 16 16 14 17 15 16 14.5 16];

% Pasar a metros
r = r_cm / 100;
L = L_cm / 100;

N = length(r);

%% =========================
% 2. RECONSTRUIR ESQUINAS
%% =========================

theta = zeros(N,1);

for i = 1:N

    j = mod(i,N) + 1;

    % Ley de cosenos
    c = (r(i)^2 + r(j)^2 - L(i)^2) ...
        / (2*r(i)*r(j));

    % Seguridad numérica
    c = max(min(c,1),-1);

    dtheta = acos(c);

    theta(j) = theta(i) + dtheta;
end

%% =========================
% 3. CONVERTIR A CARTESIANAS
%% =========================

x_manual = r(:).*cos(theta);
y_manual = r(:).*sin(theta);

% cerrar polígono
x_manual(end+1) = x_manual(1);
y_manual(end+1) = y_manual(1);

%% =========================
% 4. ORIENTACIÓN (ROTACIÓN)
%% =========================

angulo_deg = 24;%25; % AJUSTAR A MANO
ang = deg2rad(angulo_deg);

R = [cos(ang) -sin(ang);
     sin(ang)  cos(ang)];

coords = R * [x_manual'; y_manual'];

x_manual_rot = coords(1,:);
y_manual_rot = coords(2,:);

%% =========================
% 5. CARGAR LIDAR
%% =========================

tablaDatos = readtable('datos_lidar.csv');

x_lidar = tablaDatos.X;
y_lidar = tablaDatos.Y;

%% =========================
% 6. GRAFICAR COMPARACIÓN
%% =========================

figure;
hold on;
grid on;
axis equal;

% nube LIDAR
scatter(x_lidar, y_lidar, 5, ...
    'filled', ...
    'MarkerFaceColor',[0 0.45 0.75]);

% trayectoria manual
plot(x_manual_rot, y_manual_rot, ...
    '-or', ...
    'LineWidth',2, ...
    'MarkerSize',6);

% robot
plot(0,0,'ko','LineWidth',2,...
    'MarkerSize',10);

xlabel('X (m)');
ylabel('Y (m)');
title('Comparación LIDAR vs trayectoria manual');

legend('LIDAR', ...
       'Trayectoria manual', ...
       'Centro LIDAR');

hold off;






%% =========================================
% 7. CÁLCULO DE ERROR
%% =========================================

% Puntos del polígono manual
polyX = x_manual_rot(:);
polyY = y_manual_rot(:);

numLidar = length(x_lidar);

errores = zeros(numLidar,1);

% recorrer cada punto LIDAR
for i = 1:numLidar

    px = x_lidar(i);
    py = y_lidar(i);

    dist_min = inf;

    % recorrer cada segmento del polígono
    for k = 1:length(polyX)-1

        x1 = polyX(k);
        y1 = polyY(k);

        x2 = polyX(k+1);
        y2 = polyY(k+1);

        % vector segmento
        vx = x2 - x1;
        vy = y2 - y1;

        % vector punto
        wx = px - x1;
        wy = py - y1;

        % proyección
        c1 = vx*wx + vy*wy;
        c2 = vx^2 + vy^2;

        t = c1 / c2;

        % limitar al segmento
        t = max(0,min(1,t));

        % punto proyectado
        projx = x1 + t*vx;
        projy = y1 + t*vy;

        % distancia
        dist = sqrt((px-projx)^2 + (py-projy)^2);

        if dist < dist_min
            dist_min = dist;
        end
    end

    errores(i) = dist_min;
end

%% =========================================
% 8. MÉTRICAS
%% =========================================

error_medio = mean(errores);

rmse = sqrt(mean(errores.^2));

error_max = max(errores);

fprintf('\n===== RESULTADOS =====\n');

fprintf('Error medio: %.4f m\n', error_medio);

fprintf('RMSE: %.4f m\n', rmse);

fprintf('Error máximo: %.4f m\n', error_max);

fprintf('======================\n');