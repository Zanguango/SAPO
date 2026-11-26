# Entorno de desarrollo — S.A.P.O.

## 1. Estado conocido del entorno

| Componente | Tecnología / referencia | Estado |
|---|---|---|
| Sistema de trabajo | Windows | Entorno local del desarrollo. |
| Base de datos | PostgreSQL 18.7 | Instalado; versión comunicada durante la preparación del proyecto. Conviene confirmarla con `SELECT version();`. |
| Administración de BD | pgAdmin | Utilizado para administrar la base local. La versión exacta está pendiente de inventario. |
| Base local | `sapo_db` | Creada y con el script SQL ejecutado previamente, según el estado de trabajo informado. |
| Backend | JavaScript, Node.js y Express | Stack elegido; API todavía no implementada en este repositorio. Versión local de Node/npm pendiente de confirmación. |
| Frontend | HTML, CSS y JavaScript | Tecnología prevista; interfaz aún no implementada. |
| Control de versiones | Git y GitHub | Repositorio público `Zanguango/SAPO`, rama principal `main`. |
| Seguimiento | GitHub Projects | Tablero de S.A.P.O. con Sprint 1 definido. |

Este inventario distingue lo que ya está instalado o creado de los componentes que solo están previstos. No se afirma que la aplicación Node.js/Express esté instalada o funcionando.

## 2. Requisitos previos previstos

Para desarrollar y ejecutar el prototipo se necesitará:
- PostgreSQL con la base `sapo_db` preparada.
- pgAdmin o cliente PostgreSQL equivalente para inspeccionar y administrar la base.
- Node.js y npm para instalar dependencias y ejecutar la futura API.
- Git para descargar, versionar y actualizar el proyecto.
- Navegador web moderno para probar la interfaz.

Antes de comenzar el backend se registrarán las versiones exactas con estos comandos en PowerShell:

```powershell
node --version
npm --version
git --version
psql --version
```

Para verificar la versión desde la base de datos:

```sql
SELECT version();
SELECT current_database(), current_schema();
```

## 3. Base de datos existente

La base PostgreSQL `sapo_db` ya está creada y se ha ejecutado previamente un script SQL del esquema. En el Sprint 1 se revisa el modelo requerido por el circuito práctico y se contrasta el esquema instalado con el fichero SQL de referencia.

El fichero de referencia analizado declara 24 tablas y 31 claves foráneas. La coincidencia de estos recuentos en la instancia local es una comprobación inicial; no sustituye la revisión de columnas, índices, restricciones y triggers. Véase [modelo de datos](DATA_MODEL_SPRINT1.md).

## 4. Variables de entorno del futuro backend

Se ha preparado `backend/.env.example` como plantilla de nombres de configuración. Cuando se implemente la API:
1. Copiar el ejemplo a un archivo local `.env`.
2. Completar los valores únicamente en el archivo local.
3. No subir `.env`, contraseñas, tokens ni secretos a GitHub.

Variables previstas:
- `PORT`: puerto HTTP de la API.
- `DB_HOST`: servidor PostgreSQL.
- `DB_PORT`: puerto de PostgreSQL.
- `DB_NAME`: nombre de base de datos; inicialmente `sapo_db`.
- `DB_USER`: usuario de conexión.
- `DB_PASSWORD`: contraseña local, que nunca debe versionarse.

El archivo de ejemplo contiene valores de muestra no utilizables como credenciales. No existe todavía un backend que consuma esta configuración.

## 5. Datos iniciales ficticios

Los scripts de datos iniciales se mantendrán separados del esquema. La carga respetará las dependencias entre entidades y utilizará exclusivamente datos ficticios. La secuencia prevista se documenta en [database/seeds/README.md](../database/seeds/README.md).

## 6. Arranque de la aplicación

Todavía no se pueden proporcionar comandos de ejecución del producto: el backend y el frontend no están implementados. Cuando se cree el proyecto Node.js/Express y la interfaz, este apartado se completará con instalación de dependencias, configuración local y comandos de arranque verificados.
