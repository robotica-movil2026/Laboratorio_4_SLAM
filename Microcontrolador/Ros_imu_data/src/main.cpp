#include "I2Cdev.h"
#include "MPU6050.h"
#include "Wire.h"
#include <Arduino.h>
#include <ros.h>
#include <sensor_msgs/Imu.h>

// Optimización de Memoria: Definimos un NodeHandle a medida.
// Reducimos el número de publicadores/suscriptores para ahorrar RAM (Uno tiene
// solo 2KB). Aumentamos el búfer de salida (OUT) a 450 bytes porque
// sensor_msgs/Imu es grande (~320 bytes serializado).
typedef ros::NodeHandle_<ArduinoHardware, 5, 1, 64, 450> CustomNodeHandle;

MPU6050 sensor;
CustomNodeHandle nh;

sensor_msgs::Imu imu_msg;
ros::Publisher imu_pub("IMU_ROS", &imu_msg);

// Variables para datos del sensor (int16_t es suficiente para los registros del
// MPU6050)
int16_t ax, ay, az;
int16_t gx, gy, gz;

// Control de tiempo para publicación (10Hz = 100ms)
unsigned long last_publish = 0;
const unsigned long publish_period = 100;

void setup() {
  Wire.begin();
  Wire.setClock(400000); // I2C a 400kHz para mayor velocidad

  nh.initNode();
  nh.advertise(imu_pub);

  sensor.initialize();

  // Llenar covariancias con 0 (ya se inicializan en 0, pero es por claridad)
  for (int i = 0; i < 9; i++) {
    imu_msg.orientation_covariance[i] = 0;
    imu_msg.angular_velocity_covariance[i] = 0;
    imu_msg.linear_acceleration_covariance[i] = 0;
  }
  // Orientación desconocida (estándar ROS: covariance[0] = -1 si no hay
  // orientación)
  imu_msg.orientation_covariance[0] = -1;
}

void loop() {
  // Publicar a una frecuencia fija sin bloquear el procesador
  if (millis() - last_publish >= publish_period) {
    last_publish = millis();

    // Obtener lecturas RAW
    sensor.getAcceleration(&ax, &ay, &az);
    sensor.getRotation(&gx, &gy, &gz);

    // Conversión a unidades SI (m/s^2 y rad/s)
    // Sensibilidad Acelerómetro (±2g): 16384 LSB/g. 1g = 9.80665 m/s^2
    imu_msg.linear_acceleration.x = (float)ax / 16384.0 * 9.80665;
    imu_msg.linear_acceleration.y = (float)ay / 16384.0 * 9.80665;
    imu_msg.linear_acceleration.z = (float)az / 16384.0 * 9.80665;

    // Sensibilidad Giroscopio (±250°/s): 131 LSB/(°/s). Conversión a radianes.
    imu_msg.angular_velocity.x = (float)gx / 131.0 * (PI / 180.0);
    imu_msg.angular_velocity.y = (float)gy / 131.0 * (PI / 180.0);
    imu_msg.angular_velocity.z = (float)gz / 131.0 * (PI / 180.0);

    // Sincronizar timestamp con ROS
    imu_msg.header.stamp = nh.now();
    imu_msg.header.frame_id = "imu_link";

    imu_pub.publish(&imu_msg);
  }
  // Mantener la comunicación activa
  nh.spinOnce();
}