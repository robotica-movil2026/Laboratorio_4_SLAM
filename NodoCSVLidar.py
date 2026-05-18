import rclpy
from rclpy.node import Node
from sensor_msgs.msg import LaserScan
import math
import csv

class LidarSaver(Node):
    def __init__(self):
        super().__init__('lidar_saver_node')
        self.subscription = self.create_subscription(
            LaserScan,
            '/scan',
            self.listener_callback,
            10)
        
        # Abrimos el archivo para escribir
        self.csv_file = open('datos_lidar.csv', mode='w')
        self.writer = csv.writer(self.csv_file)
        self.writer.writerow(['X', 'Y', 'Distancia', 'Angulo'])

    def listener_callback(self, msg):
        for i, distance in enumerate(msg.ranges):
            # Filtrar distancias infinitas o fuera de rango
            if msg.range_min < distance < msg.range_max:
                # Calcular el ángulo del rayo i
                angle = msg.angle_min + (i * msg.angle_increment)
                
                # Conversión a Cartesianas
                x = distance * math.cos(angle)
                y = distance * math.sin(angle)
                
                # Guardar en el CSV
                self.writer.writerow([x, y, distance, angle])
        
        self.get_logger().info('Escaneo guardado en CSV')

    def __del__(self):
        self.csv_file.close()

def main(args=None):
    rclpy.init(args=args)
    nodo = LidarSaver()
    try:
        rclpy.spin(nodo)
    except KeyboardInterrupt:
        pass
    nodo.destroy_node()
    rclpy.shutdown()