#!/usr/bin/env python3.8

import rospy
from sensor_msgs.msg import LaserScan
import math
import csv

class LidarSaver:
    def __init__(self):
        # Inicializar el nodo (rospy lo hace en main, pero aquí lo dejamos por claridad)
        # El nombre del nodo debe coincidir con el usado en rospy.init_node()
        self.node_name = "lidar_saver_node"
        
        # Suscriptor al tópico /scan (tópico típico del laser en ROS1)
        self.subscriber = rospy.Subscriber('/scan', LaserScan, self.listener_callback)
        
        # Abrir archivo CSV para escritura
        self.csv_file = open('datos_lidar.csv', mode='w')
        self.writer = csv.writer(self.csv_file)
        self.writer.writerow(['X', 'Y', 'Distancia', 'Angulo'])
        
        # Registrar cierre del archivo al apagar el nodo
        rospy.on_shutdown(self.cerrar_archivo)
    
    def listener_callback(self, msg):
        # Iterar sobre cada medición del laser
        for i, distance in enumerate(msg.ranges):
            # Filtrar distancias válidas (dentro del rango definido en el mensaje)
            if msg.range_min < distance < msg.range_max:
                # Calcular ángulo del rayo i
                angle = msg.angle_min + (i * msg.angle_increment)
                
                # Convertir a coordenadas cartesianas
                x = distance * math.cos(angle)
                y = distance * math.sin(angle)
                
                # Guardar en el CSV
                self.writer.writerow([x, y, distance, angle])
        
        rospy.loginfo("Escaneo guardado en CSV")
    
    def cerrar_archivo(self):
        """Cierra el archivo CSV cuando se apaga el nodo."""
        if self.csv_file and not self.csv_file.closed:
            self.csv_file.close()
            rospy.loginfo("Archivo CSV cerrado correctamente")

def main():
    # Inicializar el nodo ROS1
    rospy.init_node('lidar_saver_node', anonymous=False)
    
    # Crear instancia de la clase
    saver = LidarSaver()
    
    # Mantener el nodo activo hasta que llegue Ctrl+C
    rospy.spin()

if __name__ == '__main__':
    main()
