% 1. Leer el archivo CSV
% readtable detecta automáticamente los encabezados (X, Y, Rango, Angulo)
tablaDatos = readtable('datos_lidar.csv');

% 2. Extraer las columnas X e Y
x = tablaDatos.X;
y = tablaDatos.Y;

% 3. Crear la figura
figure('Name', 'Visualización de LIDAR 2D');
hold on;

% Graficar usando scatter (nube de puntos)
% El punto '.' lo hace ver más limpio si son muchos datos
scatter(x, y, 5, 'filled', 'MarkerEdgeColor', [0 0.5 0.8]);

% 4. Ajustes visuales CRUCIALES
grid on;            % Mostrar rejilla
axis equal;         % Mantiene la proporción (evita que el mapa se vea estirado)
xlabel('Eje X (metros)');
ylabel('Eje Y (metros)');
title('Escaneo de LIDAR (Coordenadas Cartesianas)');

% Opcional: Dibujar el robot en el origen (0,0)
plot(0, 0, 'ro', 'MarkerSize', 10, 'LineWidth', 2);
legend('Puntos detectados', 'Posición del Robot');

hold off;