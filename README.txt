# Server Control Kit v2.0 (Linux)

## Descripción
El Server Control Kit es una herramienta todo-en-uno para administrar servidores Linux desde Windows. Permite control remoto de energía, diagnóstico de red, y configuración avanzada con una interfaz intuitiva de menú.

## Características principales
- 🚀 Control de energía (apagar, reiniciar, suspender, hibernar)
- 🌐 Diagnóstico de red (ping, test de velocidad, escaneo de puertos)
- 🔑 Configuración SSH sin contraseña
- ⚙️ Configuración sudo sin contraseña para comandos críticos
- 📊 Verificación de dependencias
- 📝 Sistema de logging integrado

## Requisitos previos
1. **Servidor Linux** accesible en la red
2. **Windows 10/11** con PowerShell 5.1+
3. **Acceso administrativo** al servidor
4. **Conexión de red** estable

## Instalación
1. Descargue el [zip con los archivos del proyecto]
2. Extraiga el contenido en una carpeta de su elección
3. Ejecute `ServerManager.bat` como administrador para evitar

## Configuración esencial (PASOS OBLIGATORIOS)

### 1. Instalar dependencias
```bash
Seleccione opción (0-15): 11
```
Esto instalará:
- wolcmd.exe (para Wake-on-LAN)
- plink.exe (cliente SSH avanzado)
- Verificará OpenSSH en Windows

### 2. Configurar SSH sin contraseña
```bash
Seleccione opción (0-15): 10
```
Esto:
1. Generará un par de claves SSH (si no existen)
2. Copiará la clave pública al servidor
3. Configurará los permisos adecuados

### 3. Configurar sudo sin contraseña
```bash
Seleccione opción (0-15): 15
```
Esto abrirá una ventana SSH donde:
1. Creará un archivo en `/etc/sudoers.d/`
2. Otorgará permisos sin contraseña para comandos específicos:
   - poweroff
   - reboot
   - suspend
   - hibernate

## Guía de uso

### Menú principal
```
============================================
       SERVER CONTROL KIT v2.0 [Linux]     
============================================

===== CONTROL DE ENERGIA =====
 1) [WoL] Encender servidor
 2) [OFF] Apagar servidor
 3) [RST] Reiniciar servidor
 4) [SUS] Suspender servidor
 5) [HIB] Hibernar servidor

===== DIAGNOSTICO DE RED =====
 6) [PING] Comprobar conectividad
 7) [SPEED] Test de velocidad (iperf3)
 8) [SCAN] Escanear puertos

===== CONFIGURACION =====
 9) [CFG] Editar configuracion
10) [SSH] Configurar SSH sin contrasena
11) [INST] Instalar requisitos
15) [SUDO] Configurar sudo sin contrasena

===== HERRAMIENTAS =====
12) [CHK] Verificar dependencias
13) [LOG] Ver logs de actividad
14) [HELP] Soporte tecnico
 0) [EXIT] Salir
============================================
```

### Funciones clave
| Opción | Comando | Función |
|--------|---------|---------|
| 1 | WoL | Enciende el servidor mediante Wake-on-LAN |
| 2 | OFF | Apaga el servidor de forma segura |
| 3 | RST | Reinicia el servidor |
| 4 | SUS | Suspende el servidor (modo bajo consumo) |
| 5 | HIB | Hiberna el servidor (estado de cero consumo) |
| 6 | PING | Verifica conectividad básica |
| 7 | SPEED | Mide velocidad de red con iperf3 |
| 8 | SCAN | Escanea puertos abiertos con nmap |
| 10 | SSH | Configura autenticación sin contraseña |
| 15 | SUDO | Configura sudo sin contraseña para comandos críticos |

## Personalización
Edite `config.ini` manualmente o mediante el menú (opción 9) para configurar:
- IP del servidor
- Dirección broadcast
- Máscara de red
- Dirección MAC
- Usuario SSH
- Puerto SSH

## Seguridad y responsabilidad
⚠️ **ADVERTENCIA IMPORTANTE** ⚠️

1. **Revise el código**: Antes de usar, examine los scripts para entender qué hacen
2. **Comandos privilegiados**: Las funciones de energía ejecutan comandos con `sudo`
3. **Acceso SSH**: La herramienta requiere acceso SSH con privilegios elevados
4. **Firewall**: Asegúrese de tener reglas de firewall adecuadas
5. **Usted es responsable**:
   - De la configuración de seguridad de su servidor
   - De las consecuencias del uso de esta herramienta
   - De mantener adecuadamente su infraestructura

## Limitaciones conocidas
1. Requiere configuración manual inicial de SSH y sudo
2. Wake-on-LAN necesita soporte en hardware y BIOS
3. iperf3 requiere instalación previa en el servidor
4. nmap debe instalarse en Windows para escaneo de puertos

## Soporte técnico
Utilice la opción 14 del menú para acceder a soluciones de problemas comunes:
- Problemas con Wake-on-LAN
- Errores de conexión SSH
- Fallos en iperf3
- Problemas con escaneo de puertos

## Registro de actividades
Todos los comandos ejecutados se registran en:
`logs\ServerManager_<fecha>.log`

---
**NOTA**: Este software se proporciona "TAL CUAL", sin garantías de ningún tipo. El usuario asume todo el riesgo asociado con su uso.