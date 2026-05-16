# Laboratorio 4 Sensores y SLAM:

## Parte 1: Manejo de Sensores y microcontroladores

 En la carpeta [Microcontrolador](Microcontrolador/) podemos encontrar el codigo en arduino para el uso de una imu **MPU6050** mediante ROS y comunicacion serial, este codigo se encarga de tomar las lecturas del sensor y enviarlas a un topico de ROS llamado **IMU_ROS**. Para ejecutarlo es necesario tener instalado el paquete **rosserial_arduino** en la carpeta del **lib** del workspace. Ademas de configurar el puerto com de la placa y cargar el codigo en el microcontrolador.

```bash
rosrun rosserial_arduino serial_node.py  _port:="/dev/ttyUSB0" _baud:="115200"
```
En otra terminal podemos ver las lecturas del sensor con:

```bash
rostopic echo /IMU_ROS
```

## Parte 2: Camara
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

## Parte 3: SLAM


PATACON DE PRUEBA
