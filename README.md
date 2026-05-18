# Laboratorio 4 Sensores y SLAM:

# Parte 1: Manejo de Sensores y microcontroladores

 En la carpeta [Microcontrolador](Microcontrolador/) podemos encontrar el codigo en arduino para el uso de una imu **MPU6050** mediante ROS y comunicacion serial, este codigo se encarga de tomar las lecturas del sensor y enviarlas a un topico de ROS llamado **IMU_ROS**. Para ejecutarlo es necesario tener instalado el paquete **rosserial_arduino** en la carpeta del **lib** del workspace. Ademas de configurar el puerto com de la placa y cargar el codigo en el microcontrolador.

```bash
rosrun rosserial_arduino serial_node.py  _port:="/dev/ttyUSB0" _baud:="115200"
```
En otra terminal podemos ver las lecturas del sensor con:

```bash
rostopic echo /IMU_ROS
```
[Video demostrativo IMU](./FotosLIDAR/imu.mkv)


[![IMU](https://img.youtube.com/vi/YRaFXCiuLRY/0.jpg)](https://www.youtube.com/watch?v=YRaFXCiuLRY)


# Parte 2: Camara
PAra el uso de la camara en ubuntu 20.04, se uso el script recomendado para hacer reconocimientos de movimiento y contorno, este se encuentra en la carpeta [Nodos](Nodos/) en el script **Image_detector.py**, y el modo de uso es el siguiente:

- Terminal 1:
```bash
catkin_make
source devel/setup.bash
roscore
```
- Terminal 2:
```bash
rosrun usb_cam usb_cam_node
```
- Terminal 3:
```bash
rosrun reconocimiento_cv image_detector.py
```

[Video demostrativo camara](./FotosLIDAR/camara.mp4)

[![IMU](https://img.youtube.com/vi/umPsq3o_AxQ/0.jpg)](https://www.youtube.com/watch?v=umPsq3o_AxQ)

# Parte 3: LIDAR

La tecnología LiDAR (Light Detection and Ranging) es un sistema de medición remota que utiliza pulsos de luz láser para calcular distancias y crear mapas tridimensionales muy precisos del entorno. Un sensor LiDAR emite miles o millones de pulsos láser por segundo hacia objetos y superficies. Luego mide el tiempo que tarda cada pulso en regresar después de reflejarse. Con millones de mediciones, el sistema construye una nube de puntos 3D extremadamente detallada.

Para visualizar el mapeo del lidar, clonamos el repo de las librerias en el workspace y lanzamos los siguientes comandos: 
```bash
catkin_make
source devel/setup.bash
roslaunch rplidar_ros rplidar_c1.launch
```
Para inicializar la referencia del lidar en el espacio y lanzar el visualizador aplicamos los siguientes comandos:
```bash
rosrun tf static_transform_publisher 0 0 0 0 0 0 baselink laser 100
rviz
```
[Lidar](./FotosLIDAR/3.jpeg)
[![LIDAR](https://img.youtube.com/vi/pYz689sKs1k/0.jpg)](https://www.youtube.com/watch?v=pYz689sKs1k)

Para capturar y graficar los datos del lidar se creó un script en python que los guarda en un .csv y los grafica con matplotlib. 

[Script de captura](./NodoCSVLidar.py)
[CSV de datos](./datos_lidar.csv)
## Comparación entre medición manual y escaneo LIDAR

Este proyecto compara una reconstrucción geométrica manual del entorno contra un escaneo 2D obtenido mediante un sensor LIDAR.

La reconstrucción manual se realizó utilizando:

- Distancia desde el centro del LIDAR hacia cada esquina.
- Longitud de cada pared.
- Reconstrucción polar-cartesiana mediante ley de cosenos.
- Ajuste angular manual para alinear ambas trayectorias.

El objetivo fue evaluar qué tan cercana es la geometría reconstruida respecto a la nube de puntos obtenida por el sensor.

### Reconstrucción geométrica de los datos del LIDAR

Los datos del sensor LIDAR fueron obtenidos desde el tópico `/scan` en ROS utilizando mensajes del tipo `LaserScan`. Cada medición contiene un conjunto de distancias radiales (`ranges`) asociadas a diferentes ángulos del escáner.

Para cada rayo detectado:

1. Se verifica que la distancia esté dentro del rango válido del sensor.
2. Se calcula el ángulo correspondiente al índice del rayo.
3. Se realiza la conversión de coordenadas polares a cartesianas.
4. Finalmente, los datos se almacenan en un archivo CSV para su posterior análisis en MATLAB.

La conversión utilizada fue:

$$
\theta = \theta_{inicial} + (i \cdot \Delta\theta)
$$

$$
x = r\cos(\theta)
$$

$$
y = r\sin(\theta)
$$

donde:

- $i$ corresponde al 'rayo' actual del LIDAR.
- $r$ corresponde a la distancia medida por el LIDAR.
- $\theta$ corresponde al ángulo del rayo láser.
- $\Delta\theta$ corresponde al cambio o incremento del ángulo.

### Reconstrucción geométrica del modelo manual

Para cada pared se calculó el ángulo entre esquinas consecutivas utilizando la ley de cosenos:

$$
L_i^2 = r_i^2 + r_{i+1}^2 - 2r_ir_{i+1}\cos(\Delta\theta_i)
$$

donde:

- $L_i$: longitud de la pared
- $r_i$: distancia desde el LIDAR a la esquina $i$
- $\Delta\theta_i$: diferencia angular entre esquinas consecutivas

Posteriormente, las coordenadas cartesianas se obtuvieron mediante:

$$
x_i = r_i\cos(\theta_i)
$$

$$
y_i = r_i\sin(\theta_i)
$$

Finalmente, se aplicó una rotación global para alinear el modelo manual con el escaneo LIDAR.



### Métricas de error

Para evaluar la similitud entre ambas trayectorias se calculó la distancia mínima entre cada punto del LIDAR y el polígono reconstruido manualmente.

### Error medio

Representa la distancia promedio entre la nube de puntos y el modelo geométrico.

$$
\bar e = \frac{1}{N}\sum_{i=1}^{N} e_i
$$

### RMSE (Root Mean Square Error)

Penaliza más fuertemente los errores grandes y es una métrica común en sistemas de mapeo y SLAM.

$$
RMSE = \sqrt{\frac{1}{N}\sum_{i=1}^{N} e_i^2}
$$

### Error máximo

Corresponde al peor caso detectado entre el escaneo y la reconstrucción manual.

$$
e_{max} = \max(e_i)
$$

### Error porcentual

El error porcentual se calculó para cada punto del escaneo LIDAR utilizando la relación entre el error geométrico obtenido y la distancia medida por el sensor:

$$
\text{Error porcentual}_i = \frac{e_i}{d_i}\times 100
$$

donde:

- $e_i$ corresponde a la distancia mínima entre el punto LIDAR y el Modelo Manual.
- $d_i$ corresponde a la distancia medida originalmente por el LIDAR.

Finalmente, se calculó el promedio de todos los errores porcentuales para obtener una métrica global de precisión del modelo reconstruido.

## Resultados

### Comparación entre trayectoria manual y LIDAR

![Comparación](FotosLIDAR/Trayectorias.png)


### Mapa de error

![Mapa de error](FotosLIDAR/Error.png)

### Resultados numéricos

- Error medio:  2.02 cm
- RMSE:         3.58 cm
- Error máximo: 21.38 cm
- Error porcentual medio: 9.17%
- Error porcentual maximo: 142.07%



# Parte 4 : SLAM

## ¿Cuál es la función principal del paquete `hector_slam` dentro del ecosistema ROS?

El paquete `hector_slam` es una implementación de SLAM (*Simultaneous Localization and Mapping*) para ROS cuya función principal es permitir que un robot construya un mapa 2D del entorno mientras estima simultáneamente su posición dentro de él utilizando información proveniente de un sensor LIDAR. `hector_slam` procesa los datos del escáner láser y realiza coincidencia entre escaneos consecutivos (*scan matching*) para estimar el movimiento del robot y actualizar el mapa del entorno.

Dentro del ecosistema ROS, `hector_slam` se encarga de:

- Recibir datos del sensor LIDAR.
- Estimar la pose del robot.
- Construir mapas 2D de ocupación.
- Publicar transformaciones (`tf`) entre sistemas de referencia.
- Integrarse con herramientas de visualización como RViz.

El paquete es especialmente útil con sensores láser y robots que no disponen de una odometría confiable.

## ¿Cómo gestiona el movimiento del robot? ¿Utiliza datos de odometría o se basa únicamente en el escaneo del LIDAR?

Una de las principales características de `hector_slam` es que puede funcionar sin utilizar datos de odometría. A diferencia de otros algoritmos SLAM que dependen fuertemente de encoders o sensores de movimiento, `hector_slam` se basa principalmente en los datos del sensor LIDAR.

El paquete utiliza una técnica denominada *scan matching*, en la cual compara escaneos consecutivos del entorno para estimar el desplazamiento y la rotación del robot. A partir de las diferencias observadas entre los escaneos láser, el algoritmo calcula la nueva pose del robot y actualiza el mapa generado.

El proceso general consiste en:

1. Obtener un escaneo láser del entorno.
2. Compararlo con el mapa previamente construido.
3. Estimar la transformación más probable entre escaneos.
4. Actualizar la posición estimada del robot.
5. Incorporar nueva información al mapa de ocupación.

Aunque `hector_slam` puede integrarse con odometría, su funcionamiento principal está diseñado para depender principalmente del LIDAR. Esto lo hace especialmente útil en robots donde la odometría es limitada, imprecisa o inexistente.

[Video demostrativo SLAM](./FotosLIDAR/hector_slam.mkv)

[![Hector_SLAM_1](https://img.youtube.com/vi/lu3zlm2ydQ8/0.jpg)](https://www.youtube.com/watch?v=lu3zlm2ydQ8)

[![Hector_SLAM_2](https://img.youtube.com/vi/6ktqQ2gvmaI/0.jpg)](https://www.youtube.com/watch?v=6ktqQ2gvmaI)

[![Hector_SLAM_3](https://img.youtube.com/vi/gr5vpYPt6pk/0.jpg)](https://www.youtube.com/watch?v=gr5vpYPt6pk)

[![Hector_SLAM_4](https://img.youtube.com/vi/EUCxyGSmOzc/0.jpg)](https://www.youtube.com/watch?v=EUCxyGSmOzc)


## Conclusiones

Los resultados muestran que la geometría detectada por el sensor LIDAR logra aproximarse correctamente a la reconstrucción manual. Las diferencias observadas se deben principalmente a:

- Ruido propio del sensor.
- Errores de medición manual.
- Reflexiones y dispersión del LIDAR.
- Pequeñas desviaciones angulares acumuladas.
