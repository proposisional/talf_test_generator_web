<h1>Generador de examenes tipo test para Teoría de Automatas y Lenguajes Formales</h1>

Aplicación web en Yii2 para generar y editar preguntas de la asignatura TALF, realizar y revisar exámenes tipo test con la dsitribución que le usuario o profesor quiere darle.

Las preguntas son generadas a través de scripts de Octave, el cual permite generación de lenguajes, gramáticas, autómatas, entre otros.

Tabla rápida de contenido
1. Características
2. Arquitectura
3. Requisitos
4. Instalación rápida (Windows + XAMPP)
5. Configuración
6. Migraciones
7. Instalación con Docker
8. Variables de entorno
9. Puesta en marcha

## 1. Características

- Generación de exámenes con selección equilibrada de preguntas por categoría
- Snapshot inmutable de las preguntas del examen (JSON)
- Historial de intentos y vista detallada de revisión (correctas en verde, errores en rojo)
- Autenticación básica de usuarios Yii2

## 2. Arquitectura

- Framework: Yii2
- Base de datos: MySQL
- Frontend: Bootstrap 5, JavaScript nativo, MathJax
- Persistencia: campos JSON para snapshot de preguntas y respuestas

## 3. Requisitos

- PHP 7.4 o superior
- MySQL 5.7+ o MariaDB equivalente
- Octave instalado y accesible en PATH si se usarán scripts
- Navegador moderno con soporte ES6

## 4. Instalación rápida (Windows + XAMPP)

1. Clonar el repositorio dentro de `c:\xampp\htdocs`
2. Abrir PowerShell y ejecutar `composer install`
3. Crear base de datos vacía (por ejemplo `app_db`)
4. Copiar/ajustar `config/db.php` con credenciales locales
5. Ejecutar migraciones
6. Iniciar Apache y MySQL desde XAMPP
7. Acceder a `http://localhost/yii/web/`

## 5. Configuración

Archivo principal de conexión: `config/db.php`
Parámetros adicionales: `config/params.php`
Constantes y rutas específicas (incluyendo Octave): `config/constants.php`
Asegurar clave de validación de cookies en `config/web.php` (campo `cookieValidationKey`)
Activado parser JSON en `request` para peticiones `application/json`

## 6. Migraciones

Ejecutar en la raíz del proyecto:

```
php yii migrate/up
```

En Windows también se puede usar:

```
yii.bat migrate/up
```

Migraciones incluidas: creación de tablas `user`, `test`, `answer`, campo `score` en `answer`, nulabilidad de `user_id` en `answer`.

## 7. Instalación con Docker

1. Instalar Docker Desktop
2. Copiar `.env.example` a `.env` y ajustar puertos y credenciales si se desea
3. Ejecutar:

```
docker compose build
docker compose up -d
```

4. Entrar al contenedor y confirmar instalación (solo primera vez si no se ejecutó entrypoint correctamente):

```
docker compose exec app composer install
docker compose exec app php yii migrate/up --interactive=0
```

Si el entrypoint funcionó ya estarán instaladas las dependencias y migraciones.

Acceso a la aplicación: `http://localhost:8080/`
Acceso PhpMyAdmin: `http://localhost:8081/`

Octave está disponible dentro del contenedor en `/usr/bin/octave`.

## 8. Variables de entorno

Archivo `.env`:

- `APP_PORT` puerto HTTP del contenedor app
- `DB_EXPOSE_PORT` puerto expuesto de MariaDB
- `DB_ROOT_PASS` contraseña root
- `DB_NAME` nombre base de datos aplicación
- `DB_USER` usuario aplicación
- `DB_PASS` contraseña usuario aplicación
- `PMA_PORT` puerto PhpMyAdmin
- `OCTAVE_BIN` ruta ejecutable Octave en contenedor

## 9. Puesta en marcha

Recrear entorno desde cero:

```
docker compose down -v
docker compose build --no-cache
docker compose up -d
```

Ver logs aplicación:

```
docker compose logs -f app
```

Ejecutar migraciones manualmente:

```
docker compose exec app php yii migrate/up --interactive=0
```

Crear usuario inicial (si no existe): usar interfaz de registro o comando personalizado futuro.

